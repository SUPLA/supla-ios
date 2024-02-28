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

import XCTest
import RxTest
import RxSwift

@testable import SUPLA

class ObservableTestCase: XCTestCase {
    
    lazy var schedulers: SuplaSchedulersMock! = {
        SuplaSchedulersMock()
    }()
    
    lazy var disposeBag: DisposeBag! = { DisposeBag() }()
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaSchedulers.self, schedulers!)
    }
    
    override func tearDown() {
        schedulers = nil
        disposeBag = nil
    }
    
    func assertEvents<T>(_ observer: TestableObserver<T>, count: Int) {
        XCTAssertEqual(observer.events.count, count)
    }
    
    func assertEvents<T>(_ observer: TestableObserver<T>, items: [Event<T>]) {
        let events = observer.events
        XCTAssertEqual(events.count, items.count)
        
        for (event, item) in zip(events, items) {
            switch (event.value, item) {
            case (.error(let e1), .error(let e2)):
                XCTAssertEqual("\(e1)", "\(e2)")
                break
            case (.next, .next), (.completed, .completed):
                break
            default:
                XCTFail("Events not equal (\(event), \(item))")
            }
        }
    }
    
    func observer<T>() -> TestableObserver<T> {
        schedulers.testScheduler.createObserver(T.self)
    }

    func startScheduler() {
        schedulers.testScheduler.start()
    }
}
