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
import Foundation

final class CloudApiClient {
    @Singleton<CloudApiTokenStore> private var tokenStore
    
    private let session: Session
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    init(session: Session? = nil) {
        self.session = session ?? Session(eventMonitors: [CloudApiLogger()])
    }

    func authenticate(email: String, password: String, serverAddress: String?) async throws {
        let serverURL = Self.baseURL(from: serverAddress) ?? URL(string: "https://cloud.supla.org")!
        guard var components = URLComponents(url: serverURL, resolvingAgainstBaseURL: false) else {
            throw CloudApiError.invalidURL
        }
        components.path = "/api/webapp-auth"
        guard let authenticationURL = components.url else { throw CloudApiError.invalidURL }

        var request = URLRequest(url: authenticationURL)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(CloudApi.ApiAuthRequest(username: email, password: password))

        let (data, response) = try await perform(request)
        guard (200..<300).contains(response.statusCode) else {
            if response.statusCode == 401 || response.statusCode == 403 { throw CloudApiError.invalidCredentials }
            throw CloudApiError.http(response.statusCode)
        }

        let auth = try jsonDecoder.decode(CloudApi.ApiAuthResponse.self, from: data)
        let baseURL = Self.baseURL(from: auth.targetURL) ?? serverURL
        tokenStore.save(
            CloudApiToken(
                accessToken: auth.accessToken,
                expiresAt: Date().addingTimeInterval(TimeInterval(auth.expiresIn)),
                baseURL: baseURL.absoluteString
            )
        )
    }

    func getSchedules() async throws -> [CloudApi.ScheduleDto] {
        let data = try await send(
            path: "/api/v3/schedules",
            query: [URLQueryItem(name: "include", value: "subject,closestExecutions")]
        )
        return try jsonDecoder.decode([CloudApi.ScheduleDto].self, from: data)
    }

    func getSchedule(id: Int) async throws -> CloudApi.ScheduleDto {
        let data = try await send(path: "/api/v3/schedules/\(id)")
        return try jsonDecoder.decode(CloudApi.ScheduleDto.self, from: data)
    }

    func updateSchedule(id: Int, schedule: CloudApi.ScheduleDto) async throws {
        _ = try await send(path: "/api/v3/schedules/\(id)", method: "PUT", body: schedule)
    }

    private func send(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: CloudApi.ScheduleDto? = nil
    ) async throws -> Data {
        guard let token = tokenStore.token else { throw CloudApiError.unauthorized }
        guard let baseURL = URL(string: token.baseURL),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else { throw CloudApiError.invalidURL }

        components.path = path
        components.queryItems = query.isEmpty ? nil : query
        guard let url = components.url else { throw CloudApiError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try jsonEncoder.encode(body)
        }

        let (data, response) = try await perform(request)
        if response.statusCode == 401 { throw CloudApiError.unauthorized }
        guard (200..<300).contains(response.statusCode) else { throw CloudApiError.http(response.statusCode) }
        return data
    }

    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let response = await session.request(request).serializingData().response
        guard let httpResponse = response.response else {
            if let error = response.error { throw error }
            throw CloudApiError.invalidResponse
        }

        guard let data = response.value else {
            if let error = response.error { throw error }
            throw CloudApiError.invalidResponse
        }
        return (data, httpResponse)
    }

    private static func baseURL(from address: String?) -> URL? {
        guard var address = address?.trimmingCharacters(in: .whitespacesAndNewlines), !address.isEmpty else { return nil }
        if !address.contains("://") { address = "https://\(address)" }
        guard let url = URL(string: address), let scheme = url.scheme, let host = url.host else { return nil }
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = url.port
        return components.url
    }
}

private final class CloudApiLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        let method = request.request?.httpMethod ?? "GET"
        let url = request.request?.url?.absoluteString ?? "<unknown URL>"
        SALog.debug("⚡️ Cloud API request started: \(method) \(url)")
    }

    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        let method = request.request?.httpMethod ?? "GET"
        let url = request.request?.url?.absoluteString ?? "<unknown URL>"

        if let error = response.error {
            if error.isExplicitlyCancelledError {
                SALog.debug("⚡️ Cloud API request cancelled: \(method) \(url)")
            } else {
                SALog.error("⚡️ Cloud API request failed: \(method) \(url) - \(error)")
            }
            return
        }

        if let statusCode = response.response?.statusCode {
            SALog.debug("⚡️ Cloud API response received: \(method) \(url) - \(statusCode)")
        } else {
            SALog.warning("⚡️ Cloud API response received without an HTTP status: \(method) \(url)")
        }
    }
}

enum CloudApiError: Error {
    case invalidCredentials
    case unauthorized
    case invalidURL
    case invalidResponse
    case http(Int)
}
