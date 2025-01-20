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

protocol ElectricityMeasurementsProvider: ChannelMeasurementsProvider {}

final class ElectricityMeasurementsProviderImpl: ElectricityMeasurementsProvider {
    @Singleton<ElectricityMeasurementItemRepository> private var electricityMeasurementItemRepository
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase
    
    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool {
        channelWithChildren.isOrHasElectricityMeter
    }
    
    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<ChannelChartSets> {
        let channel = channelWithChildren.channel
        
        return electricityMeasurementItemRepository
            .findMeasurements(
                remoteId: channelWithChildren.remoteId,
                serverId: channel.profile.server?.id,
                startDate: spec.startDate,
                endDate: spec.endDate
            )
            .map { self.aggregating($0, spec) }
            .map {
                let labels = self.labels(spec, self.getChannelBaseIconUseCase.invoke(channel: channel), $0)
                return [self.historyDataSet(channel, labels, spec.aggregation, $0.list)]
            }
            .map {
                let typeName: String? = if let label = (spec.customFilters as? ElectricityChartFilters)?.type.label {
                    "\(label) [kWh]"
                } else {
                    nil
                }
                
                return ChannelChartSets(
                    remoteId: channel.remote_id,
                    function: channel.func,
                    name: self.getCaptionUseCase.invoke(data: channel.shareable).string,
                    aggregation: spec.aggregation,
                    dataSets: $0,
                    customData: ElectricityMarkerCustomData(
                        filters: spec.customFilters as? ElectricityChartFilters,
                        price: channel.ev?.electricityMeter().pricePerUnit(),
                        currency: channel.ev?.electricityMeter().currency()
                    ),
                    typeName: typeName
                )
            }
    }
    
    private func labels(_ spec: ChartDataSpec, _ icon: IconResult, _ result: AggregationResult) -> HistoryDataSet.Label {
        var result = result
        let formatter = ListElectricityMeterValueFormatter()
        
        switch ((spec.customFilters as? ElectricityChartFilters)?.type) {
        case .balanceVector,
             .balanceArithmetic,
             .balanceHourly: return .multiple([
                HistoryDataSet.LabelData(icon: icon, value: "", color: .onSurfaceVariant, presentColor: false, useColor: false),
                .forwarded(formatter.format(result.nextSum(), withUnit: false)),
                .reversed(formatter.format(result.nextSum(), withUnit: false))
            ])
        case .balanceChartAggregated: return .multiple([
                .init(icon: icon, value: "", color: .onSurfaceVariant, presentColor: false),
                .forwarded(formatter.format(result.nextSum(), withUnit: false)),
                .reversed(formatter.format(result.nextSum(), withUnit: false)),
                .init(color: .onSurfaceVariant)
            ])
        default:
            var labels: [HistoryDataSet.LabelData] = []
            spec.customFilters?.ifPhase1 {
                labels.append(.init(
                    icon: icon,
                    value: formatter.format(result.nextSum(), withUnit: false),
                    color: .phase1Color
                ))
            }
            spec.customFilters?.ifPhase2 {
                labels.append(.init(
                    icon: labels.count == 0 ? icon : nil,
                    value: formatter.format(result.nextSum(), withUnit: false),
                    color: .phase2Color
                ))
            }
            spec.customFilters?.ifPhase3 {
                labels.append(.init(
                    icon: labels.count == 0 ? icon : nil,
                    value: formatter.format(result.nextSum(), withUnit: false),
                    color: .phase3Color
                ))
            }
            
            return .multiple(labels)
        }
    }
    
    private func historyDataSet(
        _ channel: SAChannel,
        _ label: HistoryDataSet.Label,
        _ aggregation: ChartDataAggregation,
        _ measurements: [AggregatedEntity]
    ) -> HistoryDataSet {
        HistoryDataSet(
            type: .electricity,
            label: label,
            valueFormatter: getValueFormatter(.electricity, channel),
            entries: divideSetToSubsets(measurements, aggregation),
            active: true
        )
    }
    
    private func aggregating(_ measurements: [SAElectricityMeasurementItem], _ spec: ChartDataSpec) -> AggregationResult {
        let aggregatedEntities = aggregatedEntities(measurements, spec)
        let sum = measurementsSum(measurements, spec)
        
        return AggregationResult(list: aggregatedEntities, sum: sum)
    }
    
    private func aggregatedEntities(_ measurements: [SAElectricityMeasurementItem], _ spec: ChartDataSpec) -> [AggregatedEntity] {
        if (spec.aggregation == .minutes) {
            return measurements
                .map {
                    AggregatedEntity(
                        date: $0.date!.timeIntervalSince1970,
                        value: .multiple(values: $0.getValues(spec: spec))
                    )
                }
        }
        
        let type = (spec.customFilters as? ElectricityChartFilters)?.type
        let aggregatedEntities = switch (type) {
        case .balanceHourly: aggregatedHourly(measurements, spec)
        default:
            measurements
                .reduce([TimeInterval: LinkedList<SAElectricityMeasurementItem>]()) { spec.aggregation.reductor($0, $1) }
                .filter { $0.value.isEmpty == false }
                .map { group in
                    switch (type) {
                    case .balanceVector: aggregatedVectorBalance(spec, group)
                    case .balanceArithmetic: aggregatedArithmeticBalance(spec, group)
                    case .balanceChartAggregated: aggregatedChartBalance(spec, group)
                    default: aggregatedPhases(spec, group)
                    }
                }
        }
        
        return if (spec.aggregation.isRank) {
            aggregatedEntities.sorted { $0.value.max < $1.value.max }
        } else {
            aggregatedEntities.sorted { $0.date < $1.date }
        }
    }
    
    private func measurementsSum(_ measurements: [SAElectricityMeasurementItem], _ spec: ChartDataSpec) -> [Double] {
        switch ((spec.customFilters as? ElectricityChartFilters)?.type) {
        case .balanceVector:
            return [
                measurements.map { $0.fae_balanced }.sum(),
                measurements.map { $0.rae_balanced }.sum()
            ]
        case .balanceArithmetic:
            return [
                measurements.map { $0.phase1_fae + $0.phase2_fae + $0.phase3_fae }.sum(),
                measurements.map { $0.phase1_rae + $0.phase2_rae + $0.phase3_rae }.sum()
            ]
        case .balanceChartAggregated:
            if (spec.aggregation == .minutes) {
                return [
                    measurements.map { $0.phase1_fae + $0.phase2_fae + $0.phase3_fae }.sum(),
                    measurements.map { $0.phase1_rae + $0.phase2_rae + $0.phase3_rae }.sum()
                ]
            } else {
                let balanced: [BalancedValue] = measurements
                    .reduce([TimeInterval: LinkedList<SAElectricityMeasurementItem>]()) { spec.aggregation.reductor($0, $1) }
                    .filter { $0.value.isEmpty == false }
                    .map { group in
                        let forwarded = group.value.map { $0.phase1_fae + $0.phase2_fae + $0.phase3_fae }.sum { $0 }
                        let reversed = group.value.map { $0.phase1_rae + $0.phase2_rae + $0.phase3_rae }.sum { $0 }
                        
                        return BalancedValue(
                            item: group.value.head!.value,
                            forwarded > reversed ? forwarded - reversed : 0,
                            reversed > forwarded ? reversed - forwarded : 0
                        )
                    }
                
                return [
                    balanced.map { $0.forwarded }.sum(),
                    balanced.map { $0.reversed }.sum()
                ]
            }
        case .balanceHourly:
            let balanced = measurements.balanceHourly()
            
            return [
                balanced.map { $0.forwarded }.sum(),
                balanced.map { $0.reversed }.sum()
            ]
        default:
            var result: [Double] = []
            
            for phase in Phase.allCases {
                spec.customFilters?.ifPhase(phase) {
                    result.append(measurements.map { $0.valueFor(phase: phase, spec: spec) }.sum())
                }
            }
            
            return result
        }
    }
    
    private func aggregatedHourly(
        _ measurements: [SAElectricityMeasurementItem],
        _ spec: ChartDataSpec
    ) -> [AggregatedEntity] {
        measurements.balanceHourly()
            .reduce([TimeInterval: LinkedList<BalancedValue>]()) { spec.aggregation.reductor($0, $1) }
            .filter { $0.value.isEmpty == false }
            .map { group in
                AggregatedEntity(
                    date: spec.aggregation.groupTimeProvider(date: group.value.head!.value.date),
                    value: .multiple(values: balanceValues(
                        consumption: group.value.map { $0.forwarded }.sum { $0 },
                        production: group.value.map { $0.reversed }.sum { $0 }
                    )
                    )
                )
            }
    }
    
    private func aggregatedVectorBalance(_ spec: ChartDataSpec, _ group: Dictionary<TimeInterval, LinkedList<SAElectricityMeasurementItem>>.Element) -> AggregatedEntity {
        let consumption = group.value.map { $0.fae_balanced }.sum { $0 }
        let production = group.value.map { $0.rae_balanced }.sum { $0 }
        
        return AggregatedEntity(
            date: spec.aggregation.groupTimeProvider(date: group.value.head!.value.date!),
            value: .multiple(values: balanceValues(consumption: consumption, production: production))
        )
    }
    
    private func aggregatedArithmeticBalance(_ spec: ChartDataSpec, _ group: Dictionary<TimeInterval, LinkedList<SAElectricityMeasurementItem>>.Element) -> AggregatedEntity {
        let consumption = group.value.map { $0.phase1_fae + $0.phase2_fae + $0.phase3_fae }.sum { $0 }
        let production = group.value.map { $0.phase1_rae + $0.phase2_rae + $0.phase3_rae }.sum { $0 }
        
        return AggregatedEntity(
            date: spec.aggregation.groupTimeProvider(date: group.value.head!.value.date!),
            value: .multiple(values: balanceValues(consumption: consumption, production: production))
        )
    }
    
    private func aggregatedChartBalance(_ spec: ChartDataSpec, _ group: Dictionary<TimeInterval, LinkedList<SAElectricityMeasurementItem>>.Element) -> AggregatedEntity {
        let consumption = group.value.map { $0.phase1_fae + $0.phase2_fae + $0.phase3_fae }.sum { $0 }
        let production = group.value.map { $0.phase1_rae + $0.phase2_rae + $0.phase3_rae }.sum { $0 }
        
        return AggregatedEntity(
            date: spec.aggregation.groupTimeProvider(date: group.value.head!.value.date!),
            value: .multiple(values: chartBalancedValues(consumption: consumption, production: production))
        )
    }
    
    private func aggregatedPhases(_ spec: ChartDataSpec, _ group: Dictionary<TimeInterval, LinkedList<SAElectricityMeasurementItem>>.Element) -> AggregatedEntity {
        var values: [Double] = []
        
        for phase in Phase.allCases {
            spec.customFilters?.ifPhase(phase) {
                values.append(group.value.map { $0.valueFor(phase: phase, spec: spec) }.sum { $0 })
            }
        }
        
        let value: AggregatedValue = if (spec.aggregation.isRank) {
            .single(value: values.sum(), min: nil, max: nil, open: nil, close: nil)
        } else {
            .multiple(values: values)
        }
        let date: TimeInterval = if (spec.aggregation.isRank) {
            group.key
        } else {
            spec.aggregation.groupTimeProvider(date: group.value.head!.value.date!)
        }
        
        return AggregatedEntity(
            date: date,
            value: value
        )
    }
}

extension HistoryDataSet.LabelData {
    static func forwarded(_ value: String) -> HistoryDataSet.LabelData {
        HistoryDataSet.LabelData(
            icon: .suplaIcon(name: .Icons.forwardEnergy),
            value: value,
            color: .chartValuePositive,
            iconSize: Dimens.iconSizeSmall
        )
    }
    
    static func reversed(_ value: String) -> HistoryDataSet.LabelData {
        HistoryDataSet.LabelData(
            icon: .suplaIcon(name: .Icons.reversedEnergy),
            value: value,
            color: .chartValueNegative,
            iconSize: Dimens.iconSizeSmall
        )
    }
}
