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
import WidgetKit

@available(iOS 17.0, *)
struct ExportCarPlayItems {
    
    protocol UseCase {
        func invoke() -> Observable<Void>
    }
    
    final class Implementation: UseCase {
        @Singleton<CarPlayItemRepository> private var carPlayItemRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<SceneRepository> private var sceneRepository
        
        func invoke() -> Observable<Void> {
            Observable.zip(
                carPlayItemRepository.findAll(),
                channelRepository.getAllChannels(),
                groupRepository.getAllGroups(),
                sceneRepository.getAllScenes()
            ) { items, channels, groups, scenes in
                Implementation.update(items, channels, groups, scenes)
            }
        }
        
        static func update(_ items: [SACarPlayItem], _ channels: [SAChannel], _ groups: [SAChannelGroup], _ scenes: [SAScene]) {
            @Singleton<GroupShared.Settings> var settings
            
            var widgetActions: [GroupShared.WidgetAction] = []
            
            for item in items {
                switch (item.subjectType) {
                case .channel:
                    if let channel = channels.first(where: { $0.remote_id == item.subjectId && $0.profile == item.profile }) {
                        widgetActions.append(item.toWidgetAction(with: channel))
                    }
                case .group:
                    if let group = groups.first(where: { $0.remote_id == item.subjectId && $0.profile == item.profile }) {
                        widgetActions.append(item.toWidgetAction(with: group))
                    }
                case .scene:
                    if let scene = scenes.first(where: { $0.sceneId == item.subjectId && $0.profile == item.profile }) {
                        widgetActions.append(item.toWidgetAction(with: scene))
                    }
                }
            }
            
            var widgetChannels: [GroupShared.WidgetChannel] = []
            channels.filter { $0.widgetSupported }.forEach {
                widgetChannels.append($0.widgetChannel)
            }
            
            settings.actions = widgetActions
            settings.channels = widgetChannels
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

@available(iOS 17.0, *)
private extension SACarPlayItem {
    
    func toWidgetAction(with channelBase: SAChannelBase) -> GroupShared.WidgetAction {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        let thermostatSubfunction: ThermostatSubfunction? =
            if let channel = channelBase as? SAChannel, channel.isHvacThermostat() {
                channel.value?.asThermostatValue().subfunction
            } else {
                nil
            }
        
        return GroupShared.WidgetAction(
            profileId: profile?.id ?? 0,
            profileName: profile?.name ?? Strings.Profiles.defaultProfileName,
            subjectType: subjectType,
            subjectId: subjectId,
            caption: caption ?? getCaptionUseCase.invoke(data: channelBase.shareableBase).string,
            action: action,
            icon: getChannelBaseIconUseCase.stateIcon(channelBase, state: action.action.state(channelBase.func)),
            sfIcon: channelBase.sfIconName(action, thermostatSubfunction),
            authorizationEntity: profile?.authorizationEntity
        )
    }
    
    func toWidgetAction(with scene: SAScene) -> GroupShared.WidgetAction {
        @Singleton<GetSceneIconUseCase> var getSceneIconUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        let iconName = getSceneIconUseCase.invoke(scene)
        
        return GroupShared.WidgetAction(
            profileId: profile?.id ?? 0,
            profileName: profile?.name ?? Strings.Profiles.defaultProfileName,
            subjectType: subjectType,
            subjectId: subjectId,
            caption: caption ?? getCaptionUseCase.invoke(data: scene.shareable).string,
            action: action,
            icon: iconName,
            sfIcon: "SFScene/\(iconName)",
            authorizationEntity: profile?.authorizationEntity
        )
    }
}

private extension SAChannelBase {
    func sfIconName(_ action: CarPlayAction, _ thermostatSubfunction: ThermostatSubfunction? = nil) -> String? {
        return switch (self.func.suplaFuntion) {
        case .controllingTheGatewayLock:
            action == .close ? "SFChannel/gateway-closed" : "SFChannel/gateway-open"
        case .controllingTheGate, .rollerGarageDoor:
            action == .close ? "SFChannel/gate-closed" : "SFChannel/gate-open"
        case .controllingTheGarageDoor:
            action == .close ? "SFChannel/garage-door-closed" : "SFChannel/garage-door-open"
        case .controllingTheDoorLock:
            action == .close ? "SFChannel/door-lock-closed" : "SFChannel/door-lock-open"
        case .controllingTheRollerShutter:
            action == .shut ? "SFChannel/roller-shutter-closed" : "SFChannel/roller-shutter-open"
        case .controllingTheRoofWindow:
            action == .close ? "SFChannel/roof-window-closed" : "SFChannel/roof-window-open"
        case .powerSwitch:
            action == .turnOn ? "SFChannel/switch-on" : "SFChannel/switch-off"
        case .lightswitch, .dimmer, .rgbLighting, .dimmerAndRgbLighting:
            action == .turnOn ? "SFChannel/light-switch-on" : "SFChannel/light-switch-off"
        case .staircaseTimer:
            action == .turnOn ? "SFChannel/staircase-timer-on" : "SFChannel/staircase-timer-off"
        case .controllingTheFacadeBlind:
            action == .shut ? "SFChannel/facade-blind-closed" : "SFChannel/facade-blind-open"
        case .curtain:
            action == .shut ? "SFChannel/curtain-closed" : "SFChannel/curtain-open"
        case .verticalBlind:
            action == .shut ? "SFChannel/vertical-blind-closed" : "SFChannel/vertical-blind-open"
        case .thermostatHeatpolHomeplus:
            action == .turnOff ? "SFChannel/thermostat-off" : "SFChannel/thermostat-heating-on"
        case .hvacThermostat:
            action == .turnOff ? "SFChannel/thermostat-off" : "SFChannel/thermostat-heating-on"
        case .hvacThermostatHeatCool:
            if let subfunction = thermostatSubfunction {
                switch (subfunction) {
                case .cool:
                    action == .turnOff ? "SFChannel/thermostat-off" : "SFChannel/thermostat-cooling-on"
                case .heat, .notSet:
                    action == .turnOff ? "SFChannel/thermostat-off" : "SFChannel/thermostat-heating-on"
                }
            } else {
                action == .turnOff ? "SFChannel/thermostat-off" : "SFChannel/thermostat-heating-on"
            }
        case .hvacDomesticHotWater:
            action == .turnOff ? "SFChannel/thermostat-off" : "SFChannel/thermostat-dhw-on"
        case .valveOpenClose, .valvePercentage:
            action == .open ? "SFChannel/valve-open" : "SFChannel/valve-closed"
        case .terraceAwning:
            action == .expand ? "SFChannel/awnings-expanded" : "SFChannel/awnings-collapsed"
        case .projectorScreen:
            action == .expand ? "SFChannel/projector-screen-expanded" : "SFChannel/projector-screen-collapsed"
        case .alarm,
             .unknown,
             .none,
             .thermometer,
             .humidity,
             .humidityAndTemperature,
             .openSensorGateway,
             .openSensorGate,
             .openSensorGarageDoor,
             .noLiquidSensor,
             .openSensorDoor,
             .openSensorRollerShutter,
             .openSensorRoofWindow,
             .ring,
             .notification,
             .depthSensor,
             .distanceSensor,
             .openingSensorWindow,
             .hotelCardSensor,
             .alarmArmamentSensor,
             .mailSensor,
             .windSensor,
             .pressureSensor,
             .rainSensor,
             .weightSensor,
             .weatherStation,
             .electricityMeter,
             .icElectricityMeter,
             .icGasMeter,
             .icWaterMeter,
             .icHeatMeter,
             .generalPurposeMeasurement,
             .generalPurposeMeter,
             .digiglassHorizontal,
             .digiglassVertical,
             .pumpSwitch,
             .heatOrColdSourceSwitch,
             .container,
             .septicTank,
             .waterTank,
             .containerLevelSensor,
             .floodSensor: nil
        }
    }
}

private extension SAChannel {
    var widgetSupported: Bool {
        switch (self.func.suplaFuntion) {
        case .thermometer, .humidityAndTemperature, .humidity: true
        default: false
        }
    }
    
    @available(iOS 17.0, *)
    var widgetChannel: GroupShared.WidgetChannel {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return GroupShared.WidgetChannel(
            profileId: profile.id,
            profileCaption: profile.displayName,
            locationId: location_id,
            locationCaption: location?.caption ?? "Location ID(\(location_id))",
            subjectId: remote_id,
            subjectCaption: getNonEmptyCaption(),
            icon: widgetIcon,
            authorizationEntity: profile.authorizationEntity
        )
    }
    
    var widgetIcon: GroupShared.WidgetIcon {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        
        return switch (self.func) {
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            .double(
                first: getChannelBaseIconUseCase.invoke(channel: self),
                second: getChannelBaseIconUseCase.invoke(channel: self, type: .second)
            )
        default:
            .single(getChannelBaseIconUseCase.invoke(channel: self))
        }
    }
}
