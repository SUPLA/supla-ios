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
    
    func observe(_ viewModel: BaseViewModel<S, E>) {
        viewModel.eventsObervable().subscribe(eventObserver).disposed(by: disposeBag)
        viewModel.stateObservable().subscribe(stateObserver).disposed(by: disposeBag)
    }
}
