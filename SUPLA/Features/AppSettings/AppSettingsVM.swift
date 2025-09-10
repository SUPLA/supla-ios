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
import RxCocoa
import RxDataSources
import RxSwift
import UserNotifications

class AppSettingsVM: BaseViewModel<AppSettingsViewState, AppSettingsViewEvent> {
    @Singleton<GlobalSettings> private var settings
    @Singleton<UserNotificationCenter> private var notificationCenter
    @Singleton<SuplaAppCoordinator> private var coordinator
    @Singleton<GroupShared.Settings> private var groupSettings
    
    override func defaultViewState() -> AppSettingsViewState { AppSettingsViewState(list: []) }
    
    override func onViewWillAppear() {
        createListObservable()
            .asDriverWithoutError()
            .drive(onNext: { list in
                self.updateView { $0.changing(path: \.list, to: list) }
            })
            .disposed(by: self)
    }
    
    private func createListObservable() -> Observable<[SettingsList]> {
        .create { observer in
            self.notificationCenter.getNotificationSettings { permission in
                var notificationsAllowed = false
                switch permission.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    notificationsAllowed = true
                default:
                    break
                }
                
                observer.onNext([
                    self.createPreferencesList(),
                    self.createPermissionsList(notificationsAllowed)
                ])
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }
    
    private func createPreferencesList() -> SettingsList {
        return .preferences(items: [
            .heightItem(
                channelHeight: settings.channelHeight,
                callback: { [weak self] in self?.updateChannelHeight(selectedItem: $0) }
            ),
            .temperatureUnitItem(
                temperatureUnit: groupSettings.temperatureUnit,
                callback: { [weak self] in self?.updateTemperatureUnit(selectedItem: $0) }
            ),
            .temperaturePrecisionItem(
                precision: groupSettings.temperaturePrecision,
                callback: { [weak self] in self?.updateTemperaturePrecision(selectedItem: $0) }
            ),
            .switchItem(
                title: Strings.Cfg.buttonAutoHide,
                selected: settings.autohideButtons,
                callback: { [weak self] in self?.settings.autohideButtons = $0 }
            ),
            .switchItem(
                title: Strings.Cfg.showChannelInfo,
                selected: settings.showChannelInfo,
                callback: { [weak self] in self?.settings.showChannelInfo = $0 }
            ),
            .switchItem(
                title: Strings.AppSettings.showBottomMenu,
                selected: settings.showBottomMenu,
                callback: { [weak self] in self?.settings.showBottomMenu = $0 }
            ),
            .switchItem(
                title: Strings.AppSettings.showLabels,
                selected: settings.showBottomLabels,
                callback: { [weak self] in self?.settings.showBottomLabels = $0 }
            ),
            .rsOpeningPercentageItem(
                opening: settings.showOpeningPercent,
                callback: { [weak self] in self?.settings.showOpeningPercent = $0 }
            ),
            .darkModeItem(
                darkModeSetting: settings.darkMode,
                callback: { [weak self] in
                    self?.settings.darkMode = $0
                    self?.send(event: .changeInterfaceStyle(style: $0.interfaceStyle))
                }
            ),
            .lockScreenItem(
                lockScreenScope: settings.lockScreenSettings.scope,
                callback: { [weak self] in self?.updateLockScreen(scope: $0) }
            ),
            .batteryLevelWarning(
                level: settings.batteryWarningLevel,
                callback: { [weak self] in self?.settings.batteryWarningLevel = $0 }
            ),
            .arrowButtonItem(
                title: Strings.Cfg.locationOrdering,
                callback: { [weak self] in self?.coordinator.navigateToLocationOrdering() }
            ),
            .arrowButtonItem(
                title: Strings.CarPlay.label,
                callback: { [weak self] in self?.coordinator.navigateToCarPlayList()}
            )
        ])
    }
    
    private func createPermissionsList(_ notificationsAllowed: Bool) -> SettingsList {
        return .permissions(items: [
            .permissionItem(
                title: Strings.AppSettings.notificationsLabel,
                active: notificationsAllowed,
                callback: { [weak self] in self?.send(event: .navigateToAppPreferences) }
            )
        ])
    }
    
    private func updateChannelHeight(selectedItem: Int) {
        if let height = ChannelHeight.allCases.enumerated().first(where: { (i, _) in i == selectedItem })?.element {
            settings.channelHeight = height
        }
    }
    
    private func updateTemperatureUnit(selectedItem: Int) {
        if let unit = TemperatureUnit.allCases.enumerated().first(where: { (i, _) in i == selectedItem })?.element {
            groupSettings.temperatureUnit = unit
        }
    }
    
    private func updateTemperaturePrecision(selectedItem: Int) {
        groupSettings.temperaturePrecision = selectedItem + 1
    }
    
    private func updateLockScreen(scope: LockScreenScope) {
        let lockScreenSettings = settings.lockScreenSettings
        if (lockScreenSettings.scope == scope) {
            return // No change
        }
        let pinSum = lockScreenSettings.pinSum
        
        if (scope == .none) {
            coordinator.navigateToLockScreen(unlockAction: .turnOffPin)
        } else if (pinSum != nil && scope == .accounts) {
            coordinator.navigateToLockScreen(unlockAction: .confirmAuthorizeAccounts)
        } else if (pinSum != nil && scope == .application) {
            coordinator.navigateToLockScreen(unlockAction: .confirmAuthorizeApplication)
        } else {
            coordinator.navigateToPinSetup(lockScreenScope: scope)
        }
    }
}

enum SettingsList: Equatable {
    case preferences(items: [SettingsListItem])
    case permissions(items: [SettingsListItem])
}

enum SettingsListItem: Equatable {
    case heightItem(channelHeight: ChannelHeight, callback: (Int) -> Void)
    case temperatureUnitItem(temperatureUnit: TemperatureUnit, callback: (Int) -> Void)
    case temperaturePrecisionItem(precision: Int, callback: (Int) -> Void)
    case switchItem(title: String, selected: Bool, callback: (Bool) -> Void, enabled: Bool = true)
    case rsOpeningPercentageItem(opening: Bool, callback: (Bool) -> Void)
    case arrowButtonItem(title: String, callback: () -> Void)
    case permissionItem(title: String, active: Bool, callback: () -> Void)
    case darkModeItem(darkModeSetting: DarkModeSetting, callback: (DarkModeSetting) -> Void)
    case lockScreenItem(lockScreenScope: LockScreenScope, callback: (LockScreenScope) -> Void)
    case batteryLevelWarning(level: Int32, callback: (Int32) -> Void)
    
    static func == (lhs: SettingsListItem, rhs: SettingsListItem) -> Bool {
        switch (lhs, rhs) {
        case (.heightItem(let lHeight, _), .heightItem(let rHeight, _)):
            return lHeight == rHeight
        case (.temperatureUnitItem(let lUnit, _), .temperatureUnitItem(let rUnit, _)):
            return lUnit == rUnit
        case (.temperaturePrecisionItem(let lUnit, _), .temperaturePrecisionItem(let rUnit, _)):
            return lUnit == rUnit
        case (.switchItem(let lTitle, let lValue, _, _), .switchItem(let rTitle, let rValue, _, _)):
            return lTitle == rTitle && lValue == rValue
        case (.rsOpeningPercentageItem(let lValue, _), .rsOpeningPercentageItem(let rValue, _)):
            return lValue == rValue
        case (.arrowButtonItem(let lValue, _), .arrowButtonItem(let rValue, _)):
            return lValue == rValue
        case (.permissionItem(let lTitle, let lValue, _), .permissionItem(let rTitle, let rValue, _)):
            return lTitle == rTitle && lValue == rValue
        case (.darkModeItem(let leftSetting, _), .darkModeItem(let rightSetting, _)):
            return leftSetting == rightSetting
        case (.lockScreenItem(let leftScope, _), .lockScreenItem(let rightScope, _)):
            return leftScope == rightScope
        case (.batteryLevelWarning(let leftLevel, _), .batteryLevelWarning(let rightLevel, _)):
            return leftLevel == rightLevel
        default:
            return false
        }
    }
}

extension SettingsList: SectionModelType {
    typealias Item = SettingsListItem
    
    var items: [SettingsListItem] {
        switch self {
        case .preferences(let items):
            return items.map { $0 }
        case .permissions(let items):
            return items.map { $0 }
        }
    }
    
    init(original: SettingsList, items: [SettingsListItem]) {
        switch original {
        case .preferences(let items):
            self = .preferences(items: items)
        case .permissions(let items):
            self = .permissions(items: items)
        }
    }
}

enum AppSettingsViewEvent: ViewEvent {
    case navigateToAppPreferences
    case changeInterfaceStyle(style: UIUserInterfaceStyle)
}

struct AppSettingsViewState: ViewState {
    var list: [SettingsList]
}
