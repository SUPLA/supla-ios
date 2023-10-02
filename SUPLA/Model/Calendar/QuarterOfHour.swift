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

enum QuarterOfHour: UInt8, CaseIterable {
    case first = 1
    case second = 2
    case third = 3
    case fourth = 4
    
    func minutes() -> Int {
        switch(self) {
        case .first: return 0
        case .second: return 15
        case .third: return 30
        case .fourth: return 45
        }
    }
    
    static func from(value: UInt8) -> QuarterOfHour {
        for result in QuarterOfHour.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        fatalError("Could not convert value `\(value)` to QuarterOfHour")
    }
    
    static func from(minute: Int) -> QuarterOfHour {
        for quarter in QuarterOfHour.allCases {
            if (minute < quarter.minutes() + 15) {
                return quarter
            }
        }
        
        fatalError("Could not find quarter for minute `\(minute)`")
    }
}
