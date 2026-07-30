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

import SwiftUI

extension CredentialsFeature {
    class ViewState: ObservableObject {
        @Published var visible: Bool
        @Published var userName: String
        @Published var password: String
        @Published var isCloudAccount: Bool
        @Published var userNameEnabled: Bool
        @Published var error: String?
        @Published var loading: Bool
        @Published var userNameInitialized: Bool

        init(
            visible: Bool = false,
            userName: String = "",
            password: String = "",
            isCloudAccount: Bool = false,
            userNameEnabled: Bool = false,
            error: String? = nil,
            loading: Bool = false,
            userNameInitialized: Bool = false
        ) {
            self.visible = visible
            self.userName = userName
            self.password = password
            self.isCloudAccount = isCloudAccount
            self.userNameEnabled = userNameEnabled
            self.error = error
            self.loading = loading
            self.userNameInitialized = userNameInitialized
        }
    }
}
