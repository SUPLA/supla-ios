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

@testable import SUPLA

extension AuthInfo {
    static func mock(
        emailAuth: Bool = true,
        serverAutoDetect: Bool = true,
        email: String = "",
        serverForEmail: String = "",
        serverForAccessID: String = "",
        accessID: Int = 0,
        accessIDpwd: String = ""
    ) -> AuthInfo {
        AuthInfo(
            emailAuth: emailAuth,
            serverAutoDetect: serverAutoDetect,
            emailAddress: email,
            serverForEmail: serverForEmail,
            serverForAccessID: serverForAccessID,
            accessID: accessID,
            accessIDpwd: accessIDpwd
        )
    }
}
