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


import XCTest
@testable import SUPLA

final class SuplaAppCoordinatorMock: SuplaAppCoordinator {

    private let navigationControllerMock = NavigationControllerMock()
    
    var navigationController: UINavigationController {
        get { navigationControllerMock }
        set {  }
    }
    
    func currentController() -> UIViewController? { UIViewController() }
    
    func navigateToAbout() {
    }
    
    func navigateToNotificationsLog() {
    }
    
    func navigateToDeviceCatalog() {
    }
    
    func navigateToLegacyDetail(_ detailType: LegacyDetailType, channelBase: SAChannelBase) {
    }
    
    func navigateToStandardDetail(item: SUPLA.ItemBundle, pages: [SUPLA.DetailPage]) {
    }
    
    func navigateToImpulseCounterDetail(item: SUPLA.ItemBundle, pages: [SUPLA.DetailPage]) {
    }
    
    func navigateToCounterPhoto(channelId: Int32) {
    }
    
    func navigateToRgbwDetail(item: SUPLA.ItemBundle, pages: [SUPLA.DetailPage]) {
    }
    
    func navigateToLegacyDimmerSettings(channelId: Int32) {
    }
    
    func showMenu() {
    }
    
    func showAuthorization() {
    }

    func openForum() {
    }
    
    func openCloud() {
    }
    
    func openUrl(url: String) {
    }
    
    func openUrl(url: URL) {
    }
    
    func start(animated: Bool) {
    }
    
    func verifyPopViewController(_ parameters: [Bool]) {
        XCTAssertEqual(navigationControllerMock.popViewControllerParameters, parameters)
    }
    
    func navigateToDeveloperOptions() {
    }
}

final class NavigationControllerMock: UINavigationController {
    
    var popViewControllerParameters: [Bool] = []
    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerParameters.append(animated)
        return nil
    }
}
