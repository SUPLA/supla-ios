/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

@testable import SUPLA

enum NativeConfigMocks {
    static func hvacConfig() -> TSCS_ChannelConfig {
        var hvac = TChannelConfig_HVAC()
        hvac.MainThermometerChannelId = 123
        hvac.AuxThermometerChannelId = 234
        hvac.AuxThermometerType = UInt8(SUPLA_HVAC_AUX_THERMOMETER_TYPE_WATER)
        hvac.AntiFreezeAndOverheatProtectionEnabled = 1
        hvac.AvailableAlgorithms = UInt16(SUPLA_HVAC_ALGORITHM_ON_OFF_SETPOINT_MIDDLE | SUPLA_HVAC_ALGORITHM_ON_OFF_SETPOINT_AT_MOST)
        hvac.UsedAlgorithm = UInt16(SUPLA_HVAC_ALGORITHM_ON_OFF_SETPOINT_AT_MOST)
        hvac.MinOnTimeS = 16
        hvac.MinOffTimeS = 24
        hvac.OutputValueOnError = 0
        hvac.Subfunction = UInt8(SUPLA_HVAC_SUBFUNCTION_HEAT)
        hvac.Temperatures.Index = 0x3FFFF
        for index in 0..<THVACTemperatureCfg.temperatureCount {
            hvac.Temperatures.setTemperature(Int16((index + 1) * 100), at: index)
        }

        var config = TSCS_ChannelConfig()
        config.setPayload(hvac)
        return config
    }

    static func weeklyScheduleConfig() -> TSCS_ChannelConfig {
        var weekly = TChannelConfig_WeeklySchedule()
        for index in 0..<TChannelConfig_WeeklySchedule.programCount {
            var program = TWeeklyScheduleProgram()
            program.Mode = UInt8(index < 2 ? SUPLA_HVAC_MODE_NOT_SET : SUPLA_HVAC_MODE_DRY)
            program.SetpointTemperatureCool = Int16((index + 1) * 100)
            program.SetpointTemperatureHeat = Int16((index + 1) * 200)
            weekly.setProgram(program, at: index)
        }

        for index in 0..<TChannelConfig_WeeklySchedule.quarterCount {
            let day = index / 96
            weekly.setProgram(day < 4 ? UInt8(day + 1) : 0, atQuarter: index)
        }

        var config = TSCS_ChannelConfig()
        config.setPayload(weekly)
        return config
    }

    static func deviceConfig(includingUserInterface: Bool) -> TSCS_DeviceConfig {
        var config = TSCS_DeviceConfig()
        config.DeviceId = 123456
        config.EndOfDataFlag = 1
        config.AvailableFields = SuplaFieldType.allFields
        config.Fields = SuplaFieldType.allFields
        if !includingUserInterface {
            config.Fields &= ~SuplaFieldType.disableUserInterface.value
        }

        var statusLed = TDeviceConfig_StatusLed()
        statusLed.StatusLedType = 1

        var screenBrightness = TDeviceConfig_ScreenBrightness()
        screenBrightness.AdjustmentForAutomatic = 10
        screenBrightness.Automatic = 1
        screenBrightness.ScreenBrightness = 50

        var buttonVolume = TDeviceConfig_ButtonVolume()
        buttonVolume.Volume = 80

        var disableUserInterface = TDeviceConfig_DisableUserInterface()
        disableUserInterface.DisableUserInterface = 2
        disableUserInterface.minAllowedTemperatureSetpointFromLocalUI = 1200
        disableUserInterface.maxAllowedTemperatureSetpointFromLocalUI = 2500

        var automaticTimeSync = TDeviceConfig_AutomaticTimeSync()
        automaticTimeSync.AutomaticTimeSync = 1

        var homeScreenOffDelay = TDeviceConfig_HomeScreenOffDelay()
        homeScreenOffDelay.HomeScreenOffDelayS = 10

        var homeScreenContent = TDeviceConfig_HomeScreenContent()
        let availableContent: [UInt64] = [
            UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_NONE),
            UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE),
            UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE_AND_HUMIDITY),
            UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TIME),
            UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TIME_DATE),
            UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE_TIME),
            UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_MAIN_AND_AUX_TEMPERATURE)
        ]
        homeScreenContent.ContentAvailable = availableContent.reduce(0, |)
        homeScreenContent.HomeScreenContent = UInt64(SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE_AND_HUMIDITY)

        var offset = 0
        append(statusLed, to: &config, at: &offset)
        append(screenBrightness, to: &config, at: &offset)
        append(buttonVolume, to: &config, at: &offset)
        if includingUserInterface {
            append(disableUserInterface, to: &config, at: &offset)
        }
        append(automaticTimeSync, to: &config, at: &offset)
        append(homeScreenOffDelay, to: &config, at: &offset)
        append(homeScreenContent, to: &config, at: &offset)
        config.ConfigSize = UInt16(offset)

        return config
    }

    private static func append<T>(_ value: T, to config: inout TSCS_DeviceConfig, at offset: inout Int) {
        precondition(offset + MemoryLayout<T>.size <= MemoryLayout.size(ofValue: config.Config))

        var value = value
        withUnsafeBytes(of: &value) { source in
            withUnsafeMutableBytes(of: &config.Config) { destination in
                destination.baseAddress!
                    .advanced(by: offset)
                    .copyMemory(from: source.baseAddress!, byteCount: source.count)
            }
        }
        offset += MemoryLayout<T>.size
    }
}
