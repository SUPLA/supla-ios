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

protocol TemperatureMeasurementsProvider: ChannelMeasurementsProvider {}

final class TemperatureMeasurementsProviderImpl: TemperatureMeasurementsProvider {
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<GetChannelBaseCaptionUseCase> private var getChannelBaseCaptionUseCase

    func handle(_ function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_THERMOMETER
    }

    func provide(_ channel: SAChannel, _ spec: ChartDataSpec, _ colorProvider: ((ChartEntryType) -> UIColor)?) -> Observable<ChannelChartSets> {
        let entryType: ChartEntryType = .temperature
        let color = colorProvider?(entryType) ?? TemperatureColors.standard

        return temperatureMeasurementItemRepository
            .findMeasurements(
                remoteId: channel.remote_id,
                profile: channel.profile,
                startDate: spec.startDate,
                endDate: spec.endDate
            )
            .map { entities in self.aggregatingTemperature(entities, spec.aggregation) }
            .map { [self.historyDataSet(channel, entryType, color, spec.aggregation, $0)] }
            .map {
                ChannelChartSets(
                    remoteId: channel.remote_id,
                    function: channel.func,
                    name: self.getChannelBaseCaptionUseCase.invoke(channelBase: channel),
                    aggregation: spec.aggregation,
                    dataSets: $0
                )
            }
    }
}
