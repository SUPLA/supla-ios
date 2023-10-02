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

import Foundation

let HoursRange = 0...23

enum DayOfWeek: UInt8, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 0
    
    static func from(value: UInt8) -> DayOfWeek {
        for result in DayOfWeek.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        fatalError("Could not convert value `\(value)` to DayOfWeek")
    }
}

extension DayOfWeek {
    func fullText() -> String {
        switch (self) {
        case .monday: return Strings.General.monday
        case .tuesday: return Strings.General.tuesday
        case .wednesday: return Strings.General.wednesday
        case .thursday: return Strings.General.thursday
        case .friday: return Strings.General.friday
        case .saturday: return Strings.General.saturday
        case .sunday: return Strings.General.sunday
        }
    }
    
    func shortText() -> String {
        switch (self) {
        case .monday: return Strings.General.mondayShort
        case .tuesday: return Strings.General.tuesdayShort
        case .wednesday: return Strings.General.wednesdayShort
        case .thursday: return Strings.General.thursdayShort
        case .friday: return Strings.General.fridayShort
        case .saturday: return Strings.General.saturdayShort
        case .sunday: return Strings.General.sundayShort
        }
    }
}
