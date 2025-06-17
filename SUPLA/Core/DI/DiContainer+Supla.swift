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
        
        register(GroupShared.Settings.self, GroupShared.Implementation())
        if #available(iOS 17.0, *) {
            register(ExportCarPlayItems.UseCase.self, ExportCarPlayItems.Implementation())
        }
        
        // Managers
        register(UpdateEventsManager.self, UpdateEventsManagerImpl())
        register(ChannelConfigEventsManager.self, ChannelConfigEventsManagerImpl())
        register(DeviceConfigEventsManager.self, DeviceConfigEventsManagerImpl())
        register(DownloadEventsManager.self, DownloadEventsManagerImpl())
        register(ApplicationEventsManager.self, ApplicationEventsManagerImpl())
        register(SuplaClientAsyncChannelsManager.self, SuplaClientAsyncChannelsManagerImpl())
        
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
        let impulseCounterMeasurementItemRepository = ImpulseCounterMeasurementItemRepositoryImpl()
        register((any ImpulseCounterMeasurementItemRepository).self, impulseCounterMeasurementItemRepository)
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
        let humidityMeasurementItemRepository = HumidityMeasurementItemRepositoryImpl()
        register((any HumidityMeasurementItemRepository).self, humidityMeasurementItemRepository)
        let voltageMeasurementItemRepository = VoltageMeasurementItemRepositoryImpl()
        register((any VoltageMeasurementItemRepository).self, voltageMeasurementItemRepository)
        let currentMeasurementItemRepository = CurrentMeasurementItemRepositoryImpl()
        register((any CurrentMeasurementItemRepository).self, currentMeasurementItemRepository)
        let powerActiveMeasurementItemRepository = PowerActiveMeasurementItemRepositoryImpl()
        register((any PowerActiveMeasurementItemRepository).self, powerActiveMeasurementItemRepository)
        register((any NotificationRepository).self, NotificationRepositoryImpl())
        register((any ChannelStateRepository).self, ChannelStateRepositoryImpl())
        register((any ProfileServerRepository).self, ProfileServerRepositoryImpl())
        register((any CarPlayItemRepository).self, CarPlayItemRepositoryImpl())
        
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
        register(DownloadHumidityLogUseCase.self,
                 DownloadHumidityLogUseCaseImpl(humidityMeasurementItemRepository))
        register(DownloadImpulseCounterLogUseCase.self,
                 DownloadImpulseCounterLogUseCaseImpl(impulseCounterMeasurementItemRepository))
        register(DownloadCurrentLogUseCase.self,
                 DownloadCurrentLogUseCaseImpl(currentMeasurementItemRepository))
        register(DownloadVoltageLogUseCase.self,
                 DownloadVoltageLogUseCaseImpl(voltageMeasurementItemRepository))
        register(DownloadPowerActiveLogUseCase.self,
                 DownloadPowerActiveLogUseCaseImpl(powerActiveMeasurementItemRepository))
        register(LoadChannelMeasurementsUseCase.self, LoadChannelMeasurementsUseCaseImpl())
        register(LoadChannelMeasurementsDateRangeUseCase.self, LoadChannelMeasurementsDateRangeUseCaseImpl())
        register(GetChannelValueUseCase.self, GetChannelValueUseCaseImpl())
        register(GetChannelValueStringUseCase.self, GetChannelValueStringUseCaseImpl())
        register(LoadChannelConfigUseCase.self, LoadChannelConfigUseCaseImpl())
        register(DeleteChannelMeasurementsUseCase.self, DeleteChannelMeasurementsUseCaseImpl())
        register(LoadElectricityMeterMeasurementsUseCase.self, LoadElectricityMeterMeasurementsUseCaseImpl())
        register(LoadImpulseCounterMeasurementsUseCase.self, LoadImpulseCounterMeasurementsUseCaseImpl())
        register(GetChannelActionStringUseCase.self, SharedCore.GetChannelActionStringUseCase())
        register(ChannelToRootRelationHolderUseCase.self, ChannelToRootRelationHolderUseCaseImpl())
        register(CaptionChangeUseCase.self, CaptionChangeUseCaseImpl())
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
        register(ContainerValueProvider.self, ContainerValueProviderImpl())
        register(RemoveHiddenChannelsUseCase.self, RemoveHiddenChannelsUseCaseImpl())
        // Usecases - Channel - MeasurementProvider
        register(TemperatureMeasurementsProvider.self, TemperatureMeasurementsProviderImpl())
        register(TemperatureAndHumidityMeasurementsProvider.self, TemperatureAndHumidityMeasurementsProviderImpl())
        register(GeneralPurposeMeterMeasurementsProvider.self, GeneralPurposeMeterMeasurementsProviderImpl())
        register(GeneralPurposeMeasurementMeasurementsProvider.self, GeneralPurposeMeasurementMeasurementsProviderImpl())
        register(ElectricityMeterMeasurementsProvider.self, ElectricityMeterMeasurementsProviderImpl())
        register(ElectricityConsumptionProvider.self, ElectricityConsumptionProviderImpl())
        register(VoltageMeasurementsProvider.self, VoltageMeasurementsProviderImpl())
        register(CurrentMeasurementsProvider.self, CurrentMeasurementsProviderImpl())
        register(PowerActiveMeasurementsProvider.self, PowerActiveMeasurementsProviderImpl())
        register(HumidityMeasurementsProvider.self, HumidityMeasurementsProviderImpl())
        register(ImpulseCounterMeasurementsProvider.self, ImpulseCounterMeasurementsProviderImpl())
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
        register(UserIcons.UseCase.self, UserIcons.Implementation())
        register(DownloadUserIcons.UseCase.self, DownloadUserIcons.Implementation())
        register(DownloadUserIconsManager.self, DownloadUserIconsManagerImpl())
        register(GetAllIconsToDownload.UseCase.self, GetAllIconsToDownload.Implementation())
        // Usecases - Location
        register(ToggleLocationUseCase.self, ToggleLocationUseCaseImpl())
        register(ReadLocationByRemoteIdUseCase.self, ReadLocationByRemoteIdUseCaseImpl())
        // Usecases - Profile
        register(DeleteAllProfileDataUseCase.self, DeleteAllProfileDataUseCaseImpl())
        register(ReadProfileByIdUseCase.self, ReadProfileByIdUseCaseImpl())
        register(SaveOrCreateProfileUseCase.self, SaveOrCreateProfileUseCaseImpl())
        register(DeleteProfileUseCase.self, DeleteProfileUseCaseImpl())
        register(ActivateProfileUseCase.self, ActivateProfileUseCaseImpl())
        register(LoadActiveProfileUrlUseCase.self, LoadActiveProfileUrlUseCaseImpl())
        // Usecases - Profile
        register(CreateProfileScenesListUseCase.self, CreateProfileScenesListUseCaseImpl())
        register(CreateChannelWithChildrenUseCase.self, CreateChannelWithChildrenUseCaseImpl())
        // Usecases - Notification
        register(InsertNotificationUseCase.self, InsertNotificationUseCaseImpl())
        register(NotificationCenterWrapper.self, NotificationCenterWrapperImpl())
        // Usecases - Lock
        register(CheckPinUseCase.self, CheckPinUseCaseImpl())
        // UseCases - Ocr
        register(DownloadOcrPhotoUseCase.self, DownloadOcrPhotoUseCaseImpl())
        // UseCases - ChannelState
        register(UpdateChannelStateUseCase.self, UpdateChannelStateUseCaseImpl())
        // UseCases - ProfileServer
        register(ReadOrCreateProfileServerUseCase.self, ReadOrCreateProfileServerUseCaseImpl())
        // UseCases - Scene
        register(SwapScenePositionsUseCase.self, SwapScenePositionsUseCaseImpl())
        register(ReadSceneByRemoteIdUseCase.self, ReadSceneByRemoteIdUseCaseImpl())
        register(GetSceneIconUseCase.self, GetSceneIconUseCaseImpl())
        // UseCases - CarPlayItem
        register(CreateCarPlayItemUseCase.self, CreateCarPlayItemUseCaseImpl())
        register(ReadCarPlayItems.UseCase.self, ReadCarPlayItems.Implementation())
        register(UpdateCarPlayOrder.UseCase.self, UpdateCarPlayOrder.Implementation())
        register(UpdateCarPlayItem.UseCase.self, UpdateCarPlayItem.Implementation())
        register(CarPlayRefresh.UseCase.self, CarPlayRefresh.Implementation())
        register(DeleteCarPlayItem.UseCase.self, DeleteCarPlayItem.Implementation())
        
        // MARK: Features
        
        // Electricity
        register(ElectricityMeterGeneralStateHandler.self, ElectricityMeterGeneralStateHandlerImpl())
        // Impulse Counter
        register(ImpulseCounterGeneralStateHandler.self, ImpulseCounterGeneralStateHandlerImpl())
        
        // MARK: Shared

        // level 0
        let ocrImageNamingProvider = registerAndGet(OcrImageNamingProvider.self, SharedCore.OcrImageNamingProvider())
        let cacheFileAccess = registerAndGet(CacheFileAccessProxy.self, CacheFileAccessProxyImpl())
        let storeFileInDirectoryUseCase = SharedCore.StoreFileInDirectoryUseCase(cacheFileAccess: cacheFileAccess)
        let base64Helper = SharedCore.Base64Helper()
        let getChannelDefaultCaptionUseCase = registerAndGet(
            GetChannelDefaultCaptionUseCase.self,
            SharedCore.GetChannelDefaultCaptionUseCase()
        )
        let getChannelBatteryIconUseCase = registerAndGet(
            GetChannelBatteryIconUseCase.self,
            SharedCore.GetChannelBatteryIconUseCase()
        )
        let getChannelSpecificIssuesUseCase = registerAndGet(
            GetChannelSpecificIssuesUseCase.self,
            SharedCore.GetChannelSpecificIssuesUseCase()
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
        register(
            GetAllChannelIssuesUseCase.self,
            SharedCore.GetAllChannelIssuesUseCase(
                getChannelLowBatteryIssueUseCase: getChannelLowBatteryIssueUseCase,
                getChannelSpecificIssuesUseCase: getChannelSpecificIssuesUseCase
            )
        )
        register(
            CheckOcrPhotoExistsUseCase.self,
            SharedCore.CheckOcrPhotoExistsUseCase(
                ocrImageNamingProvider: ocrImageNamingProvider,
                cacheFileAccess: cacheFileAccess
            )
        )
        register(
            StoreChannelOcrPhotoUseCase.self,
            SharedCore.StoreChannelOcrPhotoUseCase(
                storeFileInDirectoryUseCase: storeFileInDirectoryUseCase,
                ocrImageNamingProvider: ocrImageNamingProvider,
                base64Helper: base64Helper
            )
        )
        
        // level 2
        register(
            GetChannelIssuesForListUseCase.self,
            SharedCore.GetChannelIssuesForListUseCase(
                getChannelLowBatteryIssueUseCase: getChannelLowBatteryIssueUseCase,
                getChannelBatteryIconUseCase: getChannelBatteryIconUseCase,
                getChannelSpecificIssuesUseCase: getChannelSpecificIssuesUseCase
            )
        )
        register(
            GetChannelIssuesForSlavesUseCase.self,
            SharedCore.GetChannelIssuesForSlavesUseCase(
                getChannelLowBatteryIssueUseCase: getChannelLowBatteryIssueUseCase,
                getChannelBatteryIconUseCase: getChannelBatteryIconUseCase,
                getChannelSpecificIssuesUseCase: getChannelSpecificIssuesUseCase
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
