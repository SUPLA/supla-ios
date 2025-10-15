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

final class ThermometerAndHumidityValueStringProvider: ChannelValueStringProvider {
    @Singleton<ThermometerAndHumidityValueProvider> private var thermometerAndHumidityValueProvider
    @Singleton<ThermometerValueFormatter> private var temperatureFormatter
    
    private let humidityFormatter = HumidityValueFormatter()
    
    func handle(_ channel: SAChannel) -> Bool {
        channel.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
    }
    
    func value(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String {
        let value = thermometerAndHumidityValueProvider.value(channel, valueType: valueType)
        return switch(valueType) {
        case .first: temperatureFormatter.format(value: value, format: ValueFormatKt.withUnit(withUnit: withUnit))
        case .second: humidityFormatter.format(value: value, format: ValueFormatKt.withUnit(withUnit: withUnit))
        }
    }
}
