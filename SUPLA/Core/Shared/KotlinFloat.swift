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

import SharedCore
    
extension KotlinFloat {
    static func from(_ number: NSNumber?) -> KotlinFloat? {
        return if let number {
            KotlinFloat(float: number.floatValue)
        } else {
            nil
        }
    }
    
    static func from(_ number: Float?) -> KotlinFloat? {
        return if let number {
            KotlinFloat(float: number)
        } else {
            nil
        }
    }
}
