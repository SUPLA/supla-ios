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

final class FacadeBlindValueTests: XCTestCase {
    func test_parseWhenSizeWrong() {
        // when
        let value = FacadeBlindValue.from(Data(), online: false)
        
        // then
        XCTAssertEqual(value.online, false)
        XCTAssertEqual(value.position, SHADING_SYSTEM_INVALID_VALUE)
        XCTAssertEqual(value.tilt, SHADING_SYSTEM_INVALID_VALUE)
        XCTAssertEqual(value.flags, [])
        XCTAssertEqual(value.hasValidPosition, false)
    }
    
    func test_parseWhenSizeCorrect() {
        // given
        let data = FacadeBlindValue.mockData(position: 22, tilt: 88)
        
        // when
        let value = FacadeBlindValue.from(data, online: true)
        
        // then
        XCTAssertEqual(value.online, true)
        XCTAssertEqual(value.position, 22)
        XCTAssertEqual(value.tilt, 88)
        XCTAssertEqual(value.flags, [])
        XCTAssertEqual(value.hasValidPosition, true)
    }
    
    func test_parseWhenSizeCorrect_invalidPositionAndTilt() {
        // given
        let data = FacadeBlindValue.mockData(position: 120, tilt: 110, flags: 4)
        
        // when
        let value = FacadeBlindValue.from(data, online: true)
        
        // then
        XCTAssertEqual(value.online, true)
        XCTAssertEqual(value.position, -1)
        XCTAssertEqual(value.tilt, -1)
        XCTAssertEqual(value.flags, [.calibrationLost])
        XCTAssertEqual(value.hasValidPosition, false)
    }
}
