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

enum RoofWindowDimensBuilder {
    static func windowJambPoints(
        _ canvasRect: CGRect,
        _ windowFrameWidth: CGFloat,
        _ windowTopCoverWidth: CGFloat
    ) -> [CGPoint] {
        let frameAndCoverWidth = windowFrameWidth + windowTopCoverWidth
        let windowLeftSide = canvasRect.minX + canvasRect.width / -2
        let windowRightSide = canvasRect.minX + canvasRect.width / 2
        let windowTopSide = canvasRect.minY + canvasRect.height / -2
        let windowBottomSide = canvasRect.minY + canvasRect.height / 2
        
        return [
            CGPoint(x: windowLeftSide, y: canvasRect.minY),
            CGPoint(x: windowLeftSide, y: windowTopSide),
            CGPoint(x: windowRightSide, y: windowTopSide),
            CGPoint(x: windowRightSide, y: windowBottomSide),
            CGPoint(x: windowLeftSide, y: windowBottomSide),
            CGPoint(x: windowLeftSide + windowFrameWidth, y: windowBottomSide - windowFrameWidth),
            CGPoint(x: windowRightSide - windowFrameWidth, y: windowBottomSide - windowFrameWidth),
            CGPoint(x: windowRightSide - windowFrameWidth, y: canvasRect.minY),
            CGPoint(x: windowRightSide - frameAndCoverWidth, y: canvasRect.minY),
            CGPoint(x: windowRightSide - frameAndCoverWidth, y: canvasRect.minY),
            CGPoint(x: windowRightSide - frameAndCoverWidth, y: windowTopSide + frameAndCoverWidth),
            CGPoint(x: windowLeftSide + frameAndCoverWidth, y: windowTopSide + frameAndCoverWidth),
            CGPoint(x: windowLeftSide + frameAndCoverWidth, y: canvasRect.minY)
        ]
    }
    
    static func windowCoverableJambPoints(
        _ canvasRect: CGRect,
        _ windowFrameWidth: CGFloat
    ) -> [CGPoint] {
        let windowLeftSide = canvasRect.minX + canvasRect.width / -2
        let windowBottomSide = canvasRect.minY + canvasRect.height / 2
        
        return [
            CGPoint(x: windowLeftSide + windowFrameWidth, y: canvasRect.minY),
            CGPoint(x: windowLeftSide + windowFrameWidth, y: windowBottomSide - windowFrameWidth),
            CGPoint(x: windowLeftSide, y: windowBottomSide),
            CGPoint(x: windowLeftSide, y: canvasRect.minY)
        ]
    }
    
    static func windowSashOutsidePoints(
        _ canvasRect: CGRect,
        _ windowFrameWidth: CGFloat
    ) -> [CGPoint] {
        let windowLeftSide = canvasRect.minX + canvasRect.width / -2
        let windowRightSide = canvasRect.minX + canvasRect.width / 2
        let windowTopSide = canvasRect.minY + canvasRect.height / -2
        let windowBottomSide = canvasRect.minY + canvasRect.height / 2
        
        return [
            CGPoint(x: windowLeftSide + windowFrameWidth, y: windowTopSide + windowFrameWidth),
            CGPoint(x: windowRightSide - windowFrameWidth, y: windowTopSide + windowFrameWidth),
            CGPoint(x: windowRightSide - windowFrameWidth, y: windowBottomSide - windowFrameWidth),
            CGPoint(x: windowLeftSide + windowFrameWidth, y: windowBottomSide - windowFrameWidth)
        ]
    }
    
    static func windowSashInsidePoints(
        _ canvasRect: CGRect,
        _ windowFrameWidth: CGFloat,
        _ windowTopCoverWidth: CGFloat
    ) -> [CGPoint] {
        let frameAndCoverWidth = windowFrameWidth + windowTopCoverWidth
        let windowLeftSide = canvasRect.minX + canvasRect.width / -2
        let windowRightSide = canvasRect.minX + canvasRect.width / 2
        let windowTopSide = canvasRect.minY + canvasRect.height / -2
        let windowBottomSide = canvasRect.minY + canvasRect.height / 2
        
        return [
            CGPoint(x: windowLeftSide + frameAndCoverWidth, y: windowTopSide + frameAndCoverWidth),
            CGPoint(x: windowRightSide - frameAndCoverWidth, y: windowTopSide + frameAndCoverWidth),
            CGPoint(x: windowRightSide - frameAndCoverWidth, y: windowBottomSide - frameAndCoverWidth),
            CGPoint(x: windowLeftSide + frameAndCoverWidth, y: windowBottomSide - frameAndCoverWidth)
        ]
    }
    
    static func framePoints(_ canvasRect: CGRect) -> [CGPoint] {
        let windowLeftSide = canvasRect.minX + canvasRect.width / -2
        let windowRightSide = canvasRect.minX + canvasRect.width / 2
        let windowTopSide = canvasRect.minY + canvasRect.height / -2
        let windowBottomSide = canvasRect.minY + canvasRect.height / 2
        
        return [
            CGPoint(x: windowLeftSide, y: windowTopSide),
            CGPoint(x: windowRightSide, y: windowTopSide),
            CGPoint(x: windowRightSide, y: windowBottomSide),
            CGPoint(x: windowLeftSide, y: windowBottomSide)
        ]
    }
}
