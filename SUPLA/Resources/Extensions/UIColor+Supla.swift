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
    
    static let primary = UIColor(red: 0, green: 209/255.0, blue: 81/255.0, alpha: 1)
    static let primaryVariant = UIColor(red: 18/255.0, green: 167/255.0, blue: 30/255.0, alpha: 1)
    static let surface = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    @objc static let background = UIColor(red: 245/255.0, green: 246/255.0, blue: 247/255.0, alpha: 1)
    
    static let disabled = UIColor(red: 180/255.0, green: 183/255.0, blue: 186/255.0, alpha: 1)
    
    static let grayLight = UIColor(red: 239/255.0, green: 239/255.0, blue: 240/255.0, alpha: 1)
    static let border = UIColor(red: 180/255.0, green: 183/255.0, blue: 186/255.0, alpha: 1)
    
    // View specific colors
    static let innerShadow = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25) // PowerButtonView
    static let negativeBorder = UIColor(red: 235/255.0, green: 58/255.0, blue: 40/255.0, alpha: 1) // PowerButtonView
    static let disabledOverlay = UIColor(red: 1, green: 1, blue: 1, alpha: 221/255.0) // PowerButtonView
    
    static let progressPointShadow = UIColor(red: 178/255.0, green: 244/255.0, blue: 184/255.0, alpha: 0.6)
    
    @objc static let suplaGreenBackground = #colorLiteral(red: 0, green: 0.6549019608, blue: 0.1176470588, alpha: 1)
    
    @objc static let suplaGreen = UIColor(red: 0, green: 209.0/255.0, blue: 81.0/255.0, alpha: 1)
    static let ctrlBorder = UIColor(red: 118.0/255.0, green: 120.0/255.0, blue: 128.0/255.0, alpha: 0.12)
    static let viewBackground = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
    static let switcherBackground = UIColor(red: 118.0/255.0, green: 120.0/255.0, blue: 128.0/255.0, alpha: 0.12)
    static let alertRed = UIColor(red: 235.0/255.0, green: 58.0/255.0, blue: 40.0/255.0, alpha: 1)

    static let formLabelColor = UIColor(red: 0.706, green: 0.718, blue: 0.729, alpha: 1)
    @objc static let textLight = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    @objc static let yellow = UIColor(red: 254, green: 231, blue: 0, alpha: 1)
    
    static let newGestureBackgroundDarker = UIColor(red: 54.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 0.87)
    static let newGestureBackgroundLighter = UIColor(red: 54.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 0.27)
}
