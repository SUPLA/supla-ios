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
            guard
                let channel = channelBase as? SAChannel,
                let type = channel.value?.sub_value_type
            else {
                return nil
            }
            switch (Int32(type)) {
            case SUBV_TYPE_IC_MEASUREMENTS:
                return .legacy(type: .ic)
            case SUBV_TYPE_ELECTRICITY_MEASUREMENTS:
                return .legacy(type: .em)
            default:
                return nil
            }
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
            SUPLA_CHANNELFNC_THERMOMETER:
            return .legacy(type: .temperature)
        case
            SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return .legacy(type: .temperature_humidity)
        case
            SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            return .legacy(type: .thermostat_hp)
        case
            SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL,
            SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
            return .legacy(type: .digiglass)
        default:
            return nil
        }
    }
}

enum DetailType: Equatable {
    case legacy(type: LegacyDetailType)
    case standard(type: StandardDetailType)
}

enum LegacyDetailType {
    case rgbw, rs, ic, em, temperature, temperature_humidity, thermostat_hp, digiglass
}

enum StandardDetailType {
    case switchType
}
