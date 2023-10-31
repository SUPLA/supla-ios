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
    func invoke(
        remoteId: Int32,
        startDate: Date,
        endDate: Date,
        aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]>
}

final class LoadChannelWithChildrenMeasurementsUseCaseImpl: LoadChannelWithChildrenMeasurementsUseCase, BaseLoadMeasurementsUseCase {
    
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChidlrenUseCase
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke(
        remoteId: Int32,
        startDate: Date,
        endDate: Date,
        aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]> {
        readChannelWithChidlrenUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channelWithChildren in
                self.profileRepository.getActiveProfile().map { (channelWithChildren, $0) }
            }
            .flatMapFirst {
                if ($0.0.channel.isHvacThermostat()) {
                    return self.buildDataSets($0.0, $0.1, startDate, endDate, aggregation)
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
        _ startDate: Date,
        _ endDate: Date,
        _ aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]> {
        var channelsWithMeasurements = channelWithChildren.children
            .sorted(by: { $0.relationType.rawValue < $1.relationType.rawValue })
            .filter { $0.channel.hasMeasurements() }
            .map { $0.channel }
        if (channelWithChildren.channel.hasMeasurements()) {
            channelsWithMeasurements.append(channelWithChildren.channel)
        }
        
        let temperatureColors = TemperatureColors()
        let humidityColors = HumidityColors()
        var observables: [Observable<[HistoryDataSet]>] = []
        
        channelsWithMeasurements.forEach { channel in
            if (channel.func == SUPLA_CHANNELFNC_THERMOMETER) {
                let color = temperatureColors.nextColor()
                observables.append(
                    temperatureMeasurementItemRepository.findMeasurements(
                        remoteId: channel.remote_id,
                        profile: profile,
                        startDate: startDate,
                        endDate: endDate
                    )
                    .map { list in
                        self.aggregating(list, aggregation) { $0.temperature?.toDouble() }
                    }
                        .map { [self.historyDataSet(channel, .temperature, color, aggregation, $0)] }
                )
            } else if (channel.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
                let firstColor = temperatureColors.nextColor()
                let secondColor = humidityColors.nextColor()
                observables.append(
                    tempHumidityMeasurementItemRepository.findMeasurements(
                        remoteId: channel.remote_id,
                        profile: profile,
                        startDate: startDate,
                        endDate: endDate
                    )
                        .map {
                            let temperatures = self.aggregating($0, aggregation) {
                                Double(truncating: $0.temperature!)
                            }
                            let humidities = self.aggregating($0, aggregation) {
                                Double(truncating: $0.humidity!)
                            }
                            return [
                                self.historyDataSet(channel, .temperature, firstColor, aggregation, temperatures),
                                self.historyDataSet(channel, .humidity, secondColor, aggregation, humidities)
                            ]
                        }
                )
            }
        }
        
        return Observable.zip(observables) { items in
            var allSets: [HistoryDataSet] = []
            items.forEach { allSets.append(contentsOf: $0) }
            return allSets
        }
    }
}

