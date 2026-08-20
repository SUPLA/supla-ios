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

extension GroupListFeature {
    class ViewModel: MainListViewModel<GroupListFeature.ViewState>, GroupListFeature.ViewDelegate {
        @Singleton<CreateProfileGroupsList.UseCase> private var createProfileGroupsListUseCase
        @Singleton<ReadGroupByRemoteIdUseCase> private var readGroupByRemoteIdUseCase
        @Singleton<ProvideGroupDetailTypeUseCase> private var provideDetailTypeUseCase
        @Singleton<ChannelBaseActionUseCase> private var channelBaseActionUseCase
        @Singleton<SwapGroupPositionsUseCase> private var swapGroupPositionsUseCase
        @Singleton<ToggleLocationUseCase> private var toggleLocationUseCase
        @Singleton<UpdateEventsManager> private var updateEventsManager
        @Singleton<GroupToMainListItem.UseCase> private var groupToMainListItemUseCase
        @Singleton<LoadActiveProfileUrlUseCase> private var loadActiveProfileUrlUseCase
        @Singleton<AppRouter> private var router

        init(state: GroupListFeature.ViewState = GroupListFeature.ViewState()) {
            super.init(state: state)
            observeStructureUpdates()
            observeGroupUpdates()
        }

        override func onViewAppear() {
            loadItems()
        }

        func onItemClick(_ item: MainListItem) {
            guard case .group = item else { return }

            readGroupByRemoteIdUseCase
                .invoke(remoteId: item.remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleClickedItem($0) })
                .disposed(by: disposeBag)
        }

        func onLeftButtonClick(_ item: MainListItem) {
            onButtonClicked(buttonType: .leftButton, item: item)
        }

        func onRightButtonClick(_ item: MainListItem) {
            onButtonClicked(buttonType: .rightButton, item: item)
        }

        func onMove(_ sourceItem: MainListItem, _ destinationItem: MainListItem) {
            guard let locationCaption = sourceItem.locationCaption else { return }

            loadItems(after:
                swapGroupPositionsUseCase
                    .invoke(
                        firstRemoteId: sourceItem.remoteId,
                        secondRemoteId: destinationItem.remoteId,
                        locationCaption: locationCaption
                    )
            )
        }

        func onLocationClick(_ item: LocationListItem) {
            loadItems(after: toggleLocationUseCase.invoke(remoteId: item.remoteId, collapsedFlag: .group))
        }

        func onNoContentButtonClick() {
            loadActiveProfileUrlUseCase
                .invoke()
                .asDriverWithoutError()
                .drive(onNext: { [weak self] url in self?.router.openUrl(url: url.url) })
                .disposed(by: disposeBag)
        }

        private func loadItems(after observable: Observable<Void> = Observable.just(())) {
            state.loading = !state.listLoaded
            observable
                .flatMapFirstWeak(with: self) { owner, _ in
                    owner.createProfileGroupsListUseCase.invoke()
                }
                .asDriver()
                .drive(onNext: { [weak self] result in
                    guard let self else { return }
                    state.loading = false
                    state.listLoaded = true

                    switch result {
                    case .success(let items):
                        state.items = items
                    case .error(let error):
                        SALog.error("Creating groups list failed with error: \(String(describing: error))")
                    }
                })
                .disposed(by: disposeBag)
        }

        private func observeStructureUpdates() {
            loadItems(after: updateEventsManager.observeGroupsUpdate())
        }

        private func observeGroupUpdates() {
            updateEventsManager
                .observeAllGroups()
                .flatMapFirstWeak(with: self) { owner, remoteId in
                    owner.readGroupByRemoteIdUseCase.invoke(remoteId: remoteId)
                }
                .compactMap { [weak self] group in
                    self?.groupToMainListItemUseCase.invoke(group)
                }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] item in self?.updateItem(item) })
                .disposed(by: disposeBag)
        }

        private func updateItem(_ item: MainListItem) {
            guard let index = state.items.firstIndex(where: { $0.key == item.key }) else { return }
            state.items[index] = item
        }

        private func onButtonClicked(buttonType: CellButtonType, item: MainListItem) {
            guard case .group = item else { return }

            readGroupByRemoteIdUseCase
                .invoke(remoteId: item.remoteId)
                .flatMapFirstWeak(with: self) { owner, group in
                    owner.channelBaseActionUseCase.invoke(group, buttonType)
                }
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }

        private func handleClickedItem(_ group: SAChannelGroup) {
            if (!isAvailableInOffline(group) && group.status().offline) {
                return
            }

            guard let detailType = provideDetailTypeUseCase.invoke(group: group) else {
                return
            }

            navigateToDetail(detailType, item: group.item(), remoteId: group.remote_id)
        }
    }
}
