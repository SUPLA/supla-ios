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

class SuplaChannelConfig {
    let remoteId: Int32
    let channelFunc: Int32?
    
    init(remoteId: Int32, channelFunc: Int32? = nil) {
        self.remoteId = remoteId
        self.channelFunc = channelFunc
    }
    
    static func from(suplaConfig: TSCS_ChannelConfig) -> SuplaChannelConfig {
        switch (suplaConfig.Func) {
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
            SUPLA_CHANNELFNC_HVAC_THERMOSTAT_AUTO,
        SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            switch(suplaConfig.ConfigType) {
            case UInt8(SUPLA_CONFIG_TYPE_DEFAULT):
                return SuplaChannelHvacConfig.from(
                    remoteId: suplaConfig.ChannelId,
                    channelFunc: suplaConfig.Func,
                    suplaConfig: SuplaChannelConfigIntegrator.extractHvacConfig(from: suplaConfig)
                )
            case UInt8(SUPLA_CONFIG_TYPE_WEEKLY_SCHEDULE):
                return SuplaChannelWeeklyScheduleConfig.from(
                    remoteId: suplaConfig.ChannelId,
                    channelFunc: suplaConfig.Func,
                    suplaConfig: SuplaChannelConfigIntegrator.extractWeeklyConfig(from: suplaConfig)
                )
            default:
                return SuplaChannelConfig(remoteId: suplaConfig.ChannelId, channelFunc: suplaConfig.Func)
            }
        default:
            return SuplaChannelConfig(remoteId: suplaConfig.ChannelId, channelFunc: suplaConfig.Func)
        }
    }
}

enum ChannelConfigResult: UInt8, CaseIterable {
    case resultFalse = 0
    case resultTrue = 1
    case dataError = 2
    case typeNotSupported = 3
    case functionNotSupported = 4
    case localConfigDisabled = 5
    case notAllowed = 6
    
    
    static func from(value: UInt8) -> ChannelConfigResult {
        for result in ChannelConfigResult.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        fatalError("Could not convert value `\(value)` to ChannelConfigResult")
    }
}
