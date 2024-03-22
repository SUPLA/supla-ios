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
import RxSwift

@testable import SUPLA

class CompletableTestCase: XCTestCase {
    lazy var schedulers: SuplaSchedulersMock! = SuplaSchedulersMock()

    lazy var disposeBag: DisposeBag! = DisposeBag()
    
    lazy var observer: (CompletableEvent) -> Void = { [weak self] in self?.events.append($0) }
    
    private var events: [CompletableEvent] = []
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaSchedulers.self, schedulers!)
    }

    override func tearDown() {
        schedulers = nil
        disposeBag = nil
        events.removeAll()
    }
    
    func assertEvents(count: Int) {
        XCTAssertEqual(events.count, count)
    }
    
    func assertEvents(contains expected: [CompletableEvent]) {
        for (event, item) in zip(events, expected) {
            switch (event, item) {
            case (.error(let found), .error(let expected)):
                XCTAssertEqual(found.localizedDescription, expected.localizedDescription)
            case (.completed, .completed):
                XCTAssertTrue(true)
            default:
                XCTFail("Events not equal (\(event), \(item))")
            }
        }
    }
}
