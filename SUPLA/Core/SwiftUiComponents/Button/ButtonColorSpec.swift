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
    
import SwiftUI

struct ButtonColorSpec {
    let normal: Color
    let pressed: Color
    let disabled: Color
    
    func value(disabled: Bool, pressed: Bool) -> Color {
        if (disabled) {
            self.disabled
        } else if (pressed) {
            self.pressed
        } else {
            self.normal
        }
    }
    
    static let primaryText = ButtonColorSpec(normal: .Supla.onPrimary, pressed: .Supla.onPrimary, disabled: .Supla.onPrimary)
    static let primaryBackground = ButtonColorSpec(normal: .Supla.primary, pressed: .Supla.primaryVariant, disabled: .Supla.disabled)
    
    static let criticalText = ButtonColorSpec(normal: .Supla.onPrimary, pressed: .Supla.onPrimary, disabled: .Supla.onPrimary)
    static let criticalBackground = ButtonColorSpec(normal: .Supla.error, pressed: .Supla.errorVariant, disabled: .Supla.disabled)
}
