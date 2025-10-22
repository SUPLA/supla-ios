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
    
extension ContainerGeneralFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ChannelUpdatesObserver {
        @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
        @Singleton<CallSuplaClientOperationUseCase> private var callSuplaClientOperationUseCase
        @Singleton<GetChannelBatteryIconUseCase> private var getChannelBatteryIconUseCase
        @Singleton<GetAllChannelIssuesUseCase> private var getAllChannelIssuesUseCase
        @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
        @Singleton<LoadChannelConfigUseCase> private var loadChannelConfigUseCase
        @Singleton<GetCaptionUseCase> private var getCaptionUseCase
        @Singleton<VibrationService> private var vibrationService
        @Singleton<ValuesFormatter> private var valuesFormatter
        
        init() {
            super.init(state: ViewState())
        }
        
        func loadData(_ remoteId: Int32) {
            Observable.zip(
                readChannelWithChildrenUseCase.invoke(remoteId: remoteId),
                loadChannelConfigUseCase.invoke(remoteId: remoteId)
            ) { channel, config in (channel, config) }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] (channel, config) in
                    self?.handle(channel, config)
                })
                .disposed(by: disposeBag)
        }
        
        func onChannelUpdate(_ channelWithChildren: ChannelWithChildren) {
            loadData(channelWithChildren.remoteId)
        }
        
        func onMuteClick(_ viewController: UIViewController?) {
            vibrationService.vibrate()
            if (state.muteAuthorizationNeeded) {
                if let viewController {
                    SAAuthorizationDialogVC { [weak self] in self?.muteAlarmSound() }.showAuthorization(viewController)
                }
            } else {
                muteAlarmSound()
            }
        }
        
        private func handle(_ channelWithChildren: ChannelWithChildren, _ config: SuplaChannelConfig?) {
            let value = channelWithChildren.channel.value?.asContainerValue()
            let config = config as? SuplaChannelContainerConfig
            let channelToLevelMap = config?.sensors.reduce(into: [Int32: Int32]()) { result, sensor in
                result[sensor.channelId] = sensor.fillLevel
            }
            let level = value?.levelKnown.ifTrue { CGFloat(value!.level) / 100 }
            let levelString = if (value?.status.online == false) {
                "offline"
            } else if let level {
                valuesFormatter.percentageToString(Float(level))
            } else {
                "---"
            }
            
            state.fluidLevel = level
            state.fluidLevelString = levelString
            state.containerType = channelWithChildren.channel.containerType
            state.controlLevels = createControlLevels(config)
            state.issues = getAllChannelIssuesUseCase.invoke(channelWithChildren: channelWithChildren.shareable)
            state.sensors = channelWithChildren.children
                .filter { $0.relationType == .default }
                .map { toSensorItem($0, channelToLevelMap) }
            state.soundOn = value?.status.online == true && value?.flags.contains(.soundAlarmOn) == true
            
            state.channelId = channelWithChildren.channel.remote_id
            state.muteAuthorizationNeeded = config?.muteAlarmSoundWithoutAdditionalAuth == false
        }
        
        private func toSensorItem(_ child: ChannelChild, _ channelToLevelMap: [Int32: Int32]?) -> RelatedChannelData {
            let caption = getCaptionUseCase.invoke(data: child.channel.shareable).string
            let captionWithPercentage =
                if let level = channelToLevelMap?[child.channel.remote_id] {
                    "\(caption) (\(level)%)"
                } else {
                    caption
                }
            
            return RelatedChannelData(
                channelId: child.channel.remote_id,
                onlineState: child.channel.onlineState,
                icon: getChannelBaseIconUseCase.invoke(channel: child.channel),
                caption: captionWithPercentage,
                userCaption: child.channel.caption ?? "",
                batteryIcon: getChannelBatteryIconUseCase.invoke(channel: child.channel.shareable),
                showChannelStateIcon: child.channel.value?.status.online ?? false
            )
        }
        
        private func createControlLevels(_ config: SuplaChannelConfig?) -> [ControlLevel] {
            guard let config = config as? SuplaChannelContainerConfig else { return [] }
        
            var result: [ControlLevel] = []
            if (config.alarmAboveLevel > 0) {
                result.append(alarmLevel(config.alarmAboveLevel, .upper))
            }
            if (config.warningAboveLevel > 0) {
                result.append(warningLevel(config.warningAboveLevel, .upper))
            }
            if (config.warningBelowLevel > 0) {
                result.append(warningLevel(config.warningBelowLevel, .lower))
            }
            if (config.alarmBelowLevel > 0) {
                result.append(alarmLevel(config.alarmBelowLevel, .lower))
            }
            
            return result.sorted { $0.level > $1.level }
        }
        
        private func alarmLevel(_ level: Int32, _ type: ControlLevelType) -> ControlLevel {
            let floatLevel = CGFloat(level - 1) / 100
            return .alarm(
                level: floatLevel,
                levelString: valuesFormatter.percentageToString(Float(floatLevel)),
                type: type
            )
        }
        
        private func warningLevel(_ level: Int32, _ type: ControlLevelType) -> ControlLevel {
            let floatLevel = CGFloat(level - 1) / 100
            return .warning(
                level: floatLevel,
                levelString: valuesFormatter.percentageToString(Float(floatLevel)),
                type: type
            )
        }
        
        private func muteAlarmSound() {
            callSuplaClientOperationUseCase.invoke(remoteId: state.channelId, type: .channel, operation: .muteAlarmSound)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
    }
}

private extension SAChannel {
    var containerType: ContainerType {
        switch (self.func) {
        case SUPLA_CHANNELFNC_WATER_TANK: .water
        case SUPLA_CHANNELFNC_SEPTIC_TANK: .septic
        default: .default
        }
    }
}
