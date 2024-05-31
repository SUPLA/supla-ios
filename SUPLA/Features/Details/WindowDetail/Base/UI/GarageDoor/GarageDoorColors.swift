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

struct GarageDoorColors {
    let building: UIColor
    let shadow: UIColor
    let slatBackground: UIColor
    let slatBorder: UIColor
    let markerBorder: UIColor
    let markerBackground: UIColor

    static func standard(_ traitCollection: UITraitCollection) -> GarageDoorColors {
        GarageDoorColors(
            building: .rollerShutterWindow.resolvedColor(with: traitCollection),
            shadow: .black,
            slatBackground: .rollerShutterSlatBackground.resolvedColor(with: traitCollection),
            slatBorder: .rollerShutterSlatBorder.resolvedColor(with: traitCollection),
            markerBorder: .black,
            markerBackground: .primaryVariant
        )
    }

    static func offline(_ traitCollection: UITraitCollection) -> GarageDoorColors {
        GarageDoorColors(
            building: .surface.resolvedColor(with: traitCollection),
            shadow: .black,
            slatBackground: .rollerShutterDisabledSlatBackground.resolvedColor(with: traitCollection),
            slatBorder: .rollerShutterDisabledSlatBorder.resolvedColor(with: traitCollection),
            markerBorder: .black,
            markerBackground: UIColor(argb: 0xffb3f1cb)
        )
    }
}
