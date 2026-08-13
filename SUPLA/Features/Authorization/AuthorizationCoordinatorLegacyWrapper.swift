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

import Foundation

@objc
final class AuthorizationCoordinatorLegacyWrapper: NSObject {
    typealias Callback = @convention(block) () -> Void

    @Singleton<AuthorizationCoordinator> private static var authorizationCoordinator

    @objc(authorizeWithOnAuthorized:onDismissed:)
    static func authorize(
        onAuthorized: @escaping Callback,
        onDismissed: @escaping Callback
    ) {
        authorizationCoordinator.authorize(
            onAuthorized: onAuthorized,
            onDismissed: onDismissed
        )
    }

    @objc
    static func isAuthorizationVisible() -> Bool {
        authorizationCoordinator.isVisible
    }
}
