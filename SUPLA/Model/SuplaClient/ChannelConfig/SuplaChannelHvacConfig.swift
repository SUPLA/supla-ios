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

import SharedCore

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
    let temperatureControlType: SuplaTemperatureControlType
    let temperatures: SuplaHvacTemperatures
    
    var minTemperature: Float? {
        if (temperatureControlType == .aux_heater_cooler_temperature) {
            temperatures.auxMinSetpoint?.fromSuplaTemperature() ?? temperatures.auxMin?.fromSuplaTemperature()
        } else {
            temperatures.roomMin?.fromSuplaTemperature()
        }
    }
    
    var maxTemperature: Float? {
        if (temperatureControlType == .aux_heater_cooler_temperature) {
            temperatures.auxMaxSetpoint?.fromSuplaTemperature() ?? temperatures.auxMax?.fromSuplaTemperature()
        } else {
            temperatures.roomMax?.fromSuplaTemperature()
        }
    }
    
    init(
        remoteId: Int32,
        channelFunc: Int32?,
        crc32: Int64,
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
        temperatureControlType: SuplaTemperatureControlType,
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
        self.temperatureControlType = temperatureControlType
        self.subfunction = subfunction
        super.init(remoteId: remoteId, channelFunc: channelFunc, crc32: crc32)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mainThermometerRemoteId = try container.decode(Int32.self, forKey: .mainThermometerRemoteId)
        auxThermometerRemoteId = try container.decode(Int32.self, forKey: .auxThermometerRemoteId)
        auxThermometerType = try container.decode(SuplaHvacThermometerType.self, forKey: .auxThermometerType)
        antiFreezeAndOverheatProtectionEnabled = try container.decode(Bool.self, forKey: .antiFreezeAndOverheatProtectionEnabled)
        availableAlgorithms = try container.decode([SuplaHvacAlgorithm].self, forKey: .availableAlgorithms)
        usedAlgorithm = try container.decode(SuplaHvacAlgorithm.self, forKey: .usedAlgorithm)
        minOnTimeSec = try container.decode(UInt16.self, forKey: .minOnTimeSec)
        minOffTimeSec = try container.decode(UInt16.self, forKey: .minOffTimeSec)
        outputValueOnError = try container.decode(Int8.self, forKey: .outputValueOnError)
        temperatures = try container.decode(SuplaHvacTemperatures.self, forKey: .temperatures)
        temperatureControlType = try container.decode(SuplaTemperatureControlType.self, forKey: .temperatureControlType)
        subfunction = ThermostatSubfunction.companion.from(value: try container.decode(Int32.self, forKey: .subfunction))
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mainThermometerRemoteId, forKey: .mainThermometerRemoteId)
        try container.encode(auxThermometerRemoteId, forKey: .auxThermometerRemoteId)
        try container.encode(auxThermometerType, forKey: .auxThermometerType)
        try container.encode(antiFreezeAndOverheatProtectionEnabled, forKey: .antiFreezeAndOverheatProtectionEnabled)
        try container.encode(availableAlgorithms, forKey: .availableAlgorithms)
        try container.encode(usedAlgorithm, forKey: .usedAlgorithm)
        try container.encode(minOnTimeSec, forKey: .minOnTimeSec)
        try container.encode(minOffTimeSec, forKey: .minOffTimeSec)
        try container.encode(outputValueOnError, forKey: .outputValueOnError)
        try container.encode(temperatures, forKey: .temperatures)
        try container.encode(temperatureControlType, forKey: .temperatureControlType)
        try container.encode(subfunction.ordinal, forKey: .subfunction)
        try super.encode(to: encoder)
    }
    
    func toJson() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        
        return nil
    }
    
    static func from(remoteId: Int32, channelFunc: Int32?, crc32: Int64, suplaConfig: TChannelConfig_HVAC) -> SuplaChannelHvacConfig {
        return SuplaChannelHvacConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            mainThermometerRemoteId: suplaConfig.MainThermometerChannelId,
            auxThermometerRemoteId: suplaConfig.AuxThermometerChannelId,
            auxThermometerType: SuplaHvacThermometerType.from(value: suplaConfig.AuxThermometerType),
            antiFreezeAndOverheatProtectionEnabled: suplaConfig.AntiFreezeAndOverheatProtectionEnabled > 0,
            availableAlgorithms: SuplaHvacAlgorithm.from(flags: suplaConfig.AvailableAlgorithms),
            usedAlgorithm: SuplaHvacAlgorithm.from(value: suplaConfig.UsedAlgorithm),
            minOnTimeSec: suplaConfig.MinOnTimeS,
            minOffTimeSec: suplaConfig.MinOffTimeS,
            outputValueOnError: suplaConfig.OutputValueOnError,
            subfunction: ThermostatSubfunction.companion.from(value: Int32(suplaConfig.Subfunction)),
            temperatureControlType: SuplaTemperatureControlType.from(value: suplaConfig.TemperatureControlType),
            temperatures: SuplaHvacTemperatures.from(temperatures: suplaConfig.Temperatures)
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case mainThermometerRemoteId
        case auxThermometerRemoteId
        case auxThermometerType
        case antiFreezeAndOverheatProtectionEnabled
        case availableAlgorithms
        case usedAlgorithm
        case minOnTimeSec
        case minOffTimeSec
        case outputValueOnError
        case subfunction
        case temperatureControlType
        case temperatures
    }
}

enum SuplaHvacThermometerType: UInt8, CaseIterable, Codable {
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
        
        SALog.error("Invalid SuplaHvacThermometerType value `\(value)'")
        return .notSet
    }
}

enum SuplaHvacAlgorithm: UInt16, CaseIterable, Codable {
    case notSet = 0
    case onOffSetpointMiddle = 1
    case onOffSetpointAtMost = 2
    
    static func from(value: UInt16) -> SuplaHvacAlgorithm {
        for result in SuplaHvacAlgorithm.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        SALog.error("Invalid SuplaHvacAlgorithm value `\(value)'")
        return .notSet
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

enum SuplaTemperatureControlType: UInt8, CaseIterable, Codable {
    case notSupported = 0
    case roomTemperature = 1
    case aux_heater_cooler_temperature = 2
    
    static func from(value: UInt8) -> SuplaTemperatureControlType {
        for result in SuplaTemperatureControlType.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        SALog.error("Invalid SuplaTemperatureControlType value `\(value)'")
        return .notSupported
    }
}

extension SuplaTemperatureControlType? {
    func filterRelationType(_ relationType: ChannelRelationType) -> Bool {
        switch (relationType) {
        case .auxThermometerFloor, .auxThermometerWater, .auxThermometerGenericCooler, .auxThermometerGenericHeater:
            return self == .aux_heater_cooler_temperature
        case .mainThermometer:
            return self != .aux_heater_cooler_temperature
        default:
            return false
        }
    }
}

struct SuplaHvacTemperatures: Codable {
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
    
    init(
        freezeProtection: Int16?,
        eco: Int16?, comfort: Int16?,
        boost: Int16?,
        heatProtection: Int16?,
        histeresis: Int16?,
        belowAlarm: Int16?,
        aboveAlarm: Int16?,
        auxMinSetpoint: Int16?,
        auxMaxSetpoint: Int16?,
        roomMin: Int16?,
        roomMax: Int16?,
        auxMin: Int16?,
        auxMax: Int16?,
        histeresisMin: Int16?,
        histeresisMax: Int16?,
        autoOffsetMin: Int16?,
        autoOffsetMax: Int16?
    ) {
        self.freezeProtection = freezeProtection
        self.eco = eco
        self.comfort = comfort
        self.boost = boost
        self.heatProtection = heatProtection
        self.histeresis = histeresis
        self.belowAlarm = belowAlarm
        self.aboveAlarm = aboveAlarm
        self.auxMinSetpoint = auxMinSetpoint
        self.auxMaxSetpoint = auxMaxSetpoint
        self.roomMin = roomMin
        self.roomMax = roomMax
        self.auxMin = auxMin
        self.auxMax = auxMax
        self.histeresisMin = histeresisMin
        self.histeresisMax = histeresisMax
        self.autoOffsetMin = autoOffsetMin
        self.autoOffsetMax = autoOffsetMax
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        freezeProtection = try container.decode(Int16?.self, forKey: .freezeProtection)
        eco = try container.decode(Int16?.self, forKey: .eco)
        comfort = try container.decode(Int16?.self, forKey: .comfort)
        boost = try container.decode(Int16?.self, forKey: .boost)
        heatProtection = try container.decode(Int16?.self, forKey: .heatProtection)
        histeresis = try container.decode(Int16?.self, forKey: .histeresis)
        belowAlarm = try container.decode(Int16?.self, forKey: .belowAlarm)
        aboveAlarm = try container.decode(Int16?.self, forKey: .aboveAlarm)
        auxMinSetpoint = try container.decode(Int16?.self, forKey: .auxMinSetpoint)
        auxMaxSetpoint = try container.decode(Int16?.self, forKey: .auxMaxSetpoint)
        roomMin = try container.decode(Int16?.self, forKey: .roomMin)
        roomMax = try container.decode(Int16?.self, forKey: .roomMax)
        auxMin = try container.decode(Int16?.self, forKey: .auxMin)
        auxMax = try container.decode(Int16?.self, forKey: .auxMax)
        histeresisMin = try container.decode(Int16?.self, forKey: .histeresisMin)
        histeresisMax = try container.decode(Int16?.self, forKey: .histeresisMax)
        autoOffsetMin = try container.decode(Int16?.self, forKey: .autoOffsetMin)
        autoOffsetMax = try container.decode(Int16?.self, forKey: .autoOffsetMax)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(freezeProtection, forKey: .freezeProtection)
        try container.encode(eco, forKey: .eco)
        try container.encode(comfort, forKey: .comfort)
        try container.encode(boost, forKey: .boost)
        try container.encode(heatProtection, forKey: .heatProtection)
        try container.encode(histeresis, forKey: .histeresis)
        try container.encode(belowAlarm, forKey: .belowAlarm)
        try container.encode(aboveAlarm, forKey: .aboveAlarm)
        try container.encode(auxMinSetpoint, forKey: .auxMinSetpoint)
        try container.encode(auxMaxSetpoint, forKey: .auxMaxSetpoint)
        try container.encode(roomMin, forKey: .roomMin)
        try container.encode(roomMax, forKey: .roomMax)
        try container.encode(auxMin, forKey: .auxMin)
        try container.encode(auxMax, forKey: .auxMax)
        try container.encode(histeresisMin, forKey: .histeresisMin)
        try container.encode(histeresisMax, forKey: .histeresisMax)
        try container.encode(autoOffsetMin, forKey: .autoOffsetMin)
        try container.encode(autoOffsetMax, forKey: .autoOffsetMax)
    }
    
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
            autoOffsetMin: getTemperature(temperatures, UInt32(TEMPERATURE_HEAT_COOL_OFFSET_MIN)),
            autoOffsetMax: getTemperature(temperatures, UInt32(TEMPERATURE_HEAT_COOL_OFFSET_MAX))
        )
    }
    
    private static func getTemperature(_ temperatures: THVACTemperatureCfg, _ index: UInt32) -> Int16? {
        if ((temperatures.Index & index) > 0) {
            let size = Mirror(reflecting: temperatures.Temperature).children.count
            
            for a in 0..<size {
                if ((1 << a) == index) {
                    return SuplaConfigIntegrator.extractTemperature(from: temperatures, for: Int32(a))
                }
            }
        }
        
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case freezeProtection
        case eco
        case comfort
        case boost
        case heatProtection
        case histeresis
        case belowAlarm
        case aboveAlarm
        case auxMinSetpoint
        case auxMaxSetpoint
        case roomMin
        case roomMax
        case auxMin
        case auxMax
        case histeresisMin
        case histeresisMax
        case autoOffsetMin
        case autoOffsetMax
    }
}
