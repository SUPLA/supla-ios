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

enum ActionSelection {
    struct ProfileItem: PickerItem {
        var id: Int32
        var label: String
    }

    struct SubjectItem: SubjectPickerItem {
        var id: String
        var remoteId: Int32
        var label: String
        var actions: [ActionId]
        var icon: IconResult?
        var isLocation: Bool
    }
    
    struct Selection: Hashable {
        let profileId: Int32
        let subjectType: SubjectType
        let subjectId: Int32
        let caption: String
        let action: ActionId
        
        init(profileId: Int32, subjectType: SubjectType, subjectId: Int32, action: ActionId) {
            self.profileId = profileId
            self.subjectType = subjectType
            self.subjectId = subjectId
            self.caption = ""
            self.action = action
        }
        
        init(profileId: Int32, subjectType: SubjectType, subjectId: Int32, caption: String, action: ActionId) {
            self.profileId = profileId
            self.subjectType = subjectType
            self.subjectId = subjectId
            self.caption = caption
            self.action = action
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(profileId)
            hasher.combine(subjectType)
            hasher.combine(subjectId)
        }
    }

    static func getSubjectsSource(_ profileId: Int32, _ subjectType: SubjectType) -> Observable<[ActionSelection.SubjectItem]> {
        switch (subjectType) {
        case .channel:
            @Singleton<ChannelRepository> var channelRepository
            return channelRepository.getAllVisibleChannels(forProfileId: profileId)
                .map { items in getSubjectItems(items.filter { $0.hasActions }, { $0.location }, { $0.subjectItem }) }
        case .group:
            @Singleton<GroupRepository> var groupRepository
            return groupRepository.getAllVisibleGroups(forProfileId: profileId)
                .map { items in getSubjectItems(items.filter { $0.hasActions }, { $0.location }, { $0.subjectItem }) }
        case .scene:
            @Singleton<SceneRepository> var sceneRepository
            return sceneRepository.getAllVisibleScenes(forProfileId: profileId)
                .map { items in getSubjectItems(items, { $0.location }, { $0.subjectItem }) }
        }
    }

    static func getSubjects(_ profileId: Int32?, _ subjectType: SubjectType?) async -> [ActionSelection.SubjectItem]? {
        guard let profileId, let subjectType else { return nil }
        return try? await Self.getSubjectsSource(profileId, subjectType).awaitFirstElement()
    }
}

extension Array where Element == AuthProfileItem {
    func toActionSelectionItems(_ preselected: AuthProfileItem? = nil) -> SelectableList<ActionSelection.ProfileItem> {
        guard let selected = preselected ?? first(where: { $0.isActive }) ?? first
        else {
            return SelectableList(selected: nil, items: [])
        }

        let selectedItem = ActionSelection.ProfileItem(id: selected.id, label: selected.displayName)
        let profileItems = map { ActionSelection.ProfileItem(id: $0.id, label: $0.displayName) }
        return SelectableList(selected: selectedItem, items: profileItems)
    }
}

extension Array where Element == ActionSelection.SubjectItem {
    func asSelectableList(selectedId: Int32? = nil) -> SelectableList<ActionSelection.SubjectItem>? {
        if (isEmpty) {
            return nil
        }

        let selected = first { $0.remoteId == selectedId }
        return SelectableList(selected: selected, items: self)
    }
}

extension Array where Element == ActionId {
    func asSelectableList(selectedAction: ActionId? = nil) -> SelectableList<ActionId>? {
        if (isEmpty) {
            return nil
        }

        let selected = first { $0 == selectedAction }
        return SelectableList(selected: selected, items: self)
    }
}

extension Array where Element == ActionSelection.Selection {
    func lastSubjectType(_ profileId: Int32) -> SubjectType? {
        last { $0.profileId == profileId }?.subjectType
    }
    
    func lastSubjectId(_ profileId: Int32, _ subjectType: SubjectType) -> Int32? {
        last { $0.profileId == profileId && $0.subjectType == subjectType }?.subjectId
    }

    func lastCaption(_ profileId: Int32, _ subjectType: SubjectType, _ subjectId: Int32?) -> String? {
        last { $0.profileId == profileId && $0.subjectType == subjectType && $0.subjectId == subjectId }?.caption
    }

    func lastAction(_ profileId: Int32, _ subjectType: SubjectType, _ subjectId: Int32?) -> ActionId? {
        last { $0.profileId == profileId && $0.subjectType == subjectType && $0.subjectId == subjectId }?.action
    }
}

private func getSubjectItems<T>(_ items: [T], _ locationExporter: (T) -> _SALocation?, _ itemConverter: (T) -> ActionSelection.SubjectItem) -> [ActionSelection.SubjectItem] {
    var result: [ActionSelection.SubjectItem] = []
    if (items.isEmpty) {
        return result
    }

    let location = locationExporter(items[0])
    var locationId = location?.location_id?.int32Value ?? 0

    if let location {
        result.append(location.subjectItem)
    }
    for item in items {
        if let location = locationExporter(item), location.location_id?.int32Value != locationId {
            result.append(location.subjectItem)
            locationId = location.location_id?.int32Value ?? 0
        }
        result.append(itemConverter(item))
    }

    return result
}

private extension SAChannel {
    var subjectItem: ActionSelection.SubjectItem {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
        let suplaFunction = self.func.suplaFuntion

        return ActionSelection.SubjectItem(
            id: "C\(remote_id)",
            remoteId: remote_id,
            label: getCaptionUseCase.invoke(data: shareable).string,
            actions: suplaFunction.actions,
            icon: getChannelBaseIconUseCase.stateIcon(self, state: getChannelBaseStateUseCase.getOfflineState(suplaFunction)),
            isLocation: false
        )
    }
}

private extension SAChannelGroup {
    var subjectItem: ActionSelection.SubjectItem {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
        let suplaFunction = self.func.suplaFuntion

        return ActionSelection.SubjectItem(
            id: "G\(remote_id)",
            remoteId: remote_id,
            label: getCaptionUseCase.invoke(data: shareable).string,
            actions: suplaFunction.actions,
            icon: getChannelBaseIconUseCase.stateIcon(self, state: getChannelBaseStateUseCase.getOfflineState(suplaFunction)),
            isLocation: false
        )
    }
}

private extension SAScene {
    var subjectItem: ActionSelection.SubjectItem {
        @Singleton<GetSceneIconUseCase> var getSceneIconUseCase

        return ActionSelection.SubjectItem(
            id: "S\(sceneId)",
            remoteId: sceneId,
            label: caption ?? "",
            actions: [.execute, .interrupt, .interruptAndExecute],
            icon: getSceneIconUseCase.invoke(self),
            isLocation: false
        )
    }
}

private extension _SALocation {
    var subjectItem: ActionSelection.SubjectItem {
        ActionSelection.SubjectItem(
            id: "L\(location_id ?? 0)",
            remoteId: location_id?.int32Value ?? 0,
            label: caption ?? "",
            actions: [],
            icon: nil,
            isLocation: true
        )
    }
}

private extension SAChannelBase {
    var hasActions: Bool {
        SharedCore.SuplaFunction.companion.from(value: self.func).actions.isEmpty == false
    }
}

private extension SharedCore.SuplaFunction {
    var actions: [ActionId] {
        switch self {
        case .openSensorGateway,
             .openSensorGate,
             .openSensorGarageDoor,
             .openSensorDoor,
             .noLiquidSensor,
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
             .thermometer,
             .humidity,
             .humidityAndTemperature,
             .unknown,
             .openSensorRollerShutter,
             .openSensorRoofWindow,
             .ring,
             .alarm,
             .notification,
             .electricityMeter,
             .icElectricityMeter,
             .icGasMeter,
             .icWaterMeter,
             .icHeatMeter,
             .generalPurposeMeasurement,
             .generalPurposeMeter,
             .digiglassHorizontal,
             .digiglassVertical,
             .container,
             .septicTank,
             .waterTank,
             .containerLevelSensor,
             .floodSensor,
             .pumpSwitch,
             .heatOrColdSourceSwitch,
             .none,
             .motionSensor,
             .binarySensor: []

        case .controllingTheDoorLock,
             .controllingTheGatewayLock: [.open]

        case .controllingTheGate,
             .controllingTheGarageDoor: [.openClose, .open, .close]

        case .controllingTheRollerShutter,
             .controllingTheRoofWindow,
             .controllingTheFacadeBlind,
             .verticalBlind,
             .rollerGarageDoor: [.shut, .reveal]

        case .powerSwitch,
             .lightswitch,
             .staircaseTimer,
             .dimmer,
             .dimmerCct,
             .rgbLighting,
             .dimmerCctAndRgb,
             .dimmerAndRgbLighting,
             .thermostatHeatpolHomeplus,
             .hvacThermostat,
             .hvacThermostatHeatCool,
             .hvacDomesticHotWater: [.turnOn, .turnOff, .toggle]

        case .valveOpenClose, .valvePercentage: [.open, .close]

        case .terraceAwning,
             .projectorScreen,
             .curtain: [.expand, .collapse]
        }
    }
}
