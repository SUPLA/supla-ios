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

class SuplaChannelConfig: Codable {
    let remoteId: Int32
    let channelFunc: Int32?
    
    init(remoteId: Int32, channelFunc: Int32? = nil) {
        self.remoteId = remoteId
        self.channelFunc = channelFunc
    }
    
    static func from(suplaConfig: TSCS_ChannelConfig, crc32: Int64) -> SuplaChannelConfig {
        if (suplaConfig.isHvacConfig()) {
            return SuplaChannelHvacConfig.from(
                remoteId: suplaConfig.ChannelId,
                channelFunc: suplaConfig.Func,
                suplaConfig: suplaConfig.asHvacConfig()
            )
        }
        if (suplaConfig.isWeeklyConfig()) {
            return SuplaChannelWeeklyScheduleConfig.from(
                remoteId: suplaConfig.ChannelId,
                channelFunc: suplaConfig.Func,
                suplaConfig: suplaConfig.asWeeklyConfig()
            )
        }
        if (suplaConfig.isGpMeterConfig()) {
            return SuplaChannelGeneralPurposeMeterConfig.from(
                remoteId: suplaConfig.ChannelId,
                function: suplaConfig.Func,
                config: suplaConfig.asGpMeterConfig(),
                crc32: crc32
            )
        }
        if (suplaConfig.isGpMeasurementConfig()) {
            return SuplaChannelGeneralPurposeMeasurementConfig.from(
                remoteId: suplaConfig.ChannelId,
                function: suplaConfig.Func,
                config: suplaConfig.asGpMeasurementConfig(),
                crc32: crc32
            )
        }
        
        return SuplaChannelConfig(remoteId: suplaConfig.ChannelId, channelFunc: suplaConfig.Func)
    }
}

fileprivate extension TSCS_ChannelConfig {
    func isHvacConfig() -> Bool {
        isHvac()
        && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
        && ConfigSize == MemoryLayout<TChannelConfig_HVAC>.size
    }
    
    func asHvacConfig() -> TChannelConfig_HVAC {
        var config = Config
        return withUnsafePointer(to: &config) { pointee in
            UnsafeRawPointer(pointee).assumingMemoryBound(to: TChannelConfig_HVAC.self).pointee
        }
    }
    
    func isWeeklyConfig() -> Bool {
        isHvac()
        && ConfigType == UInt8(SUPLA_CONFIG_TYPE_WEEKLY_SCHEDULE)
        && ConfigSize == MemoryLayout<TChannelConfig_WeeklySchedule>.size
    }
    
    func asWeeklyConfig() -> TChannelConfig_WeeklySchedule {
        var config = Config
        return withUnsafePointer(to: &config) { pointee in
            UnsafeRawPointer(pointee).assumingMemoryBound(to: TChannelConfig_WeeklySchedule.self).pointee
        }
    }
    
    func isGpMeterConfig() -> Bool {
        Func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
        && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
        && ConfigSize == MemoryLayout<TChannelConfig_GeneralPurposeMeter>.size
    }
    
    func asGpMeterConfig() -> TChannelConfig_GeneralPurposeMeter {
        var config = Config
        return withUnsafePointer(to: &config) { pointee in
            UnsafeRawPointer(pointee).assumingMemoryBound(to: TChannelConfig_GeneralPurposeMeter.self).pointee
        }
    }
    
    func isGpMeasurementConfig() -> Bool {
        Func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
        && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
        && ConfigSize == MemoryLayout<TChannelConfig_GeneralPurposeMeasurement>.size
    }
    
    func asGpMeasurementConfig() -> TChannelConfig_GeneralPurposeMeasurement {
        var config = Config
        return withUnsafePointer(to: &config) { pointee in
            UnsafeRawPointer(pointee).assumingMemoryBound(to: TChannelConfig_GeneralPurposeMeasurement.self).pointee
        }
    }
    
    private func isHvac() -> Bool {
        switch(Func) {
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
            SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL,
        SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER: return true
            
        default: return false
        }
    }
}
