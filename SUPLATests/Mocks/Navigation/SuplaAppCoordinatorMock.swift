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
    

import XCTest
@testable import SUPLA

final class SuplaAppCoordinatorMock: SuplaAppCoordinator {
    
    private let navigationControllerMock = NavigationControllerMock()
    
    var navigationController: UINavigationController {
        get { navigationControllerMock }
        set {  }
    }
    
    func attachToWindow(_ window: UIWindow) {
    }
    
    func currentController() -> UIViewController? { UIViewController() }
    
    var navigateToMainMock: FunctionMock<Void, Void> = .void()
    func navigateToMain() {
        navigateToMainMock.handle(())
    }
    
    func navigateToSettings() {
    }
    
    func navigateToLocationOrdering() {
    }
    
    var navigateToProfilesMock: FunctionMock<Void, Void> = .void()
    func navigateToProfiles() {
        navigateToProfilesMock.handle(())
    }
    
    func navigateToAddWizard() {
    }
    
    func navigateToAbout() {
    }
    
    func navigateToNotificationsLog() {
    }
    
    func navigateToDeviceCatalog() {
    }
    
    var navigateToProfileMock: FunctionMock<Int32?, Void> = .void()
    func navigateToProfile(profileId: Int32?) {
        navigateToProfileMock.handle(profileId)
    }
    
    var navigateToProfileWithLockCheckMock: FunctionMock<(Int32?, Bool), Void> = .void()
    func navigateToProfile(profileId: Int32?, withLockCheck: Bool) {
        navigateToProfileWithLockCheckMock.handle((profileId, withLockCheck))
    }
    
    func navigateToCreateAccountWeb() {
    }
    
    func navigateToRemoveAccountWeb(needsRestart: Bool, serverAddress: String?) {
    }
    
    func navigateToLegacyDetail(_ detailType: LegacyDetailType, channelBase: SAChannelBase) {
    }
    
    func navigateToSwitchDetail(item: ItemBundle, pages: [DetailPage]) {
    }
    
    func navigateToThermostatDetail(item: ItemBundle, pages: [DetailPage]) {
    }
    
    func navigateToThermometerDetail(item: ItemBundle, pages: [DetailPage]) {
    }
    
    func navigateToGpmDetail(item: ItemBundle, pages: [DetailPage]) {
    }
    
    func navigateToWindowDetail(item: ItemBundle, pages: [DetailPage]) {
    }
    
    func navigateToElectricityMeterDetail(item: SUPLA.ItemBundle, pages: [SUPLA.DetailPage]) {
    }
    
    func navigateToPinSetup(lockScreenScope: LockScreenScope) {
    }
    
    var navigateToLockScreenMock: FunctionMock<LockScreenFeature.UnlockAction, Void> = .void()
    func navigateToLockScreen(unlockAction: LockScreenFeature.UnlockAction) {
        navigateToLockScreenMock.handle(unlockAction)
    }
    
    func navigateToImpulseCounterDetail(item: SUPLA.ItemBundle, pages: [SUPLA.DetailPage]) {
    }
    
    func navigateToHumidityDetail(item: SUPLA.ItemBundle, pages: [SUPLA.DetailPage]) {
    }
    
    func navigateToCounterPhoto(channelId: Int32) {
    }
    
    func popToStatus() {
    }
    
    func showMenu() {
    }
    
    func showAuthorization() {
    }
    
    var showLoginMock: FunctionMock<Void, Void> = .void()
    func showLogin() {
        showLoginMock.handle(())
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
}

final class NavigationControllerMock: UINavigationController {
    
    var popViewControllerParameters: [Bool] = []
    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerParameters.append(animated)
        return nil
    }
}
