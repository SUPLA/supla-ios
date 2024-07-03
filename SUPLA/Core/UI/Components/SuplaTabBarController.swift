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

class SuplaTabBarController<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>>: UITabBarController, NavigationBarVisibilityController {
    
    let viewModel: VM
    var navigationBarHidden: Bool { false }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    fileprivate let disposeBag = DisposeBag()
    
    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        
        viewModel.onViewDidLoad()
        
        viewModel.eventsObervable()
            .subscribe(onNext: { [weak self] event in self?.handle(event: event) })
            .disposed(by: disposeBag)
        viewModel.stateObservable()
            .subscribe(onNext: { [weak self] state in self?.handle(state: state) })
            .disposed(by: disposeBag)
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!navigationBarHidden) {
            setupToolbar(toolbarFont: getToolbarFont())
        }
    }
    
    func handle(event: E) { fatalError("handle(event:) has not been implemented!") }
    func handle(state: S) { } // default empty implementation
    func getToolbarFont() -> UIFont { UIFont.suplaTitleBarFont }
    
    private func setupView() {
        tabBar.barTintColor = .background
        tabBar.tintColor = .suplaGreen
        tabBar.unselectedItemTintColor = .onBackground
        tabBar.isTranslucent = false
        ShadowValues.apply(toLayer: tabBar.layer)
        tabBar.backgroundColor = .background
    }
    
#if DEBUG
    deinit {
        let className = NSStringFromClass(type(of: self))
        SALog.debug("[DEINIT] BC:\(className)")
    }
#endif
}

extension Disposable {
    func disposed<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>>(by vc: SuplaTabBarController<S, E, VM>) {
        self.disposed(by: vc.disposeBag)
    }
}
