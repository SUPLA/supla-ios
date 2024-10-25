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
    @objc static let error = UIColor(red: 235.0/255.0, green: 58.0/255.0, blue: 40.0/255.0, alpha: 1)
    static let errorContainer = UIColor(named: "Colors/error_container")!
    
    static let suplaButtonBackgroundOutside = UIColor(named: "Colors/supla_button_background_outside")!
    @objc static let buttonPressed = UIColor(argb: 0xFF59E866)
    
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
    static let chartPhase1 = UIColor(named: "Colors/phase1")!
    static let chartPhase2 = UIColor(named: "Colors/phase2")!
    static let chartPhase3 = UIColor(named: "Colors/phase3")!
    static let chartValuePositive = UIColor(named: "Colors/value_positive")!
    static let chartValueNegative = UIColor(named: "Colors/value_negative")!
    
    static let chartPie1 = UIColor(named: "Colors/pie_1")!
    static let chartPie2 = UIColor(named: "Colors/pie_2")!
    static let chartPie3 = UIColor(named: "Colors/pie_3")!
    static let chartPie4 = UIColor(named: "Colors/pie_4")!
    static let chartPie5 = UIColor(named: "Colors/pie_5")!
    static let chartPie6 = UIColor(named: "Colors/pie_6")!
    static let chartPie7 = UIColor(named: "Colors/pie_7")!
    static let chartPie8 = UIColor(named: "Colors/pie_8")!
    static let chartPie9 = UIColor(named: "Colors/pie_9")!
    static let chartPie10 = UIColor(named: "Colors/pie_10")!
    static let chartPie11 = UIColor(named: "Colors/pie_11")!
    static let chartPie12 = UIColor(named: "Colors/pie_12")!
    static let chartPie13 = UIColor(named: "Colors/pie_13")!
    static let chartPie14 = UIColor(named: "Colors/pie_14")!
    static let chartPie15 = UIColor(named: "Colors/pie_15")!
    static let chartPie16 = UIColor(named: "Colors/pie_16")!
    static let chartPie17 = UIColor(named: "Colors/pie_17")!
    static let chartPie18 = UIColor(named: "Colors/pie_18")!
    static let chartPie19 = UIColor(named: "Colors/pie_19")!
    static let chartPie20 = UIColor(named: "Colors/pie_20")!
    static let chartPie21 = UIColor(named: "Colors/pie_21")!
    static let chartPie22 = UIColor(named: "Colors/pie_22")!
    static let chartPie23 = UIColor(named: "Colors/pie_23")!
    static let chartPie24 = UIColor(named: "Colors/pie_24")!
    
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
    
    @objc static let colorPickerDefault = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
    @objc static let rgbwSelectedTabColor = UIColor(red: 0.07, green: 0.65, blue: 0.12, alpha: 1.00)
    @objc static let diwInputOptionSelected = UIColor(red: 1.00, green: 0.60, blue: 0.00, alpha: 1.00)
    @objc static let phase1Color = UIColor(red: 0.56, green: 0.92, blue: 1.00, alpha: 1.0)
    @objc static let phase2Color = UIColor(red: 0.59, green: 0.57, blue: 1.00, alpha: 1.0)
    @objc static let phase3Color = UIColor(red: 1.00, green: 0.82, blue: 0.57, alpha: 1.0)
    @objc static let chartValuePositiveColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0)
    @objc static let chartValueNegativeColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
    @objc static let chartRoomTemperature = UIColor(red: 0.00, green: 0.76, blue: 0.99, alpha: 1.0)
    @objc static let hpBtnOn = UIColor(red: 0.14, green: 0.75, blue: 0.13, alpha: 1.0)
    @objc static let hpBtnOff = UIColor(red: 0.94, green: 0.27, blue: 0.29, alpha: 1.0)
    @objc static let hpBtnUnknown = UIColor(red: 0.90, green: 0.74, blue: 0.49, alpha: 1.0)
    @objc static let menuSeparatorColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 0.4)
    @objc static let vlCfgButtonColor = UIColor(red: 0.07, green: 0.65, blue: 0.12, alpha: 1.00)
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
    
    @objc func toDictonary() -> [String: NSNumber] {
        let (red, green, blue, alpha) = rgba
        return [
            "red": NSNumber(value: red),
            "green": NSNumber(value: green),
            "blue": NSNumber(value: blue),
            "alpha": NSNumber(value: alpha)
        ]
    }
    
    @objc static func fromDictonary(_ value: NSObject?) -> UIColor? {
        guard let dictonary = value as? [String: NSNumber],
              let red = dictonary["red"],
              let green = dictonary["green"],
              let blue = dictonary["blue"],
              let alpha = dictonary["alpha"]
        else { return nil }
        
        return UIColor(
            red: CGFloat(red.floatValue),
            green: CGFloat(green.floatValue),
            blue: CGFloat(blue.floatValue),
            alpha: CGFloat(alpha.floatValue)
        )
    }
}
