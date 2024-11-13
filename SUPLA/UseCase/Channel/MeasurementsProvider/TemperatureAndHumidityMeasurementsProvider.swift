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

protocol TemperatureAndHumidityMeasurementsProvider: ChannelMeasurementsProvider {}

final class TemperatureAndHumidityMeasurementsProviderImpl: TemperatureAndHumidityMeasurementsProvider {
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase

    func handle(_ function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
    }

    func provide(_ channel: SAChannel, _ spec: ChartDataSpec, _ colorProvider: ((ChartEntryType) -> UIColor)?) -> Observable<ChannelChartSets> {
        tempHumidityMeasurementItemRepository
            .findMeasurements(
                remoteId: channel.remote_id,
                profile: channel.profile,
                startDate: spec.startDate,
                endDate: spec.endDate
            )
            .map { measurements in
                [
                    self.historyDataSet(
                        channel,
                        .temperature,
                        colorProvider?(.temperature) ?? TemperatureColors.standard,
                        spec.aggregation,
                        self.aggregatingTemperature(measurements, spec.aggregation)
                    ),
                    self.historyDataSet(
                        channel,
                        .humidity,
                        colorProvider?(.humidity) ?? HumidityColors.standard,
                        spec.aggregation,
                        self.aggregatingHumidity(measurements, spec.aggregation)
                    )
                ]
            }
            .map {
                ChannelChartSets(
                    remoteId: channel.remote_id,
                    function: channel.func,
                    name: self.getCaptionUseCase.invoke(data: channel.shareable).string,
                    aggregation: spec.aggregation,
                    dataSets: $0
                )
            }
    }
}
