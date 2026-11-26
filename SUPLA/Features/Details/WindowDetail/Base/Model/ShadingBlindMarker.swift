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

struct ShadingBlindMarker: Equatable {
    let position: CGFloat
    let tiltValue: CGFloat?
    let tilt0Angle: CGFloat?
    let tilt100Angle: CGFloat?

    var tilt: CGFloat? {
        guard let tiltValue, let tilt0Angle, let tilt100Angle else { return nil }
        return tilt0Angle + (tilt100Angle - tilt0Angle) * tiltValue / 100
    }

    init(position: CGFloat, tiltValue: CGFloat?, tilt0Angle: CGFloat? = nil, tilt100Angle: CGFloat? = nil) {
        self.position = position
        self.tiltValue = tiltValue
        self.tilt0Angle = tilt0Angle
        self.tilt100Angle = tilt100Angle
    }
}
