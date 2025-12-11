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

extension DimmerDetailFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate, ChannelUpdatesObserver, GroupUpdatesObserver {
        @Singleton private var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCase
        @Singleton private var readGroupWithChannelsUseCase: ReadGroupWithChannels.UseCase
        @Singleton private var getAllChannelIssuesUseCase: GetAllChannelIssuesUseCase
        @Singleton private var getChannelBaseStateUseCase: GetChannelBaseStateUseCase
        @Singleton private var getChannelBaseIconUseCase: GetChannelBaseIconUseCase
        @Singleton private var executeRgbActionUseCase: ExecuteRgbAction.UseCase
        @Singleton private var delayedRgbActionSubject: DelayedRgbwActionSubject
        @Singleton private var dateProvider: DateProvider
        @Singleton private var schedulers: SuplaSchedulers
        
        @Inject private var loadingTimeoutManager: LoadingTimeoutManager
        
        private var remoteId: Int32? = nil
        private var type: SubjectType? = nil
        private var profileId: Int32? = nil
        private var rgbColor: HsvColor? = nil
        private var changing: Bool = false
        private var lastInteractionTime: TimeInterval? = nil
        
        private var actionData: RgbwActionData? {
            guard let remoteId, let type, let brightness = state.value.brightness else { return nil }
            
            return RgbwActionData(
                remoteId: remoteId,
                type: type,
                brightness: brightness,
                color: rgbColor ?? .turnOff
            )
        }
        
        private let updateRelay = PublishRelay<Void>()
        
        init() {
            super.init(state: ViewState())
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
            state.value = .single(brightness: brightness)
            
            if let actionData {
                delayedRgbActionSubject.emit(data: actionData)
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
                delayedRgbActionSubject.sendImmediately(data: actionData)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
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
        
        private func turn(on: Bool) {
            guard let remoteId, let type else { return }
            
            executeRgbActionUseCase.invoke(
                type: type,
                remoteId: remoteId,
                brightness: on ? 100 : 0,
                color: rgbColor ?? HsvColor(hue: 0, saturation: 0, value: 0.5),
                onOff: true
            )
            .subscribe()
            .disposed(by: disposeBag)
        }
        
        private func reloadData() {
            guard let type, let remoteId else { return }
            
            switch (type) {
            case .channel: loadChannel(remoteId)
            case .group: loadGroup(remoteId)
            case .scene: break
            }
        }
        
        private func loadChannel(_ remoteId: Int32) {
            readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] channel in
                        self?.handleChannel(channel)
                    }
                )
                .disposed(by: disposeBag)
        }
        
        private func handleChannel(_ channelWithChildren: ChannelWithChildren) {
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
            let value = getValue(channel)
            let dimmerValue: DimmerValue =
                if let brightness = value?.brightness {
                    .single(brightness: Int(brightness))
                } else {
                    .empty
                }
            
            profileId = channel.profile.id
            if let rgbValue = getRgbValue(channel) {
                rgbColor = rgbValue.color.toHsv(rgbValue.colorBrightness)
            }
            
            state.offline = channel.status().offline
            state.value = dimmerValue
            state.deviceStateData = .init(
                label: Strings.SwitchDetail.stateLabel,
                icon: getChannelBaseIconUseCase.invoke(channel: channel),
                value: getDeviceStateValue(channel.status(), channelState)
            )
            state.issues = getAllChannelIssuesUseCase.invoke(channelWithChildren: channelWithChildren.shareable)
            state.onButtonState = .init(
                icon: getButtonIcon(channel, getChannelState(channel, .on)),
                label: Strings.General.turnOn,
                active: value?.brightness ?? 0 > 0,
                type: .positive
            )
            state.offButtonState = .init(
                icon: getButtonIcon(channel, getChannelState(channel, .off)),
                label: Strings.General.turnOff,
                active: value?.brightness ?? 0 == 0,
                type: .negative
            )
            state.loadingState = state.loadingState.copy(loading: false)
        }
        
        private func getValue(_ channel: SAChannel) -> DimmerBaseValue? {
            switch (channel.func) {
            case SuplaFunction.dimmer.value: channel.value?.asDimmerValue()
            case SuplaFunction.dimmerAndRgbLighting.value: channel.value?.asRgbwValue()
            default: fatalError("Unsupported function: \(channel.func)")
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
        
        private func getButtonIcon(_ channel: SAChannelBase, _ state: ChannelState) -> IconResult {
            return switch (state) {
            case .default: getChannelBaseIconUseCase.stateIcon(channel, state: state)
            case .rgbAndDimmer(let dimmer, _): .originalSuplaIcon(name: dimmer == .on ? .Icons.fncDimmerOn : .Icons.fncDimmerOff)
            }
        }
        
        private func getChannelState(_ channel: SAChannelBase, _ value: ChannelState.Value) -> ChannelState {
            if (channel.func == SuplaFunction.dimmerAndRgbLighting.value) {
                .rgbAndDimmer(dimmer: value, rgb: .notUsed)
            } else {
                .default(value: value)
            }
        }
        
        private func getRgbValue(_ channel: SAChannel) -> RgbBaseValue? {
            switch (channel.func) {
            case SuplaFunction.dimmerAndRgbLighting.value: channel.value?.asRgbwValue()
            default: nil
            }
        }
        
        private func loadGroup(_ remoteId: Int32) {
            readGroupWithChannelsUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] groupWithChannels in
                    self?.handleGroup(groupWithChannels)
                })
                .disposed(by: disposeBag)
        }
        
        private func handleGroup(_ groupWithChannels: ReadGroupWithChannels.GroupWithChannels) {
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
            let groupStateValue = groupWithChannels.aggregatedState(policy: .rgb)
            
            profileId = group.profile.id
            
            state.onButtonState = .init(
                icon: getButtonIcon(group, getChannelState(group, .on)),
                label: Strings.General.turnOn,
                active: groupStateValue == .on,
                type: .positive
            )
            state.offButtonState = .init(
                icon: getButtonIcon(group, getChannelState(group, .off)),
                label: Strings.General.turnOff,
                active: groupStateValue == .off,
                type: .negative
            )
            state.deviceStateData = .init(
                label: Strings.SwitchDetail.stateLabel,
                icon: getChannelBaseIconUseCase.invoke(channel: group),
                value: getDeviceStateValue(group.status(), .default(value: groupStateValue ?? .off))
            )
            state.value = .multiple(group.brightness)
            state.offline = group.status().offline
            state.loadingState = state.loadingState.copy(loading: false)
        }
    }
}
