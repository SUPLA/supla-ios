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

protocol ElectricityMeasurementsProvider: MeasurementsProvider {
    var getCaptionUseCase: GetCaptionUseCase { get }
    
    func formatLabelValue(_ electricityValue: SAElectricityMeterExtendedValue, _ phase: Phase) -> String
    func findMeasurementsForPhase(
        _ channel: SAChannel,
        _ spec: ChartDataSpec,
        _ isFirst: Bool,
        _ phase: Phase
    ) -> Observable<(Phase, HistoryDataSet)>
}

extension ElectricityMeasurementsProvider {
    
    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<ChannelChartSets> {
        let channel = channelWithChildren.channel
        var observables: [Observable<(Phase, HistoryDataSet)>] = []
        
        spec.customFilters?.ifPhase1 {
            observables.append(findMeasurementsForPhase(channel, spec, observables.isEmpty, .phase1))
        }
        spec.customFilters?.ifPhase2 {
            observables.append(findMeasurementsForPhase(channel, spec, observables.isEmpty, .phase2))
        }
        spec.customFilters?.ifPhase3 {
            observables.append(findMeasurementsForPhase(channel, spec, observables.isEmpty, .phase3))
        }
        
        return Observable.zip(observables)
            .map { historyDataSets in
                ChannelChartSets(
                    remoteId: channel.remote_id,
                    function: channel.func,
                    name: self.getCaptionUseCase.invoke(data: channel.shareable).string,
                    aggregation: spec.aggregation,
                    dataSets: historyDataSets.map { $0.1 },
                    typeName: (spec.customFilters as? ElectricityChartFilters)?.type.dataTypeLabel
                )
            }
    }
    
    func aggregating<T: BaseHistoryEntity>(
        _ measurements: [T],
        _ aggregation: ChartDataAggregation
    ) -> [AggregatedEntity] {
        if aggregation == .minutes {
            return measurements
                .map {
                    AggregatedEntity(
                        date: $0.date!.timeIntervalSince1970,
                        value: .withPhase(value: $0.avg, min: $0.min, max: $0.max, phase: Phase.from(value: $0.phase))
                    )
                }
        }

        return measurements
            .reduce([TimeInterval: LinkedList<T>]()) { aggregation.reductor($0, $1) }
            .map { group in
                AggregatedEntity(
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: .withPhase(
                        value: group.value.avg { $0.avg },
                        min: group.value.min { $0.min },
                        max: group.value.max { $0.max },
                        phase: Phase.from(value: group.value.head!.value.phase)
                    )
                )
            }
            .sorted { $0.date < $1.date }
    }

    func historyDataSet(
        _ channel: SAChannel,
        _ phase: Phase,
        _ isFirst: Bool,
        _ type: ChartEntryType,
        _ aggregation: ChartDataAggregation,
        _ measurements: [AggregatedEntity]
    ) -> HistoryDataSet {
        HistoryDataSet(
            type: type,
            label: createLabel(channel: channel, phase: phase, isFirst: isFirst),
            valueFormatter: getValueFormatter(type, channel),
            entries: divideSetToSubsets(measurements, aggregation),
            active: true
        )
    }
    
    private func createLabel(channel: SAChannel, phase: Phase, isFirst: Bool) -> HistoryDataSet.Label {
        @Singleton var getChannelBaseIconUseCase: GetChannelBaseIconUseCase
        let icon = isFirst ? getChannelBaseIconUseCase.invoke(channel: channel) : nil
        let electricityValue = channel.ev?.electricityMeter()
        let phases = channel.phases

        if phases.contains(phase) {
            if let electricityValue {
                let value = formatLabelValue(electricityValue, phase)
                return .single(HistoryDataSet.LabelData(icon: icon, value: value, color: phase.color!))
            }
        }

        return .single(HistoryDataSet.LabelData(icon: icon, value: NO_VALUE_TEXT, color: .disabled))
    }
}

