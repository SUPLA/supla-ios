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

class SuplaChannelConfigTests: XCTestCase {
    
    func test_shouldGetConfigWithoutType() {
        // given
        var config = TSCS_ChannelConfig()
        config.ChannelId = 123
        config.Func = SUPLA_CHANNELFNC_HUMIDITY
        
        // when
        let result = SuplaChannelConfig.from(suplaConfig: config, crc32: 0)
        
        // then
        XCTAssertTrue(type(of: result) == SuplaChannelConfig.self)
        XCTAssertEqual(result.remoteId, 123)
        XCTAssertEqual(result.channelFunc, SUPLA_CHANNELFNC_HUMIDITY)
    }
    
    func test_shouldGetHvacConfigForTermostat() {
        // given
        var config = getHvacConfig()
        config.ChannelId = 123
        config.Func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        config.ConfigType = UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
        config.ConfigSize = UInt16(MemoryLayout<TChannelConfig_HVAC>.size)
        
        // when
        let result = SuplaChannelConfig.from(suplaConfig: config, crc32: 0)
        
        // then
        XCTAssertTrue(type(of: result) == SuplaChannelHvacConfig.self)
        XCTAssertEqual(result.remoteId, 123)
        XCTAssertEqual(result.channelFunc, SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
        
        let hvacConfig = result as! SuplaChannelHvacConfig
        XCTAssertEqual(hvacConfig.mainThermometerRemoteId, 123)
        XCTAssertEqual(hvacConfig.auxThermometerRemoteId, 234)
        XCTAssertEqual(hvacConfig.auxThermometerType, .water)
        XCTAssertEqual(hvacConfig.antiFreezeAndOverheatProtectionEnabled, true)
        XCTAssertEqual(hvacConfig.availableAlgorithms, [.onOffSetpointMiddle, .onOffSetpointAtMost])
        XCTAssertEqual(hvacConfig.usedAlgorithm, .onOffSetpointAtMost)
        XCTAssertEqual(hvacConfig.minOnTimeSec, 16)
        XCTAssertEqual(hvacConfig.minOffTimeSec, 24)
        XCTAssertEqual(hvacConfig.outputValueOnError, 0)
        XCTAssertEqual(hvacConfig.subfunction, .heat)
        
        XCTAssertEqual(hvacConfig.temperatures.freezeProtection, 100)
        XCTAssertEqual(hvacConfig.temperatures.eco, 200)
        XCTAssertEqual(hvacConfig.temperatures.comfort, 300)
        XCTAssertEqual(hvacConfig.temperatures.boost, 400)
        XCTAssertEqual(hvacConfig.temperatures.heatProtection, 500)
        XCTAssertEqual(hvacConfig.temperatures.histeresis, 600)
        XCTAssertEqual(hvacConfig.temperatures.belowAlarm, 700)
        XCTAssertEqual(hvacConfig.temperatures.aboveAlarm, 800)
        XCTAssertEqual(hvacConfig.temperatures.auxMinSetpoint, 900)
        XCTAssertEqual(hvacConfig.temperatures.auxMaxSetpoint, 1000)
        XCTAssertEqual(hvacConfig.temperatures.roomMin, 1100)
        XCTAssertEqual(hvacConfig.temperatures.roomMax, 1200)
        XCTAssertEqual(hvacConfig.temperatures.auxMin, 1300)
        XCTAssertEqual(hvacConfig.temperatures.auxMax, 1400)
        XCTAssertEqual(hvacConfig.temperatures.histeresisMin, 1500)
        XCTAssertEqual(hvacConfig.temperatures.histeresisMax, 1600)
        XCTAssertEqual(hvacConfig.temperatures.autoOffsetMin, 1700)
        XCTAssertEqual(hvacConfig.temperatures.autoOffsetMax, 1800)
    }
    
    func test_shouldGetWeeklyScheduleConfigForTermostat() {
        // given
        var config = getWeeklScheduleConfig()
        config.ChannelId = 123
        config.Func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        config.ConfigType = UInt8(SUPLA_CONFIG_TYPE_WEEKLY_SCHEDULE)
        config.ConfigSize = UInt16(MemoryLayout<TChannelConfig_WeeklySchedule>.size)
        
        // when
        let result = SuplaChannelConfig.from(suplaConfig: config, crc32: 0)
        
        // then
        XCTAssertTrue(type(of: result) == SuplaChannelWeeklyScheduleConfig.self)
        XCTAssertEqual(result.remoteId, 123)
        XCTAssertEqual(result.channelFunc, SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
        
        let weeklyConfig = result as! SuplaChannelWeeklyScheduleConfig
        XCTAssertEqual(
            weeklyConfig.programConfigurations[0],
            SuplaWeeklyScheduleProgram(program: .program1, mode: .notSet, setpointTemperatureHeat: 200, setpointTemperatureCool: 100)
        )
        XCTAssertEqual(
            weeklyConfig.programConfigurations[1],
            SuplaWeeklyScheduleProgram(program: .program2, mode: .notSet, setpointTemperatureHeat: 400, setpointTemperatureCool: 200)
        )
        XCTAssertEqual(
            weeklyConfig.programConfigurations[2],
            SuplaWeeklyScheduleProgram(program: .program3, mode: .dry, setpointTemperatureHeat: 600, setpointTemperatureCool: 300)
        )
        XCTAssertEqual(
            weeklyConfig.programConfigurations[3],
            SuplaWeeklyScheduleProgram(program: .program4, mode: .dry, setpointTemperatureHeat: 800, setpointTemperatureCool: 400)
        )
        
        for idx in 0..<627 {
            let entry = weeklyConfig.schedule[idx]
            let hour = UInt8((idx % 96) / 4)
            if (idx < 96) {
                XCTAssertEqual(entry.dayOfWeek, .sunday)
                XCTAssertEqual(entry.hour, hour)
                XCTAssertEqual(entry.program, .program1)
            } else if (idx < 192) {
                XCTAssertEqual(entry.dayOfWeek, .monday)
                XCTAssertEqual(entry.hour, hour)
                XCTAssertEqual(entry.program, .program2)
            } else if (idx < 288) {
                XCTAssertEqual(entry.dayOfWeek, .tuesday)
                XCTAssertEqual(entry.hour, hour)
                XCTAssertEqual(entry.program, .program3)
            } else if (idx < 384) {
                XCTAssertEqual(entry.dayOfWeek, .wednesday)
                XCTAssertEqual(entry.hour, hour)
                XCTAssertEqual(entry.program, .program4)
            } else {
                XCTAssertEqual(entry.hour, hour)
                XCTAssertEqual(entry.program, .off)
            }
        }
    }
    
    func test_shouldGetGeneralPurposeMeterConfig() {
        // given
        var config = getGpMeterConfig()
        config.ChannelId = 123
        config.Func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
        config.ConfigType = UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
        
        // when
        let result = SuplaChannelConfig.from(suplaConfig: config, crc32: 0)
        
        // then
        XCTAssertTrue(type(of: result) == SuplaChannelGeneralPurposeMeterConfig.self)
        XCTAssertEqual(result.remoteId, 123)
        XCTAssertEqual(result.channelFunc, SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER)
        
        let gpmConfig = result as! SuplaChannelGeneralPurposeMeterConfig
        XCTAssertEqual(gpmConfig.valueDivider, 10)
        XCTAssertEqual(gpmConfig.valueMultiplier, 20)
        XCTAssertEqual(gpmConfig.valueAdded, 30)
        XCTAssertEqual(gpmConfig.valuePrecision, 40)
        XCTAssertEqual(gpmConfig.unitBeforValue, "Test before")
        XCTAssertEqual(gpmConfig.unitAfterValue, "Test after")
        
        XCTAssertEqual(gpmConfig.noSpaceBeforeValue, true)
        XCTAssertEqual(gpmConfig.noSpaceAfterValue, false)
        XCTAssertEqual(gpmConfig.keepHistory, true)
        XCTAssertEqual(gpmConfig.defaultValueDivider, 50)
        XCTAssertEqual(gpmConfig.defaultValueMultiplier, 60)
        XCTAssertEqual(gpmConfig.defaultValueAdded, 70)
        XCTAssertEqual(gpmConfig.defaultValuePrecision, 80)
        XCTAssertEqual(gpmConfig.defaultUnitBeforeValue, "Test def bef")
        XCTAssertEqual(gpmConfig.defaultUnitAfterValue, "Test def aft")
        XCTAssertEqual(gpmConfig.refreshIntervalMs, 100)
        XCTAssertEqual(gpmConfig.counterType, .alwaysDecrement)
        XCTAssertEqual(gpmConfig.chartType, .bar)
        XCTAssertEqual(gpmConfig.includeValueAddedInHistory, false)
        XCTAssertEqual(gpmConfig.fillMissingData, true)
    }
    
    func test_shouldGetGeneralPurposeMeasurementConfig() {
        // given
        var config = getGpMeasurementConfig()
        config.ChannelId = 123
        config.Func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
        config.ConfigType = UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
        
        // when
        let result = SuplaChannelConfig.from(suplaConfig: config, crc32: 0)
        
        // then
        XCTAssertTrue(type(of: result) == SuplaChannelGeneralPurposeMeasurementConfig.self)
        XCTAssertEqual(result.remoteId, 123)
        XCTAssertEqual(result.channelFunc, SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT)
        
        let gpmConfig = result as! SuplaChannelGeneralPurposeMeasurementConfig
        XCTAssertEqual(gpmConfig.valueDivider, 10)
        XCTAssertEqual(gpmConfig.valueMultiplier, 20)
        XCTAssertEqual(gpmConfig.valueAdded, 30)
        XCTAssertEqual(gpmConfig.valuePrecision, 40)
        XCTAssertEqual(gpmConfig.unitBeforValue, "Test before")
        XCTAssertEqual(gpmConfig.unitAfterValue, "Test after")
        
        XCTAssertEqual(gpmConfig.noSpaceBeforeValue, true)
        XCTAssertEqual(gpmConfig.noSpaceAfterValue, false)
        XCTAssertEqual(gpmConfig.keepHistory, true)
        XCTAssertEqual(gpmConfig.defaultValueDivider, 50)
        XCTAssertEqual(gpmConfig.defaultValueMultiplier, 60)
        XCTAssertEqual(gpmConfig.defaultValueAdded, 70)
        XCTAssertEqual(gpmConfig.defaultValuePrecision, 80)
        XCTAssertEqual(gpmConfig.defaultUnitBeforeValue, "Test def bef")
        XCTAssertEqual(gpmConfig.defaultUnitAfterValue, "Test def aft")
        XCTAssertEqual(gpmConfig.refreshIntervalMs, 100)
        XCTAssertEqual(gpmConfig.chartType, .candle)
    }
    
    private func getHvacConfig() -> TSCS_ChannelConfig {
        return SuplaConfigIntegrator.mockHvacConfig()
    }
    
    private func getWeeklScheduleConfig() -> TSCS_ChannelConfig {
        return SuplaConfigIntegrator.mockWeeklyScheduleConfig()
    }
    
    private func getGpMeterConfig() -> TSCS_ChannelConfig {
        var config = TChannelConfig_GeneralPurposeMeter()
        config.ValueDivider = 10
        config.ValueMultiplier = 20
        config.ValueAdded = 30
        config.ValuePrecision = 40
        "Test before".copyToCharArray(array: &config.UnitBeforeValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        "Test after".copyToCharArray(array: &config.UnitAfterValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        config.NoSpaceBeforeValue = 1
        config.NoSpaceAfterValue = 0
        config.KeepHistory = 1
        config.DefaultValueDivider = 50
        config.DefaultValueMultiplier = 60
        config.DefaultValueAdded = 70
        config.DefaultValuePrecision = 80
        "Test def bef".copyToCharArray(array: &config.DefaultUnitBeforeValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        "Test def aft".copyToCharArray(array: &config.DefaultUnitAfterValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        config.RefreshIntervalMs = 100
        config.CounterType = 2
        config.ChartType = 0
        config.IncludeValueAddedInHistory = 0
        config.FillMissingData = 1
        
        var channelConfig = TSCS_ChannelConfig()
        channelConfig.ConfigSize = UInt16(MemoryLayout<TChannelConfig_GeneralPurposeMeter>.size)
        
        var sourcePointer = withUnsafeMutablePointer(to: &config) { UnsafeRawPointer($0) }
        var destPointer = withUnsafeMutablePointer(to: &channelConfig.Config) { UnsafeMutableRawPointer($0) }
        memcpy(destPointer, sourcePointer, MemoryLayout<TChannelConfig_GeneralPurposeMeter>.size)
        
        return channelConfig
    }
    
    private func getGpMeasurementConfig() -> TSCS_ChannelConfig {
        var config = TChannelConfig_GeneralPurposeMeasurement()
        config.ValueDivider = 10
        config.ValueMultiplier = 20
        config.ValueAdded = 30
        config.ValuePrecision = 40
        "Test before".copyToCharArray(array: &config.UnitBeforeValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        "Test after".copyToCharArray(array: &config.UnitAfterValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        config.NoSpaceBeforeValue = 1
        config.NoSpaceAfterValue = 0
        config.KeepHistory = 1
        config.DefaultValueDivider = 50
        config.DefaultValueMultiplier = 60
        config.DefaultValueAdded = 70
        config.DefaultValuePrecision = 80
        "Test def bef".copyToCharArray(array: &config.DefaultUnitBeforeValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        "Test def aft".copyToCharArray(array: &config.DefaultUnitAfterValue, capacity: Int(SUPLA_GENERAL_PURPOSE_UNIT_SIZE))
        config.RefreshIntervalMs = 100
        config.ChartType = 2
        
        var channelConfig = TSCS_ChannelConfig()
        channelConfig.ConfigSize = UInt16(MemoryLayout<TChannelConfig_GeneralPurposeMeasurement>.size)
        
        var sourcePointer = withUnsafeMutablePointer(to: &config) { UnsafeRawPointer($0) }
        var destPointer = withUnsafeMutablePointer(to: &channelConfig.Config) { UnsafeMutableRawPointer($0) }
        memcpy(destPointer, sourcePointer, MemoryLayout<TChannelConfig_GeneralPurposeMeasurement>.size)
        
        return channelConfig
    }
}
