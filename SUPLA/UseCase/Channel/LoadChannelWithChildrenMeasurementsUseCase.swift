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

protocol LoadChannelWithChildrenMeasurementsUseCase {
    func invoke(remoteId: Int32, spec: ChartDataSpec) -> Observable<[ChannelChartSets]>
}

final class LoadChannelWithChildrenMeasurementsUseCaseImpl: LoadChannelWithChildrenMeasurementsUseCase {
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChidlrenUseCase
    @Singleton<TemperatureMeasurementsProvider> private var temperatureMeasurementsProvider
    @Singleton<TemperatureAndHumidityMeasurementsProvider> private var temperatureAndHumidityMeasurementsProvider
    @Singleton<ProfileRepository> private var profileRepository

    func invoke(remoteId: Int32, spec: ChartDataSpec) -> Observable<[ChannelChartSets]> {
        readChannelWithChidlrenUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channelWithChildren in
                self.profileRepository.getActiveProfile().map { (channelWithChildren, $0) }
            }
            .flatMapFirst {
                if ($0.0.channel.isHvacThermostat()) {
                    return self.buildDataSets($0.0, $0.1, spec)
                } else {
                    return Observable.error(
                        GeneralError.illegalArgument(message: "LoadChannelWithChildrenMeasurementsUseCase: channel function not supported (\($0.0.channel.func)")
                    )
                }
            }
    }

    private func buildDataSets(
        _ channelWithChildren: ChannelWithChildren,
        _ profile: AuthProfileItem,
        _ spec: ChartDataSpec
    ) -> Observable<[ChannelChartSets]> {
        var channelsWithMeasurements = channelWithChildren.children
            .sorted(by: { $0.relationType.value < $1.relationType.value })
            .filter { $0.channel.hasMeasurements() }
            .map { $0.withChildren }
        if (channelWithChildren.channel.hasMeasurements()) {
            channelsWithMeasurements.append(channelWithChildren)
        }

        let temperatureColors = TemperatureColors()
        let humidityColors = HumidityColors()
        var observables: [Observable<ChannelChartSets>] = []

        for channel in channelsWithMeasurements {
            if (channel.function == SUPLA_CHANNELFNC_THERMOMETER) {
                let color = temperatureColors.nextColor()
                observables.append(temperatureMeasurementsProvider.provide(channel, spec) { _ in color })
            } else if (channel.function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
                let firstColor = temperatureColors.nextColor()
                let secondColor = humidityColors.nextColor()
                observables.append(temperatureAndHumidityMeasurementsProvider.provide(channel, spec) { type in type == .humidity ? secondColor : firstColor })
            }
        }

        return Observable.zip(observables)
    }
}
