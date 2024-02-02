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

final class SuplaChannelGeneralPurposeMeterConfig: SuplaChannelGeneralPurposeBaseConfig {
    
    let counterType: SuplaChannelConfigMeterCounterType
    let chartType: SuplaChannelConfigMeterChartType
    let includeValueAddedInHistory: Bool
    let fillMissingData: Bool
    
    init(
        remoteId: Int32,
        channelFunc: Int32?,
        crc32: Int64,
        valueDivider: Int32,
        valueMultiplier: Int32,
        valueAdded: Int64,
        valuePrecision: UInt8,
        unitBeforValue: String,
        unitAfterValue: String,
        noSpaceBeforeValue: Bool,
        noSpaceAfterValue: Bool,
        keepHistory: Bool,
        defaultValueDivider: Int32,
        defaultValueMultiplier: Int32,
        defaultValueAdded: Int64,
        defaultValuePrecision: UInt8,
        defaultUnitBeforeValue: String,
        defaultUnitAfterValue: String,
        refreshIntervalMs: UInt16,
        counterType: SuplaChannelConfigMeterCounterType,
        chartType: SuplaChannelConfigMeterChartType,
        includeValueAddedInHistory: Bool,
        fillMissingData: Bool
    ) {
        self.counterType = counterType
        self.chartType = chartType
        self.includeValueAddedInHistory = includeValueAddedInHistory
        self.fillMissingData = fillMissingData
        
        super.init(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            valueDivider: valueDivider,
            valueMultiplier: valueMultiplier,
            valueAdded: valueAdded,
            valuePrecision: valuePrecision,
            unitBeforValue: unitBeforValue,
            unitAfterValue: unitAfterValue,
            noSpaceBeforeValue: noSpaceBeforeValue,
            noSpaceAfterValue: noSpaceAfterValue,
            keepHistory: keepHistory,
            defaultValueDivider: defaultValueDivider,
            defaultValueMultiplier: defaultValueMultiplier,
            defaultValueAdded: defaultValueAdded,
            defaultValuePrecision: defaultValuePrecision,
            defaultUnitBeforeValue: defaultUnitBeforeValue,
            defaultUnitAfterValue: defaultUnitAfterValue,
            refreshIntervalMs: refreshIntervalMs
        )
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        counterType = try container.decode(SuplaChannelConfigMeterCounterType.self, forKey: .counterType)
        chartType = try container.decode(SuplaChannelConfigMeterChartType.self, forKey: .chartType)
        includeValueAddedInHistory = try container.decode(Bool.self, forKey: .includeValueAddedInHistory)
        fillMissingData = try container.decode(Bool.self, forKey: .fillMissingData)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(counterType, forKey: .counterType)
        try container.encode(chartType, forKey: .chartType)
        try container.encode(includeValueAddedInHistory, forKey: .includeValueAddedInHistory)
        try container.encode(fillMissingData, forKey: .fillMissingData)
        try super.encode(to: encoder)
    }
    
    static func from(
        remoteId: Int32,
        function: Int32,
        config: TChannelConfig_GeneralPurposeMeter,
        crc32: Int64
    ) -> SuplaChannelGeneralPurposeMeterConfig {
        SuplaChannelGeneralPurposeMeterConfig(
            remoteId: remoteId,
            channelFunc: function,
            crc32: crc32,
            valueDivider: config.ValueDivider,
            valueMultiplier: config.ValueMultiplier,
            valueAdded: config.ValueAdded,
            valuePrecision: config.ValuePrecision,
            unitBeforValue: String.fromC(config.UnitBeforeValue),
            unitAfterValue: String.fromC(config.UnitAfterValue),
            noSpaceBeforeValue: config.NoSpaceBeforeValue == 1,
            noSpaceAfterValue: config.NoSpaceAfterValue == 1,
            keepHistory: config.KeepHistory == 1,
            defaultValueDivider: config.DefaultValueDivider,
            defaultValueMultiplier: config.DefaultValueMultiplier,
            defaultValueAdded: config.DefaultValueAdded,
            defaultValuePrecision: config.DefaultValuePrecision,
            defaultUnitBeforeValue: String.fromC(config.DefaultUnitBeforeValue),
            defaultUnitAfterValue: String.fromC(config.DefaultUnitAfterValue),
            refreshIntervalMs: config.RefreshIntervalMs,
            counterType: SuplaChannelConfigMeterCounterType.from(config.CounterType),
            chartType: SuplaChannelConfigMeterChartType.from(config.ChartType),
            includeValueAddedInHistory: config.IncludeValueAddedInHistory == 1,
            fillMissingData: config.FillMissingData == 1
        )
    }
    
    private enum CodingKeys : String, CodingKey {
        case counterType
        case chartType
        case includeValueAddedInHistory
        case fillMissingData
    }
}

enum SuplaChannelConfigMeterCounterType: Int32, CaseIterable, Codable {
    case incrementAndDecrement = 0
    case alwaysIncrement = 1
    case alwaysDecrement = 2
    
    static func from(_ counterType: UInt8) -> SuplaChannelConfigMeterCounterType {
        for type in SuplaChannelConfigMeterCounterType.allCases {
            if (type.rawValue == counterType) {
                return type
            }
        }
        
        NSLog("Invalid SuplaChannelConfigMeterCounterType value `\(counterType)'")
        return .incrementAndDecrement
    }
}

enum SuplaChannelConfigMeterChartType: Int32, CaseIterable, Codable {
    case linear = 1
    case bar = 0
    
    static func from(_ chartType: UInt8) -> SuplaChannelConfigMeterChartType {
        for type in SuplaChannelConfigMeterChartType.allCases {
            if (type.rawValue == chartType) {
                return type
            }
        }
        
        NSLog("Invalid SuplaChannelConfigMeterChartType value `\(chartType)'")
        return .linear
    }
}
