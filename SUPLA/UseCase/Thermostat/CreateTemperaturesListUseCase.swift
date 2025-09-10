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

protocol CreateTemperaturesListUseCase {
    func invoke(channelWithChildren: ChannelWithChildren) -> [MeasurementValue]
}

final class CreateTemperaturesListUseCaseImpl: CreateTemperaturesListUseCase {
    
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<GetChannelBatteryIconUseCase> private var getChannelBatteryIconUseCase
    @Singleton<ValuesFormatter> private var formatter
    
    func invoke(channelWithChildren: ChannelWithChildren) -> [MeasurementValue] {
        let temperatureControlType = channelWithChildren.channel.temperatureControlType
        let children = channelWithChildren.children
            .filter { $0.relationType.isThermometer() }
            .sorted {
                if (temperatureControlType == .aux_heater_cooler_temperature) {
                    $0.relationType.value > $1.relationType.value
                } else {
                    $0.relationType.value < $1.relationType.value
                }
            }
        
        var result: [MeasurementValue] = []
        if (children.filter({ $0.relationType == .mainThermometer }).isEmpty) {
            result.append(MeasurementValue(id: result.count, icon: .suplaIcon(name: .Icons.fncUnknown), value: NO_VALUE_TEXT))
        }
        
        for child in children {
            result.append(child.channel.toTemperatureValue(result.count, getChannelBaseIconUseCase, getChannelBatteryIconUseCase))
            if (child.channel.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
                result.append(child.channel.toHumidityValue(result.count, getChannelBaseIconUseCase, getChannelBatteryIconUseCase, formatter))
            }
        }
        return result
    }
}

fileprivate extension SAChannel {
    func toTemperatureValue(
        _ id: Int,
        _ getChannelBaseIconUseCase: GetChannelBaseIconUseCase,
        _ getChannelBatteryIconUseCase: GetChannelBatteryIconUseCase
    ) -> MeasurementValue {
        MeasurementValue(
            id: id,
            icon: getChannelBaseIconUseCase.invoke(channel: self),
            value: status().online ? temperatureValue().toTemperatureString() : NO_VALUE_TEXT,
            batteryIcon: getChannelBatteryIconUseCase.invoke(channel: shareable)
        )
    }
    
    func toHumidityValue(
        _ id: Int,
        _ getChannelBaseIconUseCase: GetChannelBaseIconUseCase,
        _ getChannelBatteryIconUseCase: GetChannelBatteryIconUseCase,
        _ valuesFormatter: ValuesFormatter
    ) -> MeasurementValue {
        MeasurementValue(
            id: id,
            icon: getChannelBaseIconUseCase.invoke(channel: self, type: .second),
            value: status().online ? valuesFormatter.humidityToString(humidityValue()) : NO_VALUE_TEXT,
            batteryIcon: getChannelBatteryIconUseCase.invoke(channel: shareable)
        )
    }
}
