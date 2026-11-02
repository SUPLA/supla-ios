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

extension MainFeature {
    struct MainDrawer: SwiftUI.View {
        struct Configuration: Equatable {
            let showMainTabs: Bool
            let selectedTab: MainTab
            let zWaveVisible: Bool
            let deviceCatalogVisible: Bool
            let helpVisible: Bool
            let aboutVisible: Bool
            let developerOptionsVisible: Bool
        }

        enum Item: Hashable {
            case channels
            case groups
            case scenes
            case profiles
            case settings
            case addDevice
            case zWave
            case deviceCatalog
            case notifications
            case cloud
            case help
            case about
            case developerOptions
            case homepage
        }

        let configuration: Configuration
        let onClose: () -> Void
        let onItemTap: (Item) -> Void

        var body: some SwiftUI.View {
            VStack(spacing: 0) {
                SuplaCore.TopBar(
                    navigationIcon: .back,
                    title: Strings.appName,
                    onNavigationIconTap: onClose
                )

                ScrollView {
                    VStack(spacing: 0) {
                        if configuration.showMainTabs {
                            tabItems
                            divider
                        }

                        drawerItem(.profiles)
                        drawerItem(.settings)
                        divider

                        drawerItem(.addDevice)
                        if configuration.zWaveVisible {
                            drawerItem(.zWave)
                        }
                        if configuration.deviceCatalogVisible {
                            drawerItem(.deviceCatalog)
                        }
                        drawerItem(.notifications)
                        divider

                        drawerItem(.cloud)
                        if configuration.helpVisible {
                            drawerItem(.help)
                        }
                        if configuration.aboutVisible {
                            drawerItem(.about)
                        }
                        if configuration.developerOptionsVisible {
                            drawerItem(.developerOptions)
                        }

                        homepageButton
                    }
                    .padding(.top, Distance.small)
                    .padding(.bottom, Distance.default)
                }
            }
            .background(Color.Supla.surface)
        }

        private var tabItems: some SwiftUI.View {
            Group {
                drawerItem(.channels, selected: configuration.selectedTab == .channels)
                drawerItem(.groups, selected: configuration.selectedTab == .groups)
                drawerItem(.scenes, selected: configuration.selectedTab == .scenes)
            }
        }

        private var divider: some SwiftUI.View {
            Rectangle()
                .fill(Color.Supla.outline)
                .frame(height: 1)
                .padding(.vertical, Distance.small)
        }

        private var homepageButton: some SwiftUI.View {
            Button(action: { onItemTap(.homepage) }) {
                Text(Item.homepage.title)
                    .fontLabelMedium()
                    .foregroundColor(.Supla.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, Distance.small)
        }

        private func drawerItem(_ item: Item, selected: Bool = false) -> some SwiftUI.View {
            Button(action: { onItemTap(item) }) {
                HStack(spacing: Distance.default) {
                    icon(for: item)
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)

                    Text(item.title)
                        .fontLabelMedium()
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.Supla.onBackground)
                .frame(height: 48)
                .padding(.horizontal, Distance.default)
                .background {
                    if selected {
                        Capsule()
                            .fill(Color.Supla.surfaceVariant)
                            .padding(.horizontal, Distance.tiny)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }

        @ViewBuilder
        private func icon(for item: Item) -> some SwiftUI.View {
            if let icon = item.icon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

private extension MainFeature.MainDrawer.Item {
    var title: String {
        switch self {
        case .channels:
            Strings.Main.channels
        case .groups:
            Strings.Main.groups
        case .scenes:
            Strings.Main.scenes
        case .profiles:
            NSLocalizedString("Your accounts", comment: "")
        case .settings:
            NSLocalizedString("Settings", comment: "")
        case .addDevice:
            NSLocalizedString("Add I/O device", comment: "")
        case .zWave:
            NSLocalizedString("Z-Wave bridge", comment: "")
        case .deviceCatalog:
            Strings.DeviceCatalog.menu
        case .notifications:
            Strings.Notifications.menu
        case .cloud:
            NSLocalizedString("Supla Cloud", comment: "")
        case .help:
            NSLocalizedString("Help", comment: "")
        case .about:
            NSLocalizedString("About", comment: "")
        case .developerOptions:
            Strings.DeveloperInfo.title
        case .homepage:
            "www.supla.org"
        }
    }

    var icon: UIImage? {
        switch self {
        case .channels:
            UIImage.iconList
        case .groups:
            UIImage(named: "bottom_bar_groups")
        case .scenes:
            UIImage(named: "coffee")
        case .profiles:
            UIImage(named: "Menu/icon_profile")
        case .settings:
            UIImage(named: "Menu/icon_settings")
        case .addDevice:
            UIImage(named: "Menu/icon_add_device")
        case .zWave:
            UIImage(named: "Menu/icon_z_wave")
        case .deviceCatalog:
            UIImage(named: "Menu/icon_device_catalog")
        case .notifications:
            UIImage(named: "icon_notification")
        case .cloud:
            UIImage(named: "Menu/icon_cloud")
        case .help:
            UIImage(named: "Menu/icon_help")
        case .about:
            UIImage(named: "Menu/icon_about")
        case .developerOptions:
            UIImage(named: "Menu/icon_dev_option")
        case .homepage:
            nil
        }
    }
}

#Preview {
    MainFeature.MainDrawer(
        configuration: .init(
            showMainTabs: true,
            selectedTab: .channels,
            zWaveVisible: true,
            deviceCatalogVisible: true,
            helpVisible: true,
            aboutVisible: true,
            developerOptionsVisible: true
        ),
        onClose: {},
        onItemTap: { _ in }
    )
    .frame(width: 320)
}

#Preview("without main tabs") {
    MainFeature.MainDrawer(
        configuration: .init(
            showMainTabs: false,
            selectedTab: .channels,
            zWaveVisible: true,
            deviceCatalogVisible: true,
            helpVisible: true,
            aboutVisible: true,
            developerOptionsVisible: true
        ),
        onClose: {},
        onItemTap: { _ in }
    )
    .frame(width: 320)
}
