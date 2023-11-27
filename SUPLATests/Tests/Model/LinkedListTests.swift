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
@testable import SUPLA

final class LinkedListTests: XCTestCase {
    
    func test_listIsEmpty() {
        // given
        let list = LinkedList<Int>()
        
        // when
        let empty = list.isEmpty
        
        // then
        XCTAssertTrue(empty)
        XCTAssertEqual(list.avg(extractor: { _ in Double(1) }), 0)
        XCTAssertEqual(list.min(extractor: { _ in Double(1) }), nil)
        XCTAssertEqual(list.max(extractor: { _ in Double(1) }), nil)
    }
    
    func test_listNotEmpty() {
        // given
        let list = LinkedList<Int>()
        list.append(1)
        
        // when
        let empty = list.isEmpty
        
        // then
        XCTAssertFalse(empty)
    }
    
    func test_shouldGetAvg() {
        // given
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        list.append(4)
        list.append(5)
        
        // when
        let avg = list.avg(extractor: { Double($0) })
        
        // then
        XCTAssertEqual(avg, 3)
    }
    
    func test_shouldGetMin() {
        // given
        let list = LinkedList<Int>()
        list.append(7)
        list.append(3)
        list.append(6)
        list.append(4)
        list.append(5)
        
        // when
        let avg = list.min(extractor: { Double($0) })
        
        // then
        XCTAssertEqual(avg, 3)
    }
    
    func test_shouldGetMax() {
        // given
        let list = LinkedList<Int>()
        list.append(3)
        list.append(7)
        list.append(6)
        list.append(4)
        list.append(5)
        
        // when
        let avg = list.max(extractor: { Double($0) })
        
        // then
        XCTAssertEqual(avg, 7)
    }
}
