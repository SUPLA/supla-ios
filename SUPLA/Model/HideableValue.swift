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

class HideableValue<T: Equatable>: Equatable {
    let value: T
    private var hide: Bool
    private var visibilityCounter: Int
    
    init(_ value: T) {
        self.value = value
        self.hide = false
        self.visibilityCounter = 1
    }
    
    init(_ value: T, hide: Bool) {
        self.value = value
        self.hide = hide
        self.visibilityCounter = 1
    }
    
    func getOptional() -> T? {
        if (hide) {
            return nil
        }
        
        visibilityCounter = visibilityCounter - 1
        return if (visibilityCounter >= 0) {
            value
        } else {
            nil
        }
    }
    
    static func == (lhs: HideableValue<T>, rhs: HideableValue<T>) -> Bool {
        lhs.value == rhs.value && lhs.hide == rhs.hide && lhs.visibilityCounter == rhs.visibilityCounter
    }
}
