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


let DAY_IN_SEC = 24 * 60 * 60
let HOUR_IN_SEC = 60 * 60
let MINUTE_IN_SEC = 60

extension Int: ScopeFunctions {
    typealias T = Int
    
    var withLeadingZero: String {
        get {
            if (self < 10) {
                return "0\(self)"
            } else {
                return "\(self)"
            }
        }
    }
    
    var days: Int {
        self / DAY_IN_SEC
    }
    
    var hoursInDay: Int {
        (self % DAY_IN_SEC) / HOUR_IN_SEC
    }
    
    var minutesInHour: Int {
        (self % HOUR_IN_SEC) / MINUTE_IN_SEC
    }
    
    var secondsInMinute: Int {
        self % MINUTE_IN_SEC
    }
    
    func toHour(withMinutes: Int? = nil) -> String {
        if let minutes = withMinutes {
            return "\(self.withLeadingZero):\(minutes.withLeadingZero)"
        } else {
            return "\(self.withLeadingZero)"
        }
    }
}
