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
    @Singleton<ValuesFormatter> private var formatter
    
    func invoke(channelWithChildren: ChannelWithChildren) -> [MeasurementValue] {
        let children = channelWithChildren.children
            .filter { $0.relationType.isThermometer() }
            .sorted { $0.relationType.value < $1.relationType.value }
        
        var result: [MeasurementValue] = []
        if (children.filter({ $0.relationType == .mainThermometer }).isEmpty) {
            result.append(MeasurementValue(icon: .suplaIcon(name: .Icons.fncUnknown), value: NO_VALUE_TEXT))
        }
        
        for child in children {
            result.append(child.channel.toTemperatureValue(getChannelBaseIconUseCase, formatter))
            if (child.channel.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
                result.append(child.channel.toHumidityValue(getChannelBaseIconUseCase, formatter))
            }
        }
        return result
    }
}

fileprivate extension SAChannel {
    func toTemperatureValue(
        _ getChannelBaseIconUseCase: GetChannelBaseIconUseCase,
        _ valuesFormatter: ValuesFormatter
    ) -> MeasurementValue {
        MeasurementValue(
            icon: getChannelBaseIconUseCase.invoke(channel: self),
            value: isOnline() ? valuesFormatter.temperatureToString(temperatureValue(), withUnit: false) : NO_VALUE_TEXT
        )
    }
    
    func toHumidityValue(
        _ getChannelBaseIconUseCase: GetChannelBaseIconUseCase,
        _ valuesFormatter: ValuesFormatter
    ) -> MeasurementValue {
        MeasurementValue(
            icon: getChannelBaseIconUseCase.invoke(channel: self, type: .second),
            value: isOnline() ? valuesFormatter.humidityToString(humidityValue()) : NO_VALUE_TEXT
        )
    }
}
