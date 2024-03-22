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

@testable import SUPLA
import XCTest

final class RollerShutterValueTests: XCTestCase {
    func test_parseWhenSizeWrong() {
        // when
        let value = RollerShutterValue.from(Data(), online: false)
        
        // then
        XCTAssertEqual(value.online, false)
        XCTAssertEqual(value.position, RollerShutterValue.invalidPosition)
        XCTAssertEqual(value.bottomPosition, 0)
        XCTAssertEqual(value.flags, [])
        XCTAssertEqual(value.hasValidPosition, false)
    }
    
    func test_parseWhenSizeCorrect() {
        // given
        let data = mockData(position: 22, bottomPosition: 88)
        
        // when
        let value = RollerShutterValue.from(data, online: true)
        
        // then
        XCTAssertEqual(value.online, true)
        XCTAssertEqual(value.position, 22)
        XCTAssertEqual(value.bottomPosition, 88)
        XCTAssertEqual(value.flags, [])
        XCTAssertEqual(value.hasValidPosition, true)
    }
    
    func test_parseWhenSizeCorrect_invalidPosition() {
        // given
        let data = mockData(position: 120, bottomPosition: 88, flags: 4)
        
        // when
        let value = RollerShutterValue.from(data, online: true)
        
        // then
        XCTAssertEqual(value.online, true)
        XCTAssertEqual(value.position, -1)
        XCTAssertEqual(value.bottomPosition, 88)
        XCTAssertEqual(value.flags, [.calibrationLost])
        XCTAssertEqual(value.hasValidPosition, false)
    }
    
    private func mockData(position: Int, bottomPosition: Int, flags: Int16 = 0) -> Data {
        var cValue = TDSC_RollerShutterValue(
            position: Int8(position),
            reserved1: 0,
            bottom_position: Int8(bottomPosition),
            flags: flags,
            reserved2: 0,
            reserved3: 0,
            reserved4: 0
        )
        return Data(bytes: &cValue, count: MemoryLayout<TDSC_RollerShutterValue>.size)
    }
}
