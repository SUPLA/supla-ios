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

private let CROSS_PATH_D = "M56.5684 16.9707L45.2549 28.2842L56.5684 39.5977L39.5977 56.5684L28.2842 45.2549L16.9707 56.5684L0 " +
"39.5977L11.3135 28.2842L0 16.9707L16.9707 0L28.2842 11.3135L39.5977 0L56.5684 16.9707Z"
private let ARROW_PATH_D = "M0 60.3008H22L78 8.30078H102M96 16.3008L102 8.30078L96 0.300781"

private let CROSS_PATH = Path.svg(CROSS_PATH_D)
private let ARROW_PATH = Path.svg(ARROW_PATH_D)

private let CROSS_LEFT: CGFloat = 145
private let CROSS_TOP: CGFloat = 72

private let ARROW_LEFT: CGFloat = 124
private let ARROW_TOP: CGFloat = 66

extension GraphicsContext {
    func drawCrossLines(scale: CGFloat, inRect: CGRect) -> (CGFloat, CGFloat, CGRect) {
        let crossLeft = inRect.minX + CROSS_LEFT * scale
        let crossTop = inRect.minY + CROSS_TOP * scale
        
        let crossPath = CROSS_PATH
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .applying(CGAffineTransform(translationX: crossLeft, y: crossTop))
        fill(crossPath, with: .color(Color.Supla.outline))
        
        let arrowLeft = inRect.minX + ARROW_LEFT * scale
        let arrowTop = inRect.minY + ARROW_TOP * scale
        
        let arrowPath = ARROW_PATH
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .applying(CGAffineTransform(translationX: arrowLeft, y: arrowTop))
            
        
        let arrowGradient = Gradient(colors: [Color.Supla.error, Color.Supla.secondary])
        let arrowShading = GraphicsContext.Shading.linearGradient(
            arrowGradient,
            startPoint: CGPoint(x: arrowLeft, y: arrowTop),
            endPoint: CGPoint(x: arrowLeft + arrowPath.boundingRect.width, y: arrowTop)
        )
        
        let lineWidth: CGFloat = 4
        stroke(
            arrowPath,
            with: arrowShading,
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        )
        
        let arrowCorrection = 6 * scale
        let mirroredArrowPath = ARROW_PATH
            .applying(CGAffineTransform(scaleX: 1, y: -1))
            .applying(CGAffineTransform(translationX: 0, y: ARROW_PATH.boundingRect.minY + ARROW_PATH.boundingRect.maxY + (lineWidth / 2) + arrowCorrection))
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .applying(CGAffineTransform(translationX: arrowLeft, y: arrowTop))
        
        stroke(
            mirroredArrowPath,
            with: arrowShading,
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        )
        
        return (arrowLeft, arrowTop, mirroredArrowPath.boundingRect)
    }
}
