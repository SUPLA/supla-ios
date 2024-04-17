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

enum SuplaHeatpolThermostatFlag: UInt8, CaseIterable {
    case on = 0
    case autoMode = 1
    case coolMode = 2
    case headMode = 3
    case ecoMode = 4
    case dryMode = 5
    case fanOnlyMode = 6
    case purifierMode = 7
    
    func value() -> UInt8 { 1 << rawValue }
    
    static func from(flags: UInt8) -> [SuplaHeatpolThermostatFlag] {
        var result: [SuplaHeatpolThermostatFlag] = []
        
        for flag in SuplaHeatpolThermostatFlag.allCases {
            if (flag.value() & flags > 0) {
                result.append(flag)
            }
        }
        
        return result
    }
}
