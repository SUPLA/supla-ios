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

final class LockScreenSettingsTests: XCTestCase {
    
    func test_shouldConvertToStringAndBack() {
        // given
        let settings = LockScreenSettings(scope: .application, pinSum: "sum", biometricAllowed: true, failsCount: 15, lockTime: 20)
        
        // when
        let settingsString = settings.asString()
        let result = LockScreenSettings.from(string: settingsString)
        
        // then
        XCTAssertEqual(result, settings)
        XCTAssertTrue(result.pinForAppRequired)
    }
    
    func test_shouldConvertToStringAndBack_withNils() {
        // given
        let settings = LockScreenSettings(scope: .application, pinSum: nil, biometricAllowed: true)
        
        // when
        let settingsString = settings.asString()
        let result = LockScreenSettings.from(string: settingsString)
        
        // then
        XCTAssertEqual(result, settings)
        XCTAssertFalse(result.pinForAppRequired)
    }
    
    func test_shouldGetDefaultSettings_whenCouldNotParse() {
        XCTAssertEqual(LockScreenSettings.from(string: nil), LockScreenSettings.DEFAULT)
        XCTAssertEqual(LockScreenSettings.from(string: "0:3"), LockScreenSettings.DEFAULT)
    }
}
