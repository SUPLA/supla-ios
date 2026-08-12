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

protocol AuthorizationCoordinator: AnyObject {
    func authorize(
        onAuthorized: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    )

    func login(
        onAuthorized: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    )
}

extension AuthorizationCoordinator {
    func authorize(
        onAuthorized: @escaping () -> Void = {},
        onDismissed: @escaping () -> Void = {}
    ) {
        authorize(onAuthorized: onAuthorized, onDismissed: onDismissed)
    }

    func login(
        onAuthorized: @escaping () -> Void = {},
        onDismissed: @escaping () -> Void = {}
    ) {
        login(onAuthorized: onAuthorized, onDismissed: onDismissed)
    }
}

final class AuthorizationCoordinatorImpl: ObservableObject, AuthorizationCoordinator {

    struct Request: Identifiable {
        let id = UUID()
        let requestType: CredentialsFeature.RequestType
        let onAuthorized: () -> Void
        let onDismissed: () -> Void
    }

    @Published var request: Request?

    func authorize(
        onAuthorized: @escaping () -> Void = {},
        onDismissed: @escaping () -> Void = {}
    ) {
        Task { @MainActor in
            request = Request(
                requestType: .authorize,
                onAuthorized: onAuthorized,
                onDismissed: onDismissed
            )
        }
    }
    
    func login(
        onAuthorized: @escaping () -> Void = {},
        onDismissed: @escaping () -> Void = {}
    ) {
        Task { @MainActor in
            request = Request(
                requestType: .login,
                onAuthorized: onAuthorized,
                onDismissed: onDismissed
            )
        }
    }

    @MainActor
    func complete() {
        let request = request
        request?.onAuthorized()

        self.request = nil
    }

    @MainActor
    func dismiss() {
        let request = request
        request?.onDismissed()

        self.request = nil
    }
}
