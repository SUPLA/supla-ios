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
import SharedCore

final class RollerShutterValueTests: XCTestCase {
    func test_parseWhenSizeWrong() {
        // when
        let value = RollerShutterValue.companion.from(online: false, bytes: KotlinByteArray.from(data: Data()))
        
        // then
        XCTAssertEqual(value.online, false)
        XCTAssertEqual(value.position, ShadingSystemValue.companion.INVALID_VALUE)
        XCTAssertEqual(value.bottomPosition, 0)
        XCTAssertEqual(value.flags, [])
        XCTAssertEqual(value.hasValidPosition(), false)
    }
    
    func test_parseWhenSizeCorrect() {
        // given
        let data = RollerShutterValue.mockData(position: 22, bottomPosition: 88)
        
        // when
        let value = RollerShutterValue.companion.from(online: true, bytes: KotlinByteArray.from(data: data))
        
        // then
        XCTAssertEqual(value.online, true)
        XCTAssertEqual(value.position, 22)
        XCTAssertEqual(value.bottomPosition, 88)
        XCTAssertEqual(value.flags, [])
        XCTAssertEqual(value.hasValidPosition(), true)
    }
    
    func test_parseWhenSizeCorrect_invalidPosition() {
        // given
        let data = RollerShutterValue.mockData(position: 120, bottomPosition: 88, flags: 4)
        
        // when
        let value = RollerShutterValue.companion.from(online: true, bytes: KotlinByteArray.from(data: data))
        
        // then
        XCTAssertEqual(value.online, true)
        XCTAssertEqual(value.position, -1)
        XCTAssertEqual(value.bottomPosition, 88)
        XCTAssertEqual(value.flags, [.calibrationLost])
        XCTAssertEqual(value.hasValidPosition(), false)
    }
}
