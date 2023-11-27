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

extension CGPoint {
    func insetBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
    
    func insetBy(point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    
    func inside(point: CGPoint, radius: CGFloat = 24) -> Bool {
        let distance = sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
        return distance < radius
    }
}
