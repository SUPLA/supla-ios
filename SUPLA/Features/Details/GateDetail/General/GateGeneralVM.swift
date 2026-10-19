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
    
extension GateGeneralFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<ObserveChannelWithChildren.UseCase> private var observeChannelWithChildrenUseCase
        @Singleton<ObserveGroupWithChannels.UseCase> private var observeGroupWithChannelsUseCase
        @Singleton private var getAllChannelIssuesUseCase: GetAllChannelIssuesUseCase
        @Singleton private var getChannelBaseStateUseCase: GetChannelBaseStateUseCase
        @Singleton<ObserveRelayProgramState.UseCase> private var observeRelayProgramStateUseCase
        @Singleton private var executeSimpleActionUseCase: ExecuteSimpleAction.UseCase
        @Singleton private var executeRelayActionUseCase: ExecuteRelayAction.UseCase
        @Singleton private var getChannelBaseIconUseCase: GetChannelBaseIconUseCase
        
        private let itemBundle: ItemBundle

        init(itemBundle: ItemBundle) {
            self.itemBundle = itemBundle
            super.init(state: ViewState())
            
            switch (itemBundle.subjectType) {
            case .channel: observeChannelAndProgramState(remoteId: itemBundle.remoteId)
            case .group: observeGroup(remoteId: itemBundle.remoteId)
            case .scene: break
            }
        }
        
        func onOpen() {
            triggerAction(.open)
        }
        
        func onClose() {
            triggerAction(.close)
        }
        
        func onOpenClose() {
            triggerAction(.openClose)
        }

        func onForce() {
            guard itemBundle.subjectType == .channel else { return }

            if state.forceActive {
                triggerAction(state.weeklyActive ? .switchToProgramMode : .switchToManualMode)
            } else {
                executeRelayActionUseCase.invoke(
                    type: itemBundle.subjectType,
                    remoteId: itemBundle.remoteId,
                    mode: state.currentlyOpen ? .forcedOn : .forcedOff
                )
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
            }
        }

        func onManual() {
            triggerAction(.switchToManualMode)
        }

        func onWeekly() {
            triggerAction(.switchToProgramMode)
        }

        func onAuto() {
            executeRelayActionUseCase.invoke(
                type: itemBundle.subjectType,
                remoteId: itemBundle.remoteId,
                mode: .automatic
            )
            .asDriverWithoutError()
            .drive()
            .disposed(by: disposeBag)
        }
        
        private func observeChannelAndProgramState(remoteId: Int32) {
            let channel = observeChannelWithChildrenUseCase.invoke(remoteId: remoteId)

            Observable.combineLatest(channel, observeRelayProgramStateUseCase.invoke(remoteId: remoteId))
                .observe(on: MainScheduler.instance)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] channel, programState in
                    self?.handleChannel(channel, programState)
                })
                .disposed(by: disposeBag)
        }

        private func observeGroup(remoteId: Int32) {
            observeGroupWithChannelsUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] groupWithChannels in
                    self?.handleGroup(groupWithChannels)
                })
                .disposed(by: disposeBag)
        }
        
        private func handleChannel(
            _ channelWithChildren: ChannelWithChildren,
            _ channelProgramState: [ChannelProgramState.Data]
        ) {
            let channel = channelWithChildren.channel
            let channelState = getChannelBaseStateUseCase.invoke(channelBase: channel)
            let showOpenAndClose = channelWithChildren.hasSensor && supportsOpenAndClose(channel.func)
            let relayValue = channel.value?.asRelayValue()
            let forceSupported = channel.flags & Int64(SUPLA_CHANNEL_FLAG_RELAY_MODE_FORCED_SUPPORTED) != 0
            let forced = relayValue?.mode == .forcedOn || relayValue?.mode == .forcedOff
            let weeklyActive = relayValue?.flags.contains(.weeklyScheduleEnabled) == true
            
            state.offline = channel.status().offline
            state.currentlyOpen = channelState.value == .opened || channelState.value == .partialyOpened
            state.forceSupported = forceSupported
            state.forceActive = forceSupported && forced
            state.forceButtonDisabled = weeklyActive
            state.lockIconType = lockIconType(forced: forced, weeklyActive: weeklyActive)
            state.channelCurrentStateData = .init(
                label: Strings.SwitchDetail.stateLabel,
                icon: getChannelBaseIconUseCase.invoke(channel: channel),
                value: getDeviceStateValue(channel.status(), channelState)
            )
            state.channelProgramState = relayValue?.showProgram(channelProgramState, channel.timerEndDate) ?? []
            state.issues = getAllChannelIssuesUseCase.invoke(channelWithChildren: channelWithChildren.shareable)
            state.mainButtonLabel = mainButtonLabel(channel.func.suplaFuntion)
            if (showOpenAndClose) {
                state.openButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(channel, state: .default(value: .opened)),
                    label: Strings.General.open,
                    active: channelState.value == .opened,
                    colors: .primaryColors
                )
                state.closeButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(channel, state: .default(value: .closed)),
                    label: Strings.General.close,
                    active: channelState.value == .closed,
                    colors: .errorColors
                )
            }
            handleOperationButtons(channelWithChildren)
        }

        private func handleOperationButtons(_ channelWithChildren: ChannelWithChildren) {
            let channel = channelWithChildren.channel
            let relayValue = channel.value?.asRelayValue()
            let weeklyAllowed = channel.flags & Int64(SUPLA_CHANNEL_FLAG_WEEKLY_SCHEDULE) != 0
            let autoAllowed = channel.flags & Int64(SUPLA_CHANNEL_FLAG_RELAY_MODE_AUTOMATIC_SUPPORTED) != 0
            let weeklyActive = relayValue?.flags.contains(.weeklyScheduleEnabled) == true

            state.manualAllowed = weeklyAllowed || autoAllowed
            state.manualActive = !weeklyActive && relayValue?.mode != .automatic
            state.weeklyAllowed = weeklyAllowed
            state.weeklyActive = weeklyActive
            state.autoAllowed = autoAllowed
            state.autoActive = !weeklyActive && relayValue?.mode == .automatic
        }

        private func lockIconType(forced: Bool, weeklyActive: Bool) -> LockIconType {
            if forced && weeklyActive {
                .temporaryClosed
            } else if forced {
                .closed
            } else {
                .opened
            }
        }
        
        private func getDeviceStateValue(_ status: SuplaChannelAvailabilityStatus, _ state: ChannelState) -> String {
            if (status.offline) {
                return Strings.SwitchDetail.stateOffline
            }
            
            return switch (state.value) {
            case .opened: Strings.General.stateOpened
            case .closed: Strings.General.stateClosed
            case .partialyOpened: Strings.General.State.partiallyOpened
            default: ""
            }
        }
        
        private func handleGroup(_ groupWithChannels: ReadGroupWithChannels.GroupWithChannels) {
            let showOpenAndClose = groupWithChannels.channels.contains(where: { $0.hasSensor && supportsOpenAndClose($0.function) })
            let gateWithoutSensor = groupWithChannels.channels.contains(where: { $0.hasSensor == false })
            let groupState = groupWithChannels.aggregatedState(policy: .openClosed)
            
            state.offline = false
            state.mainButtonLabel = mainButtonLabel(groupWithChannels.group.func.suplaFuntion)
            state.relatedChannelsData = groupWithChannels.relatedChannelData
            state.showOpenAndCloseWarning = supportsOpenAndClose(groupWithChannels.group.func) && showOpenAndClose && gateWithoutSensor
            state.manualAllowed = false
            state.manualActive = false
            state.weeklyAllowed = false
            state.weeklyActive = false
            state.autoAllowed = false
            state.autoActive = false
            state.forceSupported = false
            state.forceActive = false
            state.forceButtonDisabled = false
            state.lockIconType = .opened
            
            if (showOpenAndClose) {
                state.openButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(groupWithChannels.group, state: .default(value: .opened)),
                    label: Strings.General.open,
                    active: groupState == .opened,
                    colors: .primaryColors
                )
                state.closeButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(groupWithChannels.group, state: .default(value: .closed)),
                    label: Strings.General.close,
                    active: groupState == .closed,
                    colors: .errorColors
                )
            }
        }
        
        private func mainButtonLabel(_ function: SuplaFunction) -> String {
            switch (function) {
            case .controllingTheGatewayLock, .controllingTheDoorLock: Strings.General.open
            default: Strings.General.stepByStep
            }
        }
        
        private func supportsOpenAndClose(_ function: Int32) -> Bool {
            switch (function) {
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR, SUPLA_CHANNELFNC_CONTROLLINGTHEGATE: true
            default: false
            }
        }
        
        private func triggerAction(_ action: ActionId) {
            if (itemBundle.subjectType != .scene) {
                executeSimpleActionUseCase.invoke(action: action, type: itemBundle.subjectType, remoteId: itemBundle.remoteId)
                    .asDriverWithoutError()
                    .drive()
                    .disposed(by: disposeBag)
            }
        }
    }
}

private extension ReadGroupWithChannels.ChannelInGroup {
    var hasSensor: Bool {
        switch self {
        case .invisible(_): false
        case .visible(let channelWithChildren): channelWithChildren.hasSensor
        }
    }
}

private extension ChannelWithChildren {
    var hasSensor: Bool {
        children.first { $0.relationType == .openingSensor } != nil
            || children.first { $0.relationType == .partialOpeningSensor } != nil
    }
}
