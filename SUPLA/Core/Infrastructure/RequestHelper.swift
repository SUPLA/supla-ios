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

protocol RequestHelper {
    func getRequest(urlString: String) -> Observable<Data>
}

final class RequestHelperImpl: RequestHelper {
    func getRequest(urlString: String) -> Observable<Data> {
        guard let url: URL = .init(string: urlString)
        else {
            return Observable.error(
                ClientError.inputError(message: "Could create URL for: '\(urlString)'")
            )
        }
        
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 5
        )
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.data(request: request)
    }
}
