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
import SwiftUI

protocol AuthorizationCoordinator: AnyObject {
    var isVisible: Bool { get }

    func authorize(
        onAuthorized: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    )

    func login(
        onAuthorized: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    )

    func cancelPendingRequest()
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

    var isVisible: Bool {
        request != nil
    }

    func authorize(
        onAuthorized: @escaping () -> Void = {},
        onDismissed: @escaping () -> Void = {}
    ) {
        performOnMainSync {
            self.request = Request(
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
        performOnMainSync {
            self.request = Request(
                requestType: .login,
                onAuthorized: onAuthorized,
                onDismissed: onDismissed
            )
        }
    }

    func cancelPendingRequest() {
        performOnMainSync {
            self.cancelPendingRequestOnMain()
        }
    }

    private func performOnMainSync(_ action: @escaping () -> Void) {
        // Synchronized to avoid race condition when creating and canceling requests
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.sync(execute: action)
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

    private func cancelPendingRequestOnMain() {
        let request = request
        self.request = nil

        request?.onDismissed()
    }
}
