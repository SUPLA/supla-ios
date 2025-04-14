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
    
import SharedCore

extension ValveGeneralFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ChannelUpdatesObserver {
        @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
        @Singleton<GetChannelBatteryIconUseCase> private var getChannelBatteryIconUseCase
        @Singleton<GetAllChannelIssuesUseCase> private var getAllChannelIssuesUseCase
        @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleActionUseCase
        @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
        @Singleton<ChannelBaseActionUseCase> private var channelBaseActionUseCase
        @Singleton<GetCaptionUseCase> private var getCaptionUseCase
        @Singleton<VibrationService> private var vibrationService
        
        init() {
            super.init(state: ViewState())
        }
        
        func loadData(_ remoteId: Int32) {
            readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] in self?.handle($0) }
                )
                .disposed(by: disposeBag)
        }
        
        func onActionClick(_ remoteId: Int32, action: ValveAction) {
            channelBaseActionUseCase.invoke(remoteId, action.buttonType)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] result in
                        switch(result) {
                        case .valveFlooding:
                            self?.state.alertDialog = .confirmation(message: Strings.Valve.warningFlooding, action: .open)
                        case .valveManuallyClosed:
                            self?.state.alertDialog = .confirmation(message: Strings.Valve.warningManuallyClosed, action: .open)
                        case .valveMotorProblemOpening:
                            self?.state.alertDialog = .confirmation(message: Strings.Valve.warningMotorProblemOpening, action: .open)
                        case .valveMotorProblemClosing:
                            self?.state.alertDialog = .confirmation(message: Strings.Valve.warningMotorProblemClosing, action: .close)
                        case .success:
                            self?.vibrationService.vibrate()
                        case .overcurrentRelayOff:
                            break // should never happen
                        }
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func closeValveAlertDialog() {
            state.alertDialog = nil
        }
        
        func forceAction(_ remoteId: Int32, action: Action) {
            state.alertDialog = nil
            executeSimpleActionUseCase.invoke(action: action, type: .channel, remoteId: remoteId)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
        
        func onChannelUpdate(_ channelWithChildren: ChannelWithChildren) {
            handle(channelWithChildren)
        }
        
        private func handle(_ channelWithChildren: ChannelWithChildren) {
            let value = channelWithChildren.channel.value?.asValveValue()
            
            state.icon = getChannelBaseIconUseCase.invoke(channel: channelWithChildren.channel)
            state.stateString = value.stateString
            state.issues = getAllChannelIssuesUseCase.invoke(channelWithChildren: channelWithChildren.shareable)
            state.sensors = channelWithChildren.children
                .filter { $0.relationType == .default }
                .map { $0.toSensorItem() }
            state.offline = value?.status.online != true
            state.isClosed = value?.isClosed() ?? true
        }
        
        private func toSensor(_ child: ChannelChild) -> SensorItemData {
            SensorItemData(
                channelId: child.channel.remote_id,
                onlineState: child.channel.onlineState,
                icon: getChannelBaseIconUseCase.invoke(channel: child.channel),
                caption: getCaptionUseCase.invoke(data: child.channel.shareable).string,
                userCaption: child.channel.caption ?? "",
                batteryIcon: getChannelBatteryIconUseCase.invoke(channel: child.channel.shareable),
                showChannelStateIcon: child.channel.value?.status.online ?? false
            )
        }
    }
    
    enum ValveAction {
        case open
        case close
        
        var buttonType: CellButtonType {
            switch self {
            case .open: .rightButton
            case .close: .leftButton
            }
        }
    }
}

private extension ValveValue? {
    var stateString: String {
        guard let self else {
            return "offline"
        }
        
        return if (self.status.offline) {
            "offline"
        } else if (self.isClosed()) {
            Strings.General.stateClosed
        } else {
            Strings.General.stateOpened
        }
    }
}

