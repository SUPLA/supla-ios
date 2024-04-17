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

class RuntimeWindowDimens {
    var scale: CGFloat = 1
    
    var canvasRect: CGRect = .zero
    var topLineRect: CGRect = .zero
    var windowRect: CGRect = .zero
    var leftGlassRect: CGRect = .zero
    var rightGlassRect: CGRect = .zero
    var slats: [CGRect] = .init(repeating: .zero, count: DefaultWindowDimens.slatsCount)
    var markerInfoRadius: CGFloat = 0
    var markerPath: UIBezierPath = .init()
    var markers: [CGRect] = []
    var slatDistance: CGFloat = 0
    var slatsDistances: CGFloat = 0
    
    func update(_ frame: CGRect) {
        createCanvasRect(frame)
        scale = canvasRect.width / DefaultWindowDimens.width
        
        createTopLineRect()
        createWindowRect()
        createGlassRects()
        createSlatRects()
        
        slatDistance = getSlatDistance()
        slatsDistances = slatDistance * CGFloat(DefaultWindowDimens.slatsCount - 1)
        
        markerInfoRadius = DefaultWindowDimens.markerInfoRadius * scale
        createMarkersRects()
    }
    
    func setMarkers(_ markersCount: Int) {
        markers = .init(repeating: .zero, count: markersCount)
    }
    
    func createSlatRects() {
        fatalError("createSlatRects() needs to be implemented")
    }
    
    func getSlatDistance() -> CGFloat {
        fatalError("createSlatDistance() needs to be implemented")
    }
    
    func createMarkersRects() {
        fatalError("createMarkersRects() needs to be implemented")
    }
    
    private func createCanvasRect(_ frame: CGRect) {
        let size = getSize(frame)
        canvasRect = CGRect(origin: CGPoint(x: (frame.width - size.width) / 2.0, y: 0.0), size: size)
    }
    
    private func createTopLineRect() {
        topLineRect = CGRect(
            origin: canvasRect.origin,
            size: CGSize(width: canvasRect.width, height: DefaultWindowDimens.topLineHeight * scale)
        )
    }
    
    private func createWindowRect() {
        let windowHorizontalMargin = DefaultWindowDimens.windowHorizontalMargin * scale
        let windowTop = topLineRect.height / 2
        let windowSize = CGSize(
            width: canvasRect.width - windowHorizontalMargin * 2,
            height: canvasRect.height - windowTop
        )
        let windowOrigin = CGPoint(x: canvasRect.minX + windowHorizontalMargin, y: windowTop)
        
        windowRect = CGRect(origin: windowOrigin, size: windowSize)
    }
    
    private func createGlassRects() {
        let glassHorizontalMargin = DefaultWindowDimens.glassHorizontalMargin * scale
        let glassVerticalMargin = DefaultWindowDimens.glassVerticalMargin * scale
        let glassMiddleMargin = DefaultWindowDimens.glassMiddelMargin * scale
        let glassWidth = (windowRect.width - (glassHorizontalMargin * 2) - glassMiddleMargin) / 2
        let glassHeight = canvasRect.height - (glassVerticalMargin * 2)
        
        let left = windowRect.minX + glassHorizontalMargin
        let size = CGSize(width: glassWidth, height: glassHeight)
        
        leftGlassRect = CGRect(
            origin: CGPoint(x: left, y: glassVerticalMargin),
            size: size
        )
        rightGlassRect = CGRect(
            origin: CGPoint(x: left + glassWidth + glassMiddleMargin, y: glassVerticalMargin),
            size: size
        )
    }
    
    private func getSize(_ frame: CGRect) -> CGSize {
        let ratio = frame.width / frame.height
        if (ratio > DefaultWindowDimens.ratio) {
            return CGSize(width: frame.height * DefaultWindowDimens.ratio, height: frame.height)
        } else {
            return CGSize(width: frame.width, height: frame.width / DefaultWindowDimens.ratio)
        }
    }
}

