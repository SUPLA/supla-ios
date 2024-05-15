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

protocol GetChannelBaseDefaultCaptionUseCase {
    func invoke(function: Int32) -> String
}

final class GetChannelBaseDefaultCaptionUseCaseImpl: GetChannelBaseDefaultCaptionUseCase {
    func invoke(function: Int32) -> String {
        switch (function) {
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
            return NSLocalizedString("Gateway opening sensor", comment: "")
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            return NSLocalizedString("Gateway", comment: "")
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
            return NSLocalizedString("Gate opening sensor", comment: "")
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            return NSLocalizedString("Gate", comment: "")
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
            return NSLocalizedString("Garage door opening sensor", comment: "")
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            return NSLocalizedString("Garage door", comment: "")
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
            return NSLocalizedString("Door opening sensor", comment: "")
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            return NSLocalizedString("Door", comment: "")
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
            return NSLocalizedString("Roller shutter opening sensor", comment: "")
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
            return NSLocalizedString("Roof window opening sensor", comment: "")
        case SUPLA_CHANNELFNC_HOTELCARDSENSOR:
            return Strings.General.Channel.captionHotelCard
        case SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR:
            return Strings.General.Channel.captionAlarmArmament
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            return NSLocalizedString("Roller shutter", comment: "")
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            return NSLocalizedString("Roof window", comment: "")
        case SUPLA_CHANNELFNC_POWERSWITCH:
            return NSLocalizedString("Power switch", comment: "")
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
            return NSLocalizedString("Lighting switch", comment: "")
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
            return NSLocalizedString("Staircase timer", comment: "")
        case SUPLA_CHANNELFNC_THERMOMETER:
            return NSLocalizedString("Thermometer", comment: "")
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return NSLocalizedString("Temperature and humidity", comment: "")
        case SUPLA_CHANNELFNC_HUMIDITY:
            return NSLocalizedString("Humidity", comment: "")
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
            return NSLocalizedString("No liquid sensor", comment: "")
        case SUPLA_CHANNELFNC_RGBLIGHTING:
            return NSLocalizedString("RGB Lighting", comment: "")
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return NSLocalizedString("Dimmer and RGB lighting", comment: "")
        case SUPLA_CHANNELFNC_DIMMER:
            return NSLocalizedString("Dimmer", comment: "")
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
            return NSLocalizedString("Distance sensor", comment: "")
        case SUPLA_CHANNELFNC_DEPTHSENSOR:
            return NSLocalizedString("Depth sensor", comment: "")
        case SUPLA_CHANNELFNC_WINDSENSOR:
            return NSLocalizedString("Wind sensor", comment: "")
        case SUPLA_CHANNELFNC_WEIGHTSENSOR:
            return NSLocalizedString("Weight sensor", comment: "")
        case SUPLA_CHANNELFNC_PRESSURESENSOR:
            return NSLocalizedString("Pressure sensor", comment: "")
        case SUPLA_CHANNELFNC_RAINSENSOR:
            return NSLocalizedString("Rain sensor", comment: "")
        case SUPLA_CHANNELFNC_MAILSENSOR:
            return NSLocalizedString("Mail sensor", comment: "")
        case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
            return NSLocalizedString("Window opening sensor", comment: "")
        case SUPLA_CHANNELFNC_ELECTRICITY_METER,
             SUPLA_CHANNELFNC_IC_ELECTRICITY_METER:
            return NSLocalizedString("Electricity Meter", comment: "")
        case SUPLA_CHANNELFNC_IC_GAS_METER:
            return NSLocalizedString("Gas Meter", comment: "")
        case SUPLA_CHANNELFNC_IC_WATER_METER:
            return NSLocalizedString("Water Meter", comment: "")
        case SUPLA_CHANNELFNC_IC_HEAT_METER:
            return NSLocalizedString("Heat Meter", comment: "")
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            return NSLocalizedString("Home+ Heater", comment: "")
        case SUPLA_CHANNELFNC_VALVE_OPENCLOSE,
             SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
            return NSLocalizedString("Valve", comment: "")
        case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL,
             SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
            return NSLocalizedString("Digiglass", comment: "")
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
             SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            return NSLocalizedString("Thermostat", comment: "")
        case SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT:
            return Strings.General.Channel.captionGeneralPurposeMeasurement
        case SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER:
            return Strings.General.Channel.captionGeneralPurposeMeter
        case SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND:
            return Strings.General.Channel.captionFacadeBlinds
        case SUPLA_CHANNELFNC_TERRACE_AWNING:
            return Strings.General.Channel.captionTerraceAwning
        default:
            return NSLocalizedString("Not supported function", comment: "")
        }
    }
}
