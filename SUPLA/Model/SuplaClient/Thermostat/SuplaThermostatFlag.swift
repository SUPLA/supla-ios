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

enum SuplaThermostatFlag: UInt16, CaseIterable {
    case setpointTempMinSet = 0
    case setpointTempMaxSet = 1
    case heating = 2
    case cooling = 3
    case weeklySchedule = 4
    case countdownTimer = 5
    case fanEnabled = 6
    case thermometerError = 7
    case clockError = 8
    case forcedOffBySensor = 9
    case heatOrCool = 10 // if set cool else heat
    case weeklyScheduleTemporalOverride = 11
    
    func value() -> UInt16 { 1 << rawValue }
    
    static func from(flags: UInt16) -> [SuplaThermostatFlag] {
        var result: [SuplaThermostatFlag] = []
        
        for flag in SuplaThermostatFlag.allCases {
            if (flag.value() & flags > 0) {
                result.append(flag)
            }
        }
        
        return result
    }
}
