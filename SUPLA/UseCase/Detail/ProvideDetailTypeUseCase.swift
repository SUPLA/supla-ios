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

protocol ProvideDetailTypeUseCase {
    func invoke(channelBase: SAChannelBase) -> DetailType?
}

final class ProvideDetailTypeUseCaseImpl: ProvideDetailTypeUseCase {
    
    func invoke(channelBase: SAChannelBase) -> DetailType? {
        switch(channelBase.func) {
        case
            SUPLA_CHANNELFNC_DIMMER,
            SUPLA_CHANNELFNC_RGBLIGHTING,
            SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return .legacy(type: .rgbw)
        case
            SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
            SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            return .legacy(type: .rs)
        case
            SUPLA_CHANNELFNC_LIGHTSWITCH,
            SUPLA_CHANNELFNC_POWERSWITCH,
            SUPLA_CHANNELFNC_STAIRCASETIMER:
            return .switchDetail(pages: getSwitchDetailPages(channelBase: channelBase))
        case
            SUPLA_CHANNELFNC_ELECTRICITY_METER:
            return .legacy(type: .em)
        case
            SUPLA_CHANNELFNC_IC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_GAS_METER,
            SUPLA_CHANNELFNC_IC_WATER_METER,
            SUPLA_CHANNELFNC_IC_HEAT_METER:
            return .legacy(type: .ic)
        case
            SUPLA_CHANNELFNC_THERMOMETER,
            SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return .thermometerDetail(pages: [.thermometerHistory])
        case
            SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            return .legacy(type: .thermostat_hp)
        case
            SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL,
            SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
            return .legacy(type: .digiglass)
        case
            SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
            SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            return .thermostatDetail(pages: [.thermostatGeneral, .schedule, .thermostatTimer, .thermostatHistory])
        default:
            return nil
        }
    }
    
    private func getSwitchDetailPages(channelBase: SAChannelBase) -> [DetailPage] {
        guard let channel = channelBase as? SAChannel
        else { return [.switchGeneral] }
        
        var pages: [DetailPage] = [.switchGeneral]
        
        if (channel.flags & SUPLA_CHANNEL_FLAG_COUNTDOWN_TIMER_SUPPORTED > 0 && channel.func != SUPLA_CHANNELFNC_STAIRCASETIMER) {
            pages.append(.switchTimer)
        }
        
        if let type = channel.value?.sub_value_type {
            if (type == SUBV_TYPE_IC_MEASUREMENTS) {
                pages.append(.historyIc)
            }
            if (type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS) {
                pages.append(.historyEm)
            }
        }
        
        return pages
    }
}

enum DetailType: Equatable {
    case legacy(type: LegacyDetailType)
    case switchDetail(pages: [DetailPage])
    case thermostatDetail(pages: [DetailPage])
    case thermometerDetail(pages: [DetailPage])
}

enum LegacyDetailType {
    case rgbw, rs, ic, em, thermostat_hp, digiglass
}

enum DetailPage {
    // Switches
    case switchGeneral
    case switchTimer
    case historyIc
    case historyEm
    
    // Thermostat
    case thermostatGeneral
    case schedule
    case thermostatTimer
    case thermostatHistory
    
    // Thermometers
    case thermometerHistory
}
