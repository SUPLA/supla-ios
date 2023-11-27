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
    func invoke(
        remoteId: Int32,
        startDate: Date,
        endDate: Date,
        aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]>
}

final class LoadChannelMeasurementsUseCaseImpl: LoadChannelMeasurementsUseCase, BaseLoadMeasurementsUseCase {
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke(
        remoteId: Int32,
        startDate: Date,
        endDate: Date,
        aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]> {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channel in
                self.profileRepository.getActiveProfile().map { (channel, $0) }
            }
            .flatMapFirst {
                if ($0.0.isThermometer()) {
                    return self.buildDataSets($0.0, $0.1, startDate, endDate, aggregation)
                } else {
                    return Observable.error(
                        GeneralError.illegalArgument(message: "LoadChannelMeasurementsUseCase: channel function not supported (\($0.0.func)")
                    )
                }
            }
    }
    
    private func buildDataSets(
        _ channel: SAChannel,
        _ profile: AuthProfileItem,
        _ startDate: Date,
        _ endDate: Date,
        _ aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]> {
        let temperatureColors = TemperatureColors()
        let humidityColors = HumidityColors()
        
        if (channel.func == SUPLA_CHANNELFNC_THERMOMETER) {
            let color = temperatureColors.nextColor()
            return temperatureSets(channel, profile, startDate, endDate, aggregation, color)
        } else if (channel.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            let temperatureColor = temperatureColors.nextColor()
            let humidityColor = humidityColors.nextColor()
            return temperatureAndHumiditySets(channel, profile, startDate, endDate, aggregation, temperatureColor, humidityColor)
        } else {
            return Observable.empty()
        }
    }
    
    private func temperatureSets(
        _ channel: SAChannel,
        _ profile: AuthProfileItem,
        _ startDate: Date,
        _ endDate: Date,
        _ aggregation: ChartDataAggregation,
        _ color: UIColor
    ) -> Observable<[HistoryDataSet]> {
        return temperatureMeasurementItemRepository.findMeasurements(
            remoteId: channel.remote_id,
            profile: profile,
            startDate: startDate,
            endDate: endDate
        )
            .map { entities in self.aggregating(entities, aggregation) { $0.temperature?.toDouble() } }
            .map { [self.historyDataSet(channel, .temperature, color, aggregation, $0)]}
    }
    
    private func temperatureAndHumiditySets(
        _ channel: SAChannel,
        _ profile: AuthProfileItem,
        _ startDate: Date,
        _ endDate: Date,
        _ aggregation: ChartDataAggregation,
        _ temperatureColor: UIColor,
        _ humidityColor: UIColor
    ) -> Observable<[HistoryDataSet]> {
        return tempHumidityMeasurementItemRepository.findMeasurements(remoteId: channel.remote_id, profile: profile, startDate: startDate, endDate: endDate)
            .map { measurements in
                let aggregatedTemperatures = self.aggregating(measurements, aggregation) {
                    $0.temperature?.toDouble()
                }
                let aggregatedHumidites = self.aggregating(measurements, aggregation) {
                    $0.humidity?.toDouble()
                }
                
                return [
                    self.historyDataSet(channel, .temperature, temperatureColor, aggregation, aggregatedTemperatures),
                    self.historyDataSet(channel, .humidity, humidityColor, aggregation, aggregatedHumidites)
                ]
            }
    }
}
