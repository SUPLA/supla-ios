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
    override var viewController: UIViewController {
        return navigationController
    }
    
    private let disposeBag = DisposeBag()
    
    private let navigationController: SuplaNavigationController
    
    private var mainVC: SAMainVC

    
    private var pendingFlow: NavigationCoordinator?
    private var pendingCompletion: (()->Void)?
    
    override init() {
        mainVC = SAMainVC(nibName: "MainVC", bundle: nil)
        navigationController = SuplaNavigationController(rootViewController: mainVC)
        super.init()
        mainVC.navigationCoordinator = self
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
        if SAApp.configIsSet() {
            showStatusView(progress: 0)
        } else {
            showAuthView(immediate: true)
        }
    }
    
    private func updateNavBar() {
        let showNav = SAApp.configIsSet() && SAApp.isClientRegistered()
        navigationController.setNavigationBarHidden(!showNav,
                                                    animated: true)
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
                navigationController.present(child.viewController,
                                             animated: child.wantsAnimatedTransitions) {
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
            if child is CfgNavigationCoordinator {
                mainVC.reloadTables();
            }
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
        startFlow(coordinator: CfgNavigationCoordinator())
    }

    @objc func showProfilesView(allowsBack: Bool) {
        startFlow(coordinator: ProfilesNavigationCoordinator(allowsBack: allowsBack))
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
    
    @objc func showAuthView(immediate: Bool) {
        startFlow(coordinator: AuthCfgNavigationCoordinator(immediate: immediate,
                                                            profileId: SAApp.profileManager().getCurrentProfile().objectID))
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

extension MainNavigationCoordinator: NavigationAnimationSupport {
    func animationControllerFor(operation: UINavigationController.Operation,
                                from fromVC: UIViewController,
                                to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let fromVC = fromVC as? SAMainVC, toVC is DetailViewController {
            let animator = SwipeTransitionAnimator(direction: .slideIn)
            animator.interactionController = fromVC.interactionController
            return animator
        } else if let fromVC = fromVC as? DetailViewController, toVC is SAMainVC {
            let animator = SwipeTransitionAnimator(direction: .slideOut)
            animator.interactionController = fromVC.interactionController
            return animator
        }
        return nil
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

