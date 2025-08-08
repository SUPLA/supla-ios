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

class EspClient {
    @Singleton<EspConfigurationSession> private var espConfigurationSession
    
    static var shared: EspClient = EspClient()
    
    var session: Session { secureSession ?? defaultSession }
    
    private lazy var secureSession: Session? = {
        guard let certificate = certificate else {
            return nil
        }
        
        return Session(
            configuration: configuration,
            interceptor: EspCookieInterceptor(),
            serverTrustManager: CustomServerTrustManager(certificate: certificate),
            // eventMonitors: [AlamofireLogger()] // Use for request debugging
        )
    }()
    
    private lazy var defaultSession: Session = {
        return Alamofire.Session(configuration: configuration, delegate: Alamofire.Session.default.delegate)
    }()
    
    private lazy var certificate: SecCertificate? = {
        guard let path = Bundle.main.path(forResource: "supla_org_cert", ofType: "cer"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let certificate = SecCertificateCreateWithData(nil, data as CFData)
        else {
            SALog.error("Could not load SUPLA root CA")
            return nil
        }
        
        return certificate
    }()
    
    private lazy var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.httpCookieStorage = nil
        return configuration
    }()
}

private class CustomServerTrustManager: ServerTrustManager, @unchecked Sendable {
    private static let trustedHost = "192.168.4.1"
    
    init(certificate: SecCertificate) {
        super.init(allHostsMustBeEvaluated: false, evaluators: [
            CustomServerTrustManager.trustedHost: PinnedCertificatesTrustEvaluator(certificates: [certificate], acceptSelfSignedCertificates: true, performDefaultValidation: false, validateHost: false)
        ])
    }
}

private final class AlamofireLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let headers: String = "\(request.request?.headers.dictionary ?? ["": ""])"
        let message = """
        ⚡️ Request Started: \(request)
        ⚡️ Headers: \(headers)
        ⚡️ Body Data: \(body)
        """
        NSLog(message)
    }
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        NSLog("⚡️ Response Received: \(response.debugDescription)")
    }
}
