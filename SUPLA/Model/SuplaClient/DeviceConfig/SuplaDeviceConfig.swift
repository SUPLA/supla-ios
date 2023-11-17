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

fileprivate let CONFIG_MAXSIZE = UInt16(SUPLA_DEVICE_CONFIG_MAXSIZE)

enum SuplaFieldType: Int, CaseIterable {
    case statusLed = 0
    case screenBrightness = 1
    case buttonVolume = 2
    case disableUserInterface = 3
    case automaticTimeSync = 4
    case homeScreenOffDelay = 5
    case homeScreenContent = 6
    
    var value: UInt64 {
        UInt64(1 << rawValue)
    }
    
    static func from(bits: UInt64) -> [SuplaFieldType] {
        var fields: [SuplaFieldType] = []
        
        for field in SuplaFieldType.allCases {
            if ((field.value & bits) > 0) {
                fields.append(field)
            }
        }
        
        return fields
    }
}

protocol SuplaField: Equatable {
    var type: SuplaFieldType { get }
}

struct SuplaDeviceConfig {
    let deviceId: Int32
    let availableFields: [SuplaFieldType]
    let fields: [any SuplaField]
    
    init(config: TSCS_DeviceConfig) {
        deviceId = config.DeviceId
        availableFields = SuplaFieldType.from(bits: config.AvailableFields)
        fields = SuplaDeviceConfig.readFieldsFrom(config)
    }
    
    private static func readFieldsFrom(_ config: TSCS_DeviceConfig) -> [any SuplaField] {
        var offset = 0
        var fields: [any SuplaField] = []
        for field in SuplaFieldType.allCases {
            if ((field.value & config.Fields) == 0) {
                // Skip fields not flagged
                continue
            }
            
            var left = Int(config.ConfigSize > CONFIG_MAXSIZE ? CONFIG_MAXSIZE : config.ConfigSize)
            
            if (left > offset) {
                left -= offset
            } else {
                break
            }
            
            var size = 0
            
            switch (field) {
            case .statusLed:
                let structSize = MemoryLayout<TDeviceConfig_StatusLed>.size
                if (left >= structSize) {
                    fields.append(getLedStatus(config, Int(offset)))
                }
                size += structSize
            case .screenBrightness:
                let structSize = MemoryLayout<TDeviceConfig_ScreenBrightness>.size
                if (left >= structSize) {
                    fields.append(getScreenBrightness(config, Int(offset)))
                }
                size += structSize
            case .buttonVolume:
                let structSize = MemoryLayout<TDeviceConfig_ButtonVolume>.size
                if (left >= structSize) {
                    fields.append(getButtonVolume(config, Int(offset)))
                }
                size += structSize
            case .disableUserInterface:
                let structSize = MemoryLayout<TDeviceConfig_DisableUserInterface>.size
                if (left >= structSize) {
                    fields.append(getDisableUserInterface(config, Int(offset)))
                }
                size += structSize
            case .automaticTimeSync:
                let structSize = MemoryLayout<TDeviceConfig_AutomaticTimeSync>.size
                if (left >= structSize) {
                    fields.append(getAutomaticTimeSync(config, Int(offset)))
                }
                size += structSize
            case .homeScreenOffDelay:
                let structSize = MemoryLayout<TDeviceConfig_HomeScreenOffDelay>.size
                if (left >= structSize) {
                    fields.append(getHomeScreenOffDelay(config, Int(offset)))
                }
                size += structSize
            case .homeScreenContent:
                let structSize = MemoryLayout<TDeviceConfig_HomeScreenContent>.size
                if (left >= structSize) {
                    fields.append(getHomeScreenContent(config, Int(offset)))
                }
                size += structSize
            }
            
            offset += size
        }
        
        return fields
    }
    
    private static func getLedStatus(_ config: TSCS_DeviceConfig, _ offset: Int) -> SuplaLedStatusField {
        var configTable = config.Config
        return withUnsafeBytes(of: &configTable) { (rawPtr) -> SuplaLedStatusField in
            SuplaLedStatusField(
                config: rawPtr.baseAddress!
                    .advanced(by: offset)
                    .assumingMemoryBound(to: TDeviceConfig_StatusLed.self)
                    .pointee
            )
        }
    }
    
    private static func getScreenBrightness(_ config: TSCS_DeviceConfig, _ offset: Int) -> SuplaScreenBrightnessField {
        var configTable = config.Config
        return withUnsafeBytes(of: &configTable) { (rawPtr) -> SuplaScreenBrightnessField in
            SuplaScreenBrightnessField(
                config: rawPtr.baseAddress!
                    .advanced(by: offset)
                    .assumingMemoryBound(to: TDeviceConfig_ScreenBrightness.self)
                    .pointee
            )
        }
    }
    
    private static func getButtonVolume(_ config: TSCS_DeviceConfig, _ offset: Int) -> SuplaButtonVolumeField {
        var configTable = config.Config
        return withUnsafeBytes(of: &configTable) { (rawPtr) -> SuplaButtonVolumeField in
            SuplaButtonVolumeField(
                config: rawPtr.baseAddress!
                    .advanced(by: offset)
                    .assumingMemoryBound(to: TDeviceConfig_ButtonVolume.self)
                    .pointee
            )
        }
    }
    
    private static func getDisableUserInterface(_ config: TSCS_DeviceConfig, _ offset: Int) -> SuplaDisableUserInterfaceField {
        var configTable = config.Config
        return withUnsafeBytes(of: &configTable) { (rawPtr) -> SuplaDisableUserInterfaceField in
            SuplaDisableUserInterfaceField(
                config: rawPtr.baseAddress!
                    .advanced(by: offset)
                    .assumingMemoryBound(to: TDeviceConfig_DisableUserInterface.self)
                    .pointee
            )
        }
    }
    
    private static func getAutomaticTimeSync(_ config: TSCS_DeviceConfig, _ offset: Int) -> SuplaAutomaticTimeSyncField {
        var configTable = config.Config
        return withUnsafeBytes(of: &configTable) { (rawPtr) -> SuplaAutomaticTimeSyncField in
            SuplaAutomaticTimeSyncField(
                config: rawPtr.baseAddress!
                    .advanced(by: offset)
                    .assumingMemoryBound(to: TDeviceConfig_AutomaticTimeSync.self)
                    .pointee
            )
        }
    }
    
    private static func getHomeScreenOffDelay(_ config: TSCS_DeviceConfig, _ offset: Int) -> SuplaHomeScreenOffDelayField {
        var configTable = config.Config
        return withUnsafeBytes(of: &configTable) { (rawPtr) -> SuplaHomeScreenOffDelayField in
            SuplaHomeScreenOffDelayField(
                config: rawPtr.baseAddress!
                    .advanced(by: offset)
                    .assumingMemoryBound(to: TDeviceConfig_HomeScreenOffDelay.self)
                    .pointee
            )
        }
    }
    
    private static func getHomeScreenContent(_ config: TSCS_DeviceConfig, _ offset: Int) -> SuplaHomeScreenContentField {
        var configTable = config.Config
        return withUnsafeBytes(of: &configTable) { (rawPtr) -> SuplaHomeScreenContentField in
            SuplaHomeScreenContentField(
                config: rawPtr.baseAddress!
                    .advanced(by: offset)
                    .assumingMemoryBound(to: TDeviceConfig_HomeScreenContent.self)
                    .pointee
            )
        }
    }
}

