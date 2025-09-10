//
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
    
extension Formatter {
    static let number = NumberFormatter()
}

extension Double {
    
    func toString(precision: Int = 0) -> String {
        Formatter.number.minimumFractionDigits = precision
        Formatter.number.maximumFractionDigits = precision
        Formatter.number.usesGroupingSeparator = true
        return Formatter.number.string(from: NSNumber(value: self)) ?? String(format: "%.\(precision)f", self)
    }
    
    func toString(minPrecision: Int = 0, maxPrecision: Int = 0) -> String {
        Formatter.number.minimumFractionDigits = minPrecision
        Formatter.number.maximumFractionDigits = maxPrecision
        Formatter.number.usesGroupingSeparator = true
        return Formatter.number.string(from: NSNumber(value: self)) ?? String(format: "%.\(maxPrecision)f", self)
    }
}
