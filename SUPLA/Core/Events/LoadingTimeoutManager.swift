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

fileprivate let TIMEOUT_S: Double = 5

protocol LoadingTimeoutManager {
    func watch(stateProvider: @escaping () -> LoadingState?, onTimeout: @escaping () -> Void) -> Disposable
}

struct LoadingState: Equatable {
    var initialLoading: Bool = true
    var loading: Bool = true
    var lastLoadingStartTimestamp: TimeInterval? = nil
    
    func copy(loading: Bool) -> LoadingState {
        @Singleton<DateProvider> var dateProvider
        
        var copy = self
        copy.initialLoading = false
        copy.loading = loading
        copy.lastLoadingStartTimestamp = loading ? dateProvider.currentTimestamp() : nil
        return copy
    }
}

final class LoadingTimeoutManagerImpl: LoadingTimeoutManager {
    
    @Singleton<DateProvider> private var dateProvider
    
    private let timeoutWatcher = Observable<Int>.interval(.milliseconds(100), scheduler: SerialDispatchQueueScheduler(qos: .background))
        .observe(on: MainScheduler.instance)
    
    func watch(stateProvider: @escaping () -> LoadingState?, onTimeout: @escaping () -> Void) -> Disposable {
        return timeoutWatcher.subscribe(onNext: { _ in
            guard let state = stateProvider() else { return }
            
            if (state.initialLoading) {
                return
            }
            if (!state.loading) {
                return
            }
            
            if let startTime = state.lastLoadingStartTimestamp {
                if (self.dateProvider.currentTimestamp() > startTime + TIMEOUT_S) {
                    onTimeout()
                }
            }
        })
    }
}
