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

struct ProjectorScreenColors {
    let screen: UIColor
    let shadow: UIColor
    let bottomRect: UIColor
    let topRect: UIColor
    let logoColor: UIColor

    static func standard(_ traitCollection: UITraitCollection) -> ProjectorScreenColors {
        ProjectorScreenColors(
            screen: .rollerShutterWindow.resolvedColor(with: traitCollection),
            shadow: .black,
            bottomRect: .rollerShutterSlatBackground.resolvedColor(with: traitCollection),
            topRect: .gray.resolvedColor(with: traitCollection),
            logoColor: .primaryVariant.copy(alpha: 0.2)
        )
    }

    static func offline(_ traitCollection: UITraitCollection) -> ProjectorScreenColors {
        ProjectorScreenColors(
            screen: .surface.resolvedColor(with: traitCollection),
            shadow: .black,
            bottomRect: .rollerShutterSlatBackground.resolvedColor(with: traitCollection),
            topRect: .disabled.resolvedColor(with: traitCollection),
            logoColor: .disabled.copy(alpha: 0.2)
        )
    }
}
