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
    
final class BinarySensorIconNameProducer: IconNameProducer {
    func accepts(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_BINARY_SENSOR
    }

    func produce(iconData: FetchIconData) -> String {
        switch (iconData.altIcon) {
        case 1: addStateSuffix(name: .Icons.fncBinarySensor1, value: iconData.state.value)
        case 2: addStateSuffix(name: .Icons.fncBinarySensor2, value: iconData.state.value)
        case 3: addStateSuffix(name: .Icons.fncBinarySensor3, value: iconData.state.value)
        case 4: addStateSuffix(name: .Icons.fncBinarySensor4, value: iconData.state.value)
        case 5: addStateSuffix(name: .Icons.fncBinarySensor5, value: iconData.state.value)
        case 6: addStateSuffix(name: .Icons.fncBinarySensor6, value: iconData.state.value)
        case 7: addStateSuffix(name: .Icons.fncBinarySensor7, value: iconData.state.value)
        case 8: addStateSuffix(name: .Icons.fncBinarySensor8, value: iconData.state.value)
        case 9: addStateSuffix(name: .Icons.fncBinarySensor9, value: iconData.state.value)
        default: addStateSuffix(name: .Icons.fncBinarySensor, value: iconData.state.value)
        }
    }
}
