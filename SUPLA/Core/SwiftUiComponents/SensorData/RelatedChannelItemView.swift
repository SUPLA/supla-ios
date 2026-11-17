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

struct RelatedChannelItemView: View {
    let data: RelatedChannelData
    let onInfoClick: (RelatedChannelData) -> Void
    let onCaptionLongPress: (RelatedChannelData) -> Void
    let onItemClick: ((RelatedChannelData) -> Void)?

    init(
        data: RelatedChannelData,
        onInfoClick: @escaping (RelatedChannelData) -> Void,
        onCaptionLongPress: @escaping (RelatedChannelData) -> Void,
        onItemClick: ((RelatedChannelData) -> Void)? = nil
    ) {
        self.data = data
        self.onInfoClick = onInfoClick
        self.onCaptionLongPress = onCaptionLongPress
        self.onItemClick = onItemClick
    }

    @ViewBuilder
    var body: some View {
        if let onItemClick {
            row
                .contentShape(Rectangle())
                .onTapGesture { onItemClick(data) }
        } else {
            row
        }
    }

    private var row: some View {
        ListItemRow {
            ListItemIcon(iconResult: data.icon)
            ListItemTitle(
                text: data.caption,
                onLongClick: { onCaptionLongPress(data) },
                onItemClick: { onItemClick?(data) }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, Distance.tiny)
            .padding(.trailing, Distance.small)
            
            data.iconsBlock?()
            
            if (data.showChannelStateIcon) {
                ListItemInfoIcon()
                    .padding(.trailing, Distance.small)
                    .contentShape(Rectangle())
                    .highPriorityGesture(TapGesture().onEnded { onInfoClick(data) })
            }
            
            ListItemDot(onlineState: data.onlineState)
        }
        .frame(minHeight: Dimens.ListItem.itemHeight * ChannelHeight.height60.factor().cg)
    }
}

struct RelatedChannelIssueIconBlock: View {
    let icon: IssueIcon

    var body: some View {
        ListItemIssueIcon(icon: icon)
            .padding(.trailing, Distance.tiny)
    }
}

#Preview("Related channel item icons") {
    BackgroundStack {
        VStack(spacing: 0) {
            RelatedChannelItemView(
                data: .visible(
                    id: 1,
                    onlineState: .online,
                    icon: .suplaIcon(name: .Icons.fncThermometerHome),
                    caption: "Thermometer",
                    userCaption: "Living room",
                    iconsBlock: RelatedChannelData.issueIconBlock(IssueIcon.Battery25()),
                    showChannelStateIcon: false
                ),
                onInfoClick: { _ in },
                onCaptionLongPress: { _ in }
            )
            
            RelatedChannelItemView(
                data: .visible(
                    id: 1,
                    onlineState: .online,
                    icon: .suplaIcon(name: .Icons.fncThermometerHome),
                    caption: "Thermometer",
                    userCaption: "Living room",
                    iconsBlock: RelatedChannelData.issueIconBlock(IssueIcon.Battery25()),
                    showChannelStateIcon: true
                ),
                onInfoClick: { _ in },
                onCaptionLongPress: { _ in }
            )

            RelatedChannelItemView(
                data: .visible(
                    id: 2,
                    onlineState: .online,
                    icon: .suplaIcon(name: "fnc_switch-on"),
                    caption: "Action trigger with schedule",
                    userCaption: "",
                    iconsBlock: {
                        AnyView(ActionTriggerIconsBlock(
                            indicatorType: .none,
                            weeklyActive: true,
                            stateIconVisible: true
                        ))
                    },
                    showChannelStateIcon: true
                ),
                onInfoClick: { _ in },
                onCaptionLongPress: { _ in }
            )

            RelatedChannelItemView(
                data: .visible(
                    id: 3,
                    onlineState: .online,
                    icon: .suplaIcon(name: "fnc_switch-on"),
                    caption: "Locked action trigger",
                    userCaption: "",
                    iconsBlock: {
                        AnyView(ActionTriggerIconsBlock(
                            indicatorType: .locked,
                            weeklyActive: true,
                            stateIconVisible: true
                        ))
                    },
                    showChannelStateIcon: true
                ),
                onInfoClick: { _ in },
                onCaptionLongPress: { _ in }
            )
        }
    }
    .environment(\.scaleFactor, 1)
}
