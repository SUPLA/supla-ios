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

final class SuplaWeeklyScheduleProgramTests: XCTestCase {
    private lazy var valuesFormatter: ValuesFormatterMock! = {
        ValuesFormatterMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: ValuesFormatter.self, valuesFormatter!)
    }
    
    override func tearDown() {
        valuesFormatter = nil
    }
    
    func test_shouldGetDescription_whenProgramIsOff() {
        // given
        let program = SuplaWeeklyScheduleProgram(program: .off, mode: .off, setpointTemperatureHeat: nil, setpointTemperatureCool: nil)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, Strings.General.turnOff)
    }
    
    func test_shouldGetDescription_whenModeIsHeat() {
        // given
        let program = SuplaWeeklyScheduleProgram(program: .program1, mode: .heat, setpointTemperatureHeat: 1200, setpointTemperatureCool: nil)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, "12.0")
    }
    
    func test_shouldGetDescription_whenModeIsCool() {
        // given
        let program = SuplaWeeklyScheduleProgram(program: .program1, mode: .cool, setpointTemperatureHeat: nil, setpointTemperatureCool: 2300)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, "23.0")
    }
    
    func test_shouldGetDescription_whenModeIsAuto() {
        // given
        let program = SuplaWeeklyScheduleProgram(program: .program1, mode: .heatCool, setpointTemperatureHeat: 1800, setpointTemperatureCool: 2100)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, "18.0 - 21.0")
    }
    
    func test_shouldGetDescriptionNoValue_whenModeIsDry() {
        // given
        let program = SuplaWeeklyScheduleProgram(program: .program1, mode: .dry, setpointTemperatureHeat: 1800, setpointTemperatureCool: 2100)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, NO_VALUE_TEXT)
    }
}
