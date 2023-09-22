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

extension ObservableType {
    func asDriverWithoutError() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
}

extension Single {
    func asDriverWithoutError() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
}

extension Observable {
    func subscribeSynchronous() throws -> Element? {
        let subscriber = SynchronousSubscriber(observable: self)
        return try subscriber.subscribeAndWait()
    }
    
    func modify(_ modifier: @escaping (Element) -> Void) -> Observable<Element> {
        map { element in
            modifier(element)
            return element
        }
    }
}

final class SynchronousSubscriber<T> {
    
    let semaphore = DispatchSemaphore(value: 0)
    weak var observable: Observable<T>?
    let disposeBag = DisposeBag()
    
    var value: T? = nil
    var error: Swift.Error? = nil
    
    init(observable: Observable<T>) {
        self.observable = observable
    }
    
    func subscribeAndWait() throws -> T? {
        observable?.subscribe(
            onNext: { value in self.value = value },
            onError: { error in
                self.error = error
                self.semaphore.signal()
            },
            onCompleted: { self.semaphore.signal() }
        )
        .disposed(by: disposeBag)
        
        semaphore.wait()
        
        if (error != nil) {
            throw error!
        }
        
        return value
    }
}
