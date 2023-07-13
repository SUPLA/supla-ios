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

class UseCaseTest<R>: XCTestCase {
    
    lazy var scheduler: TestScheduler! = { TestScheduler(initialClock: 0) }()
    lazy var disposeBag: DisposeBag! = { DisposeBag() }()
    
    lazy var observer: TestableObserver<R>! = {
        scheduler.createObserver(R.self)
    }()
    
    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        observer = nil
    }
    
    func assertTuple<T1: Equatable, T2:Equatable>(_ tuples: [(T1, T2)], equalTo others: [(T1, T2)]) {
        XCTAssertEqual(tuples.count, others.count)
        
        for i in 0...(tuples.count-1) {
            XCTAssertEqual(tuples[i].0, others[i].0)
            XCTAssertEqual(tuples[i].1, others[i].1)
        }
    }
    
    func assertTuple<T1: Equatable, T2:Equatable, T3:Equatable>(_ tuples: [(T1, T2, T3)], equalTo others: [(T1, T2, T3)]) {
        XCTAssertEqual(tuples.count, others.count)
        
        if (tuples.count > 0) {
            for i in 0...(tuples.count-1) {
                XCTAssertEqual(tuples[i].0, others[i].0)
                XCTAssertEqual(tuples[i].1, others[i].1)
                XCTAssertEqual(tuples[i].2, others[i].2)
            }
        }
    }
    
    func assertTuple<T1: Equatable, T2:Equatable, T3:Equatable, T4:Equatable, T5:Equatable>(_ tuples: [(T1, T2, T3, T4, T5)], equalTo others: [(T1, T2, T3, T4, T5)]) {
        XCTAssertEqual(tuples.count, others.count)
        
        for i in 0...(tuples.count-1) {
            XCTAssertEqual(tuples[i].0, others[i].0)
            XCTAssertEqual(tuples[i].1, others[i].1)
            XCTAssertEqual(tuples[i].2, others[i].2)
            XCTAssertEqual(tuples[i].3, others[i].3)
            XCTAssertEqual(tuples[i].4, others[i].4)
        }
    }
    
    func assertVoid(_ events: [Recorded<Event<Void>>], equalTo items: [Event<Void>]) {
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
}
