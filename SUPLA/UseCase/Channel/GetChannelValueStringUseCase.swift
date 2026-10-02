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

protocol GetChannelValueStringUseCase {
    func invoke(_ channelWithChildren: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String
    func valueOrNil(_ channelWithChildren: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String?
}

extension GetChannelValueStringUseCase {
    func invoke(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first, withUnit: Bool = true) -> String {
        invoke(channelWithChildren, valueType: valueType, withUnit: withUnit)
    }

    func valueOrNil(_ channelWithChildren: ChannelWithChildren) -> String? {
        valueOrNil(channelWithChildren, valueType: .first, withUnit: true)
    }

    func valueOrNil(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first) -> String? {
        valueOrNil(channelWithChildren, valueType: valueType, withUnit: true)
    }
}

final class GetChannelValueStringUseCaseImpl: GetChannelValueStringUseCase {
    
    private let providers: [ChannelValueStringProvider] = [
        DepthValueStringProvider(),
        DistanceValueStringProvider(),
        GpmValueStringProvider(),
        HumidityValueStringProvider(),
        PressureValueStringProvider(),
        RainValueStringProvider(),
        ThermometerAndHumidityValueStringProvider(),
        ThermometerValueStringProvider(),
        WeigthValueStringProvider(),
        WindValueStringProvider(),
        ElectricityMeterValueStringProvider(),
        SwitchWithElectricityMeterValueStringProvider(),
        ImpulseCounterValueStringProvider(),
        SwitchWithImpulseCounterValueStringProvider(),
        ContainerValueStringProvider(),
        HomePlusThermostatValueStringProvider(),
        HvacThermostatValueStringProvider()
    ]
    
    func invoke(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first, withUnit: Bool = true) -> String {
        return valueOrNil(channelWithChildren, valueType: valueType, withUnit: withUnit) ?? NO_VALUE_TEXT
    }
    
    func valueOrNil(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first, withUnit: Bool = true) -> String? {
        if let provider = providers.first(where: { $0.handle(channelWithChildren) }) {
            return provider.valueWithOfflineCheck(channelWithChildren, valueType: valueType, withUnit: withUnit)
        }
        
        SALog.debug("No value provider for channel function `\(channelWithChildren.function)`")
        return nil
    }
}


protocol ChannelValueStringProvider {
    func handle(_ channel: ChannelWithChildren) -> Bool
    func value(_ channel: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String
}

private extension ChannelValueStringProvider {
    func valueWithOfflineCheck(_ channel: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String {
        if (channel.channel.status().offline) {
            return NO_VALUE_TEXT
        }
        
        return value(channel, valueType: valueType, withUnit: withUnit)
    }
}
