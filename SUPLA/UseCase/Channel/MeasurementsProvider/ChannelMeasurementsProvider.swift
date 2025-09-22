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
    
protocol ChannelMeasurementsProvider: MeasurementsProvider {
    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool
}

extension ChannelMeasurementsProvider {
    func provide(_ channelWithChildren: ChannelWithChildren, _ spec: ChartDataSpec) -> Observable<ChannelChartSets> {
        provide(channelWithChildren, spec, nil)
    }
    
    func historyDataSet(
        _ channelWithChildren: ChannelWithChildren,
        _ type: ChartEntryType,
        _ color: UIColor,
        _ aggregation: ChartDataAggregation,
        _ measurements: [AggregatedEntity]
    ) -> HistoryDataSet {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetChannelValueStringUseCase> var getChannelValueStringUseCase
        
        let icon = switch (type) {
        case .humidity: getChannelBaseIconUseCase.invoke(channel: channelWithChildren.channel, type: .second)
        default: getChannelBaseIconUseCase.invoke(channel: channelWithChildren.channel)
        }
        
        let value = switch (type) {
        case .humidity: getChannelValueStringUseCase.invoke(channelWithChildren.channel, valueType: .second)
        default: getChannelValueStringUseCase.invoke(channelWithChildren.channel)
        }
        
        return HistoryDataSet(
            type: type,
            label: singleLabel(icon, value, color),
            valueFormatter: getValueFormatter(type, channelWithChildren),
            entries: divideSetToSubsets(measurements, aggregation),
            active: true
        )
    }
    
    func aggregatingTemperature<T: BaseTemperatureEntity>(
        _ measurements: [T],
        _ aggregation: ChartDataAggregation
    ) -> [AggregatedEntity] {
        if (aggregation == .minutes) {
            return measurements
                .filter { $0.temperature != nil }
                .map { $0.toAggregatedEntity(aggregation) }
        }
        
        return measurements
            .filter { $0.temperature != nil }
            .reduce([TimeInterval: LinkedList<T>]()) { aggregation.reductor($0, $1) }
            .map { group in
                AggregatedEntity(
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: .single(
                        value: group.value.avg { $0.temperature!.toDouble() },
                        min: group.value.min { $0.temperature!.toDouble() },
                        max: group.value.max { $0.temperature!.toDouble() },
                        open: group.value.head!.value.temperature!.toDouble(),
                        close: group.value.tail!.value.temperature!.toDouble()
                    )
                )
            }
            .sorted { $0.date < $1.date }
    }
    
    func aggregatingHumidity<T: BaseHumidityEntity>(
        _ measurements: [T],
        _ aggregation: ChartDataAggregation
    ) -> [AggregatedEntity] {
        if (aggregation == .minutes) {
            return measurements
                .filter { $0.humidity != nil }
                .map { $0.toAggregatedEntity(aggregation) }
        }
        
        return measurements
            .filter { $0.humidity != nil }
            .reduce([TimeInterval: LinkedList<T>]()) { aggregation.reductor($0, $1) }
            .map { group in
                AggregatedEntity(
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: .single(
                        value: group.value.avg { $0.humidity!.toDouble() },
                        min: group.value.min { $0.humidity!.toDouble() },
                        max: group.value.max { $0.humidity!.toDouble() },
                        open: group.value.head!.value.humidity!.toDouble(),
                        close: group.value.tail!.value.humidity!.toDouble()
                    )
                )
            }
            .sorted { $0.date < $1.date }
    }
    
    func channelChartSets(_ channel: SAChannel, _ spec: ChartDataSpec, _ dataSets: [HistoryDataSet]) -> ChannelChartSets {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return ChannelChartSets(
            remoteId: channel.remote_id,
            function: channel.func,
            name: getCaptionUseCase.invoke(data: channel.shareable).string,
            aggregation: spec.aggregation,
            dataSets: dataSets
        )
    }
}

protocol MeasurementsProvider {
    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<ChannelChartSets>
}

extension MeasurementsProvider {
    func getValueFormatter(_ type: ChartEntryType, _ channelWithChildren: ChannelWithChildren) -> SharedCore.ValueFormatter {
        switch (type) {
        case .humidity, .humidityOnly: SharedCore.HumidityValueFormatter.shared
        case .temperature: thermometerValueFormatter()
        case .generalPurposeMeasurement,
             .generalPurposeMeter:
            SharedCore.GpmValueFormatter.staticFormatter(channelWithChildren.channel.config?.configAsSuplaConfig())
        case .electricity: ElectricityMeterValueFormatter()
        case .impulseCounter: SharedCore.ImpulseCounterValueFormatter.staticFormatter(channelWithChildren)
        case .voltage: SharedCore.VoltageValueFormatter.shared
        case .current: SharedCore.CurrentValueFormatter.shared
        case .powerActive: SharedCore.PowerActiveValueFormatter.shared
        }
    }
    
    func divideSetToSubsets(_ entities: [AggregatedEntity], _ aggregation: ChartDataAggregation) -> [[AggregatedEntity]] {
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
    
    private func thermometerValueFormatter() -> SharedCore.ValueFormatter {
        @Singleton<SharedCore.ThermometerValueFormatter> var formatter
        return formatter
    }
}

private extension BaseTemperatureEntity {
    func toAggregatedEntity(_ aggregation: ChartDataAggregation) -> AggregatedEntity {
        AggregatedEntity(
            date: date!.timeIntervalSince1970,
            value: .single(value: temperature!.toDouble(), min: nil, max: nil, open: nil, close: nil)
        )
    }
}

private extension BaseHumidityEntity {
    func toAggregatedEntity(_ aggregation: ChartDataAggregation) -> AggregatedEntity {
        AggregatedEntity(
            date: date!.timeIntervalSince1970,
            value: .single(value: humidity!.toDouble(), min: nil, max: nil, open: nil, close: nil)
        )
    }
}
