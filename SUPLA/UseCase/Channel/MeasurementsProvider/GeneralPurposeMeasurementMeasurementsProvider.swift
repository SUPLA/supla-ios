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

protocol GeneralPurposeMeasurementMeasurementsProvider: ChannelMeasurementsProvider {}

final class GeneralPurposeMeasurementMeasurementsProviderImpl: GeneralPurposeMeasurementMeasurementsProvider {
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase

    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
    }

    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<ChannelChartSets> {
        let entryType: ChartEntryType = .generalPurposeMeasurement
        let color = colorProvider?(entryType) ?? TemperatureColors.standard

        return generalPurposeMeasurementItemRepository
            .findMeasurements(
                remoteId: channelWithChildren.remoteId,
                serverId: channelWithChildren.channel.profile.server?.id,
                startDate: spec.startDate,
                endDate: spec.endDate
            )
            .map { entities in self.aggregatingGeneralPurposeMeasurement(entities, spec.aggregation) }
            .map { [self.historyDataSet(channelWithChildren.channel, .generalPurposeMeasurement, color, spec.aggregation, $0)] }
            .map {
                ChannelChartSets(
                    remoteId: channelWithChildren.channel.remote_id,
                    function: channelWithChildren.channel.func,
                    name: self.getCaptionUseCase.invoke(data: channelWithChildren.channel.shareable).string,
                    aggregation: spec.aggregation,
                    dataSets: $0
                )
            }
    }

    private func aggregatingGeneralPurposeMeasurement(
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
            .reduce([TimeInterval: LinkedList<SAGeneralPurposeMeasurementItem>]()) { aggregation.reductor($0, $1) }
            .map { group in
                AggregatedEntity(
                    date: aggregation.groupTimeProvider(date: group.value.head!.value.date!),
                    value: .single(
                        value: group.value.avg { $0.value_average!.toDouble() },
                        min: group.value.min { $0.value_min!.toDouble() },
                        max: group.value.max { $0.value_max!.toDouble() },
                        open: group.value.head!.value.value_open!.toDouble(),
                        close: group.value.tail!.value.value_close!.toDouble()
                    )
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
            date: date!.timeIntervalSince1970,
            value: .single(
                value: value_average!.toDouble(),
                min: value_min?.toDouble(),
                max: value_max?.toDouble(),
                open: value_open?.toDouble(),
                close: value_close?.toDouble()
            )
        )
    }
}
