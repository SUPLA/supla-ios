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
import SwiftUI

protocol SuplaAppCoordinator: Coordinator {
    func attachToWindow(_ window: UIWindow)
    func currentController() -> UIViewController?
    func navigateToSettings()
    func navigateToLocationOrdering()
    func navigateToAddWizard()
    func navigateToAbout()
    func navigateToNotificationsLog()
    func navigateToDeviceCatalog()
    func navigateToCreateAccountWeb()
    func navigateToRemoveAccountWeb(needsRestart: Bool, serverAddress: String?)
    func navigateToLegacyDetail(_ detailType: LegacyDetailType, channelBase: SAChannelBase)
    func navigateToImpulseCounterDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToRgbwDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToStandardDetail(item: ItemBundle, pages: [DetailPage])
    func navigateToCounterPhoto(channelId: Int32)
    func navigateToDeveloperOptions()
    func navigateToLegacyDimmerSettings(channelId: Int32)

    func popToStatus()
    
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
        // TODO: - remove when unused
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
    
    func navigateToSettings() {
        navigateTo(AppSettingsVC())
    }
    
    func navigateToLocationOrdering() {
        let viewController = LocationOrderingVC()
        viewController.bind(viewModel: LocationOrderingVM())
        navigateTo(viewController)
    }
    
    func navigateToAddWizard() {
        let avc = AddWizardFeature.ViewController.create()
        avc.modalPresentationStyle = .fullScreen
        avc.modalTransitionStyle = .crossDissolve
        present(avc, animated: true)
    }
    
    func navigateToAbout() {
        navigateTo(AboutFeature.ViewController.create())
    }
    
    func navigateToNotificationsLog() {
        navigateTo(NotificationsLogFeature.ViewController.create())
    }
    
    func navigateToDeviceCatalog() {
        navigateTo(DeviceCatalogVC())
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
    
    func navigateToStandardDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(StandardDetailVC(item: item, pages: pages))
    }
    
    func navigateToImpulseCounterDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(ImpulseCounterDetailVC(item: item, pages: pages))
    }
    
    func navigateToRgbwDetail(item: ItemBundle, pages: [DetailPage]) {
        navigateTo(RgbAndDimmerDetailVC(item: item, pages: pages))
    }
    
    func navigateToCounterPhoto(channelId: Int32) {
        navigateTo(CounterPhotoFeature.ViewController.create(channelId: channelId))
    }
    
    func navigateToDeveloperOptions() {
        navigateTo(DeveloperInfoFeature.ViewController.create())
    }
    
    func navigateToLegacyDimmerSettings(channelId: Int32) {
        navigateTo(LegacyDimmerSettingsVC(remoteId: channelId))
    }
    
    func popToStatus() {
        //        popToViewController(ofClass: StatusFeature.ViewController.self)
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
