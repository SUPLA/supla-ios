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

struct RelatedChannelItemView: View {
    let data: RelatedChannelData
    let onInfoClick: (RelatedChannelData) -> Void
    let onCaptionLongPress: (RelatedChannelData) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ListItemIcon(iconResult: data.icon)
            CellCaption(text: data.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, Distance.tiny)
                .padding(.trailing, Distance.small)
                .onLongPressGesture { onCaptionLongPress(data) }
            ListItemIssueIcon(icon: data.batteryIcon)
                .padding(.trailing, Distance.small)
            if (data.showChannelStateIcon) {
                ListItemInfoIcon()
                    .padding(.trailing, Distance.small)
                    .onTapGesture { onInfoClick(data) }
            }
            ListItemDot(onlineState: data.onlineState)
        }
        .frame(maxWidth: .infinity)
        .padding([.leading], Distance.small)
        .padding([.trailing], Distance.default)
        .padding([.top, .bottom], Distance.tiny)
        .background(Color.Supla.surface)
    }
}
