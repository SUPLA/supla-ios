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

protocol PickerItem: Hashable, Identifiable {
    var label: String { get }
}

struct DayPickerItem: PickerItem {
    let id: Int

    var label: String {
        if (id == 1) {
            Strings.TimerDetail.dayPattern.arguments(id)
        } else {
            Strings.TimerDetail.daysPattern.arguments(id)
        }
    }
}

extension Int {
    var asDayPickerItem: DayPickerItem { DayPickerItem(id: self) }
}

struct HourPickerItem: PickerItem {
    let id: Int

    var label: String {
        if (id == 1) {
            Strings.TimerDetail.hourPattern.arguments(id)
        } else {
            Strings.TimerDetail.hoursPattern.arguments(id)
        }
    }
}

extension Int {
    var asHourPickerItem: HourPickerItem { HourPickerItem(id: self) }
}

struct NumberPickerItem: PickerItem {
    let id: Int
    let pattern: String

    var label: String {
        pattern.arguments(id)
    }
}

extension Int {
    var asMinutePickerItem: NumberPickerItem {
        NumberPickerItem(id: self, pattern: Strings.TimerDetail.minutePattern)
    }
}
