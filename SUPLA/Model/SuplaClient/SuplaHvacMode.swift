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

public enum SuplaHvacMode: UInt8, CaseIterable {
    case notSet = 0
    case off = 1
    case heat = 2
    case cool = 3
    case auto = 4
    case fanOnly = 6
    case dry = 7
    case cmdTurnOn = 8
    case cmdWeeklySchedule = 9
    case cmdSwitchToManual = 10
    
    var icon: UIImage? {
        get {
            switch (self) {
            case .off: return .iconPowerButton
            case .heat: return .iconHeat
            case .cool: return .iconCool
            default: return nil
            }
        }
    }
    
    var iconColor: UIColor? {
        get {
            switch (self) {
            case .off: return .gray
            case .heat: return .red
            case .cool: return .blue
            default: return nil
            }
        }
    }
    
    static func from(hvacMode: UInt8) -> SuplaHvacMode {
        for mode in SuplaHvacMode.allCases {
            if (mode.rawValue == hvacMode) {
                return mode
            }
        }
        
        fatalError("Invalid SuplaHvacMode value `\(hvacMode)`")
    }
}
