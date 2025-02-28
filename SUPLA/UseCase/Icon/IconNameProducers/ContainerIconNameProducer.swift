//
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
    
final class ContainerIconNameProducer: IconNameProducer {
    func accepts(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_CONTAINER
    }

    func produce(iconData: IconData) -> String {
        switch (iconData.altIcon) {
        case 1: addStateSuffix(name: .Icons.fncContainer1, state: iconData.state)
        case 2: addStateSuffix(name: .Icons.fncContainer2, state: iconData.state)
        case 3: addStateSuffix(name: .Icons.fncContainer3, state: iconData.state)
        default: addStateSuffix(name: .Icons.fncContainer, state: iconData.state)
        }
    }
}
