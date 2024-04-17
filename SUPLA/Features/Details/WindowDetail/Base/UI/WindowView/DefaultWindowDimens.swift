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

enum DefaultWindowDimens {
    static let width: CGFloat = 288
    static let height: CGFloat = 336
    static var ratio: CGFloat { width / height }
    
    static let topLineHeight: CGFloat = 16
    static let slatsCount: Int = .init(ceil((height - topLineHeight) / slatHeight))
    static let slatHeight: CGFloat = 24
    static let slatDistance: CGFloat = 5
    
    static let windowHorizontalMargin: CGFloat = 16
    static let glassMiddelMargin: CGFloat = 20
    static let glassHorizontalMargin: CGFloat = 18
    static let glassVerticalMargin: CGFloat = 24
    static let slatHorizontalMargin: CGFloat = 8
    
    static let markerHeight: CGFloat = 8
    static let markerWidth: CGFloat = 28
    static let markerInfoRadius: CGFloat = 14
    
    static let windowCornerRadius: CGFloat = 8
    
    static let shadowRadius: CGFloat = 3
    static let shadowOffset: CGSize = .init(width: 0, height: 1.5)
    static let shadowOpacity: Float = 0.15
}
