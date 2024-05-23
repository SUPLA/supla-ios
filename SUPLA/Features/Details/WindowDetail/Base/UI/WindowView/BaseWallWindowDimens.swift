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

class BaseWallWindowDimens {
    var scale: CGFloat = 0
    
    var canvasRect: CGRect = .zero
    var topLineRect: CGRect = .zero
    var windowRect: CGRect = .zero
    var leftGlassRect: CGRect = .zero
    var rightGlassRect: CGRect = .zero
    
    func update(_ frame: CGRect) {
        createCanvasRect(frame)
        
        scale = canvasRect.width / WindowDimens.width
        
        createTopLineRect()
        createWindowRect()
        createGlassRects()
    }
    
    private func createTopLineRect() {
        topLineRect = CGRect(
            origin: canvasRect.origin,
            size: CGSize(width: canvasRect.width, height: WindowDimens.topLineHeight * scale)
        )
    }
    
    private func createWindowRect() {
        let windowHorizontalMargin = WindowDimens.windowHorizontalMargin * scale
        let windowTop = topLineRect.height / 2
        let windowSize = CGSize(
            width: canvasRect.width - windowHorizontalMargin * 2,
            height: canvasRect.height - windowTop
        )
        let windowOrigin = CGPoint(x: canvasRect.minX + windowHorizontalMargin, y: windowTop)
        
        windowRect = CGRect(origin: windowOrigin, size: windowSize)
    }
    
    private func createGlassRects() {
        let glassHorizontalMargin = WindowDimens.glassHorizontalMargin * scale
        let glassVerticalMargin = WindowDimens.glassVerticalMargin * scale
        let glassMiddleMargin = WindowDimens.glassMiddelMargin * scale
        let glassWidth = (windowRect.width - (glassHorizontalMargin * 2) - glassMiddleMargin) / 2
        let glassHeight = windowRect.height - (glassVerticalMargin * 2)
        
        let left = windowRect.minX + glassHorizontalMargin
        let top = windowRect.minY + glassVerticalMargin
        let size = CGSize(width: glassWidth, height: glassHeight)
        
        leftGlassRect = CGRect(
            origin: CGPoint(x: left, y: top),
            size: size
        )
        rightGlassRect = CGRect(
            origin: CGPoint(x: left + glassWidth + glassMiddleMargin, y: top),
            size: size
        )
    }
    
    private func createCanvasRect(_ frame: CGRect) {
        let size = getSize(frame)
        canvasRect = CGRect(
            origin: CGPoint(x: (frame.width - size.width) / 2.0, y: WindowDimens.padding),
            size: size
        )
    }
    
    private func getSize(_ frame: CGRect) -> CGSize {
        let ratio = frame.width / frame.height
        if (ratio > WindowDimens.ratio) {
            let height = frame.height - WindowDimens.padding * 2
            return CGSize(width: height * WindowDimens.ratio, height: height)
        } else {
            let width = frame.width - WindowDimens.padding * 2
            return CGSize(width: width, height: width / WindowDimens.ratio)
        }
    }
}
