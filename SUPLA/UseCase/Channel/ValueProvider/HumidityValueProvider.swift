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

protocol HumidityValueProvider: ChannelValueProvider {
}

final class HumidityValueProviderImpl: HumidityValueProvider, IntValueParser {
    
    func handle(_ channel: SAChannel) -> Bool {
        channel.func == SUPLA_CHANNELFNC_HUMIDITY
    }
    
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        if let intValue = asIntValue(channel.value?.dataValue(), startingFromByte: 4) {
            return Double(intValue) / 1000.0
        }
        
        return HumidityValueProviderImpl.UNKNOWN_VALUE
    }
    
    static let UNKNOWN_VALUE = -1.0
}

