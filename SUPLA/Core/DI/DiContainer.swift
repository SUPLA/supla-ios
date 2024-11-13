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

protocol DiContainerProtocol {
    func register<Component>(type: Component.Type, _ component: Any)
    func resolve<Component>(type: Component.Type) -> Component?
}

@objc
final class DiContainer: NSObject, DiContainerProtocol {
    static let shared = DiContainer()
    
    override private init() {}
    
    var components: [String: Any] = [:]
    var producers: [String: () -> Any] = [:]
    
    func register<Component>(type: Component.Type, _ component: Any) {
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

        register(SuplaAppCoordinator.self, SuplaAppCoordinatorImpl())
        let globalSettings = registerAndGet(GlobalSettings.self, GlobalSettingsImpl())
        register(RuntimeConfig.self, RuntimeConfigImpl())
        register(SuplaClientProvider.self, SuplaClientProviderImpl())
        register(SuplaAppProvider.self, SuplaAppProviderImpl())
        register(VibrationService.self, VibrationServiceImpl())
        register(SingleCall.self, SingleCallImpl())
        register(DateProvider.self, DateProviderImpl())
        register(UserNotificationCenter.self, UserNotificationCenterImpl())
        register(RequestHelper.self, RequestHelperImpl())
        register(ValuesFormatter.self, ValuesFormatterImpl())
        register(DelayedThermostatActionSubject.self, DelayedThermostatActionSubjectImpl())
        register(DelayedWeeklyScheduleConfigSubject.self, DelayedWeeklyScheduleConfigSubjectImpl())
        register(SuplaCloudService.self, SuplaCloudServiceImpl())
        register(SuplaCloudConfigHolder.self, SuplaCloudConfigHolderImpl())
        register(UserStateHolder.self, UserStateHolderImpl())
        register(SessionResponseProvider.self, SessionResponseProviderImpl())
        register(SuplaSchedulers.self, SuplaSchedulersImpl())
        register(ThreadHandler.self, ThreadHandlerImpl())
        register(SuplaAppStateHolder.self, SuplaAppStateHolderImpl())
        register(BuildInfo.self, BuildInfoImpl())
        
        // Managers
        register(UpdateEventsManager.self, UpdateEventsManagerImpl())
        register(ChannelConfigEventsManager.self, ChannelConfigEventsManagerImpl())
        register(DeviceConfigEventsManager.self, DeviceConfigEventsManagerImpl())
        register(DownloadEventsManager.self, DownloadEventsManagerImpl())
        register(ApplicationEventsManager.self, ApplicationEventsManagerImpl())
        
        // MARK: Repositories

        register((any ProfileRepository).self, ProfileRepositoryImpl())
        register((any SceneRepository).self, SceneRepositoryImpl())
        register((any LocationRepository).self, LocationRepositoryImpl())
        register((any ChannelRepository).self, ChannelRepositoryImpl())
        register((any GroupRepository).self, GroupRepositoryImpl())
        register((any ChannelValueRepository).self, ChannelValueRepositoryImpl())
        register((any ChannelGroupRelationRepository).self, ChannelGroupRelationRepositoryImpl())
        register((any ChannelExtendedValueRepository).self, ChannelExtendedValueRepositoryImpl())
        let electricityMeasurementItemRepository = ElectricityMeasurementItemRepositoryImpl()
        register((any ElectricityMeasurementItemRepository).self, electricityMeasurementItemRepository)
        register((any ImpulseCounterMeasurementItemRepository).self, ImpulseCounterMeasurementItemRepositoryImpl())
        register((any UserIconRepository).self, UserIconRepositoryImpl())
        register((any ThermostatMeasurementItemRepository).self, ThermostatMeasurementItemRepositoryImpl())
        register((any SuplaCloudClientRepository).self, SuplaCloudClientRepositoryImpl())
        register((any ChannelRelationRepository).self, ChannelRelationRepositoryImpl())
        register((any ChannelConfigRepository).self, ChannelConfigRepositoryImpl())
        let temperatureMeasurementItemRepository = TemperatureMeasurementItemRepositoryImpl()
        register((any TemperatureMeasurementItemRepository).self, temperatureMeasurementItemRepository)
        let tempHumidityMeasurementItemRepository = TempHumidityMeasurementItemRepositoryImpl()
        register((any TempHumidityMeasurementItemRepository).self, tempHumidityMeasurementItemRepository)
        let generalPurposeMeasurementItemRepository = GeneralPurposeMeasurementItemRepositoryImpl()
        register((any GeneralPurposeMeasurementItemRepository).self, generalPurposeMeasurementItemRepository)
        let generalPurposeMeterItemRepository = GeneralPurposeMeterItemRepositoryImpl()
        register((any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository)
        register((any NotificationRepository).self, NotificationRepositoryImpl())
        
        // MARK: Usecases

        // Usecases - Channel
        register(UpdateChannelUseCase.self, UpdateChannelUseCaseImpl())
        register(SwapChannelPositionsUseCase.self, SwapChannelPositionsUseCaseImpl())
        register(CreateProfileChannelsListUseCase.self, CreateProfileChannelsListUseCaseImpl())
        register(ReadChannelByRemoteIdUseCase.self, ReadChannelByRemoteIdUseCaseImpl())
        register(ReadChannelWithChildrenUseCase.self, ReadChannelWithChildrenUseCaseImpl())
        register(ReadChannelWithChildrenTreeUseCase.self, ReadChannelWithChildrenTreeUseCaseImpl())
        register(CreateTemperaturesListUseCase.self, CreateTemperaturesListUseCaseImpl())
        register(DownloadChannelMeasurementsUseCase.self, DownloadChannelMeasurementsUseCaseImpl())
        register(DownloadTemperatureLogUseCase.self,
                 DownloadTemperatureLogUseCaseImpl(temperatureMeasurementItemRepository))
        register(DownloadTempHumidityLogUseCase.self,
                 DownloadTempHumidityLogUseCaseImpl(tempHumidityMeasurementItemRepository))
        register(DownloadGeneralPurposeMeasurementLogUseCase.self,
                 DownloadGeneralPurposeMeasurementLogUseCaseImpl(generalPurposeMeasurementItemRepository))
        register(DownloadGeneralPurposeMeterLogUseCase.self,
                 DownloadGeneralPurposeMeterLogUseCaseImpl(generalPurposeMeterItemRepository))
        register(DownloadElectricityMeterLogUseCase.self,
                 DownloadElectricityMeterLogUseCaseImpl(electricityMeasurementItemRepository))
        register(LoadChannelMeasurementsUseCase.self, LoadChannelMeasurementsUseCaseImpl())
        register(LoadChannelMeasurementsDateRangeUseCase.self, LoadChannelMeasurementsDateRangeUseCaseImpl())
        register(GetChannelValueUseCase.self, GetChannelValueUseCaseImpl())
        register(GetChannelValueStringUseCase.self, GetChannelValueStringUseCaseImpl())
        register(LoadChannelConfigUseCase.self, LoadChannelConfigUseCaseImpl())
        register(DeleteChannelMeasurementsUseCase.self, DeleteChannelMeasurementsUseCaseImpl())
        register(LoadElectricityMeterMeasurementsUseCase.self, LoadElectricityMeterMeasurementsUseCaseImpl())
        register(GetChannelActionStringUseCase.self, SharedCore.GetChannelActionStringUseCase())
        // Usecases - Channel - ValueProvider
        register(DepthValueProvider.self, DepthValueProviderImpl())
        register(DistanceValueProvider.self, DistanceValueProviderImpl())
        register(GpmValueProvider.self, GpmValueProviderImpl())
        register(HumidityValueProvider.self, HumidityValueProviderImpl())
        register(PressureValueProvider.self, PressureValueProviderImpl())
        register(RainValueProvider.self, RainValueProviderImpl())
        register(ThermometerAndHumidityValueProvider.self, ThermometerAndHumidityValueProviderImpl())
        register(ThermometerValueProvider.self, ThermometerValueProviderImpl())
        register(WeightValueProvider.self, WeightValueProviderImpl())
        register(WindValueProvider.self, WindValueProviderImpl())
        register(ElectricityMeterValueProvider.self, ElectricityMeterValueProviderImpl())
        register(SwitchWithElectricityMeterValueProvider.self, SwitchWithElectricityMeterValueProviderImpl())
        register(ImpulseCounterValueProvider.self, ImpulseCounterValueProviderImpl())
        register(SwitchWithImpulseCounterValueProvider.self, SwitchWithImpulseCounterValueProviderImpl())
        // Usecases - Channel - MeasurementProvider
        register(TemperatureMeasurementsProvider.self, TemperatureMeasurementsProviderImpl())
        register(TemperatureAndHumidityMeasurementsProvider.self, TemperatureAndHumidityMeasurementsProviderImpl())
        register(GeneralPurposeMeterMeasurementsProvider.self, GeneralPurposeMeterMeasurementsProviderImpl())
        register(GeneralPurposeMeasurementMeasurementsProvider.self, GeneralPurposeMeasurementMeasurementsProviderImpl())
        register(ElectricityMeasurementsProvider.self, ElectricityMeasurementsProviderImpl())
        // Usecases - ChannelBase
        register(GetChannelBaseStateUseCase.self, GetChannelBaseStateUseCaseImpl())
        register(GetChannelBaseIconUseCase.self, GetChannelBaseIconUseCaseImpl())
        register(LoadChannelWithChildrenMeasurementsUseCase.self, LoadChannelWithChildrenMeasurementsUseCaseImpl())
        register(LoadChannelWithChildrenMeasurementsDateRangeUseCase.self, LoadChannelWithChildrenMeasurementsDateRangeUseCaseImpl())
        register(GetChannelBaseDefaultCaptionUseCase.self, SharedCore.GetChannelDefaultCaptionUseCase())
        register(ChannelBaseActionUseCase.self, ChannelBaseActionUseCaseImpl())
        // Usecases - ChannelConfig
        register(InsertChannelConfigUseCase.self, InsertChannelConfigUseCaseImpl())
        register(RequestChannelConfigUseCase.self, RequestChannelConfigUseCaseImpl())
        // Usecases - Client
        register(ExecuteSimpleActionUseCase.self, ExecuteSimpleActionUseCaseImpl())
        register(StartTimerUseCase.self, StartTimerUseCaseImpl())
        register(GetChannelConfigUseCase.self, GetChannelConfigUseCaseImpl())
        register(SetChannelConfigUseCase.self, SetChannelConfigUseCaseImpl())
        register(GetDeviceConfigUseCase.self, GetDeviceConfigUseCaseImpl())
        register(ExecuteThermostatActionUseCase.self, ExecuteThermostatActionUseCaseImpl())
        register(CallSuplaClientOperationUseCase.self, CallSuplaClientOperationUseCaseImpl())
        register(ExecuteRollerShutterActionUseCase.self, ExecuteRollerShutterActionUseCaseImpl())
        register(AuthorizeUseCase.self, AuthorizeUseCaseImpl())
        register(LoginUseCase.self, LoginUseCaseImpl())
        register(ExecuteFacadeBlindActionUseCase.self, ExecuteFacadeBlindActionUseCaseImpl())
        register(DisconnectUseCase.self, DisconnectUseCaseImpl())
        register(ReconnectUseCase.self, ReconnectUseCaseImpl())
        // Usecases - Detail
        register(ProvideChannelDetailTypeUseCase.self, ProvideChannelDetailTypeUseCaseImpl())
        register(ProvideGroupDetailTypeUseCase.self, ProvideGroupDetailTypeUseCaseImpl())
        // Usecases - Group
        register(SwapGroupPositionsUseCase.self, SwapGroupPositionsUseCaseImpl())
        register(CreateProfileGroupsListUseCase.self, CreateProfileGroupsListUseCaseImpl())
        register(ReadGroupByRemoteIdUseCase.self, ReadGroupByRemoteIdUseCaseImpl())
        register(GetGroupOnlineSummaryUseCase.self, GetGroupOnlineSummaryUseCaseImpl())
        register(UpdateChannelGroupTotalValueUseCase.self, UpdateChannelGroupTotalValueUseCaseImpl())
        register(GetGroupActivePercentageUseCase.self, GetGroupActivePercentageUseCaseImpl())
        register(ReadGroupTiltingDetailsUseCase.self, ReadGroupTiltingDetailsUseCaseImpl())
        // Usecases - Icon
        register(GetDefaultIconNameUseCase.self, GetDefaultIconNameUseCaseImpl())
        // Usecases - Location
        register(ToggleLocationUseCase.self, ToggleLocationUseCaseImpl())
        // Usecases - Profile
        register(DeleteAllProfileDataUseCase.self, DeleteAllProfileDataUseCaseImpl())
        register(ReadProfileByIdUseCase.self, ReadProfileByIdUseCaseImpl())
        register(SaveOrCreateProfileUseCase.self, SaveOrCreateProfileUseCaseImpl())
        register(DeleteProfileUseCase.self, DeleteProfileUseCaseImpl())
        register(ActivateProfileUseCase.self, ActivateProfileUseCaseImpl())
        register(LoadActiveProfileUrlUseCase.self, LoadActiveProfileUrlUseCaseImpl())
        // Usecases - Profile
        register(CreateProfileScenesListUseCase.self, CreateProfileScenesListUseCaseImpl())
        register(SwapScenePositionsUseCase.self, SwapScenePositionsUseCaseImpl())
        register(CreateChannelWithChildrenUseCase.self, CreateChannelWithChildrenUseCaseImpl())
        // Usecases - Notification
        register(InsertNotificationUseCase.self, InsertNotificationUseCaseImpl())
        register(NotificationCenterWrapper.self, NotificationCenterWrapperImpl())
        // Usecases - Lock
        register(CheckPinUseCase.self, CheckPinUseCaseImpl())
        
        // MARK: Features
        
        // Electricity
        register(ElectricityMeterGeneralStateHandler.self, ElectricityMeterGeneralStateHandlerImpl())
        
        // MARK: Shared

        // level 0
        let getChannelDefaultCaptionUseCase = registerAndGet(
            GetChannelDefaultCaptionUseCase.self,
            SharedCore.GetChannelDefaultCaptionUseCase()
        )
        let getChannelBatteryIconUseCase = registerAndGet(
            GetChannelBatteryIconUseCase.self,
            SharedCore.GetChannelBatteryIconUseCase()
        )
        
        // level 1
        let getCaptionUseCase = registerAndGet(
            GetCaptionUseCase.self,
            SharedCore.GetCaptionUseCase(getChannelDefaultCaptionUseCase: getChannelDefaultCaptionUseCase)
        )
        let getChannelLowBatteryIssueUseCase = registerAndGet(
            GetChannelLowBatteryIssueUseCase.self,
            SharedCore.GetChannelLowBatteryIssueUseCase(
                getCaptionUseCase: getCaptionUseCase,
                applicationPreferences: globalSettings
            )
        )
        
        // level 2
        let getChannelIssuesForListUseCase = registerAndGet(
            GetChannelIssuesForListUseCase.self,
            SharedCore.GetChannelIssuesForListUseCase(
                getChannelLowBatteryIssueUseCase: getChannelLowBatteryIssueUseCase, getChannelBatteryIconUseCase: getChannelBatteryIconUseCase
            )
        )
        
        // MARK: Not singletons

        DiContainer.shared.register(type: LoadingTimeoutManager.self, producer: { LoadingTimeoutManagerImpl() })
    }
    
    static func register<Component>(_ type: Component.Type, _ component: Any) {
        DiContainer.shared.register(type: type, component)
    }
    
    static func registerAndGet<Component, Instance>(_ type: Component.Type, _ component: Instance) -> Instance {
        DiContainer.shared.register(type: type, component)
        return component
    }
    
    @objc static func updateEventsManager() -> UpdateEventsManagerEmitter? {
        return DiContainer.shared.resolve(type: UpdateEventsManager.self)
    }

    @objc static func channelConfigEventsManager() -> ChannelConfigEventsManagerEmitter? {
        return DiContainer.shared.resolve(type: ChannelConfigEventsManager.self)
    }

    @objc static func deviceConfigEventsManager() -> DeviceConfigEventsManagerEmitter? {
        return DiContainer.shared.resolve(type: DeviceConfigEventsManager.self)
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
