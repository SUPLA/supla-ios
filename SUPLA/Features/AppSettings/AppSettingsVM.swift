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
    
    override func defaultViewState() -> AppSettingsViewState { AppSettingsViewState(list: []) }
    
    override func onViewDidLoad() {
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
        var settings = self.settings
        return .preferences(items: [
            .heightItem(
                channelHeight: settings.channelHeight,
                callback: { self.updateChannelHeight(selectedItem: $0) }
            ),
            .temperatureUnitItem(
                temperatureUnit: settings.temperatureUnit,
                callback: { self.updateTemperatureUnit(selectedItem: $0) }
            ),
            .switchItem(
                title: Strings.Cfg.buttonAutoHide,
                selected: settings.autohideButtons,
                callback: { settings.autohideButtons = $0 }
            ),
            .switchItem(
                title: Strings.Cfg.showChannelInfo,
                selected: settings.showChannelInfo,
                callback: { settings.showChannelInfo = $0 }
            ),
            .switchItem(
                title: Strings.AppSettings.showLabels,
                selected: settings.showBottomLabels,
                callback: { settings.showBottomLabels = $0 }
            ),
            .rsOpeningPercentageItem(
                opening: settings.showOpeningPercent,
                callback: { settings.showOpeningPercent = $0 }
            ),
            .arrowButtonItem(
                title: Strings.Cfg.locationOrdering,
                callback: { self.send(event: .navigateToLocationOrdering) }
            )
        ])
    }
    
    private func createPermissionsList(_ notificationsAllowed: Bool) -> SettingsList {
        return .permissions(items: [
            .permissionItem(
                title: Strings.AppSettings.notificationsLabel,
                active: notificationsAllowed,
                callback: { self.send(event: .navigateToAppPreferences) }
            )
        ])
    }
    
    private func updateChannelHeight(selectedItem: Int) {
        var settings = settings
        if let height = ChannelHeight.allCases.enumerated().first(where: { (i, _) in i == selectedItem })?.element {
            settings.channelHeight = height
        }
    }
    
    private func updateTemperatureUnit(selectedItem: Int) {
        var settings = settings
        if let unit = TemperatureUnit.allCases.enumerated().first(where: { (i, _) in i == selectedItem })?.element {
            settings.temperatureUnit = unit
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
    case switchItem(title: String, selected: Bool, callback: (Bool) -> Void)
    case rsOpeningPercentageItem(opening: Bool, callback: (Bool) -> Void)
    case arrowButtonItem(title: String, callback: () -> Void)
    case permissionItem(title: String, active: Bool, callback: () -> Void)
    
    static func == (lhs: SettingsListItem, rhs: SettingsListItem) -> Bool {
        switch (lhs, rhs) {
        case (.heightItem(let lHeight, _), .heightItem(let rHeight, _)):
            return lHeight == rHeight
        case (.temperatureUnitItem(let lUnit, _), .temperatureUnitItem(let rUnit, _)):
            return lUnit == rUnit
        case (.switchItem(let lTitle, let lValue, _), .switchItem(let rTitle, let rValue, _)):
            return lTitle == rTitle && lValue == rValue
        case (.rsOpeningPercentageItem(let lValue, _), .rsOpeningPercentageItem(let rValue, _)):
            return lValue == rValue
        case (.arrowButtonItem(let lValue, _), .arrowButtonItem(let rValue, _)):
            return lValue == rValue
        case (.permissionItem(let lTitle, let lValue, _), .permissionItem(let rTitle, let rValue, _)):
            return lTitle == rTitle && lValue == rValue
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
    case navigateToLocationOrdering
    case navigateToAppPreferences
}

struct AppSettingsViewState: ViewState {
    var list: [SettingsList]
}
