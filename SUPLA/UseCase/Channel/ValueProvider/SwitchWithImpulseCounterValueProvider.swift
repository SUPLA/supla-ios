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

protocol SwitchWithImpulseCounterValueProvider: ChannelValueProvider {}

class SwitchWithImpulseCounterValueProviderImpl: SwitchWithImpulseCounterValueProvider, LongValueParser {
    func handle(_ channel: SAChannel) -> Bool {
        switch (channel.func) {
        case SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER:
            (channel.value?.sub_value_type ?? 0) == SUBV_TYPE_IC_MEASUREMENTS
        default: false
        }
    }

    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        if let value = asLongValue(channel.value?.dataSubValue()) {
            Double(value) / 1000
        } else {
            ImpulseCounterValueProviderImpl.UNKNOWN_VALUE
        }
    }
}
