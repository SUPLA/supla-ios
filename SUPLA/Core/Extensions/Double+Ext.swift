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

extension Double {
    func minus(_ value: Double) -> Double {
        return self - value
    }
    
    func plus(_ value: Double) -> Double {
        return self + value
    }
    
    func times(_ value: Double) -> Double {
        return self * value
    }
    
    func also(_ transformation: (Double) -> Double) -> Double {
        return transformation(self)
    }
    
    func ifNotZero<T>(function: (Double) -> T?) -> T? {
        self == 0.0 ? nil : function(self)
    }
    
    func convert<T>(_ transformation: (Double) -> T) -> T {
        return transformation(self)
    }
}

extension Double? {
    func also(_ transformation: (Double) -> Double) -> Double? {
        if let value = self {
            return transformation(value)
        }
        return nil
    }
}
