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

final class SuplaChannelGeneralPurposeMeasurementConfig: SuplaChannelGeneralPurposeBaseConfig {
    let chartType: SuplaChannelConfigMeasurementChartType
    
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
        chartType: SuplaChannelConfigMeasurementChartType
    ) {
        self.chartType = chartType
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
        chartType = try container.decode(SuplaChannelConfigMeasurementChartType.self, forKey: .chartType)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chartType, forKey: .chartType)
        try super.encode(to: encoder)
    }
    
    static func from(
        remoteId: Int32,
        function: Int32,
        config: TChannelConfig_GeneralPurposeMeasurement,
        crc32: Int64
    ) -> SuplaChannelGeneralPurposeMeasurementConfig {
        SuplaChannelGeneralPurposeMeasurementConfig(
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
            chartType: SuplaChannelConfigMeasurementChartType.from(config.ChartType)
        )
    }
    
    private enum CodingKeys : String, CodingKey {
        case chartType
    }
}

enum SuplaChannelConfigMeasurementChartType: Int32, CaseIterable, Codable {
    case linear = 0
    case bar = 1
    case candle = 2
    
    static func from(_ chartType: UInt8) -> SuplaChannelConfigMeasurementChartType {
        for type in SuplaChannelConfigMeasurementChartType.allCases {
            if (type.rawValue == chartType) {
                return type
            }
        }
        
        NSLog("Invalid SuplaChannelConfigMeasurementChartType value `\(chartType)'")
        return .linear
    }
}
