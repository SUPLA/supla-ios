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

struct ActionTriggerListItemView: View {
    @Environment(\.scaleFactor) private var scaleFactor
    @Environment(\.showChannelInfo) private var showChannelInfo

    let item: ActionTriggerListItem
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
                ZStack {
                    ListItemIcon(iconResult: item.base.icon)
                }
                .frame(width: scale(scaleFactor, DEFAULT_LIST_ITEM_ICON_WIDTH * 1.3))
                .overlay(alignment: .bottomTrailing) {
                    if item.base.status.online {
                        indicatorIcon
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var indicatorIcon: some View {
        switch item.indicatorType {
        case .none:
            EmptyView()
        case .locked:
            Icon.Lock(
                size: Dimens.iconSizeSmall * scaleFactor,
                color: .Supla.onBackground
            )
        case .temporaryUnlocked:
            Image(.Icons.unlockTemporary)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimens.iconSize * scaleFactor, height: Dimens.iconSize * scaleFactor)
                .foregroundColor(.Supla.onBackground)
        }
    }
}

#Preview {
    VStack(spacing: 1) {
        ActionTriggerListItemView(
            item: ActionTriggerListItem(
                base: DefaultListItem(
                    remoteId: 1,
                    profileId: 1,
                    userCaption: "Button",
                    function: .actionTrigger,
                    locationCaption: "Default",
                    locationId: 1,
                    status: .channel(.online),
                    title: "Button",
                    icon: .originalSuplaIcon(name: .Icons.fncActionTrigger),
                    value: nil,
                    leftButtonTitle: Strings.General.unlock,
                    rightButtonTitle: Strings.General.lock
                ),
                indicatorType: .locked
            ),
            onInfoClick: {},
            onIssueClick: { _ in },
            onTitleLongClick: {},
            onItemClick: {}
        )

        ActionTriggerListItemView(
            item: ActionTriggerListItem(
                base: DefaultListItem(
                    remoteId: 2,
                    profileId: 1,
                    userCaption: "Button",
                    function: .actionTrigger,
                    locationCaption: "Default",
                    locationId: 1,
                    status: .channel(.online),
                    title: "Button",
                    icon: .originalSuplaIcon(name: .Icons.fncActionTrigger),
                    value: nil,
                    leftButtonTitle: Strings.General.unlock,
                    rightButtonTitle: Strings.General.lock
                ),
                indicatorType: .temporaryUnlocked
            ),
            onInfoClick: {},
            onIssueClick: { _ in },
            onTitleLongClick: {},
            onItemClick: {}
        )

        ActionTriggerListItemView(
            item: ActionTriggerListItem(
                base: DefaultListItem(
                    remoteId: 3,
                    profileId: 1,
                    userCaption: "Offline button",
                    function: .actionTrigger,
                    locationCaption: "Default",
                    locationId: 1,
                    status: .channel(.offline),
                    title: "Offline button",
                    icon: .originalSuplaIcon(name: .Icons.fncActionTrigger),
                    value: nil,
                    leftButtonTitle: Strings.General.unlock,
                    rightButtonTitle: Strings.General.lock
                ),
                indicatorType: .locked
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
