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

fileprivate let DELAYED_COMMAND_DELAY_S = RxTimeInterval.seconds(2)

class DelayedCommandSubject<T: DelayableData> {
    
    private let delayedRequestSubject = PublishSubject<T>()
    private let disposeBag = DisposeBag()
    
    init() {
        delayedRequestSubject
            .debounce(DELAYED_COMMAND_DELAY_S, scheduler: ConcurrentDispatchQueueScheduler.init(queue: .global()))
            .flatMap {
                if (!$0.sent) {
                    return self.execute(data: $0)
                } else {
                    return Observable.just(RequestResult.success)
                }
            }
            .subscribe(onError: { SALog.error("Could not execute delayed request \($0)")})
            .disposed(by: disposeBag)
    }
    
    func emit(data: T) {
        delayedRequestSubject.on(.next(data))
    }
    
    func sendImmediately(data: T) -> Observable<RequestResult> {
        let sendState = data.sentState() as! T
        delayedRequestSubject.on(.next(sendState))
        
        return execute(data: sendState)
    }
    
    func execute(data: T) -> Observable<RequestResult> {
        return Observable.just(.failure)
    }
}

protocol DelayableData {
    var sent: Bool { get }
    func sentState() -> DelayableData
}
