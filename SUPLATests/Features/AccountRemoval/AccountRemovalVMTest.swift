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
        sut = AccountRemovalVM()
    }
    
    override func tearDown() {
        sut = nil
        scheduler = nil
    }
    
    func testIfFinishIsEmittedForProperUrl() {
        // given
        let observer = scheduler.createObserver(AccountRemovalViewEvent.self)
        sut.eventsObervable().subscribe(observer).disposed(by: disposeBag)
        
        // when
        sut.handleUrl(url: "https://cloud.supla.org/db99845855b2ecbfecca9a095062b96c3e27703f?ack=true")
        
        // then
        
        XCTAssertEqual(observer.events, [.next(0, .finish)])
    }
    
    func testIfNothingIsEmmittedForOtherUrls() {
        // given
        let observer = scheduler.createObserver(AccountRemovalViewEvent.self)
        sut.eventsObervable().subscribe(observer).disposed(by: disposeBag)
        
        // when
        sut.handleUrl(url: "https://cloud.supla.org/home")
        sut.handleUrl(url: "https://googl.com")
        
        // then
        
        XCTAssertEqual(observer.events, [])
    }
}
