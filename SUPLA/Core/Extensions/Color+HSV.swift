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

struct HsvColor: Equatable {
    let hue: Double
    let saturation: Double
    let value: Double

    var color: UIColor {
        UIColor(hue: hue / 360.0, saturation: saturation, brightness: value, alpha: 1)
    }

    var fullBrightnessColor: UIColor {
        UIColor(hue: hue / 360.0, saturation: saturation, brightness: 1, alpha: 1)
    }

    var valueAsPercentage: Int32 {
        let result = Int32(round(value * 100.0))

        return if (result > 100) {
            100
        } else if (result < 0) {
            0
        } else {
            result
        }
    }

    init(hue: Double = 0, saturation: Double = 0, value: Double = 0) {
        self.hue = hue
        self.saturation = saturation
        self.value = value
    }

    func copy(hue: Double? = nil, saturation: Double? = nil, value: Double? = nil) -> HsvColor {
        HsvColor(hue: hue ?? self.hue, saturation: saturation ?? self.saturation, value: value ?? self.value)
    }
    
    static var turnOn: HsvColor = HsvColor(hue: 0, saturation: 0, value: 1)
    static var turnOff: HsvColor = HsvColor(hue: 0, saturation: 0, value: 0)
}

extension UIColor {
    func toHsv(_ brightness: Int32? = nil) -> HsvColor? {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return nil
        }

        let hueDegrees = h * 360.0
        let value = if let brightness { percentageToBrightness(brightness) } else { b }

        return HsvColor(
            hue: hueDegrees,
            saturation: s,
            value: value
        )
    }
    
    private func percentageToBrightness(_ brightness: Int32) -> CGFloat {
        if (brightness > 100) {
            return 1
        } else if (brightness < 0) {
            return 0
        } else {
            return CGFloat(brightness) / 100
        }
    }
}
