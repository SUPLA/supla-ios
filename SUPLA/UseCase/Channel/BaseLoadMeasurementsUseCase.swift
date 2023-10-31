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

protocol BaseLoadMeasurementsUseCase {
}

extension BaseLoadMeasurementsUseCase {
    
    func aggregating<T: SAMeasurementItem>(
        _ measurements: [T],
        _ aggregation: ChartDataAggregation,
        _ extractor: (T) -> Double?
    ) -> [AggregatedEntity] {
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
            .map { self.toAggregatedEntities($0, aggregation: aggregation, extractor: extractor) }
            .sorted { $0.date < $1.date }
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
            color: color,
            entries: divideSetToSubsets(measurements, aggregation, type),
            active: true
        )
    }
    
    private func toAggregatedEntities<T: SAMeasurementItem>(
        _ group: Dictionary<TimeInterval, [T]>.Element,
        aggregation: ChartDataAggregation,
        extractor: (T) -> Double?
    ) -> AggregatedEntity {
        let groupData = group.value.sorted { $0.date! < $1.date! }
        let date = aggregation.groupTimeProvider(date: groupData.first!.date!)
        return AggregatedEntity (
            aggregation: aggregation,
            date: date,
            value: group.value.map { extractor($0)! }.avg(),
            min: group.value.map { extractor($0)! }.min(),
            max: group.value.map { extractor($0)! }.max()
        )
    }
    
    private func channelValueText(_ channel: SAChannel, _ type: ChartEntryType) -> String {
        @Singleton<ValuesFormatter> var formatter
        
        return switch(type) {
        case .temperature: formatter.temperatureToString(channel.temperatureValue(), withUnit: false)
        case .humidity: formatter.humidityToString(channel.humidityValue())
        }
    }
    
    private func channelIcon(_ channel: SAChannel, _ type: ChartEntryType) -> UIImage? {
        @Singleton<ValuesFormatter> var formatter
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        
        return switch(type) {
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
