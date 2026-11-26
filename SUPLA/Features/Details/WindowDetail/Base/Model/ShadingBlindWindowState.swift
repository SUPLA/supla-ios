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

protocol ShadingBlindWindowState: WindowState {
    var windowTilt: WindowGroupedValue? { get set }
    var sliderTilt: WindowGroupedValue? { get set }
    var tilt0Angle: CGFloat? { get set }
    var tilt100Angle: CGFloat? { get set }
    var markers: [ShadingBlindMarker] { get set }
}

extension ShadingBlindWindowState {
    var sliderTiltValue: CGFloat? {
        (sliderTilt)?.value(for: .slider)
    }

    var sliderTiltDegrees: CGFloat? {
        guard let tilt = sliderTilt ?? windowTilt,
              let value = tilt.value(for: .slider),
              let tilt0Angle,
              let tilt100Angle
        else { return nil }

        return tilt0Angle + (tilt100Angle - tilt0Angle) * value / 100
    }
}
