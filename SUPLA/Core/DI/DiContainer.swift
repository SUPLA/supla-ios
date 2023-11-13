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
    var producers: [String: () -> Any] = [:]
    
    func register<Component>(type: Component.Type, component: Any) {
        if (!(component is Component)) {
            fatalError("Registered component (type: `\(type)` does not implement defined protocol")
        }
        components["\(type)"] = component
    }
    
    func register<Component>(type: Component.Type, producer: @escaping () -> Any) {
        producers["\(type)"] = producer
    }
    
    func resolve<Component>(type: Component.Type) -> Component? {
        return components["\(type)"] as? Component
    }
    
    func producer<Component>(type: Component.Type) -> Component? {
        if let producer = producers["\(type)"] {
            return producer() as? Component
        }
        
        return nil
    }
}

extension DiContainer {
    @objc static func start() {
        // MARK: General
        DiContainer.shared.register(type: GlobalSettings.self, component: GlobalSettingsImpl())
        DiContainer.shared.register(type: RuntimeConfig.self, component: RuntimeConfigImpl())
        DiContainer.shared.register(type: SuplaClientProvider.self, component: SuplaClientProviderImpl())
        DiContainer.shared.register(type: SuplaAppWrapper.self, component: SuplaAppWrapperImpl())
        DiContainer.shared.register(type: VibrationService.self, component: VibrationServiceImpl())
        DiContainer.shared.register(type: UpdateEventsManager.self, component: UpdateEventsManagerImpl())
        DiContainer.shared.register(type: ConfigEventsManager.self, component: ConfigEventsManagerImpl())
        DiContainer.shared.register(type: DownloadEventsManager.self, component: DownloadEventsManagerImpl())
        DiContainer.shared.register(type: SingleCall.self, component: SingleCallImpl())
        DiContainer.shared.register(type: DateProvider.self, component: DateProviderImpl())
        DiContainer.shared.register(type: UserNotificationCenter.self, component: UserNotificationCenterImpl())
        DiContainer.shared.register(type: RequestHelper.self, component: RequestHelperImpl())
        DiContainer.shared.register(type: ValuesFormatter.self, component: ValuesFormatterImpl())
        DiContainer.shared.register(type: DelayedThermostatActionSubject.self, component: DelayedThermostatActionSubjectImpl())
        DiContainer.shared.register(type: DelayedWeeklyScheduleConfigSubject.self, component: DelayedWeeklyScheduleConfigSubjectImpl())
        DiContainer.shared.register(type: SuplaCloudService.self, component: SuplaCloudServiceImpl())
        DiContainer.shared.register(type: SuplaCloudConfigHolder.self, component: SuplaCloudConfigHolderImpl())
        DiContainer.shared.register(type: UserStateHolder.self, component: UserStateHolderImpl())
        DiContainer.shared.register(type: SessionResponseProvider.self, component: SessionResponseProviderImpl())
        DiContainer.shared.register(type: SuplaSchedulers.self, component: SuplaSchedulersImpl())
        
        // MARK: Repositories
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
        DiContainer.shared.register(type: (any SuplaCloudClientRepository).self, component: SuplaCloudClientRepositoryImpl())
        DiContainer.shared.register(type: (any ChannelRelationRepository).self, component: ChannelRelationRepositoryImpl())
        
        // MARK: Usecases
        // Usecases - Channel
        DiContainer.shared.register(type: SwapChannelPositionsUseCase.self, component: SwapChannelPositionsUseCaseImpl())
        DiContainer.shared.register(type: CreateProfileChannelsListUseCase.self, component: CreateProfileChannelsListUseCaseImpl())
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, component: ReadChannelByRemoteIdUseCaseImpl())
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, component: ReadChannelWithChildrenUseCaseImpl())
        DiContainer.shared.register(type: CreateTemperaturesListUseCase.self, component: CreateTemperaturesListUseCaseImpl())
        DiContainer.shared.register(type: DownloadChannelMeasurementsUseCase.self, component: DownloadChannelMeasurementsUseCaseImpl())
        DiContainer.shared.register(type: DownloadTemperatureMeasurementsUseCase.self, component: DownloadTemperatureMeasurementsUseCaseImpl())
        DiContainer.shared.register(type: DownloadTempHumidityMeasurementsUseCase.self, component: DownloadTempHumidityMeasurementsUseCaseImpl())
        DiContainer.shared.register(type: LoadChannelMeasurementsUseCase.self, component: LoadChannelMeasurementsUseCaseImpl())
        DiContainer.shared.register(type: LoadChannelMeasurementsDateRangeUseCase.self, component: LoadChannelMeasurementsDateRangeUseCaseImpl())
        // Usecases - ChannelBase
        DiContainer.shared.register(type: GetChannelBaseStateUseCase.self, component: GetChannelBaseStateUseCaseImpl())
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, component: GetChannelBaseIconUseCaseImpl())
        DiContainer.shared.register(type: LoadChannelWithChildrenMeasurementsUseCase.self, component: LoadChannelWithChildrenMeasurementsUseCaseImpl())
        DiContainer.shared.register(type: LoadChannelWithChildrenMeasurementsDateRangeUseCase.self, component: LoadChannelWithChildrenMeasurementsDateRangeUseCaseImpl())
        // Usecases - Client
        DiContainer.shared.register(type: ExecuteSimpleActionUseCase.self, component: ExecuteSimpleActionUseCaseImpl())
        DiContainer.shared.register(type: StartTimerUseCase.self, component: StartTimerUseCaseImpl())
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, component: GetChannelConfigUseCaseImpl())
        DiContainer.shared.register(type: SetChannelConfigUseCase.self, component: SetChannelConfigUseCaseImpl())
        DiContainer.shared.register(type: ExecuteThermostatActionUseCase.self, component: ExecuteThermostatActionUseCaseImpl())
        // Usecases - Detail
        DiContainer.shared.register(type: ProvideDetailTypeUseCase.self, component: ProvideDetailTypeUseCaseImpl())
        // Usecases - Group
        DiContainer.shared.register(type: SwapGroupPositionsUseCase.self, component: SwapGroupPositionsUseCaseImpl())
        DiContainer.shared.register(type: CreateProfileGroupsListUseCase.self, component: CreateProfileGroupsListUseCaseImpl())
        // Usecases - Icon
        DiContainer.shared.register(type: GetDefaultIconNameUseCase.self, component: GetDefaultIconNameUseCaseImpl())
        // Usecases - Location
        DiContainer.shared.register(type: ToggleLocationUseCase.self, component: ToggleLocationUseCaseImpl())
        // Usecases - Profile
        DiContainer.shared.register(type: DeleteAllProfileDataUseCase.self, component: DeleteAllProfileDataUseCaseImpl())
        // Usecases - Profile
        DiContainer.shared.register(type: CreateProfileScenesListUseCase.self, component: CreateProfileScenesListUseCaseImpl())
        DiContainer.shared.register(type: SwapScenePositionsUseCase.self, component: SwapScenePositionsUseCaseImpl())
        DiContainer.shared.register(type: CreateChannelWithChildrenUseCase.self, component: CreateChannelWithChildrenUseCaseImpl())
        
        // MARK: Not singletons
        DiContainer.shared.register(type: LoadingTimeoutManager.self, producer: { LoadingTimeoutManagerImpl() })
    }
    
    @objc static func updateEventsManager() -> UpdateEventsManagerEmitter? {
        return DiContainer.shared.resolve(type: UpdateEventsManager.self)
    }
    @objc static func configEventsManager() -> ConfigEventsManagerEmitter? {
        return DiContainer.shared.resolve(type: ConfigEventsManager.self)
    }
    @objc static func setPushToken(token: Data?) {
        var settings = DiContainer.shared.resolve(type: GlobalSettings.self)
        settings?.pushToken = token
    }
    @objc static func getPushToken() -> Data? {
        DiContainer.shared.resolve(type: GlobalSettings.self)?.pushToken
    }
    @objc static func setOAuthToken(token: SAOAuthToken) {
        var configHolder = DiContainer.shared.resolve(type: SuplaCloudConfigHolder.self)
        configHolder?.token = token
    }
    @objc static func setOAuthUrl(url: String) {
        var configHolder = DiContainer.shared.resolve(type: SuplaCloudConfigHolder.self)
        configHolder?.url = url
    }
}
