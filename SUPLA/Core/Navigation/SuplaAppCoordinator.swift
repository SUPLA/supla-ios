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

import RxSwift

protocol SuplaAppCoordinator: Coordinator {
    func attachToWindow(_ window: UIWindow)
    func currentController() -> UIViewController?
    func navigateToMain()
    func navigateToSettings()
    func navigateToLocationOrdering()
    func navigateToProfiles()
    func navigateToAddWizard()
    func navigateToAbout()
    func navigateToNotificationsLog()
    func navigateToDeviceCatalog()
    func navigateToProfile(profileId: Int32?)
    func navigateToProfile(profileId: Int32?, withLockCheck: Bool)
    func navigateToCreateAccountWeb()
    func navigateToRemoveAccountWeb(needsRestart: Bool, serverAddress: String?)
    func navigateToLegacyDetail(_ detailType: LegacyDetailType, channelBase: SAChannelBase)
    func navigateToSwitchDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToThermostatDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToThermometerDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToGpmDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToWindowDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToElectricityMeterDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToImpulseCounterDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToPinSetup(lockScreenScope: LockScreenScope)
    func navigateToLockScreen(unlockAction: LockScreenFeature.UnlockAction)
    func navigateToCounterPhoto(channelId: Int32)
    func navigateToHumidityDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToValveDetail(item: ItemBundle, pages: [DetailPage])
    
    func popToStatus()
    
    func showMenu()
    func showAuthorization(_ onAuthorizedCallback: @escaping () -> Void)
    func showLogin()
    
    func openForum()
    func openCloud()
    func openUrl(url: String)
    func openUrl(url: URL)
}

protocol NavigationSubcontroller {
    func screenTakeoverAllowed() -> Bool
}

final class SuplaAppCoordinatorImpl: NSObject, SuplaAppCoordinator {
    @Singleton<SuplaAppStateHolder> private var stateHolder
    @Singleton<SuplaSchedulers> private var schedulers
    @Singleton<GlobalSettings> private var settings
    
    private var stateDisposable: Disposable? = nil
    
    lazy var navigationController: UINavigationController = {
        let controller = SuplaAppNavigationController()
        return controller
    }()

    func attachToWindow(_ window: UIWindow) {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func start(animated: Bool = false) {
        stateDisposable = stateHolder.state()
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .subscribe(onNext: {
                switch ($0) {
                case .initialization, .connecting(_), .finished:
                    self.navigateToStatusView()
                case .locked:
                    self.navigationController.viewControllers.last?.presentedViewController?.dismiss(animated: false)
                    self.popToViewController(ofClass: StatusFeature.ViewController.self)
                    self.navigateToLockScreen(unlockAction: .authorizeApplication)
                default:
                    break
                }
            })
    }
    
    func currentController() -> UIViewController? {
        if let presentedController = navigationController.viewControllers.last?.presentedViewController {
            return getPresentedController(presentedController)
        }
        return navigationController.viewControllers.last
    }
    
    private func getPresentedController(_ controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return getPresentedController(presentedController)
        }
        return controller
    }
    
    func navigateToMain() {
        navigateTo(MainVC())
    }
    
    func navigateToSettings() {
        navigateTo(AppSettingsVC())
    }
    
    func navigateToLocationOrdering() {
        let viewController = LocationOrderingVC()
        viewController.bind(viewModel: LocationOrderingVM())
        navigateTo(viewController)
    }
    
    func navigateToProfiles() {
        let profiles = ProfilesVC()
        profiles.bind(viewModel: ProfilesVM(profileManager: SAApp.profileManager()))
        navigateTo(profiles)
    }
    
    func navigateToAddWizard() {
        navigationController.viewControllers.last?.presentedViewController?.dismiss(animated: false)
        
        let avc = SAAddWizardVC(nibName: "AddWizardVC", bundle: nil)
        avc.modalPresentationStyle = .fullScreen
        avc.modalTransitionStyle = .crossDissolve
        present(avc, animated: true)
    }
    
    func navigateToAbout() {
        navigateTo(AboutFeature.ViewController.create())
    }
    
    func navigateToNotificationsLog() {
        navigateTo(NotificationsLogVC())
    }
    
    func navigateToDeviceCatalog() {
        navigateTo(DeviceCatalogVC())
    }
    
    func navigateToProfile(profileId: Int32?) {
        navigateToProfile(profileId: profileId, withLockCheck: true)
    }
    
    func navigateToProfile(profileId: Int32?, withLockCheck: Bool) {
        if (withLockCheck && settings.lockScreenSettings.pinForAccountsRequired) {
            if let profileId = profileId {
                navigateToLockScreen(unlockAction: .authorizeAccountsEdit(profileId: profileId))
            } else {
                navigateToLockScreen(unlockAction: .authorizeAccountsCreate)
            }
        } else {
            navigateTo(CreateProfileFeature.ViewController.create(profileId: profileId))
        }
    }
    
    func navigateToCreateAccountWeb() {
        navigateTo(SACreateAccountVC(nibName: "CreateAccountVC", bundle: nil))
    }
    
    func navigateToRemoveAccountWeb(needsRestart: Bool, serverAddress: String?) {
        navigateTo(AccountRemovalVC(needsRestart: needsRestart, serverAddress: serverAddress))
    }
    
    func navigateToLegacyDetail(_ detailType: LegacyDetailType, channelBase: SAChannelBase) {
        navigateTo(DetailViewController(detailViewType: detailType, channelBase: channelBase))
    }
    
    func navigateToSwitchDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(SwitchDetailVC(item: item, pages: pages))
    }
    
    func navigateToThermostatDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(ThermostatDetailVC(item: item, pages: pages))
    }
    
    func navigateToThermometerDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(ThermometerDetailVC(item: item, pages: pages))
    }
    
    func navigateToGpmDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(GpmDetailVC(item: item, pages: pages))
    }
    
    func navigateToWindowDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(WindowDetailVC(item: item, pages: pages))
    }
    
    func navigateToElectricityMeterDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(ElectricityMeterDetailVC(item: item, pages: pages))
    }
    
    func navigateToImpulseCounterDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(ImpulseCounterDetailVC(item: item, pages: pages))
    }
    
    func navigateToHumidityDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(HumidityDetailVC(item: item, pages: pages))
    }
    
    func navigateToValveDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(ValveDetailVC(item: item, pages: pages))
    }
    
    func navigateToPinSetup(lockScreenScope: LockScreenScope) {
        navigateTo(PinSetupFeature.ViewController.create(scope: lockScreenScope))
    }
    
    func navigateToLockScreen(unlockAction: LockScreenFeature.UnlockAction) {
        navigateTo(LockScreenFeature.ViewController.create(unlockAction: unlockAction))
    }
    
    func navigateToCounterPhoto(channelId: Int32) {
        navigateTo(CounterPhotoFeature.ViewController.create(channelId: channelId))
    }
    
    func popToStatus() {
        popToViewController(ofClass: StatusFeature.ViewController.self)
    }
    
    func showMenu() {
        present(SuplaMenuController())
    }
    
    func showAuthorization(_ onAuthorizedCallback: @escaping () -> Void) {
        present(SAAuthorizationDialogVC(onAuthorizedCallback))
    }
    
    func showLogin() {
        present(SALoginDialogVC {})
    }
    
    func openForum() {
        openUrl(url: NSLocalizedString("https://en-forum.supla.org", comment: ""))
    }
    
    func openCloud() {
        openUrl(url: "https://cloud.supla.org")
    }
    
    func openUrl(url: String) {
        if let url = URL(string: url) {
            openUrl(url: url)
        }
    }
    
    func openUrl(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func navigateToStatusView() {
        if (navigationController.viewControllers.isEmpty) {
            navigateTo(StatusFeature.ViewController.create())
        } else if (navigationToStatusAllowed()) {
            navigationController.viewControllers.last?.presentedViewController?.dismiss(animated: false)
            popToViewController(ofClass: StatusFeature.ViewController.self)
        }
    }
    
    private func navigationToStatusAllowed() -> Bool {
        if (navigationController.viewControllers.last is StatusFeature.ViewController) {
            return false // Already in
        }
        
        if let subcontroller = navigationController.viewControllers.last as? NavigationSubcontroller {
            return subcontroller.screenTakeoverAllowed()
        }
        
        if let subcontroller = navigationController.viewControllers.last?.presentedViewController as? NavigationSubcontroller {
            return subcontroller.screenTakeoverAllowed()
        }
        
        return true
    }
}

final class SuplaAppNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    
    private var statusBarStyle: UIStatusBarStyle = .lightContent
    private var navigationBarHiddenOverride: Bool = true
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        statusBarStyle = viewController.preferredStatusBarStyle
        SALog.debug("[PUSH] \(String(describing: viewController))")
        
        if let navBarController = viewController as? NavigationBarVisibilityController {
            SALog.debug("[PUSH] Setting navigation bar hidden: \(navBarController.navigationBarHidden)")
            navigationBarHiddenOverride = navBarController.navigationBarHidden
            super.setNavigationBarHidden(navigationBarHiddenOverride, animated: false)
        }
        
        navigationBar.topItem?.backButtonDisplayMode = .minimal
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let viewController = super.popViewController(animated: animated)
        SALog.debug("[POP] \(String(describing: viewController))")
        
        statusBarStyle = viewControllers.last?.preferredStatusBarStyle ?? .lightContent
        if let navBarController = viewControllers.last as? NavigationBarVisibilityController {
            SALog.debug("[POP] Setting navigation bar hidden: \(navBarController.navigationBarHidden)")
            navigationBarHiddenOverride = navBarController.navigationBarHidden
            super.setNavigationBarHidden(navigationBarHiddenOverride, animated: false)
        }
        return viewController
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let viewControllers = super.popToViewController(viewController, animated: animated)
        SALog.debug("[POP] \(String(describing: viewController))")
        
        statusBarStyle = viewController.preferredStatusBarStyle
        if let navBarController = viewController as? NavigationBarVisibilityController {
            SALog.debug("[POP] Setting navigation bar hidden: \(navBarController.navigationBarHidden)")
            navigationBarHiddenOverride = navBarController.navigationBarHidden
            super.setNavigationBarHidden(navigationBarHiddenOverride, animated: false)
        }
        return viewControllers
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        SALog.debug("setNavigationBarHidden(hidden: \(hidden), animated: \(animated)) overriden by \(navigationBarHiddenOverride)")
        super.setNavigationBarHidden(navigationBarHiddenOverride, animated: animated)
    }
}

@objc
final class SuplaAppCoordinatorLegacyWrapper: NSObject {
    @objc
    static func finish() {
        @Singleton<SuplaAppCoordinator> var coordinator
        coordinator.popViewController()
    }
    
    @objc
    static func dismiss(animated: Bool = true) {
        @Singleton<SuplaAppCoordinator> var coordinator
        coordinator.dismiss(animated: true)
    }
    
    @objc
    static func currentViewController() -> UIViewController? {
        @Singleton<SuplaAppCoordinator> var coordinator
        return coordinator.currentController()
    }
    
    @objc
    static func push(_ viewController: UIViewController) {
        @Singleton<SuplaAppCoordinator> var coordinator
        coordinator.navigateTo(viewController)
    }
    
    @objc
    static func present(_ viewController: UIViewController) {
        @Singleton<SuplaAppCoordinator> var coordinator
        coordinator.present(viewController)
    }
}
