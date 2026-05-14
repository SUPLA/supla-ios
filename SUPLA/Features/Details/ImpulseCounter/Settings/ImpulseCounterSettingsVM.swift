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

extension ImpulseCounterSettingsFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<RefreshImpulseCounterAggregatedValue.UseCase> private var refreshImpulseCounterAggregatedValueUseCase
        @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
        @Singleton<GetCaptionUseCase> private var getCaptionUseCase
        @Singleton<UserStateHolder> private var userStateHolder

        private let item: ItemBundle

        init(_ item: ItemBundle) {
            self.item = item
            super.init(state: ViewState())
        }

        func onListValueAggregationChanged(_ newValue: ListValueAggregation?) {
            let profileId = item.profileId
            let remoteId = item.remoteId

            state.listValueAggregation = state.listValueAggregation.changing(path: \.selected, to: newValue)

            let settings = userStateHolder.getImpulseCounterSettings(profileId: profileId, remoteId: remoteId)
            userStateHolder.setImpulseCounterSettings(settings.copy(showOnList: newValue), profileId: profileId, remoteId: remoteId)
            
            let refreshUseCase = refreshImpulseCounterAggregatedValueUseCase
            Task { [refreshUseCase] in
                await refreshUseCase.invoke(profileId: profileId, remoteId: remoteId)
            }
        }

        func loadData() {
            readChannelByRemoteIdUseCase.invoke(remoteId: item.remoteId)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] in self?.handleChannel($0) }
                )
                .disposed(by: disposeBag)
        }

        private func handleChannel(_ channel: SAChannel) {
            let settings = userStateHolder.getImpulseCounterSettings(profileId: item.profileId, remoteId: item.remoteId)

            state.channelName = getCaptionUseCase.invoke(data: channel.shareable).string
            state.listValueAggregation = state.listValueAggregation.changing(path: \.selected, to: settings.showOnList)
        }
    }
}
