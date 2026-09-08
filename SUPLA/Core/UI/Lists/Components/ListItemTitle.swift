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

struct ListItemTitleFramePreferenceKey: PreferenceKey {
    static let coordinateSpaceName = "ListItemTitleFrame"
    static var defaultValue: CGRect = .null

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ListItemTitle: View {
    @Environment(\.scaleFactor) private var scaleFactor
    @Environment(\.listSearchText) private var listSearchText

    let text: String
    let onLongClick: () -> Void
    let onItemClick: () -> Void
    let maxLines: Int

    init(
        text: String,
        onLongClick: @escaping () -> Void = {},
        onItemClick: @escaping () -> Void = {},
        maxLines: Int = 1
    ) {
        self.text = text
        self.onLongClick = onLongClick
        self.onItemClick = onItemClick
        self.maxLines = maxLines
    }

    var body: some View {
        HighlightedTextBySearch(text: text, searchText: listSearchText)
            .lineLimit(maxLines)
            .truncationMode(.tail)
            .font(Font.Supla.listItemCaption(scaleFactor))
            .foregroundColor(Color.Supla.onBackground)
            .onTapGesture(perform: onItemClick)
            .onLongPressGesture(perform: onLongClick)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ListItemTitleFramePreferenceKey.self,
                        value: proxy.frame(in: .named(ListItemTitleFramePreferenceKey.coordinateSpaceName))
                    )
                }
            }
    }
}
