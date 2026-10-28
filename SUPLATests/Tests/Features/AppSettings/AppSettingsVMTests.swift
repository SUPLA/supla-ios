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

import Combine
import UserNotifications
import XCTest

@testable import SUPLA

@available(iOS 17.0, *)
final class AppSettingsVMTests: XCTestCase {
    private var viewModel: AppSettingsFeature.ViewModel!
    private var settings: GlobalSettingsMock!
    private var router: AppRouter!
    private var groupSharedSettings: GroupShared.SettingsMock!
    private var notificationCenter: UserNotificationCenterMock!

    override func setUp() {
        super.setUp()

        settings = GlobalSettingsMock()
        router = AppRouter()
        groupSharedSettings = GroupShared.SettingsMock()
        notificationCenter = UserNotificationCenterMock()
        notificationCenter.notificationSettings = notificationSettings(status: .authorized)

        DiContainer.shared.register(type: GlobalSettings.self, settings)
        DiContainer.shared.register(type: AppRouter.self, router)
        DiContainer.shared.register(type: GroupShared.Settings.self, groupSharedSettings)
        DiContainer.shared.register(type: UserNotificationCenter.self, notificationCenter)

        viewModel = AppSettingsFeature.ViewModel()
    }

    override func tearDown() {
        viewModel = nil
        settings = nil
        router = nil
        groupSharedSettings = nil
        notificationCenter = nil

        super.tearDown()
    }

    func test_onViewAppearLoadsStoredSettingsIntoViewState() {
        settings.channelHeightReturns = .height60
        settings.autohideButtonsReturns = true
        settings.showChannelInfoReturns = true
        settings.showBottomMenuReturns = false
        settings.showBottomLabelsReturns = false
        settings.hideUnavailableChannelsMock.returns = .single(true)
        settings.showOpeningPercentReturns = false
        settings.darkModeReturns = .always
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .accounts, pinSum: nil, biometricAllowed: false)
        settings.batteryWarningLevelMock.returns = .single(25)
        groupSharedSettings.temperatureUnitMock.returns = .single(.fahrenheit)
        groupSharedSettings.temperaturePrecisionMock.returns = .single(2)

        viewModel.onViewAppear()

        XCTAssertEqual(viewModel.state.channelHeight, .height60)
        XCTAssertEqual(viewModel.state.temperatureUnit, .fahrenheit)
        XCTAssertEqual(viewModel.state.temperaturePrecision, 2)
        XCTAssertTrue(viewModel.state.autohideButtons)
        XCTAssertTrue(viewModel.state.showChannelInfo)
        XCTAssertFalse(viewModel.state.showBottomMenu)
        XCTAssertFalse(viewModel.state.showBottomLabels)
        XCTAssertTrue(viewModel.state.hideUnavailableChannels)
        XCTAssertFalse(viewModel.state.showOpeningPercent)
        XCTAssertEqual(viewModel.state.darkMode, .always)
        XCTAssertEqual(viewModel.state.lockScreenScope, .accounts)
        XCTAssertEqual(viewModel.state.batteryWarningLevel, "25")
    }

    func test_settingChangesAreSavedAndUpdateViewState() {
        viewModel.onChannelHeightChanged(.height150)
        viewModel.onTemperatureUnitChanged(.fahrenheit)
        viewModel.onTemperaturePrecisionChanged(2)
        viewModel.onAutohideButtonsChanged(true)
        viewModel.onChannelInfoChanged(true)
        viewModel.onBottomMenuChanged(false)
        viewModel.onBottomLabelsChanged(false)
        viewModel.onUnavailableChannelsChanged(true)
        viewModel.onOpeningPercentageChanged(false)

        XCTAssertEqual(settings.channelHeightValues, [.height150])
        XCTAssertEqual(groupSharedSettings.temperatureUnitMock.parameters, [.fahrenheit])
        XCTAssertEqual(groupSharedSettings.temperaturePrecisionMock.parameters, [2])
        XCTAssertEqual(settings.autohideButtonsValues, [true])
        XCTAssertEqual(settings.showChannelInfoValues, [true])
        XCTAssertEqual(settings.showBottomMenuValues, [false])
        XCTAssertEqual(settings.showBottomLabelsValues, [false])
        XCTAssertEqual(settings.hideUnavailableChannelsMock.parameters, [true])
        XCTAssertEqual(settings.showOpeningPercentValues, [false])

        XCTAssertEqual(viewModel.state.channelHeight, .height150)
        XCTAssertEqual(viewModel.state.temperatureUnit, .fahrenheit)
        XCTAssertEqual(viewModel.state.temperaturePrecision, 2)
        XCTAssertTrue(viewModel.state.autohideButtons)
        XCTAssertTrue(viewModel.state.showChannelInfo)
        XCTAssertFalse(viewModel.state.showBottomMenu)
        XCTAssertFalse(viewModel.state.showBottomLabels)
        XCTAssertTrue(viewModel.state.hideUnavailableChannels)
        XCTAssertFalse(viewModel.state.showOpeningPercent)
    }

    func test_batteryWarningAcceptsAtMostTwoDigitsAndPreservesEmptyDraft() {
        viewModel.onBatteryWarningLevelChanged("25")
        viewModel.onBatteryWarningLevelChanged("")
        viewModel.onBatteryWarningLevelChanged("123")
        viewModel.onBatteryWarningLevelChanged("x")

        XCTAssertEqual(settings.batteryWarningLevelMock.parameters, [25])
        XCTAssertEqual(viewModel.state.batteryWarningLevel, "")
    }

    func test_lockScreenChangeNavigatesToPinSetupWhenPinIsNotConfigured() {
        viewModel.onLockScreenChanged(.application)

        XCTAssertEqual(router.path, [.pinSetup(scope: .application)])
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }

    func test_lockScreenChangeNavigatesToConfirmationWhenPinIsConfigured() {
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .accounts, pinSum: "sum", biometricAllowed: false)

        viewModel.onLockScreenChanged(.application)

        XCTAssertEqual(router.path, [.lockScreen(action: .confirmAuthorizeApplication)])
        XCTAssertEqual(settings.lockScreenSettingsValues.count, 0)
    }

    func test_lockScreenCanBeTurnedOffThroughPinConfirmation() {
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .application, pinSum: "sum", biometricAllowed: false)

        viewModel.onLockScreenChanged(.none)

        XCTAssertEqual(router.path, [.lockScreen(action: .turnOffPin)])
    }

    func test_navigationActionsUseExistingRoutes() {
        viewModel.onLocationOrdering()
        viewModel.onCarPlaySettings()
        viewModel.onNfcSettings()

        XCTAssertEqual(router.path, [.locationOrdering, .carPlayList, .nfcTagsList])
    }

    func test_refreshPermissionsUpdatesNotificationStatus() {
        notificationCenter.notificationSettings = notificationSettings(status: .authorized)

        let statusUpdated = expectation(description: "Notification permission status updated")
        let statusRevoked = expectation(description: "Notification permission revocation updated")
        var hasReceivedAuthorizedStatus = false
        let cancellable = viewModel.state.$notificationsAllowed
            .dropFirst()
            .sink { allowed in
                if !hasReceivedAuthorizedStatus && allowed {
                    hasReceivedAuthorizedStatus = true
                    statusUpdated.fulfill()
                } else if hasReceivedAuthorizedStatus && !allowed {
                    statusRevoked.fulfill()
                }
            }

        viewModel.refreshPermissions()

        wait(for: [statusUpdated], timeout: 1)
        XCTAssertTrue(viewModel.state.notificationsAllowed)
        notificationCenter.notificationSettings = notificationSettings(status: .denied)
        viewModel.refreshPermissions()

        wait(for: [statusRevoked], timeout: 1)
        XCTAssertFalse(viewModel.state.notificationsAllowed)
        withExtendedLifetime(cancellable) {}
    }

    private func notificationSettings(status: UNAuthorizationStatus) -> UNNotificationSettings {
        let settings = AppSettingsTestUserNotificationSettings(coder: AppSettingsTestCoder())!
        settings.status = status
        return settings
    }
}

private final class AppSettingsTestUserNotificationSettings: UNNotificationSettings {
    var status: UNAuthorizationStatus = .notDetermined

    override var authorizationStatus: UNAuthorizationStatus { status }
}

private final class AppSettingsTestCoder: NSCoder {
    override func decodeInt64(forKey key: String) -> Int64 { 0 }
    override func decodeBool(forKey key: String) -> Bool { false }
}
