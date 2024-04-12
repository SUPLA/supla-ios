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
import CoreData

@testable import SUPLA

class AccountRemovalVMTest: XCTestCase {
    
    private var scheduler: TestScheduler!
    private var sut: AccountRemovalVM!
    
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        sut = nil
        scheduler = nil
    }
    
    func testIfFinishIsEmittedForProperUrl() {
        sut = AccountRemovalVM(needsRestart: false)
        
        // given
        let observer = scheduler.createObserver(AccountRemovalViewEvent.self)
        sut.eventsObervable().subscribe(observer).disposed(by: disposeBag)
        
        // when
        _ = sut.shouldHandle(url: "https://cloud.supla.org/db99845855b2ecbfecca9a095062b96c3e27703f?ack=true")
        
        // then
        
        XCTAssertEqual(observer.events, [.next(0, .finish)])
    }
    
    func testIfFinishWithRestartIsEmittedForProperUrl() {
        sut = AccountRemovalVM(needsRestart: true)
        
        // given
        let observer = scheduler.createObserver(AccountRemovalViewEvent.self)
        sut.eventsObervable().subscribe(observer).disposed(by: disposeBag)
        
        // when
        _ = sut.shouldHandle(url: "https://cloud.supla.org/db99845855b2ecbfecca9a095062b96c3e27703f?ack=true")
        
        // then
        
        XCTAssertEqual(observer.events, [.next(0, .finishAndRestart)])
    }
    
    func testIfNothingIsEmmittedForOtherUrls() {
        sut = AccountRemovalVM(needsRestart: false)
        
        // given
        let observer = scheduler.createObserver(AccountRemovalViewEvent.self)
        sut.eventsObervable().subscribe(observer).disposed(by: disposeBag)
        
        // when
        _ = sut.shouldHandle(url: "https://cloud.supla.org/home")
        _ = sut.shouldHandle(url: "https://googl.com")
        
        // then
        
        XCTAssertEqual(observer.events, [])
    }
    
    func test_shouldUseAddressToBuildUrl() {
        // given
        sut = AccountRemovalVM(needsRestart: false, serverAddress: "beta-cloud.supla.org")
        
        // when
        let url = sut.provideUrl()
        
        // then
        XCTAssertTrue(url.absoluteString.starts(with: "https://beta-cloud.supla.org/db99845855b2ecbfecca9a095062b96c3e27703f"))
    }
    
    func test_shouldUseSuplaWhenNoAddressProvided() {
        // given
        sut = AccountRemovalVM(needsRestart: false)
        
        // when
        let url = sut.provideUrl()
        
        // then
        XCTAssertTrue(url.absoluteString.starts(with: "https://cloud.supla.org/db99845855b2ecbfecca9a095062b96c3e27703f"))
    }
}
