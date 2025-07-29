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

private let ESP_URL = "http://192.168.4.1"
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
        
        private lazy var session: Alamofire.Session = {
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 30
            configuration.requestCachePolicy = .reloadIgnoringCacheData
            return Alamofire.Session(configuration: configuration, delegate: Alamofire.Session.default.delegate)
        }()
        
        private var request: DataRequest? = nil
        
        func invoke(data: InputData) async -> Result {
            SALog.info("ESP Configuration started")
            let mainTask = Task {
                let result = await perform(data: data)
                try Task.checkCancellation()
                return result
            }
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: TIMEOUT_SECS * NSEC_PER_SEC)
                SALog.debug("Timeout reached - canceling task")
                mainTask.cancel()
            }
            
            do {
                let result = try await withTaskCancellationHandler {
                    try await mainTask.value
                } onCancel: {
                    SALog.debug("ESP Configuration task canceled")
                    mainTask.cancel()
                    timeoutTask.cancel()
                }
                timeoutTask.cancel()
                return result
            } catch {
                SALog.error("Configure ESP device end up with timeout")
                return .timeout
            }
        }
        
        func perform(data: InputData) async -> Result {
            guard let profile = try? await profileRepository.getActiveProfile().subscribeAwait() else {
                return .failed
            }
            guard let html = await repeatCalls(times: GET_REPEATS, action: { await get() }),
                  let document = try? SwiftSoup.parse(html)
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
            
            let postHtml = await repeatCalls(times: POST_REPEATS) { await post(espData.fieldMap) }
            guard let postHtml else {
                return .failed
            }
            
            if let postHtmlDocument = try? SwiftSoup.parse(postHtml),
               let resultMessage = try? postHtmlDocument.select(TAG_RESULT_MESSAGE).html(),
               resultMessage.lowercased().contains("data saved")
            {
                SALog.info("Data saved, trying to reboot")
                espData.reboot = true
                _ = await post(espData.fieldMap)
            }
            
            return .success(result: result)
        }
        
        private func get() async -> String? {
            await withTaskCancellationHandler {
                try? await withUnsafeThrowingContinuation { continuation in
                    request = session.request(ESP_URL)
                        .responseString { response in
                            switch response.result {
                            case .success(let value):
                                SALog.info("GET request finished with success")
                                continuation.resume(returning: value)
                            case .failure(let error):
                                SALog.error("GET request failed with error: \(error)")
                                continuation.resume(throwing: error)
                            }
                        }
                }
            } onCancel: {
                request?.cancel()
            }
        }
        
        private func post(_ data: [String: String]) async -> String? {
            await withTaskCancellationHandler {
                try? await withUnsafeThrowingContinuation { continuation in
                    session.request(ESP_URL, method: .post, parameters: data)
                        .responseString { response in
                            switch response.result {
                            case .success(let value):
                                SALog.info("POST request finished with success")
                                continuation.resume(returning: value)
                            case .failure(let error):
                                SALog.error("POST request failed with error: \(error)")
                                continuation.resume(throwing: error)
                            }
                        }
                }
            } onCancel: {
                request?.cancel()
            }
        }
        
        private func repeatCalls<T>(times: Int = 3, action: () async -> T?) async -> T? {
            for _ in 0 ..< times {
                if (!Task.isCancelled) {
                    if let result = await action() {
                        return result
                    } else {
                        try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    }
                }
            }
            return nil
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
    }
}
