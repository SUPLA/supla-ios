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

import Combine
import Foundation
import RxSwift
import UIKit

class AppRouter: ObservableObject {
    @Singleton<SuplaAppStateHolder> private var stateHolder
    @Singleton<SuplaSchedulers> private var schedulers
    @Singleton<GlobalSettings> private var settings
    @Singleton<AuthorizationCoordinator> private var authorizationCoordinator

    @Published private(set) var root: AppRoot = .status
    @Published var path: [AppRoute] = []

    private let deepLinkParser: DeepLinkParser
    private var stateDisposable: Disposable?
    private var pendingConnectionTakeover = false

    init(deepLinkParser: DeepLinkParser = DeepLinkParser()) {
        self.deepLinkParser = deepLinkParser
    }

    var currentRoute: AppRoute? {
        path.last
    }

    var connectionTakeoverPolicy: ConnectionTakeoverPolicy {
        currentRoute?.connectionTakeoverPolicy ?? root.connectionTakeoverPolicy
    }

    func start() {
        guard stateDisposable == nil else { return }

        stateDisposable = stateHolder.state()
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .subscribe(
                onNext: { [weak self] state in
                    SALog.debug("AppRouter got state \(state)")
                    self?.handle(appState: state)
                },
                onError: {
                    SALog.error("Failed by handling app state: \(String(describing: $0))")
                }
            )
    }

    func setRoot(_ root: AppRoot) {
        path.removeAll()
        self.root = root
    }

    func navigate(to route: AppRoute) {
        path.append(allowedRoute(for: route))
    }

    func replaceCurrent(with route: AppRoute) {
        guard !path.isEmpty else {
            navigate(to: route)
            return
        }

        path.removeLast()
        path.append(allowedRoute(for: route))
    }

    func back() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func handleDeepLink(_ url: URL) {
        guard let deepLinkRoute = deepLinkParser.parse(url) else { return }
        navigate(to: AppRoute(deepLinkRoute))
    }

    func openUrl(url: String) {
        guard let url = URL(string: url) else { return }
        openUrl(url: url)
    }

    func openUrl(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func openForum() {
        openUrl(url: NSLocalizedString("https://en-forum.supla.org", comment: ""))
    }

    func openCloud() {
        openUrl(url: "https://cloud.supla.org")
    }

    func openHomepage() {
        openUrl(url: "https://www.supla.org")
    }

    func openZWaveWizard() {
        authorizationCoordinator.authorize(onAuthorized: { [weak self] in
            self?.navigate(to: .zWave)
        })
    }

    func connectionWasLost() {
        switch connectionTakeoverPolicy {
        case .allowed:
            showConnectionStatus()

        case .deferred:
            pendingConnectionTakeover = true
        }
    }

    func blockingRouteDidFinish() {
        guard pendingConnectionTakeover else { return }
        pendingConnectionTakeover = false
        showConnectionStatus()
    }

    private func handle(appState: SuplaAppState) {
        switch appState {
        case .initialization,
             .connecting,
             .finished:
            connectionWasLost()

        case .locked:
            showConnectionStatus()

        default:
            break
        }
    }

    private func showConnectionStatus() {
        path.removeAll()
        root = .status
    }

    private func allowedRoute(for route: AppRoute) -> AppRoute {
        switch route {
        case .profile(let profileId, true) where settings.lockScreenSettings.pinForAccountsRequired:
            if (profileId != ProfileDto.INVALID_ID) {
                return .lockScreen(action: .authorizeAccountsEdit(profileId: profileId))
            } else {
                return .lockScreen(action: .authorizeAccountsCreate)
            }

        default:
            return route
        }
    }
}
