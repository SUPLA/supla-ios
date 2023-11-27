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

struct SuplaScreenBrightnessField: SuplaField {
    let type: SuplaFieldType = .screenBrightness
    let automatic: Bool
    let level: Int
    let adjustmentForAutomatic: Int
    
    init(config: TDeviceConfig_ScreenBrightness) {
        automatic = config.Automatic == 1
        level = Int(config.ScreenBrightness)
        adjustmentForAutomatic = Int(config.AdjustmentForAutomatic)
    }
    
    init(automatic: Bool, level: Int, adjustmentForAutomatic: Int) {
        self.automatic = automatic
        self.level = level
        self.adjustmentForAutomatic = adjustmentForAutomatic
    }
}
