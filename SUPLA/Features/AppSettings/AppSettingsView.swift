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

import SwiftUI

extension AppSettingsFeature {

    protocol ViewDelegate {
        func onChannelHeightChanged(_ value: ChannelHeight)
        func onTemperatureUnitChanged(_ value: TemperatureUnit)
        func onTemperaturePrecisionChanged(_ value: Int)
        func onAutohideButtonsChanged(_ value: Bool)
        func onChannelInfoChanged(_ value: Bool)
        func onBottomMenuChanged(_ value: Bool)
        func onBottomLabelsChanged(_ value: Bool)
        func onUnavailableChannelsChanged(_ value: Bool)
        func onOpeningPercentageChanged(_ value: Bool)
        func onNightModeChanged(_ value: DarkModeSetting)
        func onLockScreenChanged(_ scope: LockScreenScope)
        func onBatteryWarningLevelChanged(_ value: String)
        func onLocationOrdering()
        func onCarPlaySettings()
        func onNfcSettings()
        func onOpenAppSettings()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: AppSettingsFeature.ViewState
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            ScrollView {
                VStack(alignment: .leading, spacing: Distance.default) {
                    appearanceSection
                    channelListSection
                    securitySection
                    integrationsSection
                    permissionsSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, Distance.default)
            }
        }

        private var appearanceSection: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                SettingsView.Header(Strings.AppSettings.appearance)
                SettingsView.Block {
                    SettingsView.ChannelHeightItem(
                        label: Strings.Cfg.channelHeight,
                        selected: viewState.channelHeight,
                        onChange: { delegate?.onChannelHeightChanged($0) }
                    )
                    SettingsView.SegmentedItem(
                        label: Strings.Cfg.temperatureUnit,
                        options: TemperatureUnit.allCases.map { $0.valueUnit.text },
                        selectedIndex: viewState.temperatureUnit == .celsius ? 0 : 1,
                        onChange: { delegate?.onTemperatureUnitChanged(TemperatureUnit.allCases[$0]) }
                    )
                    SettingsView.SegmentedItem(
                        label: Strings.AppSettings.temperaturePrecision,
                        options: temperaturePrecisionOptions,
                        selectedIndex: viewState.temperaturePrecision - 1,
                        onChange: { delegate?.onTemperaturePrecisionChanged($0 + 1) }
                    )
                    SettingsView.SegmentedItem(
                        label: Strings.Cfg.rsDisplayMode,
                        options: [Strings.Cfg.showOpeningModeOpening, Strings.Cfg.showOpeningModeClosing],
                        selectedIndex: viewState.showOpeningPercent ? 0 : 1,
                        onChange: { delegate?.onOpeningPercentageChanged($0 == 0) }
                    )
                    SettingsView.SegmentedItem(
                        label: Strings.AppSettings.nightMode,
                        options: [Strings.General.yes, Strings.General.no, Strings.General.auto],
                        selectedIndex: nightModeIndex,
                        onChange: { delegate?.onNightModeChanged(DarkModeSetting.from($0 + 1)) }
                    )
                    batteryWarningItem
                    SettingsView.NavigationItem(
                        label: Strings.Cfg.locationOrdering,
                        onClick: { delegate?.onLocationOrdering() }
                    )
                }
            }
        }

        private var channelListSection: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                SettingsView.Header(Strings.AppSettings.channelList)
                SettingsView.Block {
                    checkbox(Strings.Cfg.buttonAutoHide, value: \ViewState.autohideButtons, action: { delegate?.onAutohideButtonsChanged($0) })
                    checkbox(Strings.Cfg.showChannelInfo, value: \ViewState.showChannelInfo, action: { delegate?.onChannelInfoChanged($0) })
                    checkbox(Strings.AppSettings.showBottomMenu, value: \ViewState.showBottomMenu, action: { delegate?.onBottomMenuChanged($0) })
                    checkbox(Strings.AppSettings.showLabels, value: \ViewState.showBottomLabels, action: { delegate?.onBottomLabelsChanged($0) })
                    checkbox(Strings.AppSettings.hideUnavailableChannels, value: \ViewState.hideUnavailableChannels, action: { delegate?.onUnavailableChannelsChanged($0) })
                }
            }
        }

        private var securitySection: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                SettingsView.Header(Strings.AppSettings.security)
                SettingsView.Block {
                    SettingsView.SegmentedItem(
                        label: Strings.AppSettings.lockScreen,
                        options: [Strings.AppSettings.lockScreenNone, Strings.AppSettings.lockScreenApp, Strings.AppSettings.lockScreenAccounts],
                        selectedIndex: viewState.lockScreenScope.rawValue,
                        onChange: { delegate?.onLockScreenChanged(LockScreenScope.from($0)) }
                    )
                }
            }
        }

        private var integrationsSection: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                SettingsView.Header(Strings.AppSettings.integrations)
                SettingsView.Block {
                    SettingsView.NavigationItem(label: BrandingConfiguration.actionsLabel, onClick: { delegate?.onCarPlaySettings() })
                    SettingsView.NavigationItem(label: Strings.Nfc.label, onClick: { delegate?.onNfcSettings() })
                }
            }
        }

        private var permissionsSection: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                SettingsView.Header(Strings.AppSettings.permissionsHeader)
                SettingsView.Block {
                    SettingsView.NavigationItem(
                        label: Strings.AppSettings.notificationsLabel,
                        value: viewState.notificationsAllowed ? "✓" : "𐄂",
                        valueColor: viewState.notificationsAllowed ? .Supla.primary : .Supla.error,
                        onClick: { delegate?.onOpenAppSettings() }
                    )
                    SettingsView.NavigationItem(
                        label: Strings.AppSettings.locationLabel,
                        value: viewState.locationAllowed ? "✓" : "𐄂",
                        valueColor: viewState.locationAllowed ? .Supla.primary : .Supla.error,
                        onClick: { delegate?.onOpenAppSettings() }
                    )
                }
            }
        }

        private var batteryWarningItem: some SwiftUI.View {
            SettingsView.TextFieldItem(
                label: Strings.AppSettings.batteryLevelWarning,
                value: Binding(
                    get: { viewState.batteryWarningLevel },
                    set: { delegate?.onBatteryWarningLevelChanged($0) }
                ),
                prefix: "<",
                suffix: "%",
                width: 112
            )
        }

        private var temperaturePrecisionOptions: [String] {
            let separator = Locale.current.decimalSeparator ?? ","
            return ["0\(separator)0°", "0\(separator)00°"]
        }

        private var nightModeIndex: Int {
            viewState.darkMode == .unset ? 1 : viewState.darkMode.rawValue - 1
        }

        private func checkbox(
            _ label: String,
            value keyPath: ReferenceWritableKeyPath<ViewState, Bool>,
            action: @escaping (Bool) -> Void
        ) -> some SwiftUI.View {
            SettingsView.ItemWithCheckbox(
                label: label,
                checked: Binding(
                    get: { viewState[keyPath: keyPath] },
                    set: action
                ),
                padding: SettingsView.pickerDefaultPadding
            )
        }
    }

}

extension SettingsView {
    struct ChannelHeightItem: View {
        let label: String
        let selected: ChannelHeight
        let onChange: (ChannelHeight) -> Void

        var body: some View {
            SettingsView.VerticalRow(spacing: Distance.tiny) {
                SettingsView.Label(label)
                HStack(spacing: Distance.small) {
                    ForEach(ChannelHeight.allCases, id: \.rawValue) { height in
                        heightButton(height)
                    }
                }
            }
        }

        private func heightButton(_ height: ChannelHeight) -> some View {
            let isSelected = height == selected
            let details = heightDetails(height)

            return Button { onChange(height) } label: {
                VStack(spacing: 0) {
                    Image(details.image)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(height: 28)
                        .foregroundColor(isSelected ? .Supla.primary : .Supla.onBackground)
                    Text(details.title)
                        .fontBodySmall()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .textColor(.Supla.onBackground)
                }
                .frame(maxWidth: .infinity, minHeight: 36)
                .padding(.horizontal, Distance.small)
                .padding(.top, 2)
                .padding(.bottom, Distance.tiny)
                .background(isSelected ? Color.Supla.primary.opacity(0.05) : Color.Supla.background)
                .clipShape(RoundedRectangle(cornerRadius: Dimens.radiusDefault))
                .overlay {
                    RoundedRectangle(cornerRadius: Dimens.radiusDefault)
                        .stroke(isSelected ? Color.Supla.primary : Color.Supla.outline)
                }
            }
            .buttonStyle(.plain)
        }

        private func heightDetails(_ height: ChannelHeight) -> (title: String, image: String) {
            switch height {
            case .height60: (Strings.AppSettings.channelHeightCompact, "channel_height_small")
            case .height100: (Strings.AppSettings.channelHeightStandard, "channel_height_normal")
            case .height150: (Strings.AppSettings.channelHeightLarge, "channel_height_big")
            }
        }
    }
}

#Preview {
    let state = AppSettingsFeature.ViewState()
    state.channelHeight = .height100
    state.temperatureUnit = .celsius
    state.temperaturePrecision = 1
    state.autohideButtons = true
    state.showChannelInfo = true
    state.showBottomMenu = true
    state.showBottomLabels = false
    state.hideUnavailableChannels = true
    state.showOpeningPercent = true
    state.darkMode = .auto
    state.lockScreenScope = .application
    state.batteryWarningLevel = "10"
    state.notificationsAllowed = true
    state.locationAllowed = false

    return ZStack() {
        Color.Supla.background.ignoresSafeArea()
        AppSettingsFeature.View(viewState: state, delegate: nil)
    }
}
