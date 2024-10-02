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

protocol GetChannelValueUseCase {
    func invoke<T>(_ channel: SAChannel, valueType: ValueType) -> T
}

extension GetChannelValueUseCase {
    func invoke<T>(_ channel: SAChannel, valueType: ValueType = .first) -> T {
        invoke(channel, valueType: valueType)
    }
}

final class GetChannelValueUseCaseImpl: GetChannelValueUseCase {
    
    @Singleton<DepthValueProvider> private var depthValueProvider
    @Singleton<DistanceValueProvider> private var distanceValueProvider
    @Singleton<GpmValueProvider> private var gpmValueProvider
    @Singleton<HumidityValueProvider> private var humidityValueProvider
    @Singleton<PressureValueProvider> private var pressureValueProvider
    @Singleton<RainValueProvider> private var rainValueProvider
    @Singleton<ThermometerAndHumidityValueProvider> private var thermometerAndHumidityValueProvider
    @Singleton<ThermometerValueProvider> private var thermometerValueProvider
    @Singleton<WeightValueProvider> private var weightValueProvider
    @Singleton<WindValueProvider> private var windValueProvider
    @Singleton<ElectricityMeterValueProvider> private var electricityMeterValueProvider
    
    private lazy var providers: [ChannelValueProvider] = {
        [
            depthValueProvider,
            distanceValueProvider,
            gpmValueProvider,
            humidityValueProvider,
            pressureValueProvider,
            rainValueProvider,
            thermometerAndHumidityValueProvider,
            thermometerValueProvider,
            weightValueProvider,
            windValueProvider,
            electricityMeterValueProvider
        ]
    }()
    
    func invoke<T>(_ channel: SAChannel, valueType: ValueType = .first) -> T {
        for provider in providers {
            if (provider.handle(channel)) {
                return provider.value(channel, valueType: valueType) as! T
            }
        }
        
        fatalError("No value provider for channel function `\(channel.func)`")
    }
}

enum ValueType {
    case first, second
}

protocol ChannelValueProvider {
    func handle(_ channel: SAChannel) -> Bool
    
    func value(_ channel: SAChannel, valueType: ValueType) -> Any
}
