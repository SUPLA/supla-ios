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

import Foundation

final class SuplaChannelHvacConfig: SuplaChannelConfig {
    
    let mainThermometerRemoteId: Int32
    let auxThermometerRemoteId: Int32
    let auxThermometerType: SuplaHvacThermometerType
    let antiFreezeAndOverheatProtectionEnabled: Bool
    let availableAlgorithms: [SuplaHvacAlgorithm]
    let usedAlgorithm: SuplaHvacAlgorithm
    let minOnTimeSec: UInt16
    let minOffTimeSec: UInt16
    let outputValueOnError: Int8
    let subfunction: ThermostatSubfunction
    let temperatures: SuplaHvacTemperatures
    
    init(
        remoteId: Int32,
        channelFunc: Int32?,
        mainThermometerRemoteId: Int32,
        auxThermometerRemoteId: Int32,
        auxThermometerType: SuplaHvacThermometerType,
        antiFreezeAndOverheatProtectionEnabled: Bool,
        availableAlgorithms: [SuplaHvacAlgorithm],
        usedAlgorithm: SuplaHvacAlgorithm,
        minOnTimeSec: UInt16,
        minOffTimeSec: UInt16,
        outputValueOnError: Int8,
        subfunction: ThermostatSubfunction,
        temperatures: SuplaHvacTemperatures
    ) {
        self.mainThermometerRemoteId = mainThermometerRemoteId
        self.auxThermometerRemoteId = auxThermometerRemoteId
        self.auxThermometerType = auxThermometerType
        self.antiFreezeAndOverheatProtectionEnabled = antiFreezeAndOverheatProtectionEnabled
        self.availableAlgorithms = availableAlgorithms
        self.usedAlgorithm = usedAlgorithm
        self.minOnTimeSec = minOnTimeSec
        self.minOffTimeSec = minOffTimeSec
        self.outputValueOnError = outputValueOnError
        self.temperatures = temperatures
        self.subfunction = subfunction
        super.init(remoteId: remoteId, channelFunc: channelFunc)
    }
    
    static func from(remoteId: Int32, channelFunc: Int32?, suplaConfig: TChannelConfig_HVAC) -> SuplaChannelHvacConfig {
        return SuplaChannelHvacConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            mainThermometerRemoteId: suplaConfig.MainThermometerChannelId,
            auxThermometerRemoteId: suplaConfig.AuxThermometerChannelId,
            auxThermometerType: SuplaHvacThermometerType.from(value: suplaConfig.AuxThermometerType),
            antiFreezeAndOverheatProtectionEnabled: suplaConfig.AntiFreezeAndOverheatProtectionEnabled > 0,
            availableAlgorithms: SuplaHvacAlgorithm.from(flags: suplaConfig.AvailableAlgorithms),
            usedAlgorithm: SuplaHvacAlgorithm.from(value: suplaConfig.UsedAlgorithm),
            minOnTimeSec: suplaConfig.MinOnTimeS,
            minOffTimeSec: suplaConfig.MinOffTimeS,
            outputValueOnError: suplaConfig.OutputValueOnError,
            subfunction: ThermostatSubfunction.from(value: suplaConfig.Subfunction),
            temperatures: SuplaHvacTemperatures.from(temperatures: suplaConfig.Temperatures)
        )
    }
}

enum SuplaHvacThermometerType: UInt8, CaseIterable {
    case notSet = 0
    case disabled = 1
    case floor = 2
    case water = 3
    case genericHeater = 4
    case genericCooler = 5
    
    static func from(value: UInt8) -> SuplaHvacThermometerType {
        for result in SuplaHvacThermometerType.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        fatalError("Could not convert value `\(value)` to SuplaHvacThermometerType")
    }
}

enum SuplaHvacAlgorithm: UInt16, CaseIterable {
    case notSet = 0
    case onOffSetpointMiddle = 1
    case onOffSetpointAtMost = 2
    
    static func from(value: UInt16) -> SuplaHvacAlgorithm {
        for result in SuplaHvacAlgorithm.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        fatalError("Could not convert value `\(value)` to SuplaHvacAlgorithm")
    }
    
    static func from(flags: UInt16) -> [SuplaHvacAlgorithm] {
        var result: [SuplaHvacAlgorithm] = []
        
        for algorithm in SuplaHvacAlgorithm.allCases {
            if (flags & algorithm.rawValue > 0) {
                result.append(algorithm)
            }
        }
        
        return result
    }
}

struct SuplaHvacTemperatures {
    let freezeProtection: Int16?
    let eco: Int16?
    let comfort: Int16?
    let boost: Int16?
    let heatProtection: Int16?
    let histeresis: Int16?
    let belowAlarm: Int16?
    let aboveAlarm: Int16?
    let auxMinSetpoint: Int16?
    let auxMaxSetpoint: Int16?
    let roomMin: Int16?
    let roomMax: Int16?
    let auxMin: Int16?
    let auxMax: Int16?
    let histeresisMin: Int16?
    let histeresisMax: Int16?
    let autoOffsetMin: Int16?
    let autoOffsetMax: Int16?
    
    static func from(temperatures: THVACTemperatureCfg) -> SuplaHvacTemperatures {
        return SuplaHvacTemperatures(
            freezeProtection: getTemperature(temperatures, UInt32(TEMPERATURE_FREEZE_PROTECTION)),
            eco: getTemperature(temperatures, UInt32(TEMPERATURE_ECO)),
            comfort: getTemperature(temperatures, UInt32(TEMPERATURE_COMFORT)),
            boost: getTemperature(temperatures, UInt32(TEMPERATURE_BOOST)),
            heatProtection: getTemperature(temperatures, UInt32(TEMPERATURE_HEAT_PROTECTION)),
            histeresis: getTemperature(temperatures, UInt32(TEMPERATURE_HISTERESIS)),
            belowAlarm: getTemperature(temperatures, UInt32(TEMPERATURE_BELOW_ALARM)),
            aboveAlarm: getTemperature(temperatures, UInt32(TEMPERATURE_ABOVE_ALARM)),
            auxMinSetpoint: getTemperature(temperatures, UInt32(TEMPERATURE_AUX_MIN_SETPOINT)),
            auxMaxSetpoint: getTemperature(temperatures, UInt32(TEMPERATURE_AUX_MAX_SETPOINT)),
            roomMin: getTemperature(temperatures, UInt32(TEMPERATURE_ROOM_MIN)),
            roomMax: getTemperature(temperatures, UInt32(TEMPERATURE_ROOM_MAX)),
            auxMin: getTemperature(temperatures, UInt32(TEMPERATURE_AUX_MIN)),
            auxMax: getTemperature(temperatures, UInt32(TEMPERATURE_AUX_MAX)),
            histeresisMin: getTemperature(temperatures, UInt32(TEMPERATURE_HISTERESIS_MIN)),
            histeresisMax: getTemperature(temperatures, UInt32(TEMPERATURE_HISTERESIS_MAX)),
            autoOffsetMin: getTemperature(temperatures, UInt32(TEMPERATURE_AUTO_OFFSET_MIN)),
            autoOffsetMax: getTemperature(temperatures, UInt32(TEMPERATURE_AUTO_OFFSET_MAX))
        )
    }
    
    private static func getTemperature(_ temperatures: THVACTemperatureCfg, _ index: UInt32) -> Int16? {
        if ((temperatures.Index & index) > 0) {
            let size = Mirror(reflecting: temperatures.Temperature).children.count
            
            for a in 0..<size {
                if ((1 << a) == index) {
                    return SuplaChannelConfigIntegrator.extractTemperature(from: temperatures, for: Int32(a))
                }
            }
        }
        
        return nil
    }
}

enum ThermostatSubfunction: UInt8, CaseIterable {
    case notSet = 0
    case heat = 1
    case cool = 2
    
    static func from(value: UInt8) -> ThermostatSubfunction {
        for result in ThermostatSubfunction.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        fatalError("Could not convert value `\(value)` to ThermostatSubfunction")
    }
}
