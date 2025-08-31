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

enum DriverResult<T> {
    case success(value: T)
    case error(error: Error)
}

extension ObservableType {
    func asDriverWithoutError() -> Driver<Element> {
        return asDriver { error in
            SALog.error("Driver got error: \(error.localizedDescription)")
            SALog.error(String(describing: error))
            
            return Driver.empty()
        }
    }
    
    func asDriver() -> Driver<DriverResult<Element>> {
        map { DriverResult.success(value: $0) }
            .asDriver { Driver.just(DriverResult.error(error: $0))}
    }
}

extension Single {
    func asDriverWithoutError() -> Driver<Element> {
        return asDriver { error in
            SALog.error("Driver got error: \(error.localizedDescription)")
            SALog.error(String(describing: error))
            
            return Driver.empty()
        }
    }
}

extension Observable {
    func subscribeAwait() async throws -> Element? {
        try? await withUnsafeThrowingContinuation { continuation in
            _ = subscribe(
                onNext: { continuation.resume(returning: $0) },
                onError: { continuation.resume(throwing: $0) }
            )
        }
    }
    func subscribeSynchronous() throws -> Element? {
        let subscriber = SynchronousSubscriber(observable: self)
        return try subscriber.subscribeAndWait()
    }
    
    func subscribeSynchronous(defaultValue: Element) -> Element {
        let subscriber = SynchronousSubscriber(observable: self)
        
        do {
            return try subscriber.subscribeAndWait() ?? defaultValue
        } catch {
            return defaultValue
        }
    }
    
    func modify(_ modifier: @escaping (Element) -> Void) -> Observable<Element> {
        map { element in
            modifier(element)
            return element
        }
    }
    
    func flatMapCompletable(_ selector: @escaping (Element) throws -> Completable) -> Completable {
        flatMap {
            try selector($0).asObservable()
        }
        .asCompletable()
    }
}

final class SynchronousSubscriber<T> {
    let semaphore = DispatchSemaphore(value: 0)
    weak var observable: Observable<T>?
    let disposeBag = DisposeBag()
    
    var value: T?
    var error: Swift.Error?
    
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
