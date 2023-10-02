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

class ValuesFormatterTests: XCTestCase {
    
    private lazy var formatter: ValuesFormatter! = {
        ValuesFormatterImpl()
    }()
    
    private lazy var globalSettings: GlobalSettingsMock! = {
        GlobalSettingsMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, component: globalSettings!)
    }
    
    override func tearDown() {
        globalSettings = nil
        formatter = nil
    }
    
    func test_shouldReturnNoValueWhenValueIsNull() {
        // when
        let result = formatter.temperatureToString(nil)
        
        // then
        XCTAssertEqual(result, "---")
    }
    
    func test_shouldFormatCelsius() {
        // given
        (formatter as! ValuesFormatterImpl).decimalSeparator = ","
        
        // when
        let result = formatter.temperatureToString(15.5324, withUnit: false, withDegree: false)
        
        // then
        XCTAssertEqual(result, "15,5")
    }
    
    func test_shouldFormatCelsiusWithDegree() {
        // given
        (formatter as! ValuesFormatterImpl).decimalSeparator = ","
        
        // when
        let result = formatter.temperatureToString(15.5324, withUnit: false, withDegree: true)
        
        // then
        XCTAssertEqual(result, "15,5°")
    }
    
    func test_shouldFormatCelsiusWithDegreeAndUnit() {
        // given
        (formatter as! ValuesFormatterImpl).decimalSeparator = ","
        
        // when
        let result = formatter.temperatureToString(15.5324, withUnit: true, withDegree: true)
        
        // then
        XCTAssertEqual(result, "15,5 °C")
    }
    
    func test_shouldFormatFahrenheit() {
        // given
        globalSettings.temperatureUnitReturns = .fahrenheit
        (formatter as! ValuesFormatterImpl).decimalSeparator = ","
        
        // when
        let result = formatter.temperatureToString(22.332, withUnit: false, withDegree: false)
        
        // then
        XCTAssertEqual(result, "72,2")
    }
    
    func test_shouldFormatFahrenheitWithDegree() {
        // given
        globalSettings.temperatureUnitReturns = .fahrenheit
        (formatter as! ValuesFormatterImpl).decimalSeparator = ","
        
        // when
        let result = formatter.temperatureToString(22.332, withUnit: false, withDegree: true)
        
        // then
        XCTAssertEqual(result, "72,2°")
    }
    
    func test_shouldFormatFahrenheitWithDegreeAndUnit() {
        // given
        globalSettings.temperatureUnitReturns = .fahrenheit
        (formatter as! ValuesFormatterImpl).decimalSeparator = ","
        
        // when
        let result = formatter.temperatureToString(22.332, withUnit: true, withDegree: true)
        
        // then
        XCTAssertEqual(result, "72,2 °F")
    }
    
    func test_shouldFormatMinutesToString() {
        // given
        let minutes = 18
        
        // when
        let string = formatter.minutesToString(minutes: minutes)
        
        // then
        XCTAssertEqual(string, Strings.General.time_just_minutes.arguments(minutes))
    }
    
    func test_shouldFormatMinutesWithHoursToString() {
        // given
        let minutes = 96
        
        // when
        let string = formatter.minutesToString(minutes: minutes)
        
        // then
        XCTAssertEqual(string, Strings.General.time_hours_and_mintes.arguments(1, 36))
    }
}
