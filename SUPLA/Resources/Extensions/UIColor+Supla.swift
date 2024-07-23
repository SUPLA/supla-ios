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
    @objc static let suplaGreen = UIColor(argb: 0xFF12A71E)
    @objc static let green = UIColor(argb: 0xFF00D151)
    
    @objc static let primary = UIColor(named: "Colors/primary")!
    @objc static let onPrimary = UIColor(named: "Colors/on_primary")!
    
    @objc static let primaryVariant = UIColor(named: "Colors/primary_variant")!
    
    @objc static let primaryContainer = UIColor(named: "Colors/primary_container")!
    @objc static let onPrimaryContainer = UIColor(named: "Colors/on_primary_container")!
    
    static let secondary = UIColor(named: "Colors/secondary")!
    static let secondaryContainer = UIColor(named: "Colors/secondary_container")!
    
    
    @objc static let surface = UIColor(named: "Colors/surface")!
    static let onSurface = UIColor(named: "Colors/on_surface")!
    
    @objc static let surfaceVariant = UIColor(named: "Colors/surface_variant")!
    @objc static let onSurfaceVariant = UIColor(named: "Colors/on_surface_variant")!
    
    @objc static let background = UIColor(named: "Colors/background")!
    @objc static let onBackground = UIColor(named: "Colors/on_background")!
    
    static let outline = UIColor(named: "Colors/outline")!
    static let outlineVariant = UIColor(named: "Colors/outline_variant")!
    
    static let disabled = UIColor(named: "Colors/disabled")!
    static let error = UIColor(red: 235.0/255.0, green: 58.0/255.0, blue: 40.0/255.0, alpha: 1)
    static let errorContainer = UIColor(named: "Colors/error_container")!
    
    static let suplaButtonBackgroundOutside = UIColor(named: "Colors/supla_button_background_outside")!
    
    @objc static let gray = UIColor(red: 126/255.0, green: 128/255.0, blue: 130/255.0, alpha: 1)
    static let grayLight = UIColor(named: "Colors/gray_light")!
    static let grayLighter = UIColor(named: "Colors/gray_lighter")!
    static let blue = UIColor(red: 0, green: 122/255.0, blue: 1, alpha: 1)
    static let lightBlue = UIColor.from(red: 140, green: 157, blue: 255, alpha: 1)
    static let lightGreen = UIColor.from(red: 176, green: 224, blue: 168, alpha: 1)
    static let lightOrange = UIColor.from(red: 255, green: 209, blue: 154, alpha: 1)
    static let lightRed = UIColor.from(red: 224, green: 152, blue: 146, alpha: 1)
    static let darkRed = UIColor(named: "Colors/dark_red")!
    static let darkBlue = UIColor(named: "Colors/dark_blue")!
    static let chartTemperature1 = error
    static let chartTemperature2 = UIColor(argb: 0xFFFF8C53)
    static let chartHumidity1 = UIColor(argb: 0xFF57A0FF)
    static let chartHumidity2 = UIColor(argb: 0xFF33FFEC)
    static let chartGpm = UIColor(argb: 0xFF01C2FB)
    static let chartGpmBorder = UIColor(argb: 0xFF005F6E)
    static let chartGpmShadow = UIColor(argb: 0x3398C4CA)
    
    @objc static let separator = UIColor(named: "Colors/separator")!
    static let separatorLight = UIColor(named: "Colors/separator_light")!
    
    static let loadingScrim = UIColor(named: "Colors/loading_scrim")!
    static let dialogScrim = UIColor(named: "Colors/dialog_scrim")!
    static let infoScrim = UIColor(named: "Colors/info_scrim")!
    static let transparent = UIColor(argb: 0x00FFFFFF)
    
    static let innerShadow = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25) // CircleControlButtonView
    static let negativeBorder = UIColor(red: 235/255.0, green: 58/255.0, blue: 40/255.0, alpha: 1) // CircleControlButtonView
    static let disabledOverlay = UIColor(named: "Colors/disabled_overlay")! // CircleControlButtonView
    
    static let progressPointShadow = UIColor(red: 178/255.0, green: 244/255.0, blue: 184/255.0, alpha: 0.6)
    
    static let rollerShutterWindow = UIColor(named: "Colors/RollerShutter/window")!
    static let rollerShutterGlassTop = UIColor(named: "Colors/RollerShutter/glass_top")!
    static let rollerShutterGlassBottom = UIColor(named: "Colors/RollerShutter/glass_bottom")!
    static let rollerShutterSlatBackground = UIColor(named: "Colors/RollerShutter/slat_background")!
    static let rollerShutterSlatBorder = UIColor(named: "Colors/RollerShutter/slat_border")!
    static let rollerShutterDisabledOverlay = UIColor(named: "Colors/RollerShutter/disabled_overlay")!
    
    static let ctrlBorder = UIColor(red: 118.0/255.0, green: 120.0/255.0, blue: 128.0/255.0, alpha: 0.12)
    static let switcherBackground = UIColor(red: 118.0/255.0, green: 120.0/255.0, blue: 128.0/255.0, alpha: 0.12)
    
    @objc static let yellow = UIColor(red: 254, green: 231, blue: 0, alpha: 1)
    
    static let newGestureBackgroundDarker = UIColor(red: 54.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 0.87)
    static let newGestureBackgroundLighter = UIColor(red: 54.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 0.27)
}

extension UIColor {
    convenience init(alpha: Int, red: Int, green: Int, blue: Int) {
        assert(alpha >= 0 && alpha <= 255, "Invalid red component")
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(
            red: CGFloat(red)/255.0,
            green: CGFloat(green)/255.0,
            blue: CGFloat(blue)/255.0,
            alpha: CGFloat(alpha)/255.0
        )
    }
    
    convenience init(argb: Int) {
        self.init(
            alpha: (argb >> 24) & 0xFF,
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF
        )
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
    
    var argbInt: Int {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return
                (Int(alpha * 255.0) << 24) +
                (Int(red * 255.0) << 16) +
                (Int(green * 255.0) << 8) +
                Int(blue * 255.0)
        } else {
            return 0xFFFFFF
        }
    }
    
    func copy(alpha: CGFloat) -> UIColor {
        let (red, green, blue, _) = rgba
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func from(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}
