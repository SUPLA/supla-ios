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


import UIKit
import RxSwift
import RxCocoa

@objc
class MainNavigationCoordinator: BaseNavigationCoordinator {
    
    @Singleton<GlobalSettings> var settings
    
    override var viewController: UIViewController {
        return navigationController
    }
    
    private let disposeBag = DisposeBag()
    
    private lazy var navigationController: SuplaNavigationController = {
        SuplaNavigationController(rootViewController: mainVC)
    }()
    private lazy var mainVC: MainVC = { MainVC(navigator: self) }()

    
    private var pendingFlow: NavigationCoordinator?
    private var pendingCompletion: (()->Void)?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onRegistered(_:)),
                                               name: .saRegistered,
                                               object: nil)
        navigationController.onViewControllerWillPop.subscribe { vc in
            if self.currentCoordinator.viewController == vc.element && !self.currentCoordinator.isFinishing {
                // top controller of child flow is being popped off the stack
                // so the flow should finish now.
                self.didFinish(coordinator: self.currentCoordinator)
            } else if let controller = vc.element as? BaseViewController,
                      let hisCoord = controller.navigationCoordinator {
                hisCoord.viewControllerDidDismiss(controller)
            }
        }.disposed(by: disposeBag)
        navigationController.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    private func showInitialView() {
        if (settings.anyAccountRegistered) {
            showStatusView(progress: 0)
        } else {
            showAuthView()
        }
    }
    
    private func updateNavBar() {
        let showNav = settings.anyAccountRegistered
        navigationController.setNavigationBarHidden(!showNav, animated: true)
    }

    override func start(from parent: NavigationCoordinator?) {
        showInitialView()
    }
    
    override func startFlow(coordinator child: NavigationCoordinator) {
        if currentCoordinator is PresentationNavigationCoordinator {
            // Finish presenting before going to other screen
            pendingFlow = child
            currentCoordinator.finish()
        } else {
            if let child = child as? PresentationNavigationCoordinator {
                child.isAnimating = true
                navigationController.present(child.viewController, animated: child.wantsAnimatedTransitions) {
                    child.isAnimating = false
                    self.completeFlowTransition()
                }
            } else {
                updateNavBar()
                navigationController.pushViewController(child.viewController,
                                                        animated: child.wantsAnimatedTransitions)
                completeFlowTransition()
            }
            super.startFlow(coordinator: child)
        }
    }
    
    override func didFinish(coordinator child: NavigationCoordinator) {
        if child is PresentationNavigationCoordinator {
            if child.viewController.presentingViewController == nil {
                child.viewController.view.removeFromSuperview()
                child.viewController.removeFromParent()
                super.didFinish(coordinator: child)
                self.resumeFlowIfNeeded()
            } else {
                navigationController.dismiss(animated: child.wantsAnimatedTransitions) {
                    super.didFinish(coordinator: child)
                    self.resumeFlowIfNeeded()
                }
            }
        } else {
            updateNavBar()
            if navigationController.topViewController == child.viewController {
                _ = navigationController.popViewController(animated: child.wantsAnimatedTransitions)
            }
            
            super.didFinish(coordinator: child)
            self.resumeFlowIfNeeded()
        }
    }
    
    private func resumeFlowIfNeeded() {
        if let resumeFlow = pendingFlow {
            pendingFlow = nil
            startFlow(coordinator: resumeFlow)
        }
    }

    
    func showSettingsView() {
        startFlow(coordinator: AppSettingsNavigationCoordinator())
    }

    @objc func showProfilesView() {
        startFlow(coordinator: ProfilesNavigationCoordinator())
    }
    
    func showNotificationsLog() {
        startFlow(coordinator: NotificationsLogNavigationCoordinator())
    }
    
    func showDeviceCatalog() {
        startFlow(coordinator: DeviceCatalogNavigationCoordinator())
    }
    
    func showAddWizard() {
        let avc = SAAddWizardVC(nibName: "AddWizardVC", bundle: nil)
        avc.modalPresentationStyle = .fullScreen
        avc.modalTransitionStyle = .crossDissolve
        startFlow(coordinator: PresentationNavigationCoordinator(viewController: avc))
    }
    
   
    func showAbout() {
        pushLegacyViewController(named: "AboutVC", of: SAAboutVC.self)
    }
    
    func openCloud() {
        openWeb(url: URL(string: "https://cloud.supla.org")!)
    }
    
    func openWeb(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func pushLegacyViewController<T>(named: String, of: T.Type)
        where T: BaseViewController {
            if currentCoordinator !== self {
                currentCoordinator.finish()
            }
        let vc = T(nibName: named, bundle: nil)
        vc.navigationCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    @objc
    func attach(to window: UIWindow) {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: -
    // MARK: Public interface
    // MARK: -
    
    @objc func showAuthView() {
        startFlow(coordinator: AuthCfgNavigationCoordinator(immediate: true, profileId: nil))
    }
    
    @objc func showStatusView(progress: NSNumber) {
        activeStatusController().setStatusConnectingProgress(progress.floatValue)
    }

    @objc func showStatusView(error: String, completion: (()->Void)? = nil) {
        pendingCompletion = completion
        activeStatusController().setStatusError(error)
    }
    
    private func activeStatusController() -> SAStatusVC {
        let vc: SAStatusVC
        if let visiblePresentation = currentCoordinator as? PresentationNavigationCoordinator,
           let statusController = visiblePresentation.viewController as? SAStatusVC {
            // already displaying status view
            vc = statusController
            if !visiblePresentation.isAnimating {
                completeFlowTransition()
            }
        } else {
            // no status display yet, so let's create new controller
            vc = SAStatusVC(nibName: "StatusVC", bundle: nil)
            let pc = PresentationNavigationCoordinator(viewController: vc)
            startFlow(coordinator: pc)
        }
        return vc
    }
    
    private func completeFlowTransition() {
        pendingCompletion?()
        pendingCompletion = nil
    }
    

    @objc func toggleMenuBar() {
        let show: Bool
        if currentCoordinator is PresentationNavigationCoordinator {
            show = currentCoordinator.viewController is SuplaMenuController
            currentCoordinator.finish()
        } else {
            show = true
        }
        if show {
            let coord = PresentationNavigationCoordinator(viewController: SuplaMenuController())
            coord.shouldAnimatePresentation = false
            startFlow(coordinator: coord)
        }
    }
    
    func navigateToLegacyDetail(legacyDetailType: LegacyDetailType, channelBase: SAChannelBase) {
        startFlow(coordinator: LegacyDetailNavigationCoordinator(detailType: legacyDetailType, channelBase: channelBase))
    }
    
    func navigateToSwitchDetail(item: ItemBundle, pages: [DetailPage]) {
        startFlow(coordinator: SwitchDetailNavigationCoordinator(item: item, pages: pages))
    }
    
    func navigateToThermostatDetail(item: ItemBundle, pages: [DetailPage]) {
        startFlow(coordinator: ThermostatDetailNavigationCoordinator(item: item, pages: pages))
    }
    
    func navigateToThermometerDetail(item: ItemBundle, pages: [DetailPage]) {
        startFlow(coordinator: ThermometerDetailNavigatorCoordinator(item: item, pages: pages))
    }
    
    func navigateToGpmDetail(item: ItemBundle, pages: [DetailPage]) {
        startFlow(coordinator: GpmDetailNavigatorCoordinator(item: item, pages: pages))
    }
    
    func navigateToRollerShutterDetail(item: ItemBundle, pages: [DetailPage]) {
        startFlow(coordinator: WindowDetailVC.Coordinator(item: item, pages: pages))
    }
    
    // MARK: -
    // MARK: Application life cycle support
    // MARK: -
    @objc
    private func onRegistered(_ notification: Notification) {
        if currentCoordinator is PresentationNavigationCoordinator &&
           currentCoordinator.viewController is SAStatusVC {
            DispatchQueue.main.async {
                self.currentCoordinator.finish()
            }
        }
        self.updateNavBar()

    }
}

protocol NavigationAnimationSupport {
    func animationControllerFor(operation: UINavigationController.Operation,
                                from fromVC: UIViewController,
                                to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
}

extension MainNavigationCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let baseCtrl = fromVC as? BaseViewController,
           let coord = baseCtrl.navigationCoordinator as? NavigationAnimationSupport {
            return coord.animationControllerFor(operation: operation, from: fromVC,
                                                to: toVC)
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let animationController = animationController as? SwipeTransitionAnimator {
            return animationController.interactionController
        } else {
            return nil
        }
    }
}

