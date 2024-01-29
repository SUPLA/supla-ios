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


class SuplaChannelGeneralPurposeBaseConfig: SuplaChannelConfig {
    
    let crc32: Int64
    let valueDivider: Int32
    let valueMultiplier: Int32
    let valueAdded: Int64
    let valuePrecision: UInt8
    let unitBeforValue: String
    let unitAfterValue: String
    let noSpaceBeforeValue: Bool
    let noSpaceAfterValue: Bool
    let keepHistory: Bool
    let defaultValueDivider: Int32
    let defaultValueMultiplier: Int32
    let defaultValueAdded: Int64
    let defaultValuePrecision: UInt8
    let defaultUnitBeforeValue: String
    let defaultUnitAfterValue: String
    let refreshIntervalMs: UInt16
    
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
        refreshIntervalMs: UInt16
    ) {
        self.crc32 = crc32
        self.valueDivider = valueDivider
        self.valueMultiplier = valueMultiplier
        self.valueAdded = valueAdded
        self.valuePrecision = valuePrecision
        self.unitBeforValue = unitBeforValue
        self.unitAfterValue = unitAfterValue
        self.noSpaceBeforeValue = noSpaceBeforeValue
        self.noSpaceAfterValue = noSpaceAfterValue
        self.keepHistory = keepHistory
        self.defaultValueDivider = defaultValueDivider
        self.defaultValueMultiplier = defaultValueMultiplier
        self.defaultValueAdded = defaultValueAdded
        self.defaultValuePrecision = defaultValuePrecision
        self.defaultUnitBeforeValue = defaultUnitBeforeValue
        self.defaultUnitAfterValue = defaultUnitAfterValue
        self.refreshIntervalMs = refreshIntervalMs
        
        super.init(remoteId: remoteId, channelFunc: channelFunc)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        crc32 = try container.decode(Int64.self, forKey: .crc32)
        valueDivider = try container.decode(Int32.self, forKey: .valueDivider)
        valueMultiplier = try container.decode(Int32.self, forKey: .valueMultiplier)
        valueAdded = try container.decode(Int64.self, forKey: .valueAdded)
        valuePrecision = try container.decode(UInt8.self, forKey: .valuePrecision)
        unitBeforValue = try container.decode(String.self, forKey: .unitBeforValue)
        unitAfterValue = try container.decode(String.self, forKey: .unitAfterValue)
        noSpaceBeforeValue = try container.decode(Bool.self, forKey: .noSpaceBeforeValue)
        noSpaceAfterValue = try container.decode(Bool.self, forKey: .noSpaceAfterValue)
        keepHistory = try container.decode(Bool.self, forKey: .keepHistory)
        defaultValueDivider = try container.decode(Int32.self, forKey: .defaultValueDivider)
        defaultValueMultiplier = try container.decode(Int32.self, forKey: .defaultValueMultiplier)
        defaultValueAdded = try container.decode(Int64.self, forKey: .defaultValueAdded)
        defaultValuePrecision = try container.decode(UInt8.self, forKey: .defaultValuePrecision)
        defaultUnitBeforeValue = try container.decode(String.self, forKey: .defaultUnitBeforeValue)
        defaultUnitAfterValue = try container.decode(String.self, forKey: .defaultUnitAfterValue)
        refreshIntervalMs = try container.decode(UInt16.self, forKey: .refreshIntervalMs)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(crc32, forKey: .crc32)
        try container.encode(valueDivider, forKey: .valueDivider)
        try container.encode(valueMultiplier, forKey: .valueMultiplier)
        try container.encode(valueAdded, forKey: .valueAdded)
        try container.encode(valuePrecision, forKey: .valuePrecision)
        try container.encode(unitBeforValue, forKey: .unitBeforValue)
        try container.encode(unitAfterValue, forKey: .unitAfterValue)
        try container.encode(noSpaceBeforeValue, forKey: .noSpaceBeforeValue)
        try container.encode(noSpaceAfterValue, forKey: .noSpaceAfterValue)
        try container.encode(keepHistory, forKey: .keepHistory)
        try container.encode(defaultValueDivider, forKey: .defaultValueDivider)
        try container.encode(defaultValueMultiplier, forKey: .defaultValueMultiplier)
        try container.encode(defaultValueAdded, forKey: .defaultValueAdded)
        try container.encode(defaultValuePrecision, forKey: .defaultValuePrecision)
        try container.encode(defaultUnitBeforeValue, forKey: .defaultUnitBeforeValue)
        try container.encode(defaultUnitAfterValue, forKey: .defaultUnitAfterValue)
        try container.encode(refreshIntervalMs, forKey: .refreshIntervalMs)
        
        try super.encode(to: encoder)
    }
    
    private enum CodingKeys : String, CodingKey {
        case crc32
        case valueDivider
        case valueMultiplier
        case valueAdded
        case valuePrecision
        case unitBeforValue
        case unitAfterValue
        case noSpaceBeforeValue
        case noSpaceAfterValue
        case keepHistory
        case defaultValueDivider
        case defaultValueMultiplier
        case defaultValueAdded
        case defaultValuePrecision
        case defaultUnitBeforeValue
        case defaultUnitAfterValue
        case refreshIntervalMs
    }
}
