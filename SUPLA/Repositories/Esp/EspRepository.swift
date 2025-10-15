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

protocol EspRepository {
    func get() async -> Esp.RequestResult
    func post(_ data: [String: String]) async -> Esp.RequestResult
    func login(password: String) async -> Esp.RequestResult
    func setup(password: String) async -> Esp.RequestResult
}

func repeated(_ times: Int, _ body: () async -> Esp.RequestResult) async -> Esp.RequestResult? {
    for _ in 0 ..< times {
        if (!Task.isCancelled) {
            let result = await body()

            switch (result) {
            case .failure, .secureConnectionNeeded: continue
            default:
                return result
            }
        }
    }

    return nil
}

private let ESP_URL = "http://192.168.4.1"
private let ESP_URL_SECURED = "https://192.168.4.1"

private let FIELD_PASSWORD = "cfg_pwd"
private let FIELD_PASSWORD_REPEAT = "confirm_cfg_pwd"
private let SESSION_COOKIE_NAME = "session"

class EspRepositoryImpl: EspRepository {
    @Singleton<EspConfigurationSession> private var espConfigurationSession

    private var url: String {
        espConfigurationSession.useSecureLayer ? ESP_URL_SECURED : ESP_URL
    }

    func get() async -> Esp.RequestResult {
        let result = await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request(url)
                .redirect(using: .doNotFollow)
                .responseString { continuation.resume(returning: responseToResult(response: $0)) }
        }

        switch (result) {
        case .secureConnectionNeeded:
            espConfigurationSession.useSecureLayer = true
        default: break // nothing to do
        }

        return result
    }

    func post(_ data: [String: String]) async -> Esp.RequestResult {
        let result = await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request(url, method: .post, parameters: data)
                .redirect(using: .doNotFollow)
                .responseString { continuation.resume(returning: responseToResult(response: $0)) }
        }

        switch (result) {
        case .secureConnectionNeeded:
            espConfigurationSession.useSecureLayer = true
        default: break // nothing to do
        }

        return result
    }

    func login(password: String) async -> Esp.RequestResult {
        await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request("\(self.url)/login", method: .post, parameters: [FIELD_PASSWORD: password])
                .redirect(using: .doNotFollow)
                .responseString {
                    retrieveCookie($0)
                    continuation.resume(returning: loginToResult(response: $0))
                }
        }
    }
    
    func setup(password: String) async -> Esp.RequestResult {
        let parameters = [
            FIELD_PASSWORD: password,
            FIELD_PASSWORD_REPEAT: password
        ]
        return await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request("\(self.url)/setup", method: .post, parameters: parameters)
                .redirect(using: .doNotFollow)
                .responseString {
                    retrieveCookie($0)
                    continuation.resume(returning: loginToResult(response: $0))
                }
        }
    }

    private func cancellableRequestBuilder(
        _ requestProvider: (UnsafeContinuation<Esp.RequestResult, Never>) -> DataRequest
    ) async -> Esp.RequestResult {
        let requestContainer: ObjectContainer<DataRequest> = .init()
        return await withTaskCancellationHandler {
            await withUnsafeContinuation { continuation in
                requestContainer.object = requestProvider(continuation)
            }
        } onCancel: {
            requestContainer.object?.cancel()
        }
    }
    
    private func buildRequest(_ url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}

private extension AFDataResponse where Success == String {
    var locationHeader: String? {
        response?.headers["Location"]
    }
}

private func responseToResult(response: AFDataResponse<String>) -> Esp.RequestResult {
    let code = response.response?.statusCode
    SALog.info("GET request finished with status code: \(code ?? 0)")

    if (code == 301 && response.locationHeader?.starts(with: "https://") ?? false) {
        return .secureConnectionNeeded
    } else if (code == 303 && response.locationHeader == "/setup") {
        return .setupNeeded
    } else if (code == 303 && response.locationHeader == "/login") {
        return .credentialsNeeded
    } else if (code == 403) {
        return .temporarilyLocked
    } else {
        switch response.result {
        case .success(let value):
            return .success(code, value)
        case .failure(let error):
            SALog.error("GET request failed with error \(error)")
            return .failure(code, error)
        }
    }
}

private func loginToResult(response: AFDataResponse<String>) -> Esp.RequestResult {
    let code = response.response?.statusCode
    SALog.info("Login request finished with status code: \(code ?? 0)")

    if (code == 301 && response.locationHeader?.starts(with: "https://") ?? false) {
        return .secureConnectionNeeded
    } else if (code == 303 && response.locationHeader == "/") {
        return .success(code, "")
    } else if (code == 403) {
        return .temporarilyLocked
    } else {
        switch response.result {
        case .success:
            return .failure(code, InvalidCredentialsError())
        case .failure(let error):
            SALog.error("GET request failed with error \(error)")
            return .failure(code, error)
        }
    }
}

private func retrieveCookie(_ response: AFDataResponse<String>) {
    @Singleton<EspConfigurationSession> var espConfigurationSession
    
    if let allHeaderFields = response.response?.allHeaderFields as? [String: String],
       let url = response.request?.url
    {
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
        for cookie in cookies {
            if (cookie.name == SESSION_COOKIE_NAME) {
                SALog.info("Session cookie found: \(cookie.name)")
                espConfigurationSession.sessionCookie = cookie.copy()
            }
        }
    }
}

class InvalidCredentialsError: Error {}

private extension HTTPCookie {
    func copy() -> HTTPCookie? {
        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: self.name,
            .value: self.value,
            .domain: self.domain,
            .path: self.path
        ]
        
        if let expiresDate = self.expiresDate {
            properties[.expires] = expiresDate
        }
        
        if self.isSecure {
            properties[.secure] = "TRUE"
        }
        
        return HTTPCookie(properties: properties)
    }
}
