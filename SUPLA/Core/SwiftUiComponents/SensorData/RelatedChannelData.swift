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

enum RelatedChannelData: Identifiable {
    var id: Int32 {
        switch self {
            case let .invisible(id): id
        case let .visible(id, _, _, _, _, _, _): id
        }
    }
    var onlineState: ListOnlineState {
        switch self {
        case .invisible(_): .unknown
        case let .visible(_, onlineState, _, _, _, _, _): onlineState
        }
    }
    var icon: IconResult? {
        switch self {
        case .invisible(_): .suplaIcon(name: .Icons.fncUnknown)
        case let .visible(_, _, icon, _, _, _, _): icon
        }
    }
    var caption: String {
        switch self {
        case .invisible(_): Strings.General.Channel.captionInvisible
        case let .visible(_, _, _, caption, _, _, _): caption
        }
    }
    var userCaption: String {
        switch self {
        case .invisible(_): ""
        case let .visible(_, _, _, _, userCaption, _, _): userCaption
        }
    }
    var batteryIcon: IssueIcon? {
        switch self {
        case .invisible(_): nil
        case let .visible(_, _, _, _, _, batteryIcon, _): batteryIcon
        }
    }
    var showChannelStateIcon: Bool {
        switch self {
        case .invisible(_): false
        case let .visible(_, _, _, _, _, _, showChannelStateIcon): showChannelStateIcon
        }
    }
    case invisible(id: Int32)
    case visible(
        id: Int32,
        onlineState: ListOnlineState,
        icon: IconResult?,
        caption: String,
        userCaption: String,
        batteryIcon: IssueIcon?,
        showChannelStateIcon: Bool
    )
}
