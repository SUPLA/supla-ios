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

enum ListOnlineState {
    case online, partiallyOnline, updating, offline, unknown

    var online: Bool {
        self == .online || self == .partiallyOnline
    }

    func mergeWith(_ other: ListOnlineState?) -> ListOnlineState {
        if (self == other) {
            self
        } else if (self == .partiallyOnline || other == .partiallyOnline) {
            .partiallyOnline
        } else if (self == .online && other == .offline) {
            .partiallyOnline
        } else if (self == .offline && other == .online) {
            .partiallyOnline
        } else if (self == .online || other == .online) {
            .online
        } else {
            .offline
        }
    }

    fileprivate static func from(_ status: SuplaChannelAvailabilityStatus) -> ListOnlineState {
        switch (status) {
        case .online: .online
        case .firmwareUpdateOngoing: .updating
        default: .offline
        }
    }
}

extension SuplaChannelAvailabilityStatus {
    var onlineState: ListOnlineState { ListOnlineState.from(self) }
}
