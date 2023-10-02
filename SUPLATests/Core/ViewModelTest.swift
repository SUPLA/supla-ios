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

class ViewModelTest<S : ViewState, E : ViewEvent>: XCTestCase {
    lazy var scheduler: TestScheduler! = { TestScheduler(initialClock: 0) }()
    lazy var stateObserver: TestableObserver<S>! = {
        scheduler.createObserver(S.self)
    }()
    lazy var eventObserver: TestableObserver<E>! = {
        scheduler.createObserver(E.self)
    }()
    lazy var disposeBag: DisposeBag! = { DisposeBag() }()
    
    override func tearDown() {
        scheduler = nil
        stateObserver = nil
        eventObserver = nil
        disposeBag = nil
    }
    
    func observe(_ viewModel: BaseViewModel<S, E>, expectationHandler: ((Any) -> Void)? = nil) {
        viewModel
            .eventsObervable()
            .do(onNext: { if let handler = expectationHandler { handler($0) } })
            .subscribe(eventObserver)
            .disposed(by: disposeBag)
                
        viewModel
                .stateObservable()
                .do(onNext: { if let handler = expectationHandler { handler($0) } })
                .subscribe(stateObserver)
                .disposed(by: disposeBag)
    }
    
    func assertStates(expected: [S]) {
        let states = stateObserver.events.map { $0.value.element }
        XCTAssertEqual(states, expected)
    }
    
    func assertState<T: Equatable>(_ id: Int, withPath path: KeyPath<S, T>, equalTo value: T) {
        XCTAssertEqual(stateObserver.events[id].value.element?[keyPath: path], value)
    }
    
    func assertState(_ id: Int, _ assertion: (S) -> Void) {
        assertion(stateObserver.events[id].value.element!)
    }
    
    func assertEvents(expected: [E]) {
        let states = eventObserver.events.map { $0.value.element }
        XCTAssertEqual(states, expected)
    }
    
    func assertEvent(_ id: Int, equalTo value: E) {
        XCTAssertEqual(eventObserver.events[id].value.element, value)
    }
    
    func assertObserverItems(statesCount: Int, eventsCount: Int) {
        XCTAssertEqual(eventObserver.events.count, eventsCount)
        XCTAssertEqual(stateObserver.events.count, statesCount)
    }
}
