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

class AuthCfgNavigationCoordinator: BaseNavigationCoordinator {
    override var wantsAnimatedTransitions: Bool {
        return !_immediate
    }
    override var viewController: UIViewController {
        return _viewController
    }
    
    private let _immediate: Bool
    private var _profileId: NSManagedObjectID?
    
    private lazy var _viewController: AccountCreationVC = {
        return AccountCreationVC(navigationCoordinator: self,
                      profileId: _profileId)
    }()
    
    init(immediate: Bool, profileId: ProfileID? = nil) {
        _immediate = immediate
        _profileId = profileId
    }
    
    @objc private func onDismissSubview(_ sender: AnyObject) {
        _viewController.navigationController?.popToViewController(_viewController,
                                                                  animated: true)
    }
    
    override func startFlow(coordinator child: NavigationCoordinator) {
        _viewController.present(child.viewController, animated: true) {
            super.startFlow(coordinator: child)
        }
    }
    
    func restartAppFlow() {
        // Go back to main navigator, finish all inbetween and start from beginning.
        let navigated = goTo(MainNavigationCoordinator.self) { navigator in
            navigator.start(from: nil)
        }
        if (!navigated) {
            finish()
        }
    }
    
    func navigateToCreateAccount() {
        let cavc = SACreateAccountVC(nibName: "CreateAccountVC", bundle: nil)
        cavc.navigationCoordinator = self
        self._viewController.navigationController?.pushViewController(cavc, animated: true)
    }
    
    func navigateToRemoveAccount(needsRestart: Bool, serverAddress: String?) {
        finish()
        (parentCoordinator as? ProfilesNavigationCoordinator)?.navigateToRemoveAccount(needsRestart: needsRestart, serverAddress: serverAddress)
    }
    
    func finish(shouldReauthenticate: Bool) {
        if (shouldReauthenticate) {
            let navigated = goTo(MainNavigationCoordinator.self) { navigator in
                navigator.showStatusView(progress: 0)
            }
            if (!navigated) {
                finish()
            }
        } else {
            finish()
        }
    }
}

extension AuthCfgNavigationCoordinator: NavigationAnimationSupport {
    func animationControllerFor(operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is SACreateAccountVC {
            return FadeTransition(isPresenting: true)
        } else if fromVC is SACreateAccountVC {
            return FadeTransition(isPresenting: false)
        } else {
            return nil
        }
    }
}
