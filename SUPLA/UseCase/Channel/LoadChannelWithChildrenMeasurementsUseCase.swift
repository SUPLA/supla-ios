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

private let MAX_ALLOWED_DISTANCE_MUTLIPLIER = 1.5
// Server provides data for each 10 minutes
private let AGGREGATING_MINUTES_DISTANCE_SEC = 600 * MAX_ALLOWED_DISTANCE_MUTLIPLIER

protocol LoadChannelWithChildrenMeasurementsUseCase {
    func invoke(
        remoteId: Int32,
        startDate: Date,
        endDate: Date,
        aggregation: ChartDataAggregation
    ) -> Observable<[HistoryDataSet]>
}

final class LoadChannelWithChildrenMeasurementsUseCaseImpl: LoadChannelWithChildrenMeasurementsUseCase {
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChidlrenUseCase
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<ValuesFormatter> private var formatter
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
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
                    return self.buildDataSets(channelWithChildren: $0.0, profile: $0.1, startDate: startDate, endDate: endDate, aggregation: aggregation)
                } else {
                    return Observable.error(
                        GeneralError.illegalArgument(message: "Channel function not supported (\($0.0.channel.func)")
                    )
                }
            }
    }
    
    private func buildDataSets(channelWithChildren: ChannelWithChildren, profile: AuthProfileItem, startDate: Date, endDate: Date, aggregation: ChartDataAggregation) -> Observable<[HistoryDataSet]> {
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
                        self.aggregating(
                            measurements: list,
                            aggregation: aggregation,
                            extractor: { $0.temperature?.toDouble() }
                        )
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
                            let temperatures = self.aggregating(
                                measurements: $0,
                                aggregation: aggregation,
                                extractor: { Double(truncating: $0.temperature!)}
                            )
                            let humidities = self.aggregating(
                                measurements: $0,
                                aggregation: aggregation,
                                extractor: { Double(truncating: $0.humidity!)}
                            )
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
    
    private func aggregating<T: SAMeasurementItem>(measurements: [T], aggregation: ChartDataAggregation, extractor: (T) -> Double?) -> [AggregatedEntity] {
        if (aggregation == .minutes) {
            return measurements
                .filter { extractor($0) != nil }
                .map {
                    AggregatedEntity(
                        aggregation: aggregation,
                        date: $0.date!.timeIntervalSince1970,
                        value: extractor($0)!,
                        min: nil,
                        max: nil
                    )
                }
        }
        
        return measurements
            .filter { extractor($0) != nil }
            .reduce([TimeInterval: [T]]()) {
                var map = $0
                let aggregator = aggregation.aggregator(date: $1.date!)
                if (map[aggregator] == nil) {
                    map[aggregator] = []
                }
                map[aggregator]?.append($1)
                return map
            }
            .map { group in
                AggregatedEntity (
                    aggregation: aggregation,
                    date: aggregation.groupTimeProvider(date: group.value.first!.date!),
                    value: group.value.map { extractor($0)! }.avg(),
                    min: group.value.map { extractor($0)! }.min(),
                    max: group.value.map { extractor($0)! }.max()
                )
            }
            .sorted { $0.date < $1.date }
    }
    
    private func historyDataSet(
        _ channel: SAChannel,
        _ type: ChartEntryType,
        _ color: UIColor,
        _ aggregation: ChartDataAggregation,
        _ measurements: [AggregatedEntity]
    ) -> HistoryDataSet {
        return HistoryDataSet(
            setId: HistoryDataSet.Id(remoteId: channel.remote_id, type: type),
            icon: channelIcon(channel, type),
            value: channelValueText(channel, type),
            color: color,
            entries: divideSetToSubsets(measurements, aggregation, type),
            active: true
        )
    }
    
    private func channelValueText(_ channel: SAChannel, _ type: ChartEntryType) -> String {
        switch(type) {
        case .temperature: formatter.temperatureToString(channel.temperatureValue(), withUnit: false)
        case .humidity: formatter.humidityToString(rawValue: channel.humidityValue())
        }
    }
    
    private func channelIcon(_ channel: SAChannel, _ type: ChartEntryType) -> UIImage? {
        switch(type) {
        case .temperature: getChannelBaseIconUseCase.invoke(channel: channel)
        case .humidity: getChannelBaseIconUseCase.invoke(channel: channel, type: .second)
        }
    }
    
    private func divideSetToSubsets(_ entities: [AggregatedEntity], _ aggregation: ChartDataAggregation, _ type: ChartEntryType) -> [[ChartDataEntry]] {
        var result: [[ChartDataEntry]] = []
        var currentSet: [ChartDataEntry] = []
        
        entities.forEach { entity in
            let entry = ChartDataEntry(x: entity.date, y: entity.value, data: entity.toDetails(type: type))
            
            if let lastInCurrentSet = currentSet.last {
                let distance = aggregation == .minutes ? AGGREGATING_MINUTES_DISTANCE_SEC : aggregation.timeInSec * MAX_ALLOWED_DISTANCE_MUTLIPLIER
                
                if (entry.x - lastInCurrentSet.x > distance) {
                    result.append(currentSet)
                    currentSet = []
                }
            }
            
            currentSet.append(entry)
        }
        
        if (!currentSet.isEmpty) {
            result.append(currentSet)
        }
        
        return result
    }
}

fileprivate extension NSDecimalNumber {
    func toDouble() -> Double {
        Double(truncating: self)
    }
}

class Colors {
    private let colors: [UIColor]
    private var position: Int = 0
    
    init(colors: [UIColor]) {
        self.colors = colors
    }
    
    func nextColor() -> UIColor {
        let color = colors[position % colors.count]
        position += 1
        return color
    }
}

final class TemperatureColors: Colors {
    init() {
        super.init(colors: [.red, .darkRed])
    }
}

final class HumidityColors: Colors {
    init() {
        super.init(colors: [.blue, .darkBlue])
    }
}

struct AggregatedEntity {
    let aggregation: ChartDataAggregation
    let date: TimeInterval
    let value: Double
    let min: Double?
    let max: Double?
    
    func toDetails(type: ChartEntryType) -> EntryDetails {
        EntryDetails(aggregation: aggregation, type: type, min: min, max: max)
    }
}

struct EntryDetails {
    let aggregation: ChartDataAggregation
    let type: ChartEntryType
    let min: Double?
    let max: Double?
}
