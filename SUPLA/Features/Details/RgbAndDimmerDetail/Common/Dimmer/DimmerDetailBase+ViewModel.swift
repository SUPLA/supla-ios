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
    
import RxRelay
import RxSwift

private let REFRESH_DELAY_S: Double = 3

extension DimmerDetailBase {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate, ChannelUpdatesObserver, GroupUpdatesObserver {
        @Singleton var delayedRgbwActionSubject: DelayedRgbwActionSubject
        @Singleton var dateProvider: DateProvider
        
        @Singleton private var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCase
        @Singleton private var readGroupWithChannelsUseCase: ReadGroupWithChannels.UseCase
        @Singleton private var reorderColorListItemsUseCase: ReorderColorListItems.UseCase
        @Singleton private var deleteColorListItemUseCase: DeleteColorListItem.UseCase
        @Singleton private var getAllChannelIssuesUseCase: GetAllChannelIssuesUseCase
        @Singleton private var getChannelBaseStateUseCase: GetChannelBaseStateUseCase
        @Singleton private var getChannelBaseIconUseCase: GetChannelBaseIconUseCase
        @Singleton private var executeRgbActionUseCase: ExecuteRgbAction.UseCase
        @Singleton private var userStateHolder: UserStateHolder
        
        @Singleton<ColorListItemRepository> private var colorListItemRepository
        
        @Inject private var loadingTimeoutManager: LoadingTimeoutManager
        
        var remoteId: Int32? = nil
        var type: SubjectType? = nil
        var changing: Bool = false
        var lastInteractionTime: TimeInterval? = nil
        var maxNumberOfItems: Int { 10 }
        private var profileId: Int32? = nil
        private var rgbColor: HsvColor? = nil
        private let updateRelay = PublishRelay<Void>()
        
        var actionData: RgbwActionData? {
            guard let remoteId, let type, let brightness = state.value.brightness else { return nil }
            
            return RgbwActionData(
                remoteId: remoteId,
                type: type,
                brightness: brightness,
                color: rgbColor ?? .turnOff,
                dimmerCct: state.value.cct ?? 0
            )
        }
        
        func getOriginalButtonIcon(_ value: ChannelState.Value) -> IconResult {
            fatalError("getOriginalButtonIcon(_:): Not implemented")
        }
        
        override func onViewDidLoad() {
            loadingTimeoutManager.watch(
                stateProvider: { [weak self] in self?.state.loadingState }
            ) { [weak self] in
                self?.updateRelay.accept(())
                if let notLoadingState = self?.state.loadingState.copy(loading: false) {
                    self?.state.loadingState = notLoadingState
                }
            }
            .disposed(by: disposeBag)
            
            updateRelay
                .debounce(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.reloadData() })
                .disposed(by: disposeBag)
        }
        
        func loadData(remoteId: Int32, type: SubjectType) {
            self.remoteId = remoteId
            self.type = type
            
            switch (type) {
            case .channel: loadChannel(remoteId)
            case .group: loadGroup(remoteId)
            case .scene: break
            }
        }
        
        func onBrightnessSelectionStarted() {
            if (state.offline) {
                return
            }
            
            lastInteractionTime = dateProvider.currentTimestamp()
            changing = true
        }
        
        func onBrightnessSelecting(_ brightness: Int) {
            if (state.offline) {
                return
            }
            
            lastInteractionTime = dateProvider.currentTimestamp()
            // Setting brightness to 0 is not allowed. If the user wants turn off the dimmer
            // should click on turn off button
            state.value = .single(brightness: max(1, brightness), cct: state.value.cct ?? 0)
            
            if let actionData {
                delayedRgbwActionSubject.emit(data: actionData)
            }
        }
        
        func onBrightnessSelected() {
            if (state.offline) {
                return
            }
            
            state.loadingState = state.loadingState.copy(loading: true)
            changing = false
            lastInteractionTime = nil
            
            if let actionData {
                delayedRgbwActionSubject.sendImmediately(data: actionData)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
        }
        
        func toggleSelectorType() {
            switch (state.selectorType) {
            case .circular:
                state.selectorType = .linear
            case .linear:
                state.selectorType = .circular
            }
            
            if let profileId, let remoteId {
                userStateHolder.setDimmerSelectorType(state.selectorType, profileId: profileId, remoteId: remoteId)
            }
        }
        
        func updateSavedColorsOrder(items: [SavedColor]) {
            guard let remoteId, let type else { return }
            
            let indexMap = Dictionary(uniqueKeysWithValues: items.enumerated().map { (index, element) in (Int(element.idx), index + 1) })
            reorderColorListItemsUseCase.invoke(subject: type, remoteId: remoteId, type: .dimmer, indexMap: indexMap)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] items in
                        self?.state.savedColors = items.compactMap { $0.savedColor }
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func onSavedColorSelected(color: SavedColor) {
            fatalError("onSavedColorSelected(color:): Not implemented")
        }
        
        func onRemoveColor(color: SavedColor) {
            guard let remoteId, let type else { return }
            
            lastInteractionTime = nil
            deleteColorListItemUseCase.invoke(subject: type, remoteId: remoteId, type: .dimmer, idx: color.idx)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] _ in self?.reloadData() })
                .disposed(by: disposeBag)
        }
        
        func onSaveCurrentColor() {
            fatalError("onSaveCurrentColor(): Not implemented")
        }
        
        func turnOn() {
            guard state.offButtonState?.active == true
            else { return }
            
            turn(on: true)
            
            lastInteractionTime = nil
            state.loadingState = state.loadingState.copy(loading: true)
        }
        
        func turnOff() {
            guard state.onButtonState?.active == true
            else { return }
            
            turn(on: false)
            
            lastInteractionTime = nil
            state.loadingState = state.loadingState.copy(loading: true)
        }
        
        func onChannelUpdate(_ channelWithChildren: ChannelWithChildren) {
            reloadData()
        }
        
        func onGroupUpdate(_ groupId: Int32) {
            reloadData()
        }
        
        func reloadData() {
            guard let type, let remoteId else { return }
            
            switch (type) {
            case .channel: loadChannel(remoteId)
            case .group: loadGroup(remoteId)
            case .scene: break
            }
        }
        
        private func turn(on: Bool) {
            guard let remoteId, let type else { return }
            
            executeRgbActionUseCase.invoke(
                type: type,
                remoteId: remoteId,
                brightness: on ? 100 : 0,
                color: rgbColor ?? HsvColor(hue: 0, saturation: 0, value: 0.5),
                onOff: true,
                dimmerCct: 0
            )
            .subscribe()
            .disposed(by: disposeBag)
        }
        
        private func loadChannel(_ remoteId: Int32) {
            Observable.zip(
                readChannelWithChildrenUseCase.invoke(remoteId: remoteId),
                colorListItemRepository.find(byRemoteId: remoteId, forSubject: .channel, andType: .dimmer)
            ) { channel, colorItems in (channel, colorItems) }
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] channel, colorItems in
                        self?.handleChannel(channel, colorItems)
                    }
                )
                .disposed(by: disposeBag)
        }
        
        private func handleChannel(_ channelWithChildren: ChannelWithChildren, _ colorListItems: [SAColorListItem]) {
            if (changing) {
                SALog.info("Update skipped because of changing")
                return // Do not change anything, when user makes manual operations
            }
            
            if let lastInteractionTime,
               lastInteractionTime + REFRESH_DELAY_S > dateProvider.currentTimestamp()
            {
                SALog.info("Update skipped because of last interaction time")
                updateRelay.accept(())
                return // Do not change anything during 3 secs after last user interaction
            }
            SALog.debug("Updating state with data")
            
            let channel = channelWithChildren.channel
            let channelState = getChannelBaseStateUseCase.invoke(channelBase: channel)
            let value = channel.value?.asRgbwwValue()
            let dimmerValue: DimmerDetailBase.DimmerValue =
                if let brightness = value?.brightness {
                    .single(brightness: Int(brightness), cct: Int(value?.cct ?? 0))
                } else {
                    .empty
                }
            
            profileId = channel.profile.id
            rgbColor = value?.color.toHsv(value?.colorBrightness)
            
            state.offline = channel.status().offline
            state.value = dimmerValue
            state.deviceStateData = .init(
                label: Strings.SwitchDetail.stateLabel,
                icon: getChannelBaseIconUseCase.invoke(channel: channel),
                value: getDeviceStateValue(channel.status(), channelState)
            )
            state.issues = getAllChannelIssuesUseCase.invoke(channelWithChildren: channelWithChildren.shareable)
            state.onButtonState = .init(
                icon: getButtonIcon(channel, .on),
                label: Strings.General.turnOn,
                active: value?.brightness ?? 0 > 0,
                type: .positive
            )
            state.offButtonState = .init(
                icon: getButtonIcon(channel, .off),
                label: Strings.General.turnOff,
                active: value?.brightness ?? 0 == 0,
                type: .negative
            )
            state.loadingState = state.loadingState.copy(loading: false)
            state.savedColors = colorListItems.compactMap { $0.savedColor }
            state.selectorType = userStateHolder.getDimmerSelectorType(profileId: channel.profile.id, remoteId: channel.remote_id)
        }
        
        private func getButtonIcon(_ channel: SAChannelBase, _ value: ChannelState.Value) -> IconResult {
            switch (channel.func.suplaFuntion) {
            case .dimmerAndRgbLighting, .dimmerCctAndRgb: getOriginalButtonIcon(value)
            default: getChannelBaseIconUseCase.stateIcon(channel, state: .default(value: value))
            }
        }
        
        private func getDeviceStateValue(_ status: SuplaChannelAvailabilityStatus, _ state: ChannelState) -> String {
            if (status.offline) {
                return Strings.SwitchDetail.stateOffline
            }
            
            let isOn = switch (state) {
            case .default(let value): value == .on
            case .rgbAndDimmer(let dimmer, _): dimmer == .on
            }
            
            if (isOn) {
                return Strings.General.on
            } else {
                return Strings.General.off
            }
        }
        
        private func loadGroup(_ remoteId: Int32) {
            Observable.zip(
                readGroupWithChannelsUseCase.invoke(remoteId: remoteId),
                colorListItemRepository.find(byRemoteId: remoteId, forSubject: .group, andType: .dimmer)
            ) { channel, colorItems in (channel, colorItems) }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] group, colors in
                    self?.handleGroup(group, colors)
                })
                .disposed(by: disposeBag)
        }
        
        private func handleGroup(_ groupWithChannels: ReadGroupWithChannels.GroupWithChannels, _ colors: [SAColorListItem]) {
            if (changing) {
                SALog.info("Update skipped because of changing")
                return // Do not change anything, when user makes manual operations
            }
            
            if let lastInteractionTime,
               lastInteractionTime + REFRESH_DELAY_S > dateProvider.currentTimestamp()
            {
                SALog.info("Update skipped because of last interaction time")
                updateRelay.accept(())
                return // Do not change anything during 3 secs after last user interaction
            }
            SALog.debug("Updating state with data")
            
            let group = groupWithChannels.group
            let groupStateValue = groupWithChannels.aggregatedState(policy: .dimmer)
            
            profileId = group.profile.id
            
            state.onButtonState = .init(
                icon: getButtonIcon(group, .on),
                label: Strings.General.turnOn,
                active: groupStateValue == .on,
                type: .positive
            )
            state.offButtonState = .init(
                icon: getButtonIcon(group, .off),
                label: Strings.General.turnOff,
                active: groupStateValue == .off,
                type: .negative
            )
            state.deviceStateData = .init(
                label: Strings.SwitchDetail.stateLabel,
                icon: getChannelBaseIconUseCase.invoke(channel: group),
                value: getDeviceStateValue(group.status(), .default(value: groupStateValue ?? .off))
            )
            state.value = .multiple(group.brightness, group.cct)
            state.offline = group.status().offline
            state.loadingState = state.loadingState.copy(loading: false)
            state.savedColors = colors.compactMap { $0.savedColor }
            state.selectorType = userStateHolder.getDimmerSelectorType(profileId: group.profile.id, remoteId: group.remote_id)
        }
    }
}
