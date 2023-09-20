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

import UIKit

extension UIColor {
    
    // App primary colors
    
    static let primary = UIColor(red: 18/255.0, green: 167/255.0, blue: 30/255.0, alpha: 1)
    static let primaryVariant = UIColor(red: 0, green: 209/255.0, blue: 81/255.0, alpha: 1)
    
    static let onBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    static let surface = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    @objc static let background = UIColor(red: 245/255.0, green: 246/255.0, blue: 247/255.0, alpha: 1)
    
    static let disabled = UIColor(red: 180/255.0, green: 183/255.0, blue: 186/255.0, alpha: 1)
    static let error = UIColor(red: 235.0/255.0, green: 58.0/255.0, blue: 40.0/255.0, alpha: 1)
    
    @objc static let gray = UIColor(red: 126/255.0, green: 128/255.0, blue: 130/255.0, alpha: 1)
    static let grayLight = UIColor(red: 239/255.0, green: 239/255.0, blue: 240/255.0, alpha: 1)
    static let blue = UIColor(red: 0, green: 122/255.0, blue: 1, alpha: 1)
    static let lightBlue = UIColor.from(red: 140, green: 157, blue: 255, alpha: 1)
    static let lightGreen = UIColor.from(red: 176, green: 224, blue: 168, alpha: 1)
    static let lightOrange = UIColor.from(red: 255, green: 209, blue: 154, alpha: 1)
    static let lightRed = UIColor.from(red: 224, green: 152, blue: 146, alpha: 1)
    
    static let border = UIColor(red: 180/255.0, green: 183/255.0, blue: 186/255.0, alpha: 1)
    static let separator = UIColor.from(red: 170, green: 170, blue: 170, alpha: 1)
    static let separatorLight = UIColor.from(red: 220, green: 222, blue: 224, alpha: 1)
    
    static let dialogScrim = UIColor(white: 0, alpha: 0.3)
    
    // View specific colors
    static let listItemBackground = UIColor(red: 249/255.0, green: 250/255.0, blue: 251/255.0, alpha: 1)
    
    static let innerShadow = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25) // CircleControlButtonView
    static let negativeBorder = UIColor(red: 235/255.0, green: 58/255.0, blue: 40/255.0, alpha: 1) // CircleControlButtonView
    static let disabledOverlay = UIColor(red: 1, green: 1, blue: 1, alpha: 221/255.0) // CircleControlButtonView
    
    static let progressPointShadow = UIColor(red: 178/255.0, green: 244/255.0, blue: 184/255.0, alpha: 0.6)
    
    @objc static let suplaGreenBackground = #colorLiteral(red: 0, green: 0.6549019608, blue: 0.1176470588, alpha: 1)
    
    @objc static let suplaGreen = UIColor(red: 0, green: 209.0/255.0, blue: 81.0/255.0, alpha: 1)
    static let ctrlBorder = UIColor(red: 118.0/255.0, green: 120.0/255.0, blue: 128.0/255.0, alpha: 0.12)
    static let viewBackground = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
    static let switcherBackground = UIColor(red: 118.0/255.0, green: 120.0/255.0, blue: 128.0/255.0, alpha: 0.12)

    @objc static let textLight = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    @objc static let yellow = UIColor(red: 254, green: 231, blue: 0, alpha: 1)
    
    static let newGestureBackgroundDarker = UIColor(red: 54.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 0.87)
    static let newGestureBackgroundLighter = UIColor(red: 54.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 0.27)
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)

            return (red, green, blue, alpha)
        }
    
    func copy(alpha: CGFloat) -> UIColor {
        let (red, green, blue, _) = rgba
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func from(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}
