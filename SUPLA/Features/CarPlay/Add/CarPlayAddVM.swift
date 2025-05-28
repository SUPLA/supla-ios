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

extension CarPlayAddFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<UpdateCarPlayItem.UseCase> private var updateCarPlayItemUseCase
        @Singleton<CreateCarPlayItemUseCase> private var createCarPlayItemUseCase
        @Singleton<CarPlayRefresh.UseCase> private var carPlayRefreshUseCase
        @Singleton<DeleteCarPlayItem.UseCase> private var deleteCarPlayItemUseCase
        @Singleton<CarPlayItemRepository> private var carPlayItemRepository
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SuplaAppCoordinator> private var coordinator

        private let id: NSManagedObjectID?
        private var selections: [Selection] = []

        init(id: NSManagedObjectID?) {
            self.id = id
            super.init(state: ViewState())
        }

        override func onViewDidLoad() {
            if let id {
                loadForEdit(id)
            } else {
                loadForAdd()
            }
        }

        func onProfileChanged(_ profile: ProfileItem) {
            let subjectType = lastSubjectType(profile.id) ?? state.subjectType

            let lastSubjectId = self.lastSubjectId(profile.id, subjectType)
            let lastCaption = self.lastCaption(profile.id, subjectType, lastSubjectId)
            let lastAction = self.lastAction(profile.id, subjectType, lastSubjectId)

            getSubjectsSource(profile.id, subjectType)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] subjects in
                        self?.state.profiles = self?.state.profiles?.changing(path: \.selected, to: profile)
                        self?.state.subjects = subjects.asSelectableList(selectedId: lastSubjectId)
                        self?.state.caption = lastCaption ?? self?.state.subjects?.selected.label ?? ""
                        self?.state.actions = self?.state.subjects?.selected.actions.asSelectableList(selectedAction: lastAction)
                    }
                )
                .disposed(by: disposeBag)
        }

        func onSubjectTypeChanged(_ subjectType: SubjectType) {
            guard let profile = state.profiles?.selected else { return }

            let lastSubjectId = self.lastSubjectId(profile.id, subjectType)
            let lastCaption = self.lastCaption(profile.id, subjectType, lastSubjectId)
            let lastAction = self.lastAction(profile.id, subjectType, lastSubjectId)

            getSubjectsSource(profile.id, subjectType)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] subjects in
                        self?.state.profiles = self?.state.profiles?.changing(path: \.selected, to: profile)
                        self?.state.subjects = subjects.asSelectableList(selectedId: lastSubjectId)
                        self?.state.caption = lastCaption ?? self?.state.subjects?.selected.label ?? ""
                        self?.state.actions = self?.state.subjects?.selected.actions.asSelectableList(selectedAction: lastAction)
                    }
                )
                .disposed(by: disposeBag)
        }

        func onSubjectChanged(_ subject: SubjectItem) {
            guard let profile = state.profiles?.selected else { return }
            let subjectType = state.subjectType
            let lastCaption = self.lastCaption(profile.id, subjectType, subject.remoteId)
            let lastAction = self.lastAction(profile.id, subjectType, subject.remoteId)

            state.subjects = state.subjects?.changing(path: \.selected, to: subject)
            state.caption = lastCaption ?? subject.label
            state.actions = subject.actions.asSelectableList(selectedAction: lastAction)
        }

        func onCaptionChanged(_ caption: String) {
            if let profileId = state.profiles?.selected.id,
               let subjectId = state.subjects?.selected.remoteId,
               let action = state.actions?.selected
            {
                let selection = Selection(
                    profileId: profileId,
                    subjectType: state.subjectType,
                    subjectId: subjectId,
                    caption: caption,
                    action: action
                )

                selections.removeAll { $0.hashValue == selection.hashValue }
                selections.append(selection)
            }
        }

        func onActionChanged(_ action: CarPlayAction) {
            state.actions = state.actions?.changing(path: \.selected, to: action)

            if let profileId = state.profiles?.selected.id,
               let subjectId = state.subjects?.selected.remoteId
            {
                let selection = Selection(
                    profileId: profileId,
                    subjectType: state.subjectType,
                    subjectId: subjectId,
                    caption: state.caption,
                    action: action
                )

                selections.removeAll { $0.hashValue == selection.hashValue }
                selections.append(selection)
            }
        }

        func onSave() {
            saveObservable()
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] in
                        self?.coordinator.popViewController()
                        self?.carPlayRefreshUseCase.post(.refresh)
                    }
                )
                .disposed(by: disposeBag)
        }

        private func saveObservable() -> Observable<Void> {
            guard let action = state.actions?.selected else { return Observable.just(()) }

            if let id {
                return updateCarPlayItemUseCase.invoke(id: id, caption: state.caption, action: action)
            } else {
                guard let profileId = state.profiles?.selected.id,
                      let subjectId = state.subjects?.selected.remoteId else { return Observable.just(()) }

                return createCarPlayItemUseCase.invoke(
                    profileId: profileId,
                    subjectType: state.subjectType,
                    subjectId: subjectId,
                    caption: state.caption,
                    action: action
                )
            }
        }

        func onDelete() {
            if let id {
                @Singleton<CarPlayItemRepository> var carPlayItemRepository

                deleteCarPlayItemUseCase.invoke(id)
                    .asDriverWithoutError()
                    .drive(
                        onNext: { [weak self] in
                            self?.coordinator.popViewController()
                            self?.carPlayRefreshUseCase.post(.refresh)
                        }
                    )
                    .disposed(by: disposeBag)
            }
        }

        private func loadForEdit(_ id: NSManagedObjectID) {
            Observable.zip(
                carPlayItemRepository.queryItem(id).compactMap { $0 },
                profileRepository.getAllProfiles()
            ) { item, profiles in (item, profiles) }
                .flatMapFirst { (item, profiles) in
                    getSubjectsSource(item.profile!.id, item.subjectType).map { (item, profiles, $0) }
                }
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] (item, profiles, subjects) in
                        self?.handleEditItem(item, profiles, subjects)
                    }
                )
                .disposed(by: disposeBag)
        }

        private func handleEditItem(_ item: SACarPlayItem, _ profiles: [AuthProfileItem], _ subjects: [CarPlayAddFeature.SubjectItem]) {
            guard let profile = item.profile else { return }

            let selectedItem = ProfileItem(id: profile.id, label: profile.displayName)
            let profileItems = profiles.map { ProfileItem(id: $0.id, label: $0.displayName) }
            state.profiles = SelectableList(selected: selectedItem, items: profileItems)

            if let selectableSubjects = subjects.asSelectableList(selectedId: item.subjectId) {
                state.subjects = selectableSubjects
                state.caption = item.caption ?? ""
                state.actions = selectableSubjects.selected.actions.asSelectableList(selectedAction: item.action)
            }

            state.showDelete = true
        }

        private func loadForAdd() {
            profileRepository.getAllProfiles()
                .flatMapFirst { [weak self] profiles in
                    getSubjectsSource(profiles.first { $0.isActive }?.id ?? profiles[0].id, self?.state.subjectType ?? .channel).map { (profiles, $0) }
                }
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] profiles, subjects in
                        let selected = profiles.first { $0.isActive } ?? profiles[0]
                        let selectedItem = ProfileItem(id: selected.id, label: selected.displayName)
                        let profileItems = profiles.map { ProfileItem(id: $0.id, label: $0.displayName) }
                        self?.state.profiles = SelectableList(selected: selectedItem, items: profileItems)

                        if let selectableSubjects = subjects.asSelectableList() {
                            self?.state.subjects = selectableSubjects
                            self?.state.caption = selectableSubjects.selected.label
                            self?.state.actions = selectableSubjects.selected.actions.asSelectableList()
                        }
                    }
                )
                .disposed(by: disposeBag)
        }

        private func lastSubjectType(_ profileId: Int32) -> SubjectType? {
            selections.last { $0.profileId == profileId }?.subjectType
        }

        private func lastSubjectId(_ profileId: Int32, _ subjectType: SubjectType) -> Int32? {
            selections.last { $0.profileId == profileId && $0.subjectType == subjectType }?.subjectId
        }

        private func lastCaption(_ profileId: Int32, _ subjectType: SubjectType, _ subjectId: Int32?) -> String? {
            selections.last { $0.profileId == profileId && $0.subjectType == subjectType && $0.subjectId == subjectId }?.caption
        }

        private func lastAction(_ profileId: Int32, _ subjectType: SubjectType, _ subjectId: Int32?) -> CarPlayAction? {
            selections.last { $0.profileId == profileId && $0.subjectType == subjectType && $0.subjectId == subjectId }?.action
        }
    }
}

private struct Selection: Hashable {
    let profileId: Int32
    let subjectType: SubjectType
    let subjectId: Int32
    let caption: String
    let action: CarPlayAction

    func hash(into hasher: inout Hasher) {
        hasher.combine(profileId)
        hasher.combine(subjectType)
        hasher.combine(subjectId)
    }
}

private func getSubjectsSource(_ profileId: Int32, _ subjectType: SubjectType) -> Observable<[CarPlayAddFeature.SubjectItem]> {
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

private func getSubjectItems<T>(_ items: [T], _ locationExporter: (T) -> _SALocation?, _ itemConverter: (T) -> CarPlayAddFeature.SubjectItem) -> [CarPlayAddFeature.SubjectItem] {
    var result: [CarPlayAddFeature.SubjectItem] = []
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

private extension SAChannelBase {
    var hasActions: Bool {
        SharedCore.SuplaFunction.companion.from(value: self.func).actions.isEmpty == false
    }
}

private extension SAChannel {
    var subjectItem: CarPlayAddFeature.SubjectItem {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase

        return CarPlayAddFeature.SubjectItem(
            id: "C\(remote_id)",
            remoteId: remote_id,
            label: getCaptionUseCase.invoke(data: shareable).string,
            actions: SharedCore.SuplaFunction.companion.from(value: self.func).actions,
            icon: getChannelBaseIconUseCase.stateIcon(self, state: getChannelBaseStateUseCase.getOfflineState(self.func)),
            isLocation: false
        )
    }
}

private extension SAChannelGroup {
    var subjectItem: CarPlayAddFeature.SubjectItem {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase

        return CarPlayAddFeature.SubjectItem(
            id: "G\(remote_id)",
            remoteId: remote_id,
            label: getCaptionUseCase.invoke(data: shareable).string,
            actions: SharedCore.SuplaFunction.companion.from(value: self.func).actions,
            icon: getChannelBaseIconUseCase.stateIcon(self, state: getChannelBaseStateUseCase.getOfflineState(self.func)),
            isLocation: false
        )
    }
}

private extension SAScene {
    var subjectItem: CarPlayAddFeature.SubjectItem {
        @Singleton<GetSceneIconUseCase> var getSceneIconUseCase

        return CarPlayAddFeature.SubjectItem(
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
    var subjectItem: CarPlayAddFeature.SubjectItem {
        CarPlayAddFeature.SubjectItem(
            id: "L\(location_id ?? 0)",
            remoteId: location_id?.int32Value ?? 0,
            label: caption ?? "",
            actions: [],
            icon: nil,
            isLocation: true
        )
    }
}

private extension SharedCore.SuplaFunction {
    var actions: [CarPlayAction] {
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
             .none: []

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
             .rgbLighting,
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

private extension Array where Element == CarPlayAddFeature.SubjectItem {
    func asSelectableList(selectedId: Int32? = nil) -> SelectableList<CarPlayAddFeature.SubjectItem>? {
        if (isEmpty) {
            return nil
        }

        let selected = first { $0.remoteId == selectedId } ?? first { !$0.isLocation }!
        return SelectableList(selected: selected, items: self)
    }
}

private extension Array where Element == CarPlayAction {
    func asSelectableList(selectedAction: CarPlayAction? = nil) -> SelectableList<CarPlayAction>? {
        if (isEmpty) {
            return nil
        }

        let selected = first { $0 == selectedAction } ?? first!
        return SelectableList(selected: selected, items: self)
    }
}
