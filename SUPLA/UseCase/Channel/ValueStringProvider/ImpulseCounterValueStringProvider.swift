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
    
class ImpulseCounterValueStringProvider: ChannelValueStringProvider {
    @Singleton<ImpulseCounterValueProvider> private var impulseCounterValueProvider
    
    func handle(_ channel: SAChannel) -> Bool {
        impulseCounterValueProvider.handle(channel)
    }
    
    func value(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String {
        guard let value = impulseCounterValueProvider.value(channel, valueType: valueType) as? Double else {
            return NO_VALUE_TEXT
        }
        
        let unit = channel.ev?.impulseCounter().unit()
        if (channel.func == SUPLA_CHANNELFNC_IC_ELECTRICITY_METER) {
            let formatter = ListElectricityMeterValueFormatter(useNoValue: true)
            return formatter.format(value, withUnit: withUnit, precision: .defaultPrecision(value: 1), custom: FormatterUnit.custom(unit: unit))
        } else {
            let formatter = ImpulseCounterChartValueFormatter(unit: unit)
            return formatter.format(value, withUnit: withUnit)
        }
    }
}
