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

import Foundation

private let MAX_ALLOWED_DISTANCE_MUTLIPLIER = 1.5
// Server provides data for each 10 minutes
private let AGGREGATING_MINUTES_DISTANCE_SEC = 600 * MAX_ALLOWED_DISTANCE_MUTLIPLIER

protocol BaseLoadMeasurementsUseCase {}

extension BaseLoadMeasurementsUseCase {
    func aggregatingTemperature(
        _ measurements: [SATemperatureMeasurementItem],
        _ aggregation: ChartDataAggregation
    ) -> [AggregatedEntity] {
        if (aggregation == .minutes) {
            return measurements
                .filter { $0.temperature != nil }
                .map { $0.toAggregatedEntity(aggregation) }
        }
        
        return measurements
            .filter { $0.temperature != nil }
            .reduce([TimeInterval: LinkedList<SATemperatureMeasurementItem>]()) { reductor(aggregation, $0, $1) }
            .map { group in
                AggregatedEntity(
                    type: .temperature,
                    aggregation: aggregation,
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: group.value.avg { $0.temperature!.toDouble() },
                    min: group.value.min { $0.temperature!.toDouble() },
                    max: group.value.max { $0.temperature!.toDouble() },
                    open: group.value.head!.value.temperature!.toDouble(),
                    close: group.value.tail!.value.temperature!.toDouble()
                )
            }
            .sorted { $0.date < $1.date }
    }
    
    func aggregatingTemperatureOrHumidity(
        _ measurements: [SATempHumidityMeasurementItem],
        _ aggregation: ChartDataAggregation,
        _ type: ChartEntryType,
        _ extractor: (SATempHumidityMeasurementItem) -> Double?
    ) -> [AggregatedEntity] {
        if (aggregation == .minutes) {
            return measurements
                .filter { extractor($0) != nil }
                .map { $0.toAggregatedEntity(aggregation, type, extractor) }
        }
        
        return measurements
            .filter { extractor($0) != nil }
            .reduce([TimeInterval: LinkedList<SATempHumidityMeasurementItem>]()) { reductor(aggregation, $0, $1) }
            .map { group in
                AggregatedEntity(
                    type: type,
                    aggregation: aggregation,
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: group.value.avg { extractor($0) },
                    min: group.value.min { extractor($0) },
                    max: group.value.max { extractor($0) },
                    open: extractor(group.value.head!.value),
                    close: extractor(group.value.tail!.value)
                )
            }
            .sorted { $0.date < $1.date }
    }
    
    func reductor<T: SAMeasurementItem>(
        _ aggregation: ChartDataAggregation,
        _ map: [TimeInterval: LinkedList<T>],
        _ item: T
    ) -> [TimeInterval: LinkedList<T>] {
        var map = map
        let aggregator = aggregation.aggregator(item: item)
        if (map[aggregator] == nil) {
            map[aggregator] = LinkedList<T>()
        }
        map[aggregator]?.append(item)
        return map
    }
    
    func historyDataSet(
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
            valueFormatter: getValueFormatter(type, config: channel.config),
            color: color,
            entries: divideSetToSubsets(measurements, aggregation, type),
            active: true
        )
    }
    
    private func toAggregatedEntities<T: SAMeasurementItem>(
        _ group: Dictionary<TimeInterval, LinkedList<T>>.Element,
        aggregation: ChartDataAggregation,
        extractor: (T) -> Double?,
        type: ChartEntryType
    ) -> AggregatedEntity {
        let date = aggregation.groupTimeProvider(date: group.value.head!.value.date!)
        return AggregatedEntity(
            type: type,
            aggregation: aggregation,
            date: date,
            value: group.value.avg { extractor($0) },
            min: group.value.min { extractor($0)! },
            max: group.value.max { extractor($0)! },
            open: extractor(group.value.head!.value),
            close: extractor(group.value.tail!.value)
        )
    }
    
    private func channelValueText(_ channel: SAChannel, _ type: ChartEntryType) -> String {
        if (!channel.isOnline()) {
            return NO_VALUE_TEXT
        }
        
        @Singleton<ValuesFormatter> var formatter
        @Singleton<GetChannelValueStringUseCase> var getChannelValueStringUseCase
        
        return switch (type) {
        case .humidity: getChannelValueStringUseCase.invoke(channel, valueType: .second)
        case .generalPurposeMeter,
             .temperature,
             .generalPurposeMeasurement: getChannelValueStringUseCase.invoke(channel)
        }
    }
    
    private func channelIcon(_ channel: SAChannel, _ type: ChartEntryType) -> UIImage? {
        @Singleton<ValuesFormatter> var formatter
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        
        return switch (type) {
        case .humidity: getChannelBaseIconUseCase.invoke(channel: channel, type: .second)
        case .generalPurposeMeasurement,
             .temperature,
             .generalPurposeMeter: getChannelBaseIconUseCase.invoke(channel: channel)
        }
    }
    
    private func getValueFormatter(_ type: ChartEntryType, config: SAChannelConfig?) -> ChannelValueFormatter {
        switch (type) {
        case .humidity: HumidityValueFormatter()
        case .temperature: ThermometerValueFormatter()
        case .generalPurposeMeasurement, .generalPurposeMeter:
            GpmValueFormatter(config: config?.configAsSuplaConfig() as? SuplaChannelGeneralPurposeBaseConfig)
        }
    }
    
    private func divideSetToSubsets(_ entities: [AggregatedEntity], _ aggregation: ChartDataAggregation, _ type: ChartEntryType) -> [[AggregatedEntity]] {
        var result: [[AggregatedEntity]] = []
        var currentSet: [AggregatedEntity] = []
        
        for entity in entities {
            if let lastInCurrentSet = currentSet.last {
                let distance = aggregation == .minutes ? AGGREGATING_MINUTES_DISTANCE_SEC : aggregation.timeInSec * MAX_ALLOWED_DISTANCE_MUTLIPLIER
                
                if (entity.date - lastInCurrentSet.date > distance) {
                    result.append(currentSet)
                    currentSet = []
                }
            }
            
            currentSet.append(entity)
        }
        
        if (!currentSet.isEmpty) {
            result.append(currentSet)
        }
        
        return result
    }
}

extension NSDecimalNumber {
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
        super.init(colors: [.chartTemperature1, .chartTemperature2])
    }
}

final class HumidityColors: Colors {
    init() {
        super.init(colors: [.chartHumidity1, .chartHumidity2])
    }
}

struct AggregatedEntity: Equatable {
    let type: ChartEntryType
    let aggregation: ChartDataAggregation
    let date: TimeInterval
    let value: Double
    let min: Double?
    let max: Double?
    let open: Double?
    let close: Double?
}

private extension SATemperatureMeasurementItem {
    func toAggregatedEntity(_ aggregation: ChartDataAggregation) -> AggregatedEntity {
        AggregatedEntity(
            type: .temperature,
            aggregation: aggregation,
            date: date!.timeIntervalSince1970,
            value: temperature!.toDouble(),
            min: nil,
            max: nil,
            open: nil,
            close: nil
        )
    }
}

private extension SATempHumidityMeasurementItem {
    func toAggregatedEntity(
        _ aggregation: ChartDataAggregation,
        _ type: ChartEntryType,
        _ extractor: (SATempHumidityMeasurementItem) -> Double?
    ) -> AggregatedEntity {
        AggregatedEntity(
            type: type,
            aggregation: aggregation,
            date: date!.timeIntervalSince1970,
            value: extractor(self)!,
            min: nil,
            max: nil,
            open: nil,
            close: nil
        )
    }
}
