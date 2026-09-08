//
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
import XCTest

final class AppRouterTests: XCTestCase {
    private lazy var stateHolder: SuplaAppStateHolderMock! = SuplaAppStateHolderMock()
    private lazy var router: AppRouter! = AppRouter()

    override func setUp() {
        DiContainer.shared.register(type: SuplaAppStateHolder.self, stateHolder!)
    }

    override func tearDown() {
        stateHolder = nil
        router = nil
    }

    func test_shouldBlockNfcDeepLink_whenAddWizardRouteIsOpen() {
        // given
        let url = URL(string: "supla://nfc/test")!
        router.navigate(to: .addWizard)

        // when
        router.handleDeepLink(url)

        // then
        XCTAssertEqual(router.path, [.addWizard])
        stateHolder.currentStateMock.verifyCalls(0)
    }

    func test_shouldBlockNfcDeepLink_whenAddWizardStarted() {
        // given
        let url = URL(string: "supla://nfc/test")!
        stateHolder.currentStateMock.returns = .single(.finished(reason: .addWizardStarted))

        // when
        router.handleDeepLink(url)

        // then
        XCTAssertEqual(router.path, [])
        stateHolder.currentStateMock.verifyCalls(1)
    }

    func test_shouldHandleNfcDeepLink_whenAddWizardIsNotActive() {
        // given
        let url = URL(string: "supla://nfc/test")!
        stateHolder.currentStateMock.returns = .single(nil)

        // when
        router.handleDeepLink(url)

        // then
        XCTAssertEqual(router.path, [.callNfcAction(url: url)])
        stateHolder.currentStateMock.verifyCalls(1)
    }
}
