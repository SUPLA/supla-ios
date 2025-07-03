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

final class WindValueStringProvider: ChannelValueStringProvider {
    @Singleton<WindValueProvider> private var windValueProvider
    
    func handle(_ channel: SAChannel) -> Bool {
        channel.func == SUPLA_CHANNELFNC_WINDSENSOR
    }
    
    func value(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String {
        if let value = windValueProvider.value(channel, valueType: valueType) as? Double,
           value > WindValueProviderImpl.UNKNOWN_VALUE && value.isNaN == false
        {
            return withUnit ? "\(value.toString(precision: 1)) m/s" : value.toString(precision: 1)
        } else {
            return NO_VALUE_TEXT
        }
    }
}
