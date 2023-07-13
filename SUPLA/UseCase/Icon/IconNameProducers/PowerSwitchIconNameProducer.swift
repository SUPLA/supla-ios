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

final class PowerSwitchIconNameProducer: IconNameProducer {
    func accepts(function: Int32) -> Bool {
        return function == SUPLA_CHANNELFNC_POWERSWITCH
    }
    
    func produce(function: Int32, state: ChannelState, altIcon: Int32, iconType: IconType) -> String {
        addStateSufix(name: switchIcon(altIcon), state: state)
    }
    
    private func switchIcon(_ altIcon: Int32) -> String {
        switch (altIcon) {
        case 1: return "tv"
        case 2: return "radio"
        case 3: return "pc"
        case 4: return "fan"
        default: return "power"
        }
    }
}