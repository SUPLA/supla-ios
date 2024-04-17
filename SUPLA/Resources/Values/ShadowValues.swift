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

struct ShadowValues {
    static let color = UIColor.black
    static let radius = CGFloat(2)
    static let opacity: Float = 0.3
    static let offset = CGSizeMake(0, 0)
    static let blur: CGFloat = 6
    
    static func apply(toLayer layer: CALayer) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
    }
    
    static func apply(toButton layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSizeMake(0, 4)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
    }
    
    static func clear(_ layer: CALayer) {
        layer.shadowColor = UIColor.transparent.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
    }
}
