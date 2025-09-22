/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
    
import Alamofire
import SwiftSoup

private let TAG_RESULT_MESSAGE = "#msg"
private let GET_REPEATS = 10
private let POST_REPEATS = 3
private let TIMEOUT_SECS: UInt64 = 60

enum ConfigureEsp {
    protocol UseCase {
        func invoke(data: InputData) async -> Result
    }
    
    class Implementation: UseCase {
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<EspRepository> private var espRepository
        
        private var request: DataRequest? = nil
        
        func invoke(data: InputData) async -> Result {
            SALog.info("ESP Configuration started")
            
            return await cancelableTaskWithTimeout(timeout: TIMEOUT_SECS) { [weak self] in
                await self?.perform(data: data) ?? .timeout
            } ?? .timeout
        }
        
        func perform(data: InputData) async -> Result {
            guard let profile = try? await profileRepository.getActiveProfile().subscribeAwait() else {
                return .failed
            }
            let getResult: Esp.RequestResult? = await repeated(GET_REPEATS) { await espRepository.get() }
            guard let html = getResult?.html else { return getResult?.result ?? .connectionError }
            guard let document = try? SwiftSoup.parse(html)
            else {
                SALog.warning("Could not connect to the ESP device")
                return .connectionError
            }
            
            let parser = EspHtmlParser()
            let espData = EspPostData(fieldMap: parser.findInputs(document: document))
            let result = parser.prepareResult(document: html, fieldMap: espData.fieldMap)
            
            if (!espData.isCompatible || !result.isCompatible) {
                SALog.warning("Got incompatible data")
                return .incompatible
            }
            
            espData.ssid = data.ssid
            espData.password = data.password
            espData.server = profile.server?.address
            espData.email = profile.email
            
            if (espData.softwareUpdate != nil) {
                SALog.info("Turning on software update")
                espData.softwareUpdate = true
            }
            if (espData.protocol != nil) {
                SALog.info("Setting supla protocol")
                espData.protocol = EspDeviceProtocol.supla
            }
            
            guard let postResult = await repeated(POST_REPEATS, { await espRepository.post(espData.fieldMap) })
            else { return .failed }
            if (!postResult.successful) {
                return .failed
            }
            
            guard let getResult = await repeated(POST_REPEATS, { await espRepository.get() }),
                  let postHtml = getResult.html
            else { return .failed }
            
            if let postHtmlDocument = try? SwiftSoup.parse(postHtml),
               let resultMessage = try? postHtmlDocument.select(TAG_RESULT_MESSAGE).html(),
               resultMessage.lowercased().contains("data saved")
            {
                SALog.info("Data saved, trying to reboot")
                espData.reboot = true
                _ = await espRepository.post(espData.fieldMap)
            }
            
            return .success(result: result)
        }
    }
    
    struct InputData {
        let ssid: String
        let password: String
    }
    
    enum Result {
        case success(result: EspConfigResult)
        case connectionError
        case incompatible
        case failed
        case timeout
        case setupNeeded
        case credentialsNeeded
        case temporarilyLocked
    }
}

private extension Esp.RequestResult {
    var successful: Bool {
        switch self {
        case .success: true
        default: false
        }
    }

    var html: String? {
        switch self {
        case .success(let html): html
        default: nil
        }
    }
    
    var result: ConfigureEsp.Result? {
        switch self {
        case .setupNeeded: .setupNeeded
        case .credentialsNeeded: .credentialsNeeded
        case .temporarilyLocked: .temporarilyLocked
        default: nil
        }
    }
}
