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

import RxSwift

protocol LoadChannelMeasurementsUseCase {
    func invoke(remoteId: Int32, spec: ChartDataSpec) -> Observable<[ChannelChartSets]>
}

final class LoadChannelMeasurementsUseCaseImpl: LoadChannelMeasurementsUseCase {
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
    @Singleton<TemperatureMeasurementsProvider> private var temperatureMeasurementsProvider
    @Singleton<TemperatureAndHumidityMeasurementsProvider> private var temperatureAndHumidityMeasurementsProvider
    @Singleton<GeneralPurposeMeterMeasurementsProvider> private var generalPurposeMeterMeasurementsProvider
    @Singleton<GeneralPurposeMeasurementMeasurementsProvider> private var generalPurposeMeasurementMeasurementsProvider
    @Singleton<ElectricityMeterMeasurementsProvider> private var electricityMeterMeasurementsProvider
    @Singleton<HumidityMeasurementsProvider> private var humidityMeasurementsProvider
    @Singleton<ImpulseCounterMeasurementsProvider> private var impulseCounterMeasurementsProvider
    @Singleton<ThermostatHeatpolMeasurementsProvider> private var thermostatHeatpolMeasurementsProvider
    
    private lazy var providers: [ChannelMeasurementsProvider] = [
        temperatureMeasurementsProvider,
        temperatureAndHumidityMeasurementsProvider,
        generalPurposeMeterMeasurementsProvider,
        generalPurposeMeasurementMeasurementsProvider,
        electricityMeterMeasurementsProvider,
        humidityMeasurementsProvider,
        impulseCounterMeasurementsProvider,
        thermostatHeatpolMeasurementsProvider
    ]

    func invoke(remoteId: Int32, spec: ChartDataSpec) -> Observable<[ChannelChartSets]> {
        readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channelWithChildren in
                for provider in self.providers {
                    if provider.handle(channelWithChildren) {
                        return provider.provide(channelWithChildren, spec)
                    }
                }
                
                return Observable.error(GeneralError.illegalArgument(
                    message: "Channel function not supported (\(channelWithChildren.function)"
                ))
            }
    }
}
