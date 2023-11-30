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
import RxCocoa

class BaseViewModel<S : ViewState, E : ViewEvent> {
    
    fileprivate let disposeBag = DisposeBag()
    private let events = PublishSubject<E>()
    private lazy var state: BehaviorSubject<S> = {
        BehaviorSubject(value: defaultViewState())
    }()
    
    func defaultViewState() -> S { fatalError("defaultViewState() has not been implemented!") }
    
    func onViewDidLoad() {}
    
    func eventsObervable() -> Observable<E> { events.asObserver() }
    func stateObservable() -> Observable<S> { state.asObserver() }
    
    func send(event: E) { events.on(.next(event)) }
    func updateView(state: S) { self.state.on(.next(state)) }
    func updateView(_ stateModifier: (S) -> S) { try! state.on(.next(stateModifier(state.value()))) }
    
    func currentState() -> S? {
        do {
            return try state.value()
        } catch {
            return nil
        }
    }
    
    func bind<T>(field path: WritableKeyPath<S, T>, toObservable observable: Observable<T>) {
        observable
            .subscribe(onNext: { [weak self] value in
                self?.updateView() { state in return state.changing(path: path, to: value) }
            })
            .disposed(by: disposeBag)
    }
    
    func bindWhenInitialized<T>(field path: WritableKeyPath<S, T?>, toObservable observable: Observable<T>) {
        observable
            .subscribe(onNext: { [weak self] value in
                self?.updateView() { state in
                    if (state.value(path: path) == nil) {
                        return state
                    }
                    return state.changing(path: path, to: value)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bind<T>(field path: WritableKeyPath<S, T>, toOptional observable: Observable<T?>) {
        observable
            .subscribe(onNext: { [weak self] value in
                guard let value = value else { return }
                self?.updateView() { state in return state.changing(path: path, to: value) }
            })
            .disposed(by: disposeBag)
    }
    
    func bind(_ observable: Observable<Void>, _ action: @escaping () -> Void) {
        observable
            .subscribe(onNext: {
                action()
            })
            .disposed(by: disposeBag)
    }
    
    func bind<T>(_ observable: Observable<T>, _ action: @escaping (T) -> Void) {
        observable
            .subscribe(onNext: { value in
                action(value)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(_ observable: ControlEvent<Void>, _ action: @escaping () -> Void) {
        observable
            .subscribe(onNext: {
                action()
            })
            .disposed(by: disposeBag)
    }
    
#if DEBUG
    deinit {
        let className = NSStringFromClass(type(of: self))
        NSLog("[DEINIT] VM:\(className)")
    }
#endif
}

extension Disposable {
    func disposed<S, E>(by viewModel: BaseViewModel<S, E>) {
        disposed(by: viewModel.disposeBag)
    }
}
