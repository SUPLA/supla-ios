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
    func invoke(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String
    func valueOrNil(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String?
}

extension GetChannelValueStringUseCase {
    func invoke(_ channel: SAChannel, valueType: ValueType = .first, withUnit: Bool = true) -> String {
        invoke(channel, valueType: valueType, withUnit: withUnit)
    }
    
    func valueOrNil(_ channel: SAChannel) -> String? {
        valueOrNil(channel, valueType: .first, withUnit: true)
    }
    
    func valueOrNil(_ channel: SAChannel, valueType: ValueType = .first) -> String? {
        valueOrNil(channel, valueType: valueType, withUnit: true)
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
        ContainerValueStringProvider()
    ]
    
    func invoke(_ channel: SAChannel, valueType: ValueType = .first, withUnit: Bool = true) -> String {
        return valueOrNil(channel, valueType: valueType, withUnit: withUnit) ?? NO_VALUE_TEXT
    }
    
    func valueOrNil(_ channel: SAChannel, valueType: ValueType = .first, withUnit: Bool = true) -> String? {
        let provider = providers.first { $0.handle(channel) }
        
        if (provider != nil && channel.status().offline) {
            return NO_VALUE_TEXT
        }
        
        if let provider {
            return provider.value(channel, valueType: valueType, withUnit: withUnit)
        }
        
        SALog.debug("No value provider for channel function `\(channel.func)`")
        return nil
    }
}


protocol ChannelValueStringProvider {
    func handle(_ channel: SAChannel) -> Bool
    func value(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String
}
