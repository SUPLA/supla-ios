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

import RxSwift

protocol SessionResponseProvider {
    func response(_ request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)>
    func data(_ request: URLRequest) -> Observable<Data>
}

final class SessionResponseProviderImpl: NSObject, SessionResponseProvider {
    
    private let unsecureSession = URLSession(configuration: .default, delegate: CustomSessionDelegate(), delegateQueue: nil)
    
    func response(_ request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        session(request.url).rx.response(request: request)
    }
    
    func data(_ request: URLRequest) -> Observable<Data> {
        session(request.url).rx.data(request: request)
    }
    
    private func session(_ url: URL?) -> URLSession {
        return if (url?.host?.contains(".supla.org") == true) {
            URLSession.shared
        } else {
            unsecureSession
        }
    }
}

class CustomSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        }
    }
}

