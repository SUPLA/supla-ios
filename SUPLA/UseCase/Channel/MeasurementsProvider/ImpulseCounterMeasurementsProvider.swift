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

protocol ImpulseCounterMeasurementsProvider: ChannelMeasurementsProvider {}

final class ImpulseCounterMeasurementsProviderImpl: ImpulseCounterMeasurementsProvider {
    @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
    @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase

    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool {
        channelWithChildren.isOrHasImpulseCounter
    }

    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<ChannelChartSets> {
        impulseCounterMeasurementItemRepository
            .findMeasurements(
                remoteId: channelWithChildren.remoteId,
                serverId: channelWithChildren.channel.profile.server?.id,
                startDate: spec.startDate,
                endDate: spec.endDate
            )
            .map { entities in self.aggregating(entities, spec) }
            .map { [self.historyDataSet($0, channelWithChildren, spec)] }
            .map {
                ChannelChartSets(
                    remoteId: channelWithChildren.remoteId,
                    function: channelWithChildren.function,
                    name: self.getCaptionUseCase.invoke(data: channelWithChildren.channel.shareable).string,
                    aggregation: spec.aggregation,
                    dataSets: $0,
                    customData: ImpulseCounterMarkerCustomData(
                        price: channelWithChildren.channel.ev?.impulseCounter().pricePerUnit(),
                        currency: channelWithChildren.channel.ev?.impulseCounter().currency()
                    )
                )
            }
    }

    private func aggregating(
        _ measurements: [SAImpulseCounterMeasurementItem],
        _ spec: ChartDataSpec
    ) -> AggregationResult {
        AggregationResult(
            list: aggregatingImpulseCounter(measurements, spec),
            sum: [measurements.map { $0.calculated_value }.sum()]
        )
    }

    private func aggregatingImpulseCounter(
        _ measurements: [SAImpulseCounterMeasurementItem],
        _ spec: ChartDataSpec
    ) -> [AggregatedEntity] {
        let aggregation = spec.aggregation
        let isRank = aggregation.isRank

        if (aggregation == .minutes) {
            return measurements
                .map { $0.toAggregatedEntity(spec.aggregation) }
        }

        return measurements
            .reduce([TimeInterval: LinkedList<SAImpulseCounterMeasurementItem>]()) { aggregation.reductor($0, $1) }
            .map { group in
                AggregatedEntity(
                    date: isRank ? group.key : aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: .single(
                        value: group.value.sum { $0.calculated_value },
                        min: nil,
                        max: nil,
                        open: nil,
                        close: nil
                    )
                )
            }
            .sorted { isRank ? $0.value.max > $1.value.max : $0.date < $1.date }
    }

    private func historyDataSet(_ result: AggregationResult, _ channelWithChildren: ChannelWithChildren, _ spec: ChartDataSpec) -> HistoryDataSet {
        var result = result
        let unit = channelWithChildren.channel.isImpulseCounter() ? channelWithChildren.channel.ev?.impulseCounter().unit() :
            channelWithChildren.children.first { $0.relationType == .meter }?.channel.ev?.impulseCounter().unit()
        let formatter = ImpulseCounterChartValueFormatter(unit: unit)

        let label = HistoryDataSet.Label.single(
            HistoryDataSet.LabelData(
                icon: getChannelBaseIconUseCase.invoke(channel: channelWithChildren.channel),
                value: formatter.format(result.nextSum()),
                color: .chartGpm
            )
        )

        return HistoryDataSet(
            type: .impulseCounter,
            label: label,
            valueFormatter: formatter,
            entries: divideSetToSubsets(result.list, spec.aggregation),
            active: true
        )
    }
}

private extension SAImpulseCounterMeasurementItem {
    func toAggregatedEntity(
        _ aggregation: ChartDataAggregation
    ) -> AggregatedEntity {
        AggregatedEntity(
            date: date!.timeIntervalSince1970,
            value: .single(value: calculated_value, min: nil, max: nil, open: nil, close: nil)
        )
    }
}
