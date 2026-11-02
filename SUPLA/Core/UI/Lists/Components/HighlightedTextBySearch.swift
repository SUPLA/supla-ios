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

struct HighlightedTextBySearch: View {
    let text: String
    let searchText: String?

    var body: some View {
        Text(attributedText)
    }

    private var attributedText: AttributedString {
        var attributed = AttributedString(text)

        guard
            let searchText,
            MainListFilter.isSearchable(searchText)
        else {
            return attributed
        }

        var searchStartIndex = text.startIndex
        while searchStartIndex < text.endIndex,
              let range = text.range(
                  of: searchText,
                  options: [.caseInsensitive],
                  range: searchStartIndex ..< text.endIndex
              ) {
            if let attributedRange = Range(range, in: attributed) {
                attributed[attributedRange].backgroundColor = Color.Supla.primary.opacity(0.2)
            }

            searchStartIndex = range.upperBound
        }

        return attributed
    }
}
