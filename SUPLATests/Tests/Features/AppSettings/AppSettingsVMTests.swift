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
import RxTest
import XCTest

@testable import SUPLA

@available(iOS 17.0, *)
class AppSettingsVMTests: ViewModelTest<AppSettingsViewState, AppSettingsViewEvent> {
    private lazy var viewModel: AppSettingsVM! = AppSettingsVM()
    
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var appCoordinator: SuplaAppCoordinatorMock! = SuplaAppCoordinatorMock()
    private lazy var groupSharedSettings: GroupShared.SettingsMock! = GroupShared.SettingsMock()

    private lazy var notificationCenter: UserNotificationCenterMock! = UserNotificationCenterMock()
    
    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: UserNotificationCenter.self, notificationCenter!)
        DiContainer.shared.register(type: SuplaAppCoordinator.self, appCoordinator!)
        DiContainer.shared.register(type: GroupShared.Settings.self, groupSharedSettings!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        settings = nil
        notificationCenter = nil
        appCoordinator = nil
        groupSharedSettings = nil
        
        super.tearDown()
    }
    
    func test_shoudCreateSettingsListWithLoadedSettings_notificationsAuthorized() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        XCTAssertEqual(list, [
            .preferences(items: [
                .heightItem(channelHeight: .height100, callback: { _ in }),
                .temperatureUnitItem(temperatureUnit: .fahrenheit, callback: { _ in }),
                .temperaturePrecisionItem(precision: 2, callback: { _ in }),
                .switchItem(title: Strings.Cfg.buttonAutoHide, selected: true, callback: { _ in }),
                .switchItem(title: Strings.Cfg.showChannelInfo, selected: false, callback: { _ in }),
                .switchItem(title: Strings.AppSettings.showBottomMenu, selected: true, callback: { _ in }),
                .switchItem(title: Strings.AppSettings.showLabels, selected: true, callback: { _ in }),
                .rsOpeningPercentageItem(opening: true, callback: { _ in }),
                .darkModeItem(darkModeSetting: .unset, callback: { _ in }),
                .lockScreenItem(lockScreenScope: .none, callback: { _ in }),
                .batteryLevelWarning(level: 10, callback: { _ in }),
                .arrowButtonItem(title: Strings.Cfg.locationOrdering, callback: {}),
                .arrowButtonItem(title: BrandingConfiguration.actionsLabel, callback: {})
            ]),
            .permissions(items: [
                .permissionItem(title: Strings.AppSettings.notificationsLabel, active: true, callback: {})
            ])
        ])
    }
    
    func test_shoudCreateSettingsListWithLoadedSettings_notificationsUnauthorized() {
        // given
        setupViewData(
            channelHeight: .height150,
            temperatureUnit: .celsius,
            autoHide: false,
            infoButtons: true,
            showOpening: false,
            notificationStatus: .notDetermined
        )
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        XCTAssertEqual(list, [
            .preferences(items: [
                .heightItem(channelHeight: .height150, callback: { _ in }),
                .temperatureUnitItem(temperatureUnit: .celsius, callback: { _ in }),
                .temperaturePrecisionItem(precision: 2, callback: { _ in }),
                .switchItem(title: Strings.Cfg.buttonAutoHide, selected: false, callback: { _ in }),
                .switchItem(title: Strings.Cfg.showChannelInfo, selected: true, callback: { _ in }),
                .switchItem(title: Strings.AppSettings.showBottomMenu, selected: true, callback: { _ in }),
                .switchItem(title: Strings.AppSettings.showLabels, selected: true, callback: { _ in }),
                .rsOpeningPercentageItem(opening: false, callback: { _ in }),
                .darkModeItem(darkModeSetting: .unset, callback: { _ in }),
                .lockScreenItem(lockScreenScope: .none, callback: { _ in }),
                .batteryLevelWarning(level: 10, callback: { _ in }),
                .arrowButtonItem(title: Strings.Cfg.locationOrdering, callback: {}),
                .arrowButtonItem(title: BrandingConfiguration.actionsLabel, callback: {})
            ]),
            .permissions(items: [
                .permissionItem(title: Strings.AppSettings.notificationsLabel, active: false, callback: {})
            ])
        ])
    }
    
    func test_shouldSaveChannelHeight() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[0]) {
        case .heightItem(_, let callback):
            callback(0)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues[0], .height60)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldSaveTemperatureUnit() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[1]) {
        case .temperatureUnitItem(_, let callback):
            callback(0)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters[0], .celsius)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldSaveButtonAutoHide() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[3]) {
        case .switchItem(_, _, let callback, _):
            callback(true)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues[0], true)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldSaveShowChannelInfo() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[4]) {
        case .switchItem(_, _, let callback, _):
            callback(false)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues[0], false)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldSaveShowBottomMenu() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[5]) {
        case .switchItem(_, _, let callback, _):
            callback(true)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomMenuValues, [true])
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldSaveShowBottomLabels() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[6]) {
        case .switchItem(_, _, let callback, _):
            callback(false)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues[0], false)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldSaveOpeningClosingPercentage() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[7]) {
        case .rsOpeningPercentageItem(_, let callback):
            callback(true)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues, [true])
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldSaveDarkModeSetting() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[8]) {
        case .darkModeItem(_, let callback):
            callback(.always)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events, [.next(0, .changeInterfaceStyle(style: .dark))])
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues, [.always])
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldNavigateToPinVerification_scopeChangeToApplication() {
        // given
        setupViewData()
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .accounts, pinSum: "sum", biometricAllowed: false)
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[9]) {
        case .lockScreenItem(_, let callback):
            callback(.application)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
        
        XCTAssertEqual(appCoordinator.navigateToPinSetupMock.parameters, [])
        XCTAssertEqual(appCoordinator.navigateToLockScreenMock.parameters, [.confirmAuthorizeApplication])
    }
    
    func test_shouldNavigateToPinVerification_scopeChangeToAccounts() {
        // given
        setupViewData()
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .application, pinSum: "sum", biometricAllowed: false)
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[9]) {
        case .lockScreenItem(_, let callback):
            callback(.accounts)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
        
        XCTAssertEqual(appCoordinator.navigateToPinSetupMock.parameters, [])
        XCTAssertEqual(appCoordinator.navigateToLockScreenMock.parameters, [.confirmAuthorizeAccounts])
    }
    
    func test_shouldNavigateToPinVerification_turnPinOff() {
        // given
        setupViewData()
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .application, pinSum: "sum", biometricAllowed: false)
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[9]) {
        case .lockScreenItem(_, let callback):
            callback(.none)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
        
        XCTAssertEqual(appCoordinator.navigateToPinSetupMock.parameters, [])
        XCTAssertEqual(appCoordinator.navigateToLockScreenMock.parameters, [.turnOffPin])
    }
    
    func test_shouldNavigateToPinSetup() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[9]) {
        case .lockScreenItem(_, let callback):
            callback(.application)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
        
        XCTAssertEqual(appCoordinator.navigateToPinSetupMock.parameters, [.application])
        XCTAssertEqual(appCoordinator.navigateToLockScreenMock.parameters, [])
    }
    
    func test_shouldSaveBatteryWarningLevel() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[10]) {
        case .batteryLevelWarning(_, let callback):
            callback(20)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events, [])
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.batteryWarningLevelMock.parameters, [20])
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    func test_shouldNavigateToLocationOrdering() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[11]) {
        case .arrowButtonItem(_, let callback):
            callback()
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
        
        XCTAssertEqual(appCoordinator.navigateToLocationOrderingMock.parameters.count, 1)
        XCTAssertEqual(appCoordinator.navigateToPinSetupMock.parameters, [])
        XCTAssertEqual(appCoordinator.navigateToLockScreenMock.parameters, [])
    }
    
    func test_shouldNavigateToAppPreferences() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewWillAppear()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[1].items[0]) {
        case .permissionItem(_, _, let callback):
            callback()
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events, [.next(0, .navigateToAppPreferences)])
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showBottomLabelsValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
        XCTAssertEqual(settings.darkModeValues.count, 0)
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }
    
    private func setupViewData(
        channelHeight: ChannelHeight = .height100,
        temperatureUnit: TemperatureUnit = .fahrenheit,
        autoHide: Bool = true,
        infoButtons: Bool = false,
        showOpening: Bool = true,
        notificationStatus: UNAuthorizationStatus = .authorized
    ) {
        settings.channelHeightReturns = channelHeight
        groupSharedSettings.temperatureUnitMock.returns = .single(temperatureUnit)
        groupSharedSettings.temperaturePrecisionMock.returns = .single(2)
        settings.autohideButtonsReturns = autoHide
        settings.showChannelInfoReturns = infoButtons
        settings.showOpeningPercentReturns = showOpening
        let notificationSettings = AppSettingsTestUserNotificationSettings(coder: AppSettingsTestCoder())!
        notificationSettings.status = notificationStatus
        notificationCenter.notificationSettings = notificationSettings
        settings.batteryWarningLevelMock.returns = .single(10)
    }
}

class AppSettingsTestUserNotificationSettings: UNNotificationSettings {
    var status: UNAuthorizationStatus = .notDetermined
    
    override var authorizationStatus: UNAuthorizationStatus { status }
}

class AppSettingsTestCoder: NSCoder {
    override func decodeInt64(forKey key: String) -> Int64 { 0 }
    override func decodeBool(forKey key: String) -> Bool { false }
}
