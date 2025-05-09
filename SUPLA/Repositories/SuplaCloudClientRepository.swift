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
import RxCocoa

protocol SuplaCloudClientRepository {
    func users(email: String) -> Observable<SuplaCloudClient.Autodiscover>
}

final class SuplaCloudClientRepositoryImpl: SuplaCloudClientRepository {
    
    @Singleton<RequestHelper> private var requestHelper
    
    let usersUrl = "https://autodiscover.supla.org/users/%@"
    
    func users(email: String) -> Observable<SuplaCloudClient.Autodiscover> {
        guard let encodedEmail = email.urlEncoded()
        else {
            return Observable.error(
                SuplaCloudClientError.parseError(message: "Could not encode email address")
            )
        }
        
        let urlString = String(format: usersUrl, encodedEmail)
        return requestHelper.getRequest(urlString: urlString)
            .map { data in
                if let autodiscover = SuplaCloudClient.Autodiscover(data: data) {
                    return autodiscover
                }
                
                throw SuplaCloudClientError.parseError(message: "Could not parse response data: '\(data)'")
            }
    }
}

private extension String {
    func urlEncoded() -> String? {
        addingPercentEncoding(withAllowedCharacters: SuplaCloudClient.emailCharacterSet)
    }
}
