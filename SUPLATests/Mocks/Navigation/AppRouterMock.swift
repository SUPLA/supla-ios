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

@testable import SUPLA

final class AppRouterMock: AppRouter {
    var startMock: FunctionMock<Void, Void> = .void()
    override func start() {
        startMock.handle(())
    }

    var setRootMock: FunctionMock<AppRoot, Void> = .void()
    override func setRoot(_ root: AppRoot) {
        setRootMock.handle(root)
    }

    var navigateMock: FunctionMock<AppRoute, Void> = .void()
    override func navigate(to route: AppRoute) {
        navigateMock.handle(route)
    }

    var replaceCurrentMock: FunctionMock<AppRoute, Void> = .void()
    override func replaceCurrent(with route: AppRoute) {
        replaceCurrentMock.handle(route)
    }

    var backMock: FunctionMock<Void, Void> = .void()
    override func back() {
        backMock.handle(())
    }

    var handleDeepLinkMock: FunctionMock<URL, Void> = .void()
    override func handleDeepLink(_ url: URL) {
        handleDeepLinkMock.handle(url)
    }

    var openUrlStringMock: FunctionMock<String, Void> = .void()
    override func openUrl(url: String) {
        openUrlStringMock.handle(url)
    }

    var openUrlMock: FunctionMock<URL, Void> = .void()
    override func openUrl(url: URL) {
        openUrlMock.handle(url)
    }

    var openForumMock: FunctionMock<Void, Void> = .void()
    override func openForum() {
        openForumMock.handle(())
    }

    var openCloudMock: FunctionMock<Void, Void> = .void()
    override func openCloud() {
        openCloudMock.handle(())
    }

    var openHomepageMock: FunctionMock<Void, Void> = .void()
    override func openHomepage() {
        openHomepageMock.handle(())
    }

    var openZWaveWizardMock: FunctionMock<Void, Void> = .void()
    override func openZWaveWizard() {
        openZWaveWizardMock.handle(())
    }

    var connectionWasLostMock: FunctionMock<Void, Void> = .void()
    override func connectionWasLost() {
        connectionWasLostMock.handle(())
    }
}
