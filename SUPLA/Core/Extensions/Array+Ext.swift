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

extension Array where Iterator.Element == Double {
    func avg() -> Double {
        return reduce(Double(0)) { $0 + $1 } / Double(count)
    }
    
    func maxOrNull() -> Double? {
        if (self.count == 0) {
            return nil
        }
        
        return self.max()
    }
    
    func sumOrNan() -> Double {
        if (isEmpty) {
            return Double.nan
        }
        
        return reduce(Double(0)) { $0 + $1 }
    }
    
    func avgOrNan() -> Double {
        if (isEmpty) {
            return Double.nan
        }
        
        return reduce(Double(0)) { $0 + $1 } / Double(count)
    }
}

extension Array where Iterator.Element == Double? {
    func maxOrNull() -> Double? {
        if (self.count == 0) {
            return nil
        }
        
        return self.filter { $0 != nil }
            .map { $0! }
            .max()
    }
    
    func minOrNull() -> Double? {
        if (self.count == 0) {
            return nil
        }
        
        return self.filter { $0 != nil }
            .map { $0! }
            .min()
    }
}

extension Array where Iterator.Element == [Double?] {
    func maxOrNull() -> Double? {
        if (self.count == 0) {
            return nil
        }
        
        return self.map { $0.maxOrNull() }.maxOrNull()
    }
    
    func minOrNull() -> Double? {
        if (self.count == 0) {
            return nil
        }
        
        return self.map { $0.minOrNull() }.minOrNull()
    }
}

extension Array where Iterator.Element: Equatable {
    func indexOf(element: Iterator.Element) -> Int? {
        for (index, item) in enumerated() {
            if (item == element) {
                return index
            }
        }
        return nil
    }
    
    func contains(all: [Element]) -> Bool {
        for item in all {
            if (!contains(item)) {
                return false
            }
        }
        
        return true
    }
}
