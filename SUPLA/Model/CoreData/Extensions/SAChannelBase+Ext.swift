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

extension SAChannelBase {
    func getIconData(type: IconType = .single, subfunction: ThermostatSubfunction? = nil) -> IconData {
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
        return IconData(
            function: self.func,
            altIcon: self.alticon,
            state: getChannelBaseStateUseCase.invoke(channelBase: self),
            type: type,
            userIcon: self.usericon,
            subfunction: subfunction
        )
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

    @objc
    func isRGBW() -> Bool {
        return self.func == SUPLA_CHANNELFNC_RGBLIGHTING || self.func == SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING || self.func == SUPLA_CHANNELFNC_DIMMER
    }

    @objc
    func isShadingSystem() -> Bool {
        return self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER ||
            self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW ||
            self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
    }

    func hasMeasurements() -> Bool {
        return self.func == SUPLA_CHANNELFNC_THERMOMETER || self.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
    }
}
