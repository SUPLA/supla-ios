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

struct HeatpolThermostatListItemView: View {
    @Environment(\.scaleFactor) private var scaleFactor
    @Environment(\.showChannelInfo) private var showChannelInfo

    let item: HeatpolThermostatListItem
    let onInfoClick: () -> Void
    let onIssueClick: (ListItemIssues) -> Void
    let onTitleLongClick: () -> Void
    let onItemClick: () -> Void

    var body: some View {
        ListItemScaffold(
            itemTitle: item.base.title,
            itemEstimatedEndDate: item.base.estimatedTimerEndDate,
            issues: item.base.issues,
            statusIndicator: ListItemStatusIndicator(
                status: item.base.status,
                hasLeftButton: item.base.leftButtonTitle != nil,
                hasRightButton: item.base.rightButtonTitle != nil
            ),
            showInfoIcon: showChannelInfo && item.base.infoSupported,
            onInfoClick: onInfoClick,
            onIssueClick: onIssueClick,
            onTitleLongClick: onTitleLongClick,
            onItemClick: onItemClick
        ) {
            ListItemMainRow {
                ListItemIcon(iconResult: item.base.icon)
                if (scaleFactor <= 1) {
                    HStack(alignment: .bottom, spacing: 0) {
                        ListItemValue(value: item.base.value ?? "")
                        if (item.base.status.online) {
                            SetpointTemperature(subValue: "/\(item.subValue)")
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ListItemValue(value: item.base.value ?? "")
                        if (item.base.status.online) {
                            SetpointTemperature(subValue: item.subValue)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 1) {
        HeatpolThermostatListItemView(
            item: HeatpolThermostatListItem(
                base: DefaultListItem(
                    remoteId: 0,
                    profileId: 0,
                    userCaption: "Thermomenter",
                    function: .thermometer,
                    locationCaption: "Default",
                    locationId: 0,
                    status: .channel(.online),
                    title: "Thermomenter",
                    icon: .originalSuplaIcon(name: .Icons.fncThermometerHome),
                    value: "23.3 C"
                ),
                subValue: "18.0 C"
            ),
            onInfoClick: {},
            onIssueClick: { _ in },
            onTitleLongClick: {},
            onItemClick: {}
        )
        HeatpolThermostatListItemView(
            item: HeatpolThermostatListItem(
                base: DefaultListItem(
                    remoteId: 0,
                    profileId: 0,
                    userCaption: "Thermomenters",
                    function: .thermometer,
                    locationCaption: "Default",
                    locationId: 0,
                    status: .group(onlinePercentage: 1, activePercentage: 0.5),
                    title: "Thermomenters",
                    icon: .originalSuplaIcon(name: .Icons.fncThermometerWater),
                    value: "23.3 C"
                ),
                subValue: "24.0 C"
            ),
            onInfoClick: {},
            onIssueClick: { _ in },
            onTitleLongClick: {},
            onItemClick: {}
        )
        .environment(\.scaleFactor, 1.5)
    }
    .padding(.vertical, 1)
    .background(Color.Supla.background)
}
