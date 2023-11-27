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

final class GateIconNameProducer: IconNameProducer {
    func accepts(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_CONTROLLINGTHEGATE || function == SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
    }
    
    func produce(iconData: IconData) -> String {
        if (iconData.function == SUPLA_CHANNELFNC_CONTROLLINGTHEGATE && iconData.state == .partialyOpened && iconData.altIcon != 2) {
            return iconData.altIcon == 1 ? "gatealt1-closed-50percent" : "gate-closed-50percent"
        }
        
        return addStateSufix(name: gateName(iconData.altIcon), state: iconData.state)
    }
    
    private func gateName(_ altIcon: Int32) -> String {
        switch (altIcon) {
        case 1: return "gatealt1"
        case 2: return "barier"
        default: return "gate"
        }
    }
}
