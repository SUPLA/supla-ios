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

enum SuplaScheduleProgram: UInt8, CaseIterable {
    case off = 0
    case program1 = 1
    case program2 = 2
    case program3 = 3
    case program4 = 4
    
    func color() -> UIColor {
        switch(self) {
        case .off: return .disabled
        case .program1: return .lightBlue
        case .program2: return .lightGreen
        case .program3: return .lightOrange
        case .program4: return .lightRed
        }
    }
    
    static func from(value: UInt8) -> SuplaScheduleProgram {
        for result in SuplaScheduleProgram.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        SALog.error("Invalid SuplaScheduleProgram value `\(value)'")
        return .off
    }
}
