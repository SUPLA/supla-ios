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

extension ElectricityMeterSettingsFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<UserStateHolder> private var userStateHolder
        @Singleton<GetCaptionUseCase> private var getCaptionsUseCase
        @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
        @Singleton<RefreshElectricityMeterAggregatedValue.UseCase> private var refreshElectricityMeterAggregatedValueUseCase

        private var availableBalancingOptions: [ElectricityMeterBalanceType] = []
        private var remoteId: Int32 = 0
        private var profileId: Int32 = 0

        init() {
            super.init(state: ViewState())
        }

        func loadData(_ remoteId: Int32) {
            readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] in self?.self.handleChannel($0) }
                )
                .disposed(by: disposeBag)
        }

        func metricOnListChange(_ type: ElectricityMeterMeasurementType?) {
            let settings = userStateHolder.getElectricityMeterSettings(profileId: profileId, remoteId: remoteId)
            guard let type, settings.metricOnList != type else { return }

            let availableAggregations = type.aggregationOptions
            let selectedAggregation = availableAggregations.selected(item: state.metricOnListAggregation?.selected)

            let availableBalancings = balancingOptions(type, selectedAggregation)
            let selectedBalancing = availableBalancings.selected(item: state.metricOnListBalancing?.selected)

            let updatedSettings = settings.copy(
                metricOnList: type,
                metricOnListBalancing: selectedBalancing,
                metricOnListAggregation: selectedAggregation
            )
            userStateHolder.setElectricityMeterSettings(updatedSettings, profileId: profileId, remoteId: remoteId)

            state.metricOnList = state.metricOnList?.changing(path: \.selected, to: type)
            state.metricOnListAggregation = availableAggregations.selectableList(selected: selectedAggregation)
            state.metricOnListBalancing = availableBalancings.selectableList(selected: selectedBalancing)

            Task {
                await refreshElectricityMeterAggregatedValueUseCase.invoke(profileId: profileId, remoteId: remoteId)
            }
        }

        func metricOnListAggregationChange(_ aggregation: ListValueAggregation?) {
            let settings = userStateHolder.getElectricityMeterSettings(profileId: profileId, remoteId: remoteId)
            guard let aggregation, settings.metricOnListAggregation != aggregation else { return }

            let availableBalancings = balancingOptions(settings.metricOnList, aggregation)
            let selectedBalancing = availableBalancings.selected(item: state.metricOnListBalancing?.selected)

            let updatedSettings = settings.copy(
                metricOnListBalancing: selectedBalancing,
                metricOnListAggregation: aggregation
            )
            userStateHolder.setElectricityMeterSettings(updatedSettings, profileId: profileId, remoteId: remoteId)

            state.metricOnListAggregation = state.metricOnListAggregation?.changing(path: \.selected, to: aggregation)
            state.metricOnListBalancing = availableBalancings.selectableList(selected: selectedBalancing)

            Task {
                await refreshElectricityMeterAggregatedValueUseCase.invoke(profileId: profileId, remoteId: remoteId)
            }
        }

        func metricOnListBalancingChange(_ type: ElectricityMeterBalanceType?) {
            let settings = userStateHolder.getElectricityMeterSettings(profileId: profileId, remoteId: remoteId)
            guard let type, settings.metricOnListBalancing != type else { return }

            userStateHolder.setElectricityMeterSettings(settings.copy(metricOnListBalancing: type), profileId: profileId, remoteId: remoteId)

            state.metricOnListBalancing = state.metricOnListBalancing?.changing(path: \.selected, to: type)

            Task {
                await refreshElectricityMeterAggregatedValueUseCase.invoke(profileId: profileId, remoteId: remoteId)
            }
        }

        func currentMonthBalancingChange(_ type: ElectricityMeterBalanceType?) {
            guard let type else { return }

            let settings = userStateHolder.getElectricityMeterSettings(profileId: profileId, remoteId: remoteId)
            userStateHolder.setElectricityMeterSettings(settings.copy(currentMonthBalancing: type), profileId: profileId, remoteId: remoteId)

            state.currentMonthBalancing?.selected = type
        }

        private func handleChannel(_ channel: SAChannel) {
            let measuredValues = channel.ev?.electricityMeter().suplaElectricityMeterMeasuredTypes ?? []
            let settings = userStateHolder.getElectricityMeterSettings(profileId: channel.profile.id, remoteId: channel.remote_id)

            availableBalancingOptions = ElectricityMeterSettings.balancingAllItems.filter { it in
                switch it {
                case .vector: measuredValues.hasBalance
                case .arithmetic, .hourly: measuredValues.contains(.forwardActiveEnergy) && measuredValues.contains(.reverseActiveEnergy)
                default: false
                }
            }

            let availableMetrics = ElectricityMeterMeasurementType.allCases.filter { $0.inside(measuredValues) }
            let selectedMetric = availableMetrics.select(item: settings.metricOnList)

            let availableAggregations = selectedMetric.aggregationOptions
            let selectedAggregation = availableAggregations.selected(item: settings.metricOnListAggregation)

            let availableBalancings = balancingOptions(selectedMetric, settings.metricOnListAggregation)
            let selectedBalancing = availableBalancings.selected(item: settings.metricOnListBalancing)

            remoteId = channel.remote_id
            profileId = channel.profile.id

            state.channelName = getCaptionsUseCase.invoke(data: channel.shareable).string
            state.metricOnList = availableMetrics.selectableList(selected: selectedMetric)
            state.metricOnListAggregation = availableAggregations.selectableList(selected: selectedAggregation)
            state.metricOnListBalancing = availableBalancings.selectableList(selected: selectedBalancing)
            state.currentMonthBalancing = currentMonthBalancingOptions(selected: settings.currentMonthBalancing)
        }

        private func balancingOptions(_ metric: ElectricityMeterMeasurementType, _ selected: ListValueAggregation?) -> [ElectricityMeterBalanceType] {
            if (metric.balancingAvailable) {
                availableBalancingOptions.filter { $0 != .hourly || selected != .noAggregation }
            } else {
                []
            }
        }

        private func currentMonthBalancingOptions(selected: ElectricityMeterBalanceType) -> SelectableList<ElectricityMeterBalanceType>? {
            if (availableBalancingOptions.count > 1) {
                SelectableList(
                    selected: availableBalancingOptions.first { $0 == selected } ?? availableBalancingOptions.first,
                    items: availableBalancingOptions
                )
            } else {
                nil
            }
        }
    }
}

private extension Array where Element == ElectricityMeterMeasurementType {
    func select(item: ElectricityMeterMeasurementType) -> ElectricityMeterMeasurementType {
        first { $0 == item } ?? first ?? .forwardActiveEnergy
    }

    func selectableList(selected: ElectricityMeterMeasurementType) -> SelectableList<ElectricityMeterMeasurementType>? {
        if (count > 1) {
            SelectableList(selected: selected, items: self)
        } else {
            nil
        }
    }
}

private extension Array where Element == ListValueAggregation {
    func selected(item: ListValueAggregation?) -> ListValueAggregation {
        first { $0 == item } ?? first ?? .noAggregation
    }

    func selectableList(selected: ListValueAggregation) -> SelectableList<ListValueAggregation>? {
        if (count > 1) {
            SelectableList(selected: selected, items: self)
        } else {
            nil
        }
    }
}

private extension Array where Element == ElectricityMeterBalanceType {
    func selected(item: ElectricityMeterBalanceType?) -> ElectricityMeterBalanceType {
        first { $0 == item } ?? first ?? .defaultValue
    }

    func selectableList(selected: ElectricityMeterBalanceType) -> SelectableList<ElectricityMeterBalanceType>? {
        if (count > 1) {
            SelectableList(selected: selected, items: self)
        } else {
            nil
        }
    }
}
