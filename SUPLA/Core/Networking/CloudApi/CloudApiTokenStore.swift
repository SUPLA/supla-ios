/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty
 of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

import Foundation

final class CloudApiTokenStore {
    private let key = "cloudApiAccessToken"

    var token: CloudApiToken? {
        guard let data = SAKeychain.getObjectWithKey(key),
              let value = try? JSONDecoder().decode(CloudApiToken.self, from: data)
        else { return nil }

        guard value.expiresAt > Date() else {
            clean()
            return nil
        }

        return value
    }

    func save(_ token: CloudApiToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }
        _ = SAKeychain.deleteObject(withKey: key)
        _ = SAKeychain.add(data, withKey: key)
    }

    func clean() {
        _ = SAKeychain.deleteObject(withKey: key)
    }
}

struct CloudApiToken: Codable {
    let accessToken: String
    let expiresAt: Date
    let baseURL: String
}
