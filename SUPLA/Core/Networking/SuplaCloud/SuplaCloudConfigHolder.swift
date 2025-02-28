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

import Dispatch
import Foundation

protocol SuplaCloudConfigHolder {
    var token: SAOAuthToken? { get set }
    var url: String? { get set }

    func clean()
    func requireUrl() throws -> String
    func requireToken() throws -> SAOAuthToken
}

final class SuplaCloudConfigHolderImpl: SuplaCloudConfigHolder {
    @Singleton<SuplaClientProvider> private var clientProvider

    private let syncedQueue = DispatchQueue(label: "RequestPrivateQueue", attributes: .concurrent)

    var token: SAOAuthToken? = nil
    var url: String? = nil
    func clean() {
        token = nil
    }

    func requireUrl() throws -> String {
        let token = try requireToken()
        let tokenUrl: String? = token.url()
        if let url = tokenUrl {
            return url
        }

        if let url = url {
            return url
        }

        throw GeneralError.illegalState(message: "Url could not by retrieved")
    }

    func requireToken() throws -> SAOAuthToken {
        return try syncedQueue.sync {
            if let token = token, token.isAlive() {
                return token
            }

            clientProvider.provide()?.oAuthTokenRequest()

            let rounds: Int32 = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? 1 : 50

            for _ in 0 ... rounds {
                if let token = token, token.isAlive() {
                    return token
                }
                usleep(100000)
            }

            throw GeneralError.illegalState(message: "Token could not by retrieved")
        }
    }
}
