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

protocol RequestHelper {
    func getRequest(urlString: String) -> Observable<Data>
    func getOAuthRequest(urlString: String) -> Observable<(response: HTTPURLResponse, data: Data)> 
}

final class RequestHelperImpl: NSObject, RequestHelper {
    
    @Singleton<SuplaCloudConfigHolder> private var configHolder
    @Singleton<SuplaClientProvider> private var clientProvider
    @Singleton<SessionResponseProvider> private var sessionResponseProvider
    @Singleton<SuplaSchedulers> private var schedulers
    
    private let syncedQueue = DispatchQueue(label: "RequestPrivateQueue", attributes: .concurrent)
    
    func getRequest(urlString: String) -> Observable<Data> {
        guard let url: URL = .init(string: urlString)
        else {
            return Observable.error(
                RequestHelperError.wrongUrl(url: urlString)
            )
        }
        
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 5
        )
        request.httpMethod = "GET"
        
        return sessionResponseProvider.data(request)
    }
    
    func getOAuthRequest(urlString: String) -> Observable<(response: HTTPURLResponse, data: Data)> {
        guard let url: URL = .init(string: urlString) else {
            return Observable.error(RequestHelperError.wrongUrl(url: urlString))
        }
        
        if (configHolder.token == nil || configHolder.token?.isAlive() == false) {
            if (!updateToken()) {
                return Observable.error(RequestHelperError.tokenNotValid(message: "By preparing request"))
            }
        }
        
        return sessionResponseProvider.response(oauthRequest(url))
            .flatMap { (response, data) in
                if (response.statusCode == 401) {
                    if (self.updateToken()) {
                        return self.sessionResponseProvider.response(self.oauthRequest(url))
                    } else {
                        return Observable.error(RequestHelperError.tokenNotValid(message: "By refreshing during the request"))
                    }
                } else {
                    return Observable.just((response, data))
                }
            }
            .subscribe(on: schedulers.background)
    }
    
    private func oauthRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
        if let token = configHolder.token {
            request.setValue("Bearer \(token.tokenString)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "GET"
        
        return request
    }
    
    private func updateToken() -> Bool {
        return syncedQueue.sync(execute: {
            clientProvider.provide().oAuthTokenRequest()
            
            for _ in 0...50 {
                if (self.configHolder.token != nil && self.configHolder.token?.isAlive() == true) {
                    return true
                }
                usleep(100000)
            }
            
            return false
        })
    }
}

enum RequestHelperError: Error {
    case wrongUrl(url: String)
    case tokenNotValid(message: String)
}
