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

extension Float {
    func toTemperatureString() -> String {
        @Singleton<ValuesFormatter> var formatter
        return formatter.temperatureToString(self, withUnit: false, withDegree: false)
    }
    
    var cg: CGFloat {
        get { CGFloat(self) }
    }
    
    func plus(_ other: Float) -> Float {
        return self + other
    }
    
    func toSuplaTemperature() -> Int16 {
        return Int16((self * 10).rounded()) * 10
    }
    
    func also<T>(_ transformation: (Float) -> T) -> T {
        return transformation(self)
    }
    
    func roundToTenths() -> Float {
        (self * 10).rounded() / 10
    }
}

extension CGFloat: ScopeFunctions {
    typealias T = CGFloat
    
    var float: Float {
        get { Float(self) }
    }
    
    func limit(min: CGFloat = 0, max: CGFloat = 1) -> CGFloat {
        if (self > max) {
            return max
        } else if (self < min) {
            return min
        } else {
            return self
        }
    }
    
    func divideToPercentage(value: CGFloat) -> CGFloat {
        self / value * 100
    }
    
    func also(_ transformation: (CGFloat) -> CGFloat) -> CGFloat {
        return transformation(self)
    }
    
    func roundToTenths() -> CGFloat {
        (self * 10).rounded() / 10
    }
}
