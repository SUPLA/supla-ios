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

import SharedCore

extension SAChannelBase {
    func getIconData(type: IconType = .single, subfunction: ThermostatSubfunction? = nil) -> FetchIconData {
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
        return FetchIconData(
            function: self.func,
            altIcon: self.alticon,
            profileId: profile.id,
            state: getChannelBaseStateUseCase.invoke(channelBase: self),
            type: type,
            userIconId: usericon_id,
            subfunction: subfunction
        )
    }
    
    func getIconData(state: ChannelState, type: IconType = .single, subfunction: ThermostatSubfunction? = nil) -> FetchIconData {
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
        return FetchIconData(
            function: self.func,
            altIcon: self.alticon,
            profileId: profile.id,
            state: state,
            type: type,
            userIconId: usericon_id,
            subfunction: subfunction
        )
    }

    func isElectricityMeter() -> Bool {
        self.func == SUPLA_CHANNELFNC_ELECTRICITY_METER
    }

    func isImpulseCounter() -> Bool {
        switch (self.func) {
            case SUPLA_CHANNELFNC_IC_GAS_METER,
                 SUPLA_CHANNELFNC_IC_HEAT_METER,
                 SUPLA_CHANNELFNC_IC_WATER_METER,
                 SUPLA_CHANNELFNC_IC_ELECTRICITY_METER: true
            default: false
        }
    }

    func isThermometer() -> Bool {
        return self.func == SUPLA_CHANNELFNC_THERMOMETER || self.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
    }

    func isGpm() -> Bool {
        return self.func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
            || self.func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
    }

    func isHvacThermostat() -> Bool {
        return self.func == SUPLA_CHANNELFNC_HVAC_THERMOSTAT || self.func == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER
    }
    
    func isValve() -> Bool {
        return self.func == SUPLA_CHANNELFNC_VALVE_OPENCLOSE || self.func == SUPLA_CHANNELFNC_VALVE_PERCENTAGE
    }

    func switchWithButtons() -> Bool {
        return switch (self.func) {
            case SUPLA_CHANNELFNC_POWERSWITCH,
                 SUPLA_CHANNELFNC_STAIRCASETIMER,
                 SUPLA_CHANNELFNC_LIGHTSWITCH: true
            default: false
        }
    }

    @objc
    func isRGBW() -> Bool {
        return self.func == SUPLA_CHANNELFNC_RGBLIGHTING || self.func == SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING || self.func == SUPLA_CHANNELFNC_DIMMER
    }

    @objc
    func isShadingSystem() -> Bool {
        return self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER ||
            self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW ||
            self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND ||
            self.func == SUPLA_CHANNELFNC_TERRACE_AWNING ||
            self.func == SUPLA_CHANNELFNC_CURTAIN ||
            self.func == SUPLA_CHANNELFNC_VERTICAL_BLIND
    }

    func hasMeasurements() -> Bool {
        return self.func == SUPLA_CHANNELFNC_THERMOMETER || self.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
    }
    
    var shareableBase: SharedCore.BaseData {
        if let channel = self as? SAChannel {
            return channel.shareable
        }
        if let group = self as? SAChannelGroup {
            return group.shareable
        }
        
        fatalError("Unexpected type: \(self)")
    }
}
