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

import XCTest
import RxTest
import RxSwift

@testable import SUPLA

class AppSettingsVMTests: ViewModelTest<AppSettingsViewState, AppSettingsViewEvent> {
    
    private lazy var viewModel: AppSettingsVM! = { AppSettingsVM() }()
    
    private lazy var settings: GlobalSettingsMock! = {
        GlobalSettingsMock()
    }()
    private lazy var notificationCenter: UserNotificationCenterMock! = {
        UserNotificationCenterMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: UserNotificationCenter.self, notificationCenter!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        settings = nil
        notificationCenter = nil
        
        super.tearDown()
    }
    
    func test_shoudCreateSettingsListWithLoadedSettings_notificationsAuthorized() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
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
                .heightItem(channelHeight: .height100, callback: {_ in }),
                .temperatureUnitItem(temperatureUnit: .fahrenheit, callback: {_ in }),
                .switchItem(title: Strings.Cfg.buttonAutoHide, selected: true, callback: {_ in }),
                .switchItem(title: Strings.Cfg.showChannelInfo, selected: false, callback: {_ in }),
                .rsOpeningPercentageItem(opening: true, callback: {_ in }),
                .arrowButtonItem(title: Strings.Cfg.locationOrdering, callback: {})
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
        viewModel.onViewDidLoad()
        
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
                .heightItem(channelHeight: .height150, callback: {_ in }),
                .temperatureUnitItem(temperatureUnit: .celsius, callback: {_ in }),
                .switchItem(title: Strings.Cfg.buttonAutoHide, selected: false, callback: {_ in }),
                .switchItem(title: Strings.Cfg.showChannelInfo, selected: true, callback: {_ in }),
                .rsOpeningPercentageItem(opening: false, callback: {_ in }),
                .arrowButtonItem(title: Strings.Cfg.locationOrdering, callback: {})
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
        viewModel.onViewDidLoad()
        
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
        XCTAssertEqual(settings.temperatureUnitValues.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
    }
    
    func test_shouldSaveTemperatureUnit() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
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
        XCTAssertEqual(settings.temperatureUnitValues[0], .celsius)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
    }
    
    func test_shouldSaveButtonAutoHide() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[2]) {
        case .switchItem(_, _, let callback):
            callback(true)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(settings.temperatureUnitValues.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues[0], true)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
    }
    
    func test_shouldSaveShowChannelInfo() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[3]) {
        case .switchItem(_, _, let callback):
            callback(false)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(settings.temperatureUnitValues.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues[0], false)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
    }
    
    func test_shouldSaveOpeningClosingPercentage() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[4]) {
        case .rsOpeningPercentageItem(_, let callback):
            callback(true)
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(settings.temperatureUnitValues.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues[0], true)
    }
    
    func test_shouldNavigateToLocationOrdering() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
        guard let list = stateObserver.events[1].value.element?.list
        else {
            XCTFail("No list")
            return
        }
        
        switch (list[0].items[5]) {
        case .arrowButtonItem(_, let callback):
            callback()
        default:
            XCTFail("No list")
        }
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events, [.next(0, .navigateToLocationOrdering)])
        XCTAssertEqual(settings.channelHeightValues.count, 0)
        XCTAssertEqual(settings.temperatureUnitValues.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
    }
    
    func test_shouldNavigateToAppPreferences() {
        // given
        setupViewData()
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
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
        XCTAssertEqual(settings.temperatureUnitValues.count, 0)
        XCTAssertEqual(settings.autohideButtonsValues.count, 0)
        XCTAssertEqual(settings.showChannelInfoValues.count, 0)
        XCTAssertEqual(settings.showOpeningPercentValues.count, 0)
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
        settings.temperatureUnitReturns = temperatureUnit
        settings.autohideButtonsReturns = autoHide
        settings.showChannelInfoReturns = infoButtons
        settings.showOpeningPercentReturns = showOpening
        let notificationSettings = AppSettingsTestUserNotificationSettings(coder: AppSettingsTestCoder())!
        notificationSettings.status = notificationStatus
        notificationCenter.notificationSettings = notificationSettings
    }
}

class AppSettingsTestUserNotificationSettings: UNNotificationSettings {
    
    var status: UNAuthorizationStatus = .notDetermined
    
    override var authorizationStatus: UNAuthorizationStatus {
        get { status }
    }
}


class AppSettingsTestCoder: NSCoder {
    override func decodeInt64(forKey key: String) -> Int64 { 0 }
    override func decodeBool(forKey key: String) -> Bool { false }
}
