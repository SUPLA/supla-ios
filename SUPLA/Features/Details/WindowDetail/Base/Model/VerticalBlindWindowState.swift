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

struct VerticalBlindWindowState: ShadingBlindWindowState, Equatable, Changeable {
    /**
     * The blind roller position in percentage
     * 0 - open
     * 100 - closed
     */
    var position: WindowGroupedValue

    var positionTextFormat: WindowGroupedValueFormat = .percentage

    /**
     * Slat tilt as percentage - 0 up to 100
     */
    var windowTilt: WindowGroupedValue? = nil

    var sliderTilt: WindowGroupedValue? = nil
    
    var tiltTextFormat: WindowGroupedValueFormat = .degree
    
    var tilt0Angle: CGFloat? = nil
    
    var tilt100Angle: CGFloat? = nil
    
    var markers: [ShadingBlindMarker] = []
    
    var windowTiltDegrees: CGFloat? {
        guard let tilt = windowTilt else { return nil }
        guard let value = tilt.value(for: .window) else { return nil }
        let value0 = tilt0Angle ?? DEFAULT_TILT_0_ANGLE
        let value100 = tilt100Angle ?? DEFAULT_TILT_100_ANGLE
        return value0 + (value100 - value0) * value / 100
    }
    
    var windowTiltText: String {
        guard let tilt = windowTilt else { return Strings.FacadeBlindsDetail.noTilt }
        return tilt.asString(tiltTextFormat, value0: tilt0Angle, value100: tilt100Angle)
    }
}
