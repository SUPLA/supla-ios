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

extension SceneListFeature {
    class ViewModel: MainListViewModel<SceneListFeature.ViewState>, SceneListFeature.ViewDelegate {
        @Singleton<CreateProfileScenesList.UseCase> private var createProfileScenesListUseCase
        @Singleton<ReadSceneByRemoteIdUseCase> private var readSceneByRemoteIdUseCase
        @Singleton<SceneToMainListItem.UseCase> private var sceneToMainListItemUseCase
        @Singleton<SwapScenePositionsUseCase> private var swapScenePositionsUseCase
        @Singleton<ToggleLocationUseCase> private var toggleLocationUseCase
        @Singleton<UpdateEventsManager> private var updateEventsManager
        @Singleton<ExecuteSimpleAction.UseCase> private var executeSimpleActionUseCase
        @Singleton<LoadActiveProfileUrlUseCase> private var loadActiveProfileUrlUseCase
        @Singleton<AppRouter> private var router

        init(state: SceneListFeature.ViewState = SceneListFeature.ViewState()) {
            super.init(state: state)
            observeStructureUpdates()
            observeSceneUpdates()
        }

        override func onViewAppear() {
            loadItems()
        }

        func onLeftButtonClick(_ item: MainListItem) {
            guard case .scene = item else { return }
            executeSimpleActionUseCase
                .invoke(action: .interrupt, type: .scene, remoteId: item.remoteId)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }

        func onRightButtonClick(_ item: MainListItem) {
            guard case .scene = item else { return }
            executeSimpleActionUseCase
                .invoke(action: .execute, type: .scene, remoteId: item.remoteId)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }

        func onMove(_ sourceItem: MainListItem, _ destinationItem: MainListItem) {
            guard let locationCaption = sourceItem.locationCaption else { return }

            loadItems(after:
                swapScenePositionsUseCase
                    .invoke(
                        firstRemoteId: sourceItem.remoteId,
                        secondRemoteId: destinationItem.remoteId,
                        locationCaption: locationCaption
                    )
            )
        }

        func onLocationClick(_ item: LocationListItem) {
            loadItems(after: toggleLocationUseCase.invoke(remoteId: item.remoteId, collapsedFlag: .scene))
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
                    owner.createProfileScenesListUseCase.invoke()
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
                        SALog.error("Creating scenes list failed with error: \(String(describing: error))")
                    }
                })
                .disposed(by: disposeBag)
        }

        private func observeStructureUpdates() {
            loadItems(after: updateEventsManager.observeScenesUpdate())
        }

        private func observeSceneUpdates() {
            updateEventsManager
                .observeAllScenes()
                .flatMapFirstWeak(with: self) { owner, remoteId in
                    owner.readSceneByRemoteIdUseCase.invoke(remoteId: remoteId)
                }
                .compactMap { [weak self] scene in
                    self?.sceneToMainListItemUseCase.invoke(scene)
                }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] item in self?.updateItem(item) })
                .disposed(by: disposeBag)
        }

        private func updateItem(_ item: MainListItem) {
            guard let index = state.items.firstIndex(where: { $0.key == item.key }) else { return }
            state.items[index] = item
        }
    }
}
