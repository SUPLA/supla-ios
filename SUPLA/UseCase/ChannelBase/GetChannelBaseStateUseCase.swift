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

protocol GetChannelBaseStateUseCase {
    func invoke(function: Int32, activeValue: Int32) -> ChannelState
}

final class GetChannelBaseStateUseCaseImpl: GetChannelBaseStateUseCase {
    
    func invoke(function: Int32, activeValue: Int32) -> ChannelState {
        switch (function) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
        SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR,
        SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            if ((activeValue & 0x2) == 0x2 && (activeValue & 0x1) == 0) {
                return .partialyOpened
            }
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY,
            SUPLA_CHANNELFNC_OPENINGSENSOR_GATE,
            SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR,
            SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
            SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER,
            SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
            SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW,
            SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW,
            SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW,
            SUPLA_CHANNELFNC_VALVE_OPENCLOSE,
            SUPLA_CHANNELFNC_VALVE_PERCENTAGE,
        SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            if (activeValue != 0) {
                return .closed
            } else {
                return .opened
            }
        case SUPLA_CHANNELFNC_POWERSWITCH,
            SUPLA_CHANNELFNC_STAIRCASETIMER,
            SUPLA_CHANNELFNC_NOLIQUIDSENSOR,
            SUPLA_CHANNELFNC_DIMMER,
            SUPLA_CHANNELFNC_RGBLIGHTING,
            SUPLA_CHANNELFNC_MAILSENSOR,
            SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS,
            SUPLA_CHANNELFNC_HOTELCARDSENSOR,
            SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR,
        SUPLA_CHANNELFNC_LIGHTSWITCH:
            if (activeValue != 0) {
                return .on
            } else {
                return .off
            }
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            let first: ChannelState = (activeValue & 0x1) != 0 ? .on : .off
            let second: ChannelState = (activeValue & 0x2) != 0 ? .on : .off
            return .complex([first, second])
        case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL,
        SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
            if (activeValue != 0) {
                return .transparent
            } else {
                return .opaque
            }
        default: return .notUsed
        }
        
        return .notUsed
    }
}
