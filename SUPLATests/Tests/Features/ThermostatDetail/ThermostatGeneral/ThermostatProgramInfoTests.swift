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

final class ThermostatProgramInfoTests: XCTestCase {
    
    private lazy var builder: ThermostatProgramInfo.Builder! = {
        ThermostatProgramInfo.Builder()
    }()
    
    private lazy var dateProvider: DateProviderMock! = {
        DateProviderMock()
    }()
    
    private lazy var valuesFormatter: ValuesFormatterMock! = {
        ValuesFormatterMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: DateProvider.self, component: dateProvider!)
        DiContainer.shared.register(type: ValuesFormatter.self, component: valuesFormatter!)
    }
    
    override func tearDown() {
        dateProvider = nil
        valuesFormatter = nil
        
        builder = nil
    }
    
    func test_shouldNotBuildWhenConfigNotSet() {
        expectFatalError(expectedMessage: "Config cannot be null") {
            _ = self.builder.build()
        }
    }
    
    func test_shouldNotBuildWhenFlagsNotSet() {
        expectFatalError(expectedMessage: "Thermostat flags cannot be null") {
            self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock()
            _ = self.builder.build()
        }
    }
    
    func test_shouldNotBuildWhenCurrentModeNotSet() {
        expectFatalError(expectedMessage: "Current mode cannot be null") {
            self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock()
            self.builder.thermostatFlags = []
            _ = self.builder.build()
        }
    }
    
    func test_shouldNotBuildWhenCurrentTemperatureNotSet() {
        expectFatalError(expectedMessage: "Current temperature cannot be null") {
            self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock()
            self.builder.thermostatFlags = []
            self.builder.currentMode = .heat
            _ = self.builder.build()
        }
    }
    
    func test_shouldNotBuildWhenChannelOnlineNotSet() {
        expectFatalError(expectedMessage: "Channel online cannot be null") {
            self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock()
            self.builder.thermostatFlags = []
            self.builder.currentMode = .heat
            self.builder.currentTemperature = 10
            _ = self.builder.build()
        }
    }
    
    func test_shouldBuildEmptyListWhenChannelOffline() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(withPrograms: true, withSchedule: true)
        self.builder.thermostatFlags = []
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = false
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_shouldBuildEmptyListWhenNoPrograms() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(withSchedule: true)
        self.builder.thermostatFlags = []
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_shouldBuildEmptyListWhenNoSchedule() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(withPrograms: true)
        self.builder.thermostatFlags = []
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_shouldBuildEmptyListWhenWeeklyScheduleNotSet() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(withPrograms: true, withSchedule: true)
        self.builder.thermostatFlags = []
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_shouldBuildErrorListWhenClockError() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(withPrograms: true, withSchedule: true)
        self.builder.thermostatFlags = [.clockError, .weeklySchedule]
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [
            ThermostatProgramInfo(
                type: .current,
                time: Strings.ThermostatDetail.clockError,
                icon: SuplaHvacMode.heat.icon,
                iconColor: SuplaHvacMode.heat.iconColor,
                description: "10.0",
                manualActive: false
            )
        ])
    }
    
    func test_shouldBuildEmptyListWhenCurrentProgramNotFound() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(withPrograms: true, withSchedule: true)
        self.builder.thermostatFlags = [.weeklySchedule]
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_shouldBuildEmptyListWhenOnlyOneProgram() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(
            withPrograms: true,
            withSchedule: true,
            secondProgram: .program2
        )
        self.builder.thermostatFlags = [.weeklySchedule]
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        dateProvider.currentDayOfWeekReturns = .sunday
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_shouldBuildProperList() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(
            withPrograms: true,
            withSchedule: true
        )
        self.builder.thermostatFlags = [.weeklySchedule]
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        dateProvider.currentDayOfWeekReturns = .sunday
        dateProvider.currentMinuteReturns = 4
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [
            ThermostatProgramInfo(
                type: .current,
                time: Strings.ThermostatDetail.programTime.arguments(
                    valuesFormatter.minutesToString(minutes: 86)
                ),
                icon: SuplaHvacMode.heat.icon,
                iconColor: SuplaHvacMode.heat.iconColor,
                description: "10.0",
                manualActive: false
            ),
            ThermostatProgramInfo(
                type: .next,
                time: nil,
                icon: SuplaHvacMode.cool.icon,
                iconColor: SuplaHvacMode.cool.iconColor,
                description: "12.0",
                manualActive: false
            )
        ])
    }
    
    func test_shouldBuildProperListWhenTemporarChangeActive() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(
            withPrograms: true,
            withSchedule: true
        )
        self.builder.thermostatFlags = [.weeklySchedule, .weeklyScheduleTemporalOverride]
        self.builder.currentMode = .off
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        dateProvider.currentDayOfWeekReturns = .sunday
        dateProvider.currentMinuteReturns = 34
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [
            ThermostatProgramInfo(
                type: .current,
                time: Strings.ThermostatDetail.programTime.arguments(
                    valuesFormatter.minutesToString(minutes: 56)
                ),
                icon: SuplaHvacMode.off.icon,
                iconColor: SuplaHvacMode.off.iconColor,
                description: nil,
                manualActive: true
            ),
            ThermostatProgramInfo(
                type: .next,
                time: nil,
                icon: SuplaHvacMode.cool.icon,
                iconColor: SuplaHvacMode.cool.iconColor,
                description: "12.0",
                manualActive: false
            )
        ])
    }
    
    func test_shouldBuildProperListWhenNextProgramIsOff() {
        // when
        self.builder.channelConfig = SuplaChannelWeeklyScheduleConfig.mock(
            withPrograms: true,
            withSchedule: true,
            secondProgram: .off
        )
        self.builder.thermostatFlags = [.weeklySchedule]
        self.builder.currentMode = .heat
        self.builder.currentTemperature = 10
        self.builder.channelOnline = true
        
        dateProvider.currentDayOfWeekReturns = .sunday
        dateProvider.currentMinuteReturns = 4
        
        // when
        let result = builder.build()
        
        // then
        XCTAssertEqual(result, [
            ThermostatProgramInfo(
                type: .current,
                time: Strings.ThermostatDetail.programTime.arguments(
                    valuesFormatter.minutesToString(minutes: 86)
                ),
                icon: SuplaHvacMode.heat.icon,
                iconColor: SuplaHvacMode.heat.iconColor,
                description: "10.0",
                manualActive: false
            ),
            ThermostatProgramInfo(
                type: .next,
                time: nil,
                icon: SuplaHvacMode.off.icon,
                iconColor: SuplaHvacMode.off.iconColor,
                description: SuplaWeeklyScheduleProgram.OFF.description,
                manualActive: false
            )
        ])
    }
}
