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

class HomePlusThermostatValueStringProvider: ChannelValueStringProvider {
    @Singleton<SharedCore.ThermometerValueFormatter> private var formatter
    @Singleton<HomePlusThermostatValueProvider> var homePlusThermostatValueProvider

    func handle(_ channel: ChannelWithChildren) -> Bool {
        homePlusThermostatValueProvider.handle(channel.channel)
    }

    func value(_ channel: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String {
        guard let value = homePlusThermostatValueProvider.value(channel.channel, valueType: valueType) as? HomePlusThermostatValue
        else { return NO_VALUE_TEXT }

        return switch (valueType) {
        case .first: formatter.format(value: value.measuredTemperature, format: ValueFormatKt.withUnit(withUnit: withUnit))
        case .second: formatter.format(value: value.presetTemperature, format: ValueFormatKt.withUnit(withUnit: withUnit))
        }
    }
}
