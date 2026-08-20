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

import SharedCore
import SwiftUI

struct MainListItemView: SwiftUI.View {
    let item: MainListItem
    let onInfoClick: () -> Void
    let onIssueClick: (ListItemIssues) -> Void
    let onTitleLongClick: () -> Void
    let onItemClick: () -> Void
    let onLocationClick: () -> Void
    let onLocationLongClick: () -> Void

    init(
        item: MainListItem,
        onInfoClick: @escaping () -> Void = {},
        onIssueClick: @escaping (ListItemIssues) -> Void = { _ in },
        onTitleLongClick: @escaping () -> Void = {},
        onItemClick: @escaping () -> Void = {},
        onLocationClick: @escaping () -> Void = {},
        onLocationLongClick: @escaping () -> Void = {}
    ) {
        self.item = item
        self.onInfoClick = onInfoClick
        self.onIssueClick = onIssueClick
        self.onTitleLongClick = onTitleLongClick
        self.onItemClick = onItemClick
        self.onLocationClick = onLocationClick
        self.onLocationLongClick = onLocationLongClick
    }

    var body: some SwiftUI.View {
        switch (item) {
        case .scene(let item):
            SceneListItemView(
                item: item,
                onInfoClick: onInfoClick,
                onIssueClick: onIssueClick,
                onTitleLongClick: onTitleLongClick,
                onItemClick: onItemClick
            )
        case .location(let item):
            LocationListItemView(
                caption: item.userCaption,
                collapsed: CollapsedFlag.channel.isCollapsed(item.collapsed),
                inSearch: false,
                onClick: onLocationClick,
                onLongClick: onLocationLongClick
            )
        case .channel(let item), .group(let item):
            IconValueListItemView(
                item: item,
                onInfoClick: onInfoClick,
                onIssueClick: onIssueClick,
                onTitleLongClick: onTitleLongClick,
                onItemClick: onItemClick
            )
        case .hvacThermostat(let item):
            ThermostatListItemView(
                item: item,
                onInfoClick: onInfoClick,
                onIssueClick: onIssueClick,
                onTitleLongClick: onTitleLongClick,
                onItemClick: onItemClick
            )
        case .heatpolThermostat(let item):
            HeatpolThermostatListItemView(
                item: item,
                onInfoClick: onInfoClick,
                onIssueClick: onIssueClick,
                onTitleLongClick: onTitleLongClick,
                onItemClick: onItemClick
            )
        case .doubleValue(let item):
            DoubleIconValueListItemView(
                item: item,
                onInfoClick: onInfoClick,
                onIssueClick: onIssueClick,
                onTitleLongClick: onTitleLongClick,
                onItemClick: onItemClick
            )
        }
    }
}
