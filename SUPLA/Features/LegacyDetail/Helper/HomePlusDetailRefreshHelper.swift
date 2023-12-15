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
import RxRelay

@objc
class HomePlusDetailRefreshHelper: NSObject {
    
    @Singleton<SuplaSchedulers> private var schedulers
    
    private let refreshRelay = BehaviorRelay<HomePlusRefreshEvent>(value: .empty())
    private var disposable: Disposable? = nil
    
    @objc
    func emit() {
        refreshRelay.accept(HomePlusRefreshEvent())
    }
    
    @objc
    func observe(observer: @escaping (HomePlusRefreshEvent) -> Void) {
        dispose()
        disposable = Observable<Int>.interval(.seconds(3), scheduler: schedulers.background)
            .map { [weak self] _ in self?.refreshRelay.value ?? HomePlusRefreshEvent.empty() }
            .filter { !$0.isProcessed() }
            .observe(on: schedulers.main)
            .subscribe(
                onNext: observer
            )
    }
    
    @objc
    func dispose() {
        if let disposable = disposable {
            disposable.dispose()
        }
        disposable = nil
    }
    
}

@objc
class HomePlusRefreshEvent: NSObject {
    
    private var processed = false
    
    @objc
    func isProcessed() -> Bool { processed }
    
    @objc
    func setProcessed() {
        processed = true
    }
    
    fileprivate static func empty() -> HomePlusRefreshEvent {
        let event = HomePlusRefreshEvent()
        event.setProcessed()
        return event
    }
}
