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

import Foundation
import RxSwift

class BaseViewControllerVM<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>>: UIViewController, NavigationBarVisibilityController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    var navigationBarHidden: Bool { false }
    var navigationBarMaintainedByParent: Bool = false
    
    @Singleton<GlobalSettings> private var settings
    
    fileprivate let disposeBag = DisposeBag()
    var stateDisposable: Disposable? = nil
    
    let viewModel: VM
    
    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        overrideUserInterfaceStyle = settings.darkMode.interfaceStyle
        
        viewModel.onViewDidLoad()
        
        viewModel.eventsObervable()
            .subscribe(
                onNext: { [weak self] event in self?.handle(event: event) },
                onError: { SALog.error("Failed by handling event \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = settings.darkMode.interfaceStyle
        
        if (!navigationBarHidden && !navigationBarMaintainedByParent) {
            setupToolbar(toolbarFont: getToolbarFont())
        }
        
        viewModel.onViewWillAppear()
        
        stateDisposable = viewModel.stateObservable()
            .subscribe(
                onNext: { [weak self] state in self?.handle(state: state) },
                onError: { SALog.error("Failed by handling state \(String(describing: $0))") }
            )
        
        NotificationCenter.default.addObserver(self, selector: #selector(onViewAppeared), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onViewDisappeared), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onViewAppeared()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDisappeared()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stateDisposable?.dispose()
        stateDisposable = nil
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func handle(event: E) { fatalError("handle(event:) has not been implemented!") }
    func handle(state: S) { } // default empty implementation
    func getToolbarFont() -> UIFont { .suplaSubtitleFont }
    
    func observeNotification(name: NSNotification.Name?, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func showInfoDialog(title: String, message: String) {
        let infoDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        infoDialog.addAction(UIAlertAction(title: Strings.General.close, style: .default))
        self.present(infoDialog, animated: true)
    }
    
    @objc func onViewAppeared() {
    }
    
    @objc func onViewDisappeared() {
    }
    
#if DEBUG
    deinit {
        let className = NSStringFromClass(type(of: self))
        SALog.debug("[DEINIT] VC:\(className)")
    }
#endif
}

extension Disposable {
    func disposed<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>>(by vc: BaseViewControllerVM<S, E, VM>) {
        self.disposed(by: vc.disposeBag)
    }
}
