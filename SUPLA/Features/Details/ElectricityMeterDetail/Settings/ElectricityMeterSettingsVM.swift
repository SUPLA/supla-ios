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
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<UserStateHolder> private var userStateHolder
        @Singleton<GetChannelBaseCaptionUseCase> private var getChannelBaseCaptionUseCase
        @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase

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

        func onShowOnChannelsListChange(_ item: SuplaElectricityMeasurementType) {
            let settings = userStateHolder.getElectricityMeterSettings(profileId: state.profileId, remoteId: state.remoteId)
            userStateHolder.setElectricityMeterSettings(settings.copy(showOnList: item), profileId: state.profileId, remoteId: state.remoteId)

            state.showOnChannelsList.selected = item
        }

        func onBalanceValueChange(_ item: ElectricityMeterBalanceType?) {
            guard let item else { return }

            let settings = userStateHolder.getElectricityMeterSettings(profileId: state.profileId, remoteId: state.remoteId)
            userStateHolder.setElectricityMeterSettings(settings.copy(balancing: item), profileId: state.profileId, remoteId: state.remoteId)

            state.balancing?.selected = item
        }

        private func handleChannel(_ channel: SAChannel) {
            let measuredValues: [SuplaElectricityMeasurementType] =
                if let types = channel.ev?.electricityMeter().suplaElectricityMeterMeasuredTypes {
                    types
                } else {
                    []
                }

            let settings = userStateHolder.getElectricityMeterSettings(profileId: channel.profile.idString, remoteId: channel.remote_id)
            let phases = channel.phases

            let balancingItems: [ElectricityMeterBalanceType]? =
                if (phases.count > 0 || measuredValues.hasBalance) {
                    ElectricityMeterSettings.balancingAllItems.filter {
                        switch ($0) {
                        case .vector: measuredValues.hasBalance
                        default: phases.count > 1
                        }
                    }
                } else {
                    nil
                }

            let selectedBalance = balancingItems?.first(where: { $0 == settings.balancing }) ?? balancingItems?.first
            let balancingList: SelectableList<ElectricityMeterBalanceType>? =
                if let balancingItems, let selectedBalance, balancingItems.count > 1 {
                    SelectableList(selected: selectedBalance, items: balancingItems)
                } else {
                    nil
                }

            state.remoteId = channel.remote_id
            state.profileId = channel.profile.idString

            state.channelName = getChannelBaseCaptionUseCase.invoke(channelBase: channel)
            state.showOnChannelsList = SelectableList(
                selected: settings.showOnListSafe,
                items: ElectricityMeterSettings.showOnListAllItems.filter { measuredValues.contains($0) }
            )
            state.balancing = balancingList
        }
    }
}
