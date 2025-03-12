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
import SharedCore

struct ChannelIssuesView: SwiftUI.View {
    var issues: [ChannelIssueItem]
    
    var body: some SwiftUI.View {
        ForEach(0 ..< issues.count, id: \.self) { issueIdx in
            ForEach(0 ..< issues[issueIdx].messages.count, id: \.self) { messageIdx in
                HStack(alignment: .top, spacing: Distance.tiny) {
                    if let icon = issues[issueIdx].icon.resource {
                        Image(uiImage: icon)
                            .resizable()
                            .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                    }
                    Text(issues[issueIdx].messages[messageIdx].string)
                        .fontBodyMedium()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding([.leading, .trailing], Distance.default)
            }
        }
    }
}
