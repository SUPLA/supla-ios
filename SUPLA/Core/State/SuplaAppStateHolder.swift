//
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

protocol SuplaAppStateHolder {
    func state() -> Observable<SuplaAppState>
    func currentState() -> SuplaAppState?
    func handle(event: SuplaAppEvent)
}

final class SuplaAppStateHolderImpl: SuplaAppStateHolder {
    @Singleton<SuplaSchedulers> private var schedulers

    private let stateSubject: BehaviorSubject<SuplaAppState> = .init(value: .initialization)

    init() {
        _ = stateSubject
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .subscribe(
                onNext: {
                    SALog.info("Supla client state: \($0)")

                    switch ($0) {
                    // The connecting state may result as a change from many different states
                    // and we want that in this state always SuplaClient tries to connect
                    // that's why this initialization is added here.
                    case .connecting: SAApp.suplaClient()
                    default: break
                    }
                }
            )
    }

    func state() -> Observable<SuplaAppState> { stateSubject.asObservable() }
    
    func currentState() -> SuplaAppState? { try? stateSubject.value() }

    func handle(event: SuplaAppEvent) {
        synced(self) {
            let state = try? stateSubject.value()
            if let nextState = state?.nextState(event: event) {
                SALog.info("Got event: \(event) -> state: \(nextState)")
                stateSubject.on(.next(nextState))
            } else {
                SALog.info("Got event: \(event)")
            }
        }
    }
}

@objc
final class SuplaAppStateHolderProxy: NSObject {
    @objc
    static func versionError() {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .error(reason: .versionError))
    }

    @objc
    static func connecting() {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .connecting)
    }
    
    @objc
    static func addWizardFinished() {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .addWizardFinished)
    }

    @objc
    static func connectionError(code: Int32) {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .error(reason: .connectionError(code: code)))
    }

    @objc
    static func connected() {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .connected)
    }

    @objc
    static func registerError(code: Int32) {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .error(reason: .registerError(code: code)))
    }

    @objc
    static func cancel() {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .cancel())
    }

    @objc
    static func finish() {
        @Singleton<SuplaAppStateHolder> var stateHolder
        stateHolder.handle(event: .finish())
    }
}
