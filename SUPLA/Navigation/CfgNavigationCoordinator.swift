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

class CfgNavigationCoordinator: BaseNavigationCoordinator {
    override var viewController: UIViewController {
        _viewController
    }
    
    private let disposeBag = DisposeBag()
    private let cfgDismissCmd = PublishSubject<Void>()
    private let locOrderingDismissCmd = PublishSubject<Void>()

    private let _viewController: CfgVC

    override init() {
        _viewController = CfgVC(dismissCmd: cfgDismissCmd)
        super.init()
    }
    
    override func start(from parent: NavigationCoordinator?) {
        super.start(from: parent)
        _viewController.openLocalizationOrderingCmd.subscribe { _ in
            if let nc = self.parentCoordinator?.viewController as?
                 UINavigationController {
                let vm = LocationOrderingVM(managedObjectContext: SAApp.db().managedObjectContext)
                let locVC = LocationOrderingVC()
                locVC.navigationCoordinator = self
                locVC.bind(viewModel: vm)
                vm.bind(inputs: LocationOrderingVM.Inputs(commitChangesTrigger: self.locOrderingDismissCmd))
                nc.pushViewController(locVC, animated: true)
            }
        }.disposed(by: disposeBag)
    }

    override func viewControllerDidDismiss(_ vc: UIViewController) {
        if vc is LocationOrderingVC {
            locOrderingDismissCmd.onNext(())
        }
    }
    
    override func parentDidTakeFlowOver(_ parent: NavigationCoordinator) {
        cfgDismissCmd.onNext(())
    }
}
