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

import CoreLocation
import SwiftUI
import UIKit
import UserNotifications

extension AppSettingsFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<UserNotificationCenter> private var notificationCenter
        @Singleton<GroupShared.Settings> private var groupSettings
        @Singleton<GlobalSettings> private var settings
        @Singleton<AppRouter> private var router

        init() {
            super.init(state: ViewState())
        }

        override func onViewAppear() {
            state.channelHeight = settings.channelHeight
            state.temperatureUnit = groupSettings.temperatureUnit
            state.temperaturePrecision = groupSettings.temperaturePrecision
            state.autohideButtons = settings.autohideButtons
            state.showChannelInfo = settings.showChannelInfo
            state.showBottomMenu = settings.showBottomMenu
            state.showBottomLabels = settings.showBottomLabels
            state.hideUnavailableChannels = settings.hideUnavailableChannels
            state.showOpeningPercent = settings.showOpeningPercent
            state.darkMode = settings.darkMode
            state.lockScreenScope = settings.lockScreenSettings.scope
            state.batteryWarningLevel = String(settings.batteryWarningLevel)
            refreshPermissions()
        }

        func refreshPermissions() {
            notificationCenter.getNotificationSettings { [weak self] permission in
                let allowed: Bool
                switch permission.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    allowed = true
                default:
                    allowed = false
                }
                DispatchQueue.main.async { self?.state.notificationsAllowed = allowed }
            }

            let status = CLLocationManager().authorizationStatus
            state.locationAllowed = status == .authorizedAlways || status == .authorizedWhenInUse
        }

        func onChannelHeightChanged(_ value: ChannelHeight) {
            settings.channelHeight = value
            state.channelHeight = value
        }

        func onTemperatureUnitChanged(_ value: TemperatureUnit) {
            groupSettings.temperatureUnit = value
            state.temperatureUnit = value
        }

        func onTemperaturePrecisionChanged(_ value: Int) {
            groupSettings.temperaturePrecision = value
            state.temperaturePrecision = value
        }

        func onAutohideButtonsChanged(_ value: Bool) {
            settings.autohideButtons = value
            state.autohideButtons = value
        }

        func onChannelInfoChanged(_ value: Bool) {
            settings.showChannelInfo = value
            state.showChannelInfo = value
        }

        func onBottomMenuChanged(_ value: Bool) {
            settings.showBottomMenu = value
            state.showBottomMenu = value
        }

        func onBottomLabelsChanged(_ value: Bool) {
            settings.showBottomLabels = value
            state.showBottomLabels = value
        }

        func onUnavailableChannelsChanged(_ value: Bool) {
            settings.hideUnavailableChannels = value
            state.hideUnavailableChannels = value
        }

        func onOpeningPercentageChanged(_ value: Bool) {
            settings.showOpeningPercent = value
            state.showOpeningPercent = value
        }

        func onNightModeChanged(_ value: DarkModeSetting) {
            settings.darkMode = value
            state.darkMode = value

            let style = value.interfaceStyle
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .foregroundActive })?
                .windows
                .first(where: \.isKeyWindow)?
                .overrideUserInterfaceStyle = style
        }

        func onLockScreenChanged(_ scope: LockScreenScope) {
            updateLockScreen(scope: scope)
        }

        func onBatteryWarningLevelChanged(_ value: String) {
            guard value.count <= 2,
                  CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: value))
            else { return }

            state.batteryWarningLevel = value
            if let level = Int32(value) {
                settings.batteryWarningLevel = level
            }
        }

        func onLocationOrdering() {
            router.navigate(to: .locationOrdering)
        }

        func onCarPlaySettings() {
            router.navigate(to: .carPlayList)
        }

        func onNfcSettings() {
            router.navigate(to: .nfcTagsList)
        }

        func onOpenAppSettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:])
        }

        private func updateLockScreen(scope: LockScreenScope) {
            let lockScreenSettings = settings.lockScreenSettings
            guard lockScreenSettings.scope != scope else { return }
            let pinSum = lockScreenSettings.pinSum

            if scope == .none {
                router.navigate(to: .lockScreen(action: .turnOffPin))
            } else if pinSum != nil && scope == .accounts {
                router.navigate(to: .lockScreen(action: .confirmAuthorizeAccounts))
            } else if pinSum != nil && scope == .application {
                router.navigate(to: .lockScreen(action: .confirmAuthorizeApplication))
            } else {
                router.navigate(to: .pinSetup(scope: scope))
            }
        }
    }
}
