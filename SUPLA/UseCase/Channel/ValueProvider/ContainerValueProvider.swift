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

import SharedCore

protocol ContainerValueProvider: ChannelValueProvider {}

final class ContainerValueProviderImpl: ContainerValueProvider {
    func handle(_ channel: SAChannel) -> Bool {
        switch channel.func {
        case SUPLA_CHANNELFNC_CONTAINER,
             SUPLA_CHANNELFNC_WATER_TANK,
             SUPLA_CHANNELFNC_SEPTIC_TANK:
            true
        default:
            false
        }
    }

    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        channel.value?.asContainerValue() ?? ContainerValue(
            status: channel.status(),
            flags: [],
            rawLevel: 0
        )
    }
}
