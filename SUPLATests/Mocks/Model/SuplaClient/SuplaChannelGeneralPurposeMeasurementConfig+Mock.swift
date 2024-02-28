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

@testable import SUPLA

extension SuplaChannelGeneralPurposeMeasurementConfig {
    static func mock(
        remoteId: Int32 = 0,
        channelFunc: Int32? = nil,
        crc32: Int64 = 0,
        valueDivider: Int32 = 0,
        valueMultiplier: Int32 = 0,
        valueAdded: Int64 = 0,
        valuePrecision: UInt8 = 0,
        unitBeforValue: String = "",
        unitAfterValue: String = "",
        noSpaceBeforeValue: Bool = false,
        noSpaceAfterValue: Bool = false,
        keepHistory: Bool = false,
        defaultValueDivider: Int32 = 0,
        defaultValueMultiplier: Int32 = 0,
        defaultValueAdded: Int64 = 0,
        defaultValuePrecision: UInt8 = 0,
        defaultUnitBeforeValue: String = "",
        defaultUnitAfterValue: String = "",
        refreshIntervalMs: UInt16 = 0,
        chartType: SuplaChannelConfigMeasurementChartType = .bar
    ) -> SuplaChannelGeneralPurposeMeasurementConfig {
        SuplaChannelGeneralPurposeMeasurementConfig(
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
            refreshIntervalMs: refreshIntervalMs,
            chartType: chartType
        )
    }
}
