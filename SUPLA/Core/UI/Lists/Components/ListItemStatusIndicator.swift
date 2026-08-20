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

enum ListItemStatus: Equatable {
    case channel(ListOnlineState)
    case group(onlinePercentage: CGFloat, activePercentage: CGFloat)
    case scene

    var isGroup: Bool {
        switch (self) {
        case .group: true
        default: false
        }
    }
    
    var online: Bool {
        switch (self) {
        case .channel(let state): state.online
        case .group(let onlinePercentage, _): onlinePercentage > 0
        case .scene: true
        }
    }
}

enum ListItemStatusSide {
    case start, end
}

struct ListItemStatusIndicator {
    let status: ListItemStatus
    let hasLeftButton: Bool
    let hasRightButton: Bool

    init(status: ListItemStatus, hasLeftButton: Bool, hasRightButton: Bool) {
        self.status = status
        self.hasLeftButton = hasLeftButton
        self.hasRightButton = hasRightButton
    }

    @ViewBuilder
    func view(side: ListItemStatusSide) -> some View {
        switch (status) {
        case .channel(let onlineState):
            statusDot(onlineState: onlineState, side: side)
        case .group(let onlinePercentage, let activePercentage):
            groupStatus(onlinePercentage: onlinePercentage, activePercentage: activePercentage, side: side)
        case .scene:
            statusDot(onlineState: .online, side: side)
        }
    }

    private func statusDot(onlineState: ListOnlineState, side: ListItemStatusSide) -> some View {
        ListItemDot(
            onlineState: onlineState,
            withButton: (side == .start && hasLeftButton) || (side == .end && hasRightButton)
        )
        .padding(side == .start ? .leading : .trailing, Distance.small)
    }

    @ViewBuilder
    private func groupStatus(
        onlinePercentage: CGFloat,
        activePercentage: CGFloat,
        side: ListItemStatusSide
    ) -> some View {
        switch (side) {
        case .start:
            if (hasLeftButton) {
                ListItemRect(percentage: onlinePercentage, colors: .online)
                    .padding(.leading, Distance.small)
            } else {
                Color.clear
                    .frame(width: Dimens.ListItem.statusIndicatorSize, height: Dimens.ListItem.statusIndicatorSize)
                    .padding(.leading, Distance.small)
            }
        case .end:
            HStack(spacing: 0) {
                ListItemRect(percentage: activePercentage, colors: .active)
                ListItemRect(percentage: onlinePercentage, colors: .online)
            }
            .padding(.trailing, Distance.small)
        }
    }
}
