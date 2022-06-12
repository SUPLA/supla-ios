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

class ProfilesNavigationCoordinator: BaseNavigationCoordinator {
    override var viewController: UIViewController {
        return _viewController
    }
    
    private let _disposeBag = DisposeBag()
    private let _dismissTrigger = PublishSubject<Void>()
    private let _editProfile = PublishSubject<Int>()
    
    private lazy var _viewController: ProfilesVC = {
        return ProfilesVC(navigationCoordinator: self)
    }()

    override func startFlow(coordinator child: NavigationCoordinator) {
        _viewController.navigationController?.pushViewController(child.viewController,
                                                                 animated: true)
        super.startFlow(coordinator: child)
    }
    
    override func start(from parent: NavigationCoordinator?) {
        super.start(from: parent)

        let vm = ProfilesVM(profileManager: SAApp.profileManager())
        _viewController.bind(viewModel: vm)

        vm.dismissTrigger.subscribe { [weak self] _ in
            self?.finish()
        }.disposed(by: _disposeBag)

        vm.openProfileTrigger.subscribe { [weak self] profileId in
            self?.openProfileView(profileId)
        }.disposed(by: _disposeBag)

        
/*
        _viewController.viewModel.initiateSignup.subscribe { _ in
            let cavc = SACreateAccountVC(nibName: "CreateAccountVC", bundle: nil)
            cavc.navigationCoordinator = self
            self._viewController.navigationController?.pushViewController(cavc, animated: true)
        }.disposed(by: _disposeBag)
        
 */
    }
    
    @objc private func onDismissSubview(_ sender: AnyObject) {
        _viewController.navigationController?
          .popToViewController(_viewController,
                               animated: true)
    }


    private func openProfileView(_ profileId: ProfileID?) {
        print("gonna open profile \(profileId)")
        let authnc = AuthCfgNavigationCoordinator(immediate: false,
                                                  profileId: profileId)
        startFlow(coordinator: authnc)
/*
        vc.viewModel.formSaved.subscribe { [weak self] _ in
            guard let nc = self?._viewController
                    .navigationController else { return }
            nc.popViewController(animated: true)
        }
 */
        
    }
}

