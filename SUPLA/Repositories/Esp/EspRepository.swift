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
import Collections

protocol EspRepository {
    func get() async -> Esp.RequestResult
    func post(_ data: OrderedDictionary<String, String>) async -> Esp.RequestResult
    func login() async -> Esp.RequestResult
    func login(password: String, fieldsMap: inout OrderedDictionary<String, String>) async -> Esp.RequestResult
    func setup() async -> Esp.RequestResult
    func setup(password: String, fieldsMap: inout OrderedDictionary<String, String>) async -> Esp.RequestResult
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
                .responseString { continuation.resume(returning: responseToResult(response: $0, requestType: "GET")) }
        }

        switch (result) {
        case .secureConnectionNeeded:
            espConfigurationSession.useSecureLayer = true
        default: break // nothing to do
        }

        return result
    }

    func post(_ data: OrderedDictionary<String, String>) async -> Esp.RequestResult {
        guard let request = buildRequest(urlString: url, fieldsMap: data) else {
            SALog.error("Could not create URLRequest")
            return .failure(nil, RequestBuilderError())
        }
        
        let result = await cancellableRequestBuilder { continuation in
            return EspClient.shared.session.request(request)
                .redirect(using: .doNotFollow)
                .responseString { continuation.resume(returning: responseToResult(response: $0, requestType: "POST")) }
        }

        switch (result) {
        case .secureConnectionNeeded:
            espConfigurationSession.useSecureLayer = true
        default: break // nothing to do
        }

        return result
    }
    
    func login() async -> Esp.RequestResult {
        await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request("\(self.url)/login", method: .get)
                .redirect(using: .doNotFollow)
                .responseString {
                    retrieveCookie($0)
                    continuation.resume(returning: getToResult(response: $0))
                }
        }
    }

    func login(password: String, fieldsMap: inout OrderedDictionary<String, String>) async -> Esp.RequestResult {
        fieldsMap[FIELD_PASSWORD] = password
        guard let request = buildRequest(urlString: "\(self.url)/login", fieldsMap: fieldsMap) else {
            SALog.error("Could not create URLRequest")
            return .failure(nil, RequestBuilderError())
        }
        
        return await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request(request)
                .redirect(using: .doNotFollow)
                .responseString {
                    retrieveCookie($0)
                    continuation.resume(returning: postToResult(response: $0))
                }
        }
    }
    
    func setup() async -> Esp.RequestResult {
        return await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request("\(self.url)/setup", method: .get)
                .redirect(using: .doNotFollow)
                .responseString {
                    retrieveCookie($0)
                    continuation.resume(returning: getToResult(response: $0))
                }
        }
    }
    
    func setup(password: String, fieldsMap: inout OrderedDictionary<String, String>) async -> Esp.RequestResult {
        fieldsMap[FIELD_PASSWORD] = password
        fieldsMap[FIELD_PASSWORD_REPEAT] = password
        guard let request = buildRequest(urlString: "\(self.url)/setup", fieldsMap: fieldsMap) else {
            SALog.error("Could not create URLRequest")
            return .failure(nil, RequestBuilderError())
        }
        
        return await cancellableRequestBuilder { continuation in
            EspClient.shared.session.request(request)
                .redirect(using: .doNotFollow)
                .responseString {
                    retrieveCookie($0)
                    continuation.resume(returning: postToResult(response: $0))
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
    
    private func buildRequest(urlString: String, fieldsMap: OrderedDictionary<String, String>) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        
        let body = fieldsMap
            .map { key, value in
                "\(key.formURLEncoded)=\(value.formURLEncoded)"
            }
            .joined(separator: "&")
        
        var request = URLRequest(url: url)
        request.method = .post
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

private extension AFDataResponse where Success == String {
    var locationHeader: String? {
        response?.headers["Location"]
    }
}

private func responseToResult(response: AFDataResponse<String>, requestType: String) -> Esp.RequestResult {
    let code = response.response?.statusCode
    SALog.info("\(requestType) request finished with status code: \(code ?? 0)")

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
            if (code == 400) {
                return .failure(code, UnknownEspError(code: code, message: value))
            } else {
                return .success(code, value)
            }
        case .failure(let error):
            SALog.error("GET request failed with error \(error)")
            return .failure(code, error)
        }
    }
}

private func getToResult(response: AFDataResponse<String>) -> Esp.RequestResult {
    let code = response.response?.statusCode
    SALog.info("Login request finished with status code: \(code ?? 0)")

    if (code == 403) {
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

private func postToResult(response: AFDataResponse<String>) -> Esp.RequestResult {
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
class RequestBuilderError: Error {}
class UnknownEspError: Error {
    let code: Int?
    let message: String
    
    init(code: Int?, message: String) {
        self.code = code
        self.message = message
    }
}

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

extension String {
    var formURLEncoded: String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+")
        return addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }
}
