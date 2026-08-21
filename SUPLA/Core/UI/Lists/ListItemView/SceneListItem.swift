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

struct SceneListItemView: View {
    let item: SceneListItem
    let onInfoClick: () -> Void
    let onIssueClick: (ListItemIssues) -> Void
    let onTitleLongClick: () -> Void
    let onItemClick: () -> Void

    var body: some View {
        ListItemScaffold(
            itemTitle: item.userCaption,
            itemEstimatedEndDate: item.estimatedTimerEndDate,
            statusIndicator: ListItemStatusIndicator(
                status: item.status,
                hasLeftButton: item.leftButtonTitle != nil,
                hasRightButton: item.rightButtonTitle != nil
            ),
            onInfoClick: onInfoClick,
            onIssueClick: onIssueClick,
            onTitleLongClick: onTitleLongClick,
            onItemClick: onItemClick
        ) {
            ListItemMainRow {
                ListItemIcon(iconResult: item.icon)
            }
        }
    }
}

#Preview {
    VStack(spacing: 1) {
        SceneListItemView(
            item: SceneListItem(
                remoteId: 0,
                profileId: 0,
                userCaption: "Scene 1",
                locationCaption: "Default",
                locationId: 0,
                status: .scene,
                icon: .originalSuplaIcon(name: .Icons.fncThermometerHome),
                estimatedTimerEndDate: Date(timeIntervalSinceNow: 154)
            ),
            onInfoClick: {},
            onIssueClick: { _ in },
            onTitleLongClick: {},
            onItemClick: {}
        )
        SceneListItemView(
            item: SceneListItem(
                remoteId: 0,
                profileId: 0,
                userCaption: "Scene 2",
                locationCaption: "Default",
                locationId: 0,
                status: .scene,
                icon: .originalSuplaIcon(name: .Icons.fncThermometerHome),
                estimatedTimerEndDate: nil
            ),
            onInfoClick: {},
            onIssueClick: { _ in },
            onTitleLongClick: {},
            onItemClick: {}
        )
    }
    .padding(.vertical, 1)
    .background(Color.Supla.background)
}
