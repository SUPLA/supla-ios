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

let SELECTOR_RADIUS: CGFloat = 12
let SELECTOR_SHADOW_RADIUS: CGFloat = 20

private let MARKER_RADIUS: CGFloat = 4
private let POINTER_SHADOW_COLOR = Color(.sRGB, red: 0x7E/255, green: 0x80/255, blue: 0x82/255, opacity: 0x64/255)
    
func drawSelectorPoint(
    context: inout GraphicsContext,
    position: CGPoint,
    color: Color
) {
    // Outer shadow ring
    let shadowRect = CGRect(
        x: position.x - SELECTOR_SHADOW_RADIUS,
        y: position.y - SELECTOR_SHADOW_RADIUS,
        width: SELECTOR_SHADOW_RADIUS * 2,
        height: SELECTOR_SHADOW_RADIUS * 2
    )
    context.fill(Path(ellipseIn: shadowRect), with: .color(POINTER_SHADOW_COLOR))

    // Inner fill + white ring
    let innerRect = CGRect(
        x: position.x - SELECTOR_RADIUS,
        y: position.y - SELECTOR_RADIUS,
        width: SELECTOR_RADIUS * 2,
        height: SELECTOR_RADIUS * 2
    )
    let innerPath = Path(ellipseIn: innerRect)
    context.fill(innerPath, with: .color(color))
    context.stroke(innerPath, with: .color(.white), lineWidth: 2)
}

func drawMarkerPoint(
    context: inout GraphicsContext,
    position: CGPoint
) {
    let rect = CGRect(
        x: position.x - MARKER_RADIUS,
        y: position.y - MARKER_RADIUS,
        width: MARKER_RADIUS * 2,
        height: MARKER_RADIUS * 2
    )
    let path = Path(ellipseIn: rect)
    context.fill(path, with: .color(.white))
    context.stroke(path, with: .color(.black), lineWidth: 1)
}
