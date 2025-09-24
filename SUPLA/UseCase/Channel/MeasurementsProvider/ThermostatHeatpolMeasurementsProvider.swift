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
import SharedCore

protocol ThermostatHeatpolMeasurementsProvider: ChannelMeasurementsProvider {}

final class ThermostatHeatpolMeasurementsProviderImpl: ThermostatHeatpolMeasurementsProvider {
    @Singleton<ThermostatMeasurementItemRepository> private var thermostatMeasurementItemRepository
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<GetChannelValueUseCase> private var getChannelValueUseCase
    @Singleton<GetChannelValueStringUseCase> private var getChannelValueStringUseCase
    @Singleton<SharedCore.ThermometerValueFormatter> private var thermometerValueFormatter

    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
    }

    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<[ChannelChartSets]> {
        let value: HomePlusThermostatValue = getChannelValueUseCase.invoke(channelWithChildren.channel)
        
        return thermostatMeasurementItemRepository
            .findMeasurements(
                remoteId: channelWithChildren.remoteId,
                serverId: channelWithChildren.channel.profile.server?.id,
                startDate: spec.startDate,
                endDate: spec.endDate
            )
            .map { entities in
                [
                    HistoryDataSet(
                        type: .temperature,
                        label: self.measuredTemperatureLabel(channelWithChildren, value),
                        valueFormatter: self.getValueFormatter(.temperature, channelWithChildren),
                        entries: self.divideSetToSubsets(self.aggregatingTemperature(entities, spec.aggregation) { $0.measured }, spec.aggregation),
                        active: true
                    ),
                    HistoryDataSet(
                        type: .presetTemperature,
                        label: self.presetTemperatureLabel(channelWithChildren, value),
                        valueFormatter: self.getValueFormatter(.presetTemperature, channelWithChildren),
                        entries: self.divideSetToSubsets(self.aggregatingTemperature(entities, spec.aggregation) { $0.preset }, spec.aggregation),
                        active: true
                    )
                ]
            }
            .map { [self.channelChartSets(channelWithChildren.channel, spec, $0)] }
    }
    
    private func measuredTemperatureLabel(_ channelWithChildren: ChannelWithChildren, _ value: HomePlusThermostatValue) -> HistoryDataSet.Label {
        .single(
            HistoryDataSet.LabelData(
                icon: getChannelBaseIconUseCase.invoke(channel: channelWithChildren.channel),
                value: thermometerValueFormatter.format(value: value.measuredTemperature, format: ValueFormat.companion.WithUnit),
                color: TemperatureColors.standard,
                description: Strings.Charts.temperatureMeasured
            )
        )
    }
    
    private func presetTemperatureLabel(_ channelWithChildren: ChannelWithChildren, _ value: HomePlusThermostatValue) -> HistoryDataSet.Label {
        .single(
            HistoryDataSet.LabelData(
                icon: nil,
                value: thermometerValueFormatter.format(value: value.presetTemperature, format: ValueFormat.companion.WithUnit),
                color: HumidityColors.standard,
                description: Strings.Charts.temperaturePreset
            )
        )
    }
}
