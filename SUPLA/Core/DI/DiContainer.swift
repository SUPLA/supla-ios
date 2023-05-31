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
import Foundation

protocol DiContainerProtocol {
    func register<Component>(type: Component.Type, component: Any)
    func resolve<Component>(type: Component.Type) -> Component?
}

@objc
final class DiContainer: NSObject, DiContainerProtocol {
    static let shared = DiContainer()
    
    private override init() {}
    
    var components: [String: Any] = [:]
    
    func register<Component>(type: Component.Type, component: Any) {
        components["\(type)"] = component
    }
    
    func resolve<Component>(type: Component.Type) -> Component? {
        return components["\(type)"] as? Component
    }
}

extension DiContainer {
    @objc static func start() {
        DiContainer.shared.register(type: GlobalSettings.self, component: GlobalSettingsImpl())
        DiContainer.shared.register(type: RuntimeConfig.self, component: RuntimeConfigImpl())
        DiContainer.shared.register(type: SuplaClientProvider.self, component: SuplaClientProviderImpl())
        DiContainer.shared.register(type: SuplaAppWrapper.self, component: SuplaAppWrapperImpl())
        DiContainer.shared.register(type: VibrationService.self, component: VibrationServiceImpl())
        DiContainer.shared.register(type: ListsEventsManager.self, component: ListsEventsManagerImpl())
        
        DiContainer.shared.register(type: (any ProfileRepository).self, component: ProfileRepositoryImpl())
        DiContainer.shared.register(type: (any SceneRepository).self, component: SceneRepositoryImpl())
        DiContainer.shared.register(type: (any LocationRepository).self, component: LocationRepositoryImpl())
        DiContainer.shared.register(type: (any ChannelRepository).self, component: ChannelRepositoryImpl())
        DiContainer.shared.register(type: (any GroupRepository).self, component: GroupRepositoryImpl())
        DiContainer.shared.register(type: (any ChannelValueRepository).self, component: ChannelValueRepositoryImpl())
        DiContainer.shared.register(type: (any ChannelGroupRelationRepository).self, component: ChannelGroupRelationRepositoryImpl())
        DiContainer.shared.register(type: (any ChannelExtendedValueRepository).self, component: ChannelExtendedValueRepositoryImpl())
        DiContainer.shared.register(type: (any ElectricityMeasurementItemRepository).self, component: ElectricityMeasurementItemRepositoryImpl())
        DiContainer.shared.register(type: (any ImpulseCounterMeasurementItemRepository).self, component: ImpulseCounterMeasurementItemRepositoryImpl())
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, component: TemperatureMeasurementItemRepositoryImpl())
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, component: TempHumidityMeasurementItemRepositoryImpl())
        DiContainer.shared.register(type: (any UserIconRepository).self, component: UserIconRepositoryImpl())
        DiContainer.shared.register(type: (any ThermostatMeasurementItemRepository).self, component: ThermostatMeasurementItemRepositoryImpl())
        
        DiContainer.shared.register(type: ToggleLocationUseCase.self, component: ToggleLocationUseCaseImpl())
        DiContainer.shared.register(type: CreateProfileScenesListUseCase.self, component: CreateProfileScenesListUseCaseImpl())
        DiContainer.shared.register(type: CreateProfileChannelsListUseCase.self, component: CreateProfileChannelsListUseCaseImpl())
        DiContainer.shared.register(type: CreateProfileGroupsListUseCase.self, component: CreateProfileGroupsListUseCaseImpl())
        DiContainer.shared.register(type: DeleteAllProfileDataUseCase.self, component: DeleteAllProfileDataUseCaseImpl())
        DiContainer.shared.register(type: SwapChannelPositionsUseCase.self, component: SwapChannelPositionsUseCaseImpl())
        DiContainer.shared.register(type: SwapGroupPositionsUseCase.self, component: SwapGroupPositionsUseCaseImpl())
        DiContainer.shared.register(type: SwapScenePositionsUseCase.self, component: SwapScenePositionsUseCaseImpl())
    }
    
    @objc static func listsEventsManager() -> ListsEventsManagerEmitter? {
        return DiContainer.shared.resolve(type: ListsEventsManager.self)
    }
}
