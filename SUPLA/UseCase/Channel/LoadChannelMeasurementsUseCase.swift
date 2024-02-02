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
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository
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
                if ($0.0.isThermometer() || $0.0.isGpm()) {
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
        } else if (channel.func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT) {
            return generalPurposeMeasurementSets(channel, profile, startDate, endDate, aggregation)
        } else if (channel.func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER) {
            return generalPurposeMeterSets(channel, profile, startDate, endDate, aggregation)
        } else {
            return Observable.error(GeneralError.illegalState(
                message: "LoadChannelMeasurementUseCase - not supported function \(channel.func)"
            ))
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
        .map { entities in self.aggregatingTemperature(entities, aggregation) }
        .map { [self.historyDataSet(channel, .temperature, color, aggregation, $0)] }
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
                let aggregatedTemperatures = self.aggregatingTemperatureOrHumidity(measurements, aggregation, .temperature) {
                    $0.temperature?.toDouble()
                }
                let aggregatedHumidites = self.aggregatingTemperatureOrHumidity(measurements, aggregation, .humidity) {
                    $0.humidity?.toDouble()
                }

                return [
                    self.historyDataSet(channel, .temperature, temperatureColor, aggregation, aggregatedTemperatures),
                    self.historyDataSet(channel, .humidity, humidityColor, aggregation, aggregatedHumidites)
                ]
            }
    }

    private func generalPurposeMeasurementSets(
        _ channel: SAChannel,
        _ profile: AuthProfileItem,
        _ startDate: Date,
        _ endDate: Date,
        _ aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]> {
        return generalPurposeMeasurementItemRepository.findMeasurements(
            remoteId: channel.remote_id,
            profile: profile,
            startDate: startDate,
            endDate: endDate
        )
        .map { entities in self.aggregatingGeneralPurposeMeasurement(entities, aggregation) }
        .map { [self.historyDataSet(channel, .generalPurposeMeasurement, .chartGpm, aggregation, $0)] }
    }

    func aggregatingGeneralPurposeMeasurement(
        _ measurements: [SAGeneralPurposeMeasurementItem],
        _ aggregation: ChartDataAggregation
    ) -> [AggregatedEntity] {
        if (aggregation == .minutes) {
            return measurements
                .filter { $0.value_average != nil }
                .map { $0.toAggregatedEntity(aggregation) }
        }

        return measurements
            .filter { $0.value_average != nil }
            .reduce([TimeInterval: LinkedList<SAGeneralPurposeMeasurementItem>]()) { reductor(aggregation, $0, $1) }
            .map { group in
                AggregatedEntity(
                    type: .generalPurposeMeasurement,
                    aggregation: aggregation,
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: group.value.avg { $0.value_average!.toDouble() },
                    min: group.value.min { $0.value_min!.toDouble() },
                    max: group.value.max { $0.value_max!.toDouble() },
                    open: group.value.head!.value.value_open!.toDouble(),
                    close: group.value.tail!.value.value_close!.toDouble()
                )
            }
            .sorted { $0.date < $1.date }
    }

    private func generalPurposeMeterSets(
        _ channel: SAChannel,
        _ profile: AuthProfileItem,
        _ startDate: Date,
        _ endDate: Date,
        _ aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]> {
        return generalPurposeMeterItemRepository.findMeasurements(
            remoteId: channel.remote_id,
            profile: profile,
            startDate: startDate,
            endDate: endDate
        )
        .map { entities in self.aggregatingGeneralPurposeMeter(entities, aggregation) }
        .map { [self.historyDataSet(channel, .generalPurposeMeter, .chartGpm, aggregation, $0)] }
    }

    func aggregatingGeneralPurposeMeter(
        _ measurements: [SAGeneralPurposeMeterItem],
        _ aggregation: ChartDataAggregation
    ) -> [AggregatedEntity] {
        if (aggregation == .minutes) {
            return measurements
                .filter { $0.value_increment != nil }
                .map { $0.toAggregatedEntity(aggregation) }
        }

        return measurements
            .filter { $0.value != nil }
            .reduce([TimeInterval: LinkedList<SAGeneralPurposeMeterItem>]()) { reductor(aggregation, $0, $1) }
            .map { group in
                AggregatedEntity(
                    type: .generalPurposeMeter,
                    aggregation: aggregation,
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: group.value.sum { $0.value_increment!.toDouble() },
                    min: nil,
                    max: nil,
                    open: nil,
                    close: nil
                )
            }
            .sorted { $0.date < $1.date }
    }
}

private extension SAGeneralPurposeMeasurementItem {
    func toAggregatedEntity(
        _ aggregation: ChartDataAggregation
    ) -> AggregatedEntity {
        AggregatedEntity(
            type: .generalPurposeMeasurement,
            aggregation: aggregation,
            date: date!.timeIntervalSince1970,
            value: value_average!.toDouble(),
            min: value_min?.toDouble(),
            max: value_max?.toDouble(),
            open: value_open?.toDouble(),
            close: value_close?.toDouble()
        )
    }
}

private extension SAGeneralPurposeMeterItem {
    func toAggregatedEntity(
        _ aggregation: ChartDataAggregation
    ) -> AggregatedEntity {
        AggregatedEntity(
            type: .generalPurposeMeter,
            aggregation: aggregation,
            date: date!.timeIntervalSince1970,
            value: value_increment!.toDouble(),
            min: nil,
            max: nil,
            open: nil,
            close: nil
        )
    }
}
