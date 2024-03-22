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

struct WindowColors {
    let window: UIColor
    let shadow: UIColor
    let glassTop: UIColor
    let glassBottom: UIColor
    let slatBackground: UIColor
    let slatBorder: UIColor
    let markerBorder: UIColor
    let markerBackground: UIColor
    
    static func standard() -> WindowColors {
        WindowColors(
            window: .surface,
            shadow: .black,
            glassTop: .windowGlassTopColor,
            glassBottom: .windowGlassBottomColor,
            slatBackground: .separatorLight,
            slatBorder: .disabled,
            markerBorder: .black,
            markerBackground: .primaryVariant
        )
    }
    
    static func offline() -> WindowColors {
        WindowColors(
            window: .surface,
            shadow: .black,
            glassTop: UIColor(argb: 0xffeffaff),
            glassBottom: UIColor(argb: 0xfff3fbff),
            slatBackground: UIColor(argb: 0xfff5f5f6),
            slatBorder: UIColor(argb: 0xffe9e9ea),
            markerBorder: .black,
            markerBackground: UIColor(argb: 0xffb3f1cb)
        )
    }
}
