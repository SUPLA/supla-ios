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

class SuplaTabBarController<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>>: UITabBarController, NavigationCoordinatorAware {
    
    fileprivate let disposeBag = DisposeBag()
    let viewModel: VM
    var navigationCoordinator: NavigationCoordinator?
    
    init(navigationCoordinator: NavigationCoordinator, viewModel: VM) {
        self.viewModel = viewModel
        self.navigationCoordinator = navigationCoordinator
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 14, *) {
            navigationItem.backButtonDisplayMode = .minimal
        }
        
        viewModel.eventsObervable()
            .subscribe(onNext: { event in self.handle(event: event) })
            .disposed(by: disposeBag)
        viewModel.stateObservable()
            .subscribe(onNext: { state in self.handle(state: state) })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.white]
        if (navigationCoordinator is MainNavigationCoordinator) {
            attributes[.font] = UIFont.suplaTitleBarFont
        } else {
            attributes[.font] = UIFont.suplaSubtitleFont
        }
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
 
    func handle(event: E) { fatalError("handle(event:) has not been implemented!") }
    func handle(state: S) { } // default empty implementation
    
    private func setupView() {
        tabBar.barTintColor = .background
        tabBar.tintColor = .suplaGreen
        tabBar.unselectedItemTintColor = .textLight
        tabBar.isTranslucent = false
        tabBar.layer.shadowOffset = CGSizeMake(0, 0)
        tabBar.layer.shadowRadius = 2
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.backgroundColor = .background
    }
}

extension Disposable {
    func disposed<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>>(by vc: SuplaTabBarController<S, E, VM>) {
        self.disposed(by: vc.disposeBag)
    }
}
