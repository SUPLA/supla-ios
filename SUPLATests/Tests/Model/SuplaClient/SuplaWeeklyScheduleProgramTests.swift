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

@available(iOS 17.0, *)
final class SuplaWeeklyScheduleProgramTests: XCTestCase {
    private lazy var valuesFormatter: ValuesFormatterMock! = ValuesFormatterMock()
    private lazy var groupSharedSettingsMock: GroupShared.SettingsMock! = GroupShared.SettingsMock()
    
    override func setUp() {
        DiContainer.shared.register(type: ValuesFormatter.self, valuesFormatter!)
        DiContainer.shared.register(type: GroupShared.Settings.self, groupSharedSettingsMock!)
    }
    
    override func tearDown() {
        valuesFormatter = nil
        groupSharedSettingsMock = nil
    }
    
    func test_shouldGetDescription_whenProgramIsOff() {
        // given
        let program = SuplaHvacWeeklyScheduleProgram(program: .off, mode: .off, setpointTemperatureHeat: nil, setpointTemperatureCool: nil)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, Strings.General.turnOff)
    }
    
    func test_shouldGetDescription_whenModeIsHeat() {
        // given
        let program = SuplaHvacWeeklyScheduleProgram(program: .program1, mode: .heat, setpointTemperatureHeat: 1200, setpointTemperatureCool: nil)
        groupSharedSettingsMock.temperatureUnitMock.returns = .single(.celsius)
        groupSharedSettingsMock.temperaturePrecisionMock.returns = .single(1)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, decimalLocalized("12.0°"))
    }
    
    func test_shouldGetDescription_whenModeIsCool() {
        // given
        let program = SuplaHvacWeeklyScheduleProgram(program: .program1, mode: .cool, setpointTemperatureHeat: nil, setpointTemperatureCool: 2300)
        groupSharedSettingsMock.temperatureUnitMock.returns = .single(.celsius)
        groupSharedSettingsMock.temperaturePrecisionMock.returns = .single(1)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, decimalLocalized("23.0°"))
    }
    
    func test_shouldGetDescription_whenModeIsAuto() {
        // given
        let program = SuplaHvacWeeklyScheduleProgram(program: .program1, mode: .heatCool, setpointTemperatureHeat: 1800, setpointTemperatureCool: 2100)
        groupSharedSettingsMock.temperatureUnitMock.returns = .single(.celsius)
        groupSharedSettingsMock.temperaturePrecisionMock.returns = .single(1)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, decimalLocalized("18.0° - 21.0°"))
    }
    
    func test_shouldGetDescriptionNoValue_whenModeIsDry() {
        // given
        let program = SuplaHvacWeeklyScheduleProgram(program: .program1, mode: .dry, setpointTemperatureHeat: 1800, setpointTemperatureCool: 2100)
        groupSharedSettingsMock.temperatureUnitMock.returns = .single(.celsius)
        groupSharedSettingsMock.temperaturePrecisionMock.returns = .single(1)
        
        // when
        let result = program.description
        
        // then
        XCTAssertEqual(result, ValueFormatterKt.NO_VALUE_TEXT)
    }

    func test_actionTriggerProgramCopyAndDefault() {
        let program = SuplaButtonWeeklyScheduleProgram(program: .program2, mode: .locked, buttonTemporaryUnlockDurationS: 59)
        XCTAssertEqual(program.copy(mode: .lockedTemporaryUnlockAllowed, buttonTemporaryUnlockDurationS: 60),
                       SuplaButtonWeeklyScheduleProgram(program: .program2, mode: .lockedTemporaryUnlockAllowed, buttonTemporaryUnlockDurationS: 60))
        XCTAssertEqual(SuplaButtonWeeklyScheduleProgram.default(), SuplaButtonWeeklyScheduleProgram(program: .off, mode: .notSet, buttonTemporaryUnlockDurationS: 0))
    }

    func test_actionTriggerProgramDescriptionUsesClockForTemporaryUnlockMode() {
        func description(_ seconds: UInt16) -> String {
            SuplaButtonWeeklyScheduleProgram(program: .program1, mode: .lockedTemporaryUnlockAllowed, buttonTemporaryUnlockDurationS: seconds).description
        }
        XCTAssertEqual(description(0), "\(Strings.General.locked) ⏱️")
        XCTAssertEqual(description(5), "\(Strings.General.locked) ⏱️")
        XCTAssertEqual(description(59), "\(Strings.General.locked) ⏱️")
        XCTAssertEqual(description(60), "\(Strings.General.locked) ⏱️")
        XCTAssertEqual(description(3_599), "\(Strings.General.locked) ⏱️")
        XCTAssertEqual(description(3_600), "\(Strings.General.locked) ⏱️")
        XCTAssertEqual(description(64_800), "\(Strings.General.locked) ⏱️")
    }

    func test_temporaryUnlockDurationClampsAndKeepsOtherPickerUnits() {
        for value in [0, 59, 60, 3_599, 3_600, 64_800] {
            XCTAssertEqual(ActionTriggerTemporaryUnlockDuration.clamp(value), value)
        }
        XCTAssertEqual(ActionTriggerTemporaryUnlockDuration.clamp(70_000), 64_800)
        let duration = 3_723 // 1:02:03
        XCTAssertEqual(ActionTriggerTemporaryUnlockDuration.replacingSeconds(7, in: duration), 3_727) // 1:02:07
        XCTAssertEqual(ActionTriggerTemporaryUnlockDuration.replacingHours(18, in: duration), 64_800)
        XCTAssertEqual(ActionTriggerTemporaryUnlockDuration.minuteValues(for: 64_800), 0...0)
        XCTAssertEqual(ActionTriggerTemporaryUnlockDuration.secondValues(for: 64_800), 0...0)
    }
}
