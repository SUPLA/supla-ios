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
    let crc32: Int64
    
    init(remoteId: Int32, channelFunc: Int32? = nil, crc32: Int64 = 0) {
        self.remoteId = remoteId
        self.channelFunc = channelFunc
        self.crc32 = crc32
    }
    
    static func from(suplaConfig: TSCS_ChannelConfig, crc32: Int64) -> SuplaChannelConfig {
        if (suplaConfig.isContainerConfig()) {
            var config: TChannelConfig_Container = suplaConfig.cast()
            return SuplaChannelContainerConfig.from(
                remoteId: suplaConfig.ChannelId,
                channelFunc: suplaConfig.Func,
                crc32: crc32,
                suplaConfig: &config
            )
        }
        if (suplaConfig.isHvacConfig()) {
            return SuplaChannelHvacConfig.from(
                remoteId: suplaConfig.ChannelId,
                channelFunc: suplaConfig.Func,
                crc32: crc32,
                suplaConfig: suplaConfig.cast()
            )
        }
        if (suplaConfig.isWeeklyConfig()) {
            return SuplaChannelWeeklyScheduleConfig.from(
                remoteId: suplaConfig.ChannelId,
                channelFunc: suplaConfig.Func,
                crc32: crc32,
                suplaConfig: suplaConfig.cast()
            )
        }
        if (suplaConfig.isGpMeterConfig()) {
            return SuplaChannelGeneralPurposeMeterConfig.from(
                remoteId: suplaConfig.ChannelId,
                function: suplaConfig.Func,
                config: suplaConfig.cast(),
                crc32: crc32
            )
        }
        if (suplaConfig.isGpMeasurementConfig()) {
            return SuplaChannelGeneralPurposeMeasurementConfig.from(
                remoteId: suplaConfig.ChannelId,
                function: suplaConfig.Func,
                config: suplaConfig.cast(),
                crc32: crc32
            )
        }
        if (suplaConfig.isRollerShutterConfig()) {
            return SuplaChannelRollerShutterConfig.from(
                suplaConfig.cast(),
                remoteId: suplaConfig.ChannelId,
                channelFunc: suplaConfig.Func,
                crc32: crc32
            )
        }
        if (suplaConfig.isFacadeBlindConfig()) {
            return SuplaChannelFacadeBlindConfig.from(
                suplaConfig.cast(),
                remoteId: suplaConfig.ChannelId,
                channelFunc: suplaConfig.Func,
                crc32: crc32
            )
        }
        
        return SuplaChannelConfig(remoteId: suplaConfig.ChannelId, channelFunc: suplaConfig.Func, crc32: crc32)
    }
}

private extension TSCS_ChannelConfig {
    func isHvacConfig() -> Bool {
        isHvac()
            && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
            && ConfigSize == MemoryLayout<TChannelConfig_HVAC>.size
    }
    
    func isWeeklyConfig() -> Bool {
        isHvac()
            && ConfigType == UInt8(SUPLA_CONFIG_TYPE_WEEKLY_SCHEDULE)
            && ConfigSize == MemoryLayout<TChannelConfig_WeeklySchedule>.size
    }
    
    func isGpMeterConfig() -> Bool {
        Func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
            && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
            && ConfigSize == MemoryLayout<TChannelConfig_GeneralPurposeMeter>.size
    }
    
    func isGpMeasurementConfig() -> Bool {
        Func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
            && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
            && ConfigSize == MemoryLayout<TChannelConfig_GeneralPurposeMeasurement>.size
    }
    
    func isRollerShutterConfig() -> Bool {
        Func == SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
            && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
            && ConfigSize == MemoryLayout<TChannelConfig_RollerShutter>.size
    }
    
    func isFacadeBlindConfig() -> Bool {
        Func == SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
            && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
            && ConfigSize == MemoryLayout<TChannelConfig_FacadeBlind>.size
    }
    
    func isContainerConfig() -> Bool {
        isContainer()
            && ConfigType == UInt8(SUPLA_CONFIG_TYPE_DEFAULT)
            && ConfigSize == MemoryLayout<TChannelConfig_Container>.size
    }
    
    func cast<T>() -> T {
        var config = Config
        return withUnsafePointer(to: &config) { pointee in
            UnsafeRawPointer(pointee).assumingMemoryBound(to: T.self).pointee
        }
    }
    
    private func isHvac() -> Bool {
        switch (Func) {
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
             SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL,
             SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER: return true
            
        default: return false
        }
    }
    
    private func isContainer() -> Bool {
        switch (Func) {
        case SUPLA_CHANNELFNC_CONTAINER,
             SUPLA_CHANNELFNC_WATER_TANK,
             SUPLA_CHANNELFNC_SEPTIC_TANK: true
        default: false
        }
    }
}
