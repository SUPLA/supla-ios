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

class BaseDetailTypeProviderUseCase {
    func provide(_ channelBase: SAChannelBase) -> DetailType? {
        switch channelBase.func {
        case
            SUPLA_CHANNELFNC_DIMMER,
            SUPLA_CHANNELFNC_RGBLIGHTING,
            SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return .legacy(type: .rgbw)
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            return .windowDetail(pages: [.roofWindow])
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            return .windowDetail(pages: [.rollerShutter])
        case SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND:
            return .windowDetail(pages: [.facadeBlind])
        case SUPLA_CHANNELFNC_TERRACE_AWNING:
            return .windowDetail(pages: [.terraceAwning])
        case SUPLA_CHANNELFNC_PROJECTOR_SCREEN:
            return .windowDetail(pages: [.projectorScreen])
        case SUPLA_CHANNELFNC_CURTAIN:
            return .windowDetail(pages: [.curtain])
        case SUPLA_CHANNELFNC_VERTICAL_BLIND:
            return .windowDetail(pages: [.verticalBlind])
        case SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR:
            return .windowDetail(pages: [.garageDoor])
        case
            SUPLA_CHANNELFNC_ELECTRICITY_METER:
            return .electricityMeterDetail(pages: [
                .electricityMeterGeneral,
                .electricityMeterHistory,
                .electricityMeterSettings
            ])
        case
            SUPLA_CHANNELFNC_IC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_GAS_METER,
            SUPLA_CHANNELFNC_IC_WATER_METER,
            SUPLA_CHANNELFNC_IC_HEAT_METER:
            return .impulseCounterDetail(pages: [.impulseCounterGeneral, .impulseCounterHistory])
        case
            SUPLA_CHANNELFNC_THERMOMETER,
            SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return .thermometerDetail(pages: [.thermometerHistory])
        case SUPLA_CHANNELFNC_HUMIDITY:
            return .humidityDetail(pages: [.humidityHistory])
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
        case
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT:
            return .gpmDetail(pages: [.gpmHistory])
        default:
            return nil
        }
    }
}

enum DetailType: Equatable {
    case legacy(type: LegacyDetailType)
    case switchDetail(pages: [DetailPage])
    case thermostatDetail(pages: [DetailPage])
    case thermometerDetail(pages: [DetailPage])
    case gpmDetail(pages: [DetailPage])
    case windowDetail(pages: [DetailPage])
    case electricityMeterDetail(pages: [DetailPage])
    case impulseCounterDetail(pages: [DetailPage])
    case humidityDetail(pages: [DetailPage])
    case valveDetail(pages: [DetailPage])
}

enum LegacyDetailType {
    case rgbw, ic, thermostat_hp, digiglass
}

enum DetailPage {
    // Switches
    case switchGeneral
    case switchTimer
    
    // Thermostat
    case thermostatGeneral
    case thermostatList
    case schedule
    case thermostatTimer
    case thermostatHistory
    
    // Thermometers
    case thermometerHistory
    
    // Humidity
    case humidityHistory
    
    // GPM
    case gpmHistory
    
    // Shading systems
    case rollerShutter
    case roofWindow
    case facadeBlind
    case terraceAwning
    case projectorScreen
    case curtain
    case verticalBlind
    case garageDoor
    
    // EM
    case electricityMeterGeneral
    case electricityMeterHistory
    case electricityMeterSettings
    
    // IC
    case impulseCounterGeneral
    case impulseCounterHistory
    case impulseCounterOcr
    
    // Valve
    case valveGeneral
}
