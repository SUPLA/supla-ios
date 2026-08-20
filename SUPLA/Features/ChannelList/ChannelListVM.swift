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

extension ChannelListFeature {
    class ViewModel: MainListViewModel<ChannelListFeature.ViewState>, ChannelListFeature.ViewDelegate {
        @Singleton<CreateProfileChannelsList.UseCase> private var createProfileChannelsListUseCase
        @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
        @Singleton<ProvideChannelDetailTypeUseCase> private var provideDetailTypeUseCase
        @Singleton<ChannelBaseActionUseCase> private var channelBaseActionUseCase
        @Singleton<ExecuteSimpleAction.UseCase> private var executeSimpleActionUseCase
        @Singleton<SwapChannelPositionsUseCase> private var swapChannelPositionsUseCase
        @Singleton<ToggleLocationUseCase> private var toggleLocationUseCase
        @Singleton<UpdateEventsManager> private var updateEventsManager
        @Singleton<ChannelToMainListItem.UseCase> private var channelToMainListItemUseCase
        @Singleton<TriggerLogHistoryDownload.UseCase> private var triggerLogHistoryDownloadUseCase
        @Singleton<AppRouter> private var router

        private var triggerLogHistoryDownloadTask: Task<Void, Never>? = nil

        init(state: ChannelListFeature.ViewState = ChannelListFeature.ViewState()) {
            super.init(state: state)
            observeStructureUpdates()
            observeChannelUpdates()
        }

        override func onViewAppear() {
            loadItems()
            startTriggerLogHistoryDownload()
        }

        override func onViewDisappear() {
            super.onViewDisappear()
            stopTriggerLogHistoryDownload()
        }

        func onItemClick(_ item: MainListItem) {
            switch (item) {
            case .channel, .hvacThermostat, .heatpolThermostat, .doubleValue:
                readChannelWithChildrenUseCase
                    .invoke(remoteId: item.remoteId)
                    .asDriverWithoutError()
                    .drive(onNext: { [weak self] in self?.handleClickedItem($0) })
                    .disposed(by: disposeBag)
            default:
                break
            }
        }

        func onIssueClick(_ issues: ListItemIssues) {
            if (issues.hasMessage()) {
                state.alertDialogState = ChannelListAlertDialogState(
                    message: issues.message,
                    remoteId: nil,
                    action: nil,
                    positiveButtonText: Strings.General.ok,
                    negativeButtonText: nil
                )
            }
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
                swapChannelPositionsUseCase
                    .invoke(
                        firstRemoteId: sourceItem.remoteId,
                        secondRemoteId: destinationItem.remoteId,
                        locationCaption: locationCaption
                    )
            )
        }

        func onLocationClick(_ item: LocationListItem) {
            loadItems(after: toggleLocationUseCase.invoke(remoteId: item.remoteId, collapsedFlag: .channel))
        }

        func onAlertConfirmed(_ remoteId: Int32?, _ action: ActionId?) {
            state.alertDialogState = nil
            if let action, let remoteId {
                executeSimpleActionUseCase
                    .invoke(action: action, type: .channel, remoteId: remoteId)
                    .asDriverWithoutError()
                    .drive()
                    .disposed(by: disposeBag)
            }
        }

        func onAlertDismissed() {
            state.alertDialogState = nil
        }

        func onAddDeviceClick() {
            router.navigate(to: .addWizard)
        }

        func onDeviceCatalogClick() {
            router.navigate(to: .deviceCatalog)
        }

        private func loadItems(after observable: Observable<Void> = Observable.just(())) {
            state.loading = !state.listLoaded
            observable
                .flatMapFirstWeak(with: self) { owner, _ in
                    owner.createProfileChannelsListUseCase.invoke()
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
                        SALog.error("Creating channels list failed with error: \(String(describing: error))")
                    }
                })
                .disposed(by: disposeBag)
        }

        private func observeStructureUpdates() {
            loadItems(after: updateEventsManager.observeChannelsUpdate())
        }

        private func observeChannelUpdates() {
            updateEventsManager
                .observeAllChannels()
                .flatMapFirstWeak(with: self) { owner, remoteId in
                    owner.readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
                }
                .compactMap { [weak self] channelWithChildren in
                    self?.channelToMainListItemUseCase.invoke(channelWithChildren)
                }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] item in self?.updateItem(item) })
                .disposed(by: disposeBag)
        }

        private func updateItem(_ item: MainListItem) {
            guard let index = state.items.firstIndex(where: { $0.key == item.key }) else { return }
            state.items[index] = item
        }

        private func startTriggerLogHistoryDownload() {
            guard triggerLogHistoryDownloadTask == nil else { return }

            let useCase = triggerLogHistoryDownloadUseCase
            triggerLogHistoryDownloadTask = Task { [useCase] in
                while !Task.isCancelled {
                    await useCase.invoke()

                    do {
                        try await Task.sleep(nanoseconds: 15 * 1_000_000_000)
                    } catch {
                        return
                    }
                }
            }
        }

        private func stopTriggerLogHistoryDownload() {
            triggerLogHistoryDownloadTask?.cancel()
            triggerLogHistoryDownloadTask = nil
        }

        private func onButtonClicked(buttonType: CellButtonType, item: MainListItem) {
            channelBaseActionUseCase
                .invoke(item.remoteId, buttonType)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] result in
                    switch result {
                    case .valveFlooding:
                        self?.showAlertDialog(Strings.Valve.warningFlooding, item.remoteId, .open)
                    case .valveManuallyClosed:
                        self?.showAlertDialog(Strings.Valve.warningManuallyClosed, item.remoteId, .open)
                    case .valveMotorProblemOpening:
                        self?.showAlertDialog(Strings.Valve.warningMotorProblemOpening, item.remoteId, .open)
                    case .valveMotorProblemClosing:
                        self?.showAlertDialog(Strings.Valve.warningMotorProblemClosing, item.remoteId, .close)
                    case .overcurrentRelayOff:
                        self?.showAlertDialog(Strings.SwitchDetail.overcurrentQuestion, item.remoteId, .turnOn)
                    case .success:
                        break
                    }
                })
                .disposed(by: disposeBag)
        }

        private func handleClickedItem(_ channelWithChildren: ChannelWithChildren) {
            let channel = channelWithChildren.channel
            if (!isAvailableInOffline(channel, children: channelWithChildren.children) && channel.status().offline) {
                return
            }

            guard let detailType = provideDetailTypeUseCase.invoke(channelWithChildren: channelWithChildren) else {
                return
            }

            navigateToDetail(detailType, item: channel.item(), remoteId: channel.remote_id)
        }

        private func showAlertDialog(
            _ message: String,
            _ remoteId: Int32? = nil,
            _ action: ActionId? = nil,
            positiveButtonText: String? = Strings.General.yes,
            negativeButtonText: String? = Strings.General.no
        ) {
            state.alertDialogState = ChannelListAlertDialogState(
                message: message,
                remoteId: remoteId,
                action: action,
                positiveButtonText: positiveButtonText,
                negativeButtonText: negativeButtonText
            )
        }
    }
}
