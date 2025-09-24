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

protocol GeneralPurposeMeterMeasurementsProvider: ChannelMeasurementsProvider {}

class GeneralPurposeMeterMeasurementsProviderImpl: GeneralPurposeMeterMeasurementsProvider {
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase

    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
    }

    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<[ChannelChartSets]> {
        generalPurposeMeterItemRepository
            .findMeasurements(
                remoteId: channelWithChildren.remoteId,
                serverId: channelWithChildren.channel.profile.server?.id,
                startDate: spec.startDate,
                endDate: spec.endDate
            )
            .map { entities in self.aggregatingGeneralPurposeMeter(entities, spec.aggregation) }
            .map { [self.historyDataSet(channelWithChildren, .generalPurposeMeter, .chartGpm, spec.aggregation, $0)] }
            .map { [self.channelChartSets(channelWithChildren.channel, spec, $0)] }
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
            .reduce([TimeInterval: LinkedList<SAGeneralPurposeMeterItem>]()) { aggregation.reductor($0, $1) }
            .map { group in
                AggregatedEntity(
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: .single(
                        value: group.value.sum { $0.value_increment!.toDouble() },
                        min: nil,
                        max: nil,
                        open: nil,
                        close: nil
                    )
                )
            }
            .sorted { $0.date < $1.date }
    }
}

private extension SAGeneralPurposeMeterItem {
    func toAggregatedEntity(
        _ aggregation: ChartDataAggregation
    ) -> AggregatedEntity {
        AggregatedEntity(
            date: date!.timeIntervalSince1970,
            value: .single(value: value_increment!.toDouble(), min: nil, max: nil, open: nil, close: nil)
        )
    }
}
