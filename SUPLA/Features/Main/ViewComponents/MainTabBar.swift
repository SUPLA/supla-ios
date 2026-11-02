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
    struct MainTabBar: SwiftUI.View {
        @Binding var selectedTab: MainTab

        let axis: Axis
        let showLabels: Bool

        private let tabs: [MainTab] = [.channels, .groups, .scenes]
        private var tabItemHeight: CGFloat {
            showLabels ? 56 : Dimens.iconSize + Distance.tiny * 2
        }

        var body: some SwiftUI.View {
            Group {
                switch axis {
                case .horizontal:
                    HStack(spacing: 0) {
                        tabItems
                    }
                    .frame(height: tabItemHeight)

                case .vertical:
                    VStack(spacing: 0) {
                        tabItems
                        Spacer(minLength: 0)
                    }
                    .frame(width: 84)
                }
            }
            .background(Color.Supla.surface)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.Supla.outline)
                    .frame(height: 1)
            }
        }

        private var tabItems: some SwiftUI.View {
            ForEach(tabs, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: Distance.tiny) {
                        Image(uiImage: tab.icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        if (showLabels) {
                            Text(tab.title)
                                .fontLabelSmall()
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: tabItemHeight)
                    .foregroundColor(selectedTab == tab ? .Supla.primary : .Supla.onBackground)
                    .contentShape(Rectangle())
                }
            }
        }
    }
}

private extension MainTab {
    var title: String {
        switch self {
        case .channels: Strings.Main.channels
        case .groups: Strings.Main.groups
        case .scenes: Strings.Main.scenes
        }
    }

    var icon: UIImage {
        switch self {
        case .channels: .iconList!
        case .groups: UIImage(named: "bottom_bar_groups")!
        case .scenes: UIImage(named: "coffee")!
        }
    }
}
