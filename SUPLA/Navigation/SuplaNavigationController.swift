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

class SuplaNavigationController: UINavigationController {
    
    let onViewControllerWillPop: Observable<UIViewController>
    let _onViewControllerWillPop = PublishSubject<UIViewController>()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override init(rootViewController: UIViewController) {
        onViewControllerWillPop = _onViewControllerWillPop.asObservable()
        super.init(rootViewController: rootViewController)
        configure()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        onViewControllerWillPop = _onViewControllerWillPop.asObservable()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        onViewControllerWillPop = _onViewControllerWillPop.asObservable()
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        view.backgroundColor = .suplaGreenBackground
        navigationBar.tintColor = .white
        navigationBar.backgroundColor = .suplaGreenBackground
        extendedLayoutIncludesOpaqueBars = false
        navigationBar.barTintColor = .suplaGreenBackground
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: true)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if let vc = super.popViewController(animated: true) {
            _onViewControllerWillPop.onNext(vc)
            return vc
        } else {
            return nil
        }
    }
}

