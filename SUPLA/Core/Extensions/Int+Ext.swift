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

extension Int16 {
    func toTemperature() -> Float {
        return Float(self) / 100
    }
}

extension Int {
    var withLeadingZero: String {
        get {
            if (self < 10) {
                return "0\(self)"
            } else {
                return "\(self)"
            }
        }
    }
    
    func toHour(withMinutes: Int? = nil) -> String {
        if let minutes = withMinutes {
            return "\(self.withLeadingZero):\(minutes.withLeadingZero)"
        } else {
            return "\(self.withLeadingZero)"
        }
    }
    

}
