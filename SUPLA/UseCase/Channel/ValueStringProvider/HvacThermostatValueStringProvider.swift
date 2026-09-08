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

class HvacThermostatValueStringProvider: ChannelValueStringProvider {
    @Singleton<SharedCore.ThermometerValueFormatter> private var formatter
    @Singleton<HomePlusThermostatValueProvider> var homePlusThermostatValueProvider
    @Singleton<ThermometerValueProvider> private var thermometerValueProvider

    func handle(_ channel: ChannelWithChildren) -> Bool {
        channel.function == SUPLA_CHANNELFNC_HVAC_THERMOSTAT ||
            channel.function == SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL ||
            channel.function == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER
    }

    func value(_ channel: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String {
        guard let mainThermometer = channel.children.first(where: { $0.relationType == .mainThermometer })
        else { return NO_VALUE_TEXT }

        let valueTemperature = thermometerValueProvider.value(mainThermometer.channel, valueType: .first)
        return formatter.format(value: valueTemperature, format: ValueFormatKt.withUnit(withUnit: withUnit))
    }
}
