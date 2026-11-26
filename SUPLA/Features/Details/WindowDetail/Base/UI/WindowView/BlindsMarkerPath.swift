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

import UIKit

enum BlindsMarkerPath {
    static func slats(in rect: CGRect, degrees: CGFloat) -> CGPath {
        let radius = min(rect.width, rect.height) / 2
        let angle = CGFloat(SlatTiltSlider.trimAngle(Float(degrees))) * .pi / 180
        let halfWidth = radius / 2
        let horizontalOffset = cos(angle) * halfWidth
        let verticalOffset = sin(angle) * halfWidth
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let path = UIBezierPath()

        for lineOffset in [CGFloat(-3), 0, 3] {
            path.move(
                to: CGPoint(
                    x: center.x - horizontalOffset,
                    y: center.y + lineOffset - verticalOffset
                )
            )
            path.addLine(
                to: CGPoint(
                    x: center.x + horizontalOffset,
                    y: center.y + lineOffset + verticalOffset
                )
            )
        }

        return path.cgPath
    }
}
