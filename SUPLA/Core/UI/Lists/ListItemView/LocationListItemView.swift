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

struct LocationListItemView: View {
    @Environment(\.listSearchText) private var listSearchText

    let caption: String
    let collapsed: Bool
    let onClick: () -> Void
    let onLongClick: () -> Void

    private var inSearch: Bool { listSearchText != nil }

    init(
        caption: String,
        collapsed: Bool,
        onClick: @escaping () -> Void = {},
        onLongClick: @escaping () -> Void = {}
    ) {
        self.caption = caption
        self.collapsed = collapsed
        self.onClick = onClick
        self.onLongClick = onLongClick
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Distance.default) {
                HighlightedTextBySearch(text: caption, searchText: listSearchText)
                    .font(.Supla.headlineSmall)
                    .foregroundColor(.Supla.onBackground)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if (!inSearch) {
                    Image(.Icons.arrowRight)
                        .renderingMode(.template)
                        .foregroundColor(.Supla.primary)
                        .rotationEffect(.degrees(collapsed ? 90 : 270))
                }
            }
            .frame(maxWidth: .infinity, minHeight: Dimens.ListItem.sectionHeight)
            .padding(.horizontal, Distance.default)
            .contentShape(Rectangle())
            .background(Color.Supla.surfaceVariant)
            .onTapGesture {
                if (!inSearch) {
                    onClick()
                }
            }
            .onLongPressGesture {
                if (!inSearch) {
                    onLongClick()
                }
            }

            SeparatorView(style: .list)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        LocationListItemView(caption: "Leaving Room", collapsed: true)
        LocationListItemView(caption: "Sleeping Room", collapsed: false)
        LocationListItemView(caption: "Sleeping Room", collapsed: false)
            .environment(\.listSearchText, "Room")
    }
    .background(Color.Supla.background)
}
