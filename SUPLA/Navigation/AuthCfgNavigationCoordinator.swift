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
    private let _disposeBag = DisposeBag()
    
    private lazy var _viewController: AuthVC = {
        return AuthVC(navigationCoordinator: self,
                      profileId: _profileId)
    }()
    
    init(immediate: Bool, profileId: ProfileID? = nil) {
        _immediate = immediate
        _profileId = profileId
    }
    
    override func start(from parent: NavigationCoordinator?) {
        super.start(from: parent)
        _viewController.viewModel.initiateSignup.subscribe { _ in
            let cavc = SACreateAccountVC(nibName: "CreateAccountVC", bundle: nil)
            cavc.navigationCoordinator = self
            self._viewController.navigationController?.pushViewController(cavc, animated: true)
        }.disposed(by: _disposeBag)
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
}
extension AuthCfgNavigationCoordinator: AuthConfigActionHandler {
    func didFinish(shouldReauthenticate: Bool) {
        finish()
        if shouldReauthenticate || !SAApp.isClientRegistered(),
            let main = parentCoordinator as? MainNavigationCoordinator {
            main.showStatusView(progress: 0)
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
