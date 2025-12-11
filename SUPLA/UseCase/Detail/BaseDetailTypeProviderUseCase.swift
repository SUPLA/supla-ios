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

private let ZAM_PRODID_DIW_01 = 2000
private let COM_PRODID_WDIM100 = 2000

class BaseDetailTypeProviderUseCase {
    func provide(_ channelBase: SAChannelBase) -> DetailType? {
        switch channelBase.func {
        case SUPLA_CHANNELFNC_DIMMER:
            return .standardDetail(pages: shouldShowRgbSettings(channelBase) ? [.dimmer, .legacyDimmerSettings] : [.dimmer])
        case SUPLA_CHANNELFNC_RGBLIGHTING:
            return .standardDetail(pages: shouldShowRgbSettings(channelBase) ? [.rgb, .legacyDimmerSettings] : [.rgb])
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return .standardDetail(pages: shouldShowRgbSettings(channelBase) ? [.rgb, .dimmer, .legacyDimmerSettings] : [.rgb, .dimmer])
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            return .standardDetail(pages: [.roofWindow])
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            return .standardDetail(pages: [.rollerShutter])
        case SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND:
            return .standardDetail(pages: [.facadeBlind])
        case SUPLA_CHANNELFNC_TERRACE_AWNING:
            return .standardDetail(pages: [.terraceAwning])
        case SUPLA_CHANNELFNC_PROJECTOR_SCREEN:
            return .standardDetail(pages: [.projectorScreen])
        case SUPLA_CHANNELFNC_CURTAIN:
            return .standardDetail(pages: [.curtain])
        case SUPLA_CHANNELFNC_VERTICAL_BLIND:
            return .standardDetail(pages: [.verticalBlind])
        case SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR:
            return .standardDetail(pages: [.garageDoor])
        case
            SUPLA_CHANNELFNC_LIGHTSWITCH,
            SUPLA_CHANNELFNC_POWERSWITCH,
            SUPLA_CHANNELFNC_STAIRCASETIMER,
            SUPLA_CHANNELFNC_PUMPSWITCH,
            SUPLA_CHANNELFNC_HEATORCOLDSOURCESWITCH:
            return .standardDetail(pages: [.switchGeneral])
        case
            SUPLA_CHANNELFNC_ELECTRICITY_METER:
            return .standardDetail(pages: [
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
            return .standardDetail(pages: [.thermometerHistory])
        case SUPLA_CHANNELFNC_HUMIDITY:
            return .standardDetail(pages: [.humidityHistory])
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
            return .standardDetail(pages: [.thermostatGeneral, .schedule, .thermostatTimer, .thermostatHistory])
        case
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT:
            return .standardDetail(pages: [.gpmHistory])
            
        case
            SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
            SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
            SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            return .standardDetail(pages: [.gateGeneral])
        default:
            return nil
        }
    }
    
    private func shouldShowRgbSettings(_ channelBase: SAChannelBase) -> Bool {
        guard let channel = channelBase as? SAChannel else { return false }
        
        let manufacturerId = channel.manufacturer_id
        let productId = channel.product_id
        
        return manufacturerId == SUPLA_MFR_DOYLETRATT && productId == 1 ||
            manufacturerId == SUPLA_MFR_ZAMEL && productId == ZAM_PRODID_DIW_01 ||
            manufacturerId == SUPLA_MFR_COMELIT && productId == COM_PRODID_WDIM100
    }
}

enum DetailType: Equatable {
    case legacy(type: LegacyDetailType)
    case standardDetail(pages: [DetailPage])
    case impulseCounterDetail(pages: [DetailPage])
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
    case thermostatHeatpolGeneral
    case thermostatHeatpolHistory
    
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
    
    // Container
    case containerGeneral
    
    // Gate
    case gateGeneral
    
    // RGBW
    case dimmer
    case rgb
    case legacyDimmerSettings
}
