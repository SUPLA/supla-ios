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
    
extension GateGeneralFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate, ChannelUpdatesObserver {
        @Singleton private var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCase
        @Singleton private var readGroupWithChannelsUseCase: ReadGroupWithChannels.UseCase
        @Singleton private var getChannelBaseStateUseCase: GetChannelBaseStateUseCase
        @Singleton private var executeSimpleActionUseCase: ExecuteSimpleActionUseCase
        @Singleton private var getChannelBaseIconUseCase: GetChannelBaseIconUseCase
        
        private var remoteId: Int32? = nil
        private var type: SubjectType? = nil
        
        init() {
            super.init(state: ViewState())
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
        
        func onOpen() {
            triggerAction(.open)
        }
        
        func onClose() {
            triggerAction(.close)
        }
        
        func onOpenClose() {
            triggerAction(.openClose)
        }
        
        func onChannelUpdate(_ channelWithChildren: ChannelWithChildren) {
            loadChannel(channelWithChildren.remoteId)
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
            let channel = channelWithChildren.channel
            let channelState = getChannelBaseStateUseCase.invoke(channelBase: channel)
            let showOpenAndClose = channelWithChildren.hasSensor && supportsOpenAndClose(channel.func)
            
            state.offline = channel.status().offline
            state.deviceStateData = .init(
                label: Strings.SwitchDetail.stateLabel,
                icon: getChannelBaseIconUseCase.invoke(channel: channel),
                value: getDeviceStateValue(channel.status(), channelState)
            )
            state.mainButtonLabel = mainButtonLabel(channel.func.suplaFuntion)
            if (showOpenAndClose) {
                state.openButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(channel, state: .opened),
                    label: Strings.General.open,
                    active: channelState == .opened,
                    type: .positive
                )
                state.closeButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(channel, state: .closed),
                    label: Strings.General.close,
                    active: channelState == .closed,
                    type: .positive
                )
            }
        }
        
        private func getDeviceStateValue(_ status: SuplaChannelAvailabilityStatus, _ state: ChannelState) -> String {
            if (status.offline) {
                return Strings.SwitchDetail.stateOffline
            }
            
            return switch (state) {
            case .opened: Strings.General.stateOpened
            case .closed: Strings.General.stateClosed
            case .partialyOpened: Strings.General.State.partiallyOpened
            default: ""
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
            let showOpenAndClose = groupWithChannels.channels.contains(where: { $0.hasSensor && supportsOpenAndClose($0.function) })
            let gateWithoutSensor = groupWithChannels.channels.contains(where: { $0.hasSensor == false })
            let groupState = groupWithChannels.aggregatedState(activeValue: .closed, inactiveValue: .opened)
            
            state.offline = false
            state.mainButtonLabel = mainButtonLabel(groupWithChannels.group.func.suplaFuntion)
            state.relatedChannelsData = groupWithChannels.relatedChannelData
            state.showOpenAndCloseWarning = supportsOpenAndClose(groupWithChannels.group.func) && showOpenAndClose && gateWithoutSensor
            
            if (showOpenAndClose) {
                state.openButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(groupWithChannels.group, state: .opened),
                    label: Strings.General.open,
                    active: groupState == .opened,
                    type: .positive
                )
                state.closeButtonState = .init(
                    icon: getChannelBaseIconUseCase.stateIcon(groupWithChannels.group, state: .closed),
                    label: Strings.General.close,
                    active: groupState == .closed,
                    type: .positive
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
        
        private func triggerAction(_ action: Action) {
            if let remoteId, let type {
                executeSimpleActionUseCase.invoke(action: action, type: type, remoteId: remoteId)
                    .asDriverWithoutError()
                    .drive()
                    .disposed(by: disposeBag)
            }
        }
    }
}

private extension ChannelWithChildren {
    var hasSensor: Bool {
        children.first { $0.relationType == .openingSensor } != nil
            || children.first { $0.relationType == .partialOpeningSensor } != nil
    }
}
