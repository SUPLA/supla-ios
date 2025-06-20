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
import RxCocoa
import RxSwift

protocol BaseViewModelBinder {
    var disposeBag: DisposeBag { get }
}

extension BaseViewModelBinder {
    func bind(_ observable: Observable<Void>, _ action: @escaping () -> Void) {
        observable
            .subscribe(
                onNext: { action() },
                onError: { SALog.error("Binding void observable failed with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    func bind(_ single: Single<Void>, _ action: @escaping () -> Void) {
        single
            .subscribe(
                onSuccess: { action() },
                onFailure: { SALog.error("Binding singe failed with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    func bind<T>(_ observable: Observable<T>, _ action: @escaping (T) -> Void) {
        observable
            .subscribe(
                onNext: { action($0) },
                onError: { SALog.error("Binding typed observable failed with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    func bind(_ observable: ControlEvent<Void>, _ action: @escaping () -> Void) {
        observable
            .subscribe(
                onNext: { action() },
                onError: { SALog.error("Binding control event failed with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    func bind<T>(_ observable: ControlProperty<T>, _ action: @escaping (T) -> Void) {
        observable
            .subscribe(
                onNext: { action($0) },
                onError: { SALog.error("Binding control property failed with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
}

class BaseViewModel<S: ViewState, E: ViewEvent>: BaseViewModelBinder {
    let disposeBag = DisposeBag()
    
    private let events = PublishSubject<E>()
    lazy var state: BehaviorSubject<S> = BehaviorSubject(value: defaultViewState())
    
    func defaultViewState() -> S { fatalError("defaultViewState() has not been implemented!") }
    
    func onViewDidLoad() {}
    func onViewWillAppear() {}
    
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
            .subscribe(
                onNext: { [weak self] value in
                    self?.updateView() { state in state.changing(path: path, to: value) }
                },
                onError: { SALog.error("Binding field with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    func bindWhenInitialized<T>(field path: WritableKeyPath<S, T?>, toObservable observable: Observable<T>) {
        observable
            .subscribe(
                onNext: { [weak self] value in
                    self?.updateView() { state in
                        if (state.value(path: path) == nil) {
                            return state
                        }
                        return state.changing(path: path, to: value)
                    }
                },
                onError: { SALog.error("Binding field when initialized failed with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    func bind<T>(field path: WritableKeyPath<S, T>, toOptional observable: Observable<T?>) {
        observable
            .subscribe(
                onNext: { [weak self] value in
                    guard let value = value else { return }
                    self?.updateView() { state in state.changing(path: path, to: value) }
                },
                onError: { SALog.error("Binding optional field failed with error: \(String(describing: $0))") }
            )
            .disposed(by: disposeBag)
    }
    
    func handle(_ disposable: Disposable) {
        disposeBag.insert(disposable)
    }
    
    #if DEBUG
        deinit {
            let className = NSStringFromClass(type(of: self))
            SALog.debug("[DEINIT] VM:\(className)")
        }
    #endif
}

extension Disposable {
    func disposed<S, E>(by viewModel: BaseViewModel<S, E>) {
        disposed(by: viewModel.disposeBag)
    }
}
