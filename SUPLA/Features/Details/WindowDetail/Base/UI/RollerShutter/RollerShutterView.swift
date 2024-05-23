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

import RxRelay
import RxSwift

// MARK: - RollerShutterView

class RollerShutterView: BaseWallWindowView<RollerShutterWindowState, RollerShutterRuntimeDimens> {
    override var windowState: RollerShutterWindowState? {
        didSet {
            if let markers = windowState?.markers,
               oldValue?.markers.count != markers.count
            {
                dimens.setMarkers(markers.count)
                setupMarkers(markers.count)
            }
            setNeedsLayout()
        }
    }
    
    private lazy var markersLayers: [CAShapeLayer] = []
    
    init() {
        super.init(RollerShutterRuntimeDimens())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawShadowingElements(_ context: CGContext, _ dimens: RollerShutterRuntimeDimens) {
        guard let position = windowState?.position.value,
              let bottomPosition = windowState?.bottomPosition
        else {
            return
        }
        
        let positionCorrectedByBottomPosition = (position / bottomPosition)
            .run { $0 > 1 ? 1 : $0 }
        
        let topCorrection = dimens.windowRect.height * (1 - positionCorrectedByBottomPosition)
        let slatDistancesPercentage = bottomPosition == 100 ? 1 : (100 - position)
            .run { $0 / (100 - bottomPosition) }
            .run { $0 > 1 ? 1 : $0 }
        
        var availableSpaceForDistances = dimens.slatsDistances * slatDistancesPercentage
        var currentCorrection = topCorrection + dimens.slatsDistances * slatDistancesPercentage
        
        for i in 0 ..< SlatDimens.count {
            let frame = dimens.slats[i].offsetBy(dx: 0, dy: -currentCorrection)
            let rect = if (frame.maxY < 0) {
                CGRect(x: frame.minX, y: 0, width: frame.width, height: 0)
            } else if (frame.minY < 0) {
                CGRect(x: frame.minX, y: 0, width: frame.width, height: frame.maxY)
            } else {
                frame
            }
            
            drawPath(context, fillColor: colors.slatBackground) { UIBezierPath(rect: rect).cgPath }
            drawPath(context, strokeColor: colors.slatBorder) { UIBezierPath(rect: rect).cgPath }
            
            if (availableSpaceForDistances > dimens.slatDistance) {
                currentCorrection -= dimens.slatDistance
            } else if (availableSpaceForDistances > 0) {
                currentCorrection -= availableSpaceForDistances
            }
            
            availableSpaceForDistances -= dimens.slatDistance
        }
    }
    
    override func updateMarkersPositions() {
        if (isMoving) {
            markersLayers.forEach { $0.path = nil }
        } else {
            let markers = windowState?.markers ?? []
            
            for i in 0 ..< markers.count {
                let topCorrection = (dimens.windowRect.height - dimens.topLineRect.height / 2) * markers[i] / 100
                let frame = dimens.markers[i].offsetBy(dx: 0, dy: topCorrection)
                markersLayers[i].path = dimens.markerPath.cgPath
                markersLayers[i].frame = frame
            }
        }
    }
    
    private func setupMarkers(_ count: Int) {
        if (!markersLayers.isEmpty) {
            markersLayers.forEach { $0.removeFromSuperlayer() }
            markersLayers.removeAll()
        }
    
        for _ in 0 ..< count {
            let markerLayer = CAShapeLayer()
            markerLayer.strokeColor = UIColor.black.cgColor
            markerLayer.lineWidth = 1
            markerLayer.fillColor = UIColor.primaryVariant.cgColor
    
            layer.addSublayer(markerLayer)
    
            markersLayers.append(markerLayer)
        }
    }
}

// MARK: - Runtime dimensions

class RollerShutterRuntimeDimens: BaseWallWindowDimens {
    
    static let markerHeight: CGFloat = 8
    static let markerWidth: CGFloat = 28
    
    var slats: [CGRect] = .init(repeating: .zero, count: SlatDimens.count)
    var markerPath: UIBezierPath = .init()
    var markers: [CGRect] = []
    var slatDistance: CGFloat = 0
    var slatsDistances: CGFloat = 0
    
    override func update(_ frame: CGRect) {
        super.update(frame)
        
        createSlatRects()
        
        slatDistance = getSlatDistance()
        slatsDistances = slatDistance * CGFloat(SlatDimens.count - 1)
        
        createMarkersRects()
    }
    
    func setMarkers(_ markersCount: Int) {
        markers = .init(repeating: .zero, count: markersCount)
    }
    
    private func getSlatDistance() -> CGFloat { SlatDimens.distance * scale }
    
    private func createSlatRects() {
        let slatHorizontalMargin = SlatDimens.horizontalMargin * scale
        let slatSize = CGSize(
            width: canvasRect.width - slatHorizontalMargin * 2,
            height: SlatDimens.height * scale
        )
        
        let top = windowRect.maxY - CGFloat(SlatDimens.count) * slatSize.height
        
        for i in 0 ..< SlatDimens.count {
            slats[i] = CGRect(
                origin: CGPoint(x: canvasRect.minX + slatHorizontalMargin, y: top + CGFloat(i) * slatSize.height),
                size: slatSize
            )
        }
    }
    
    private func createMarkersRects() {
        let markerWidth = RollerShutterRuntimeDimens.markerWidth * scale
        let markerHeight = RollerShutterRuntimeDimens.markerHeight * scale
        let halfHeight = markerHeight / 2
        
        markerPath.removeAllPoints()
        markerPath.move(to: CGPoint(x: 0, y: halfHeight))
        markerPath.addLine(to: CGPoint(x: halfHeight, y: 0))
        markerPath.addLine(to: CGPoint(x: markerWidth, y: 0))
        markerPath.addLine(to: CGPoint(x: markerWidth, y: markerHeight))
        markerPath.addLine(to: CGPoint(x: halfHeight, y: markerHeight))
        markerPath.addLine(to: CGPoint(x: 0, y: halfHeight))
        markerPath.close()
        
        for i in 0 ..< markers.count {
            markers[i] = CGRect(
                x: windowRect.minX,
                y: topLineRect.maxY - halfHeight,
                width: markerWidth,
                height: markerHeight
            )
        }
    }
}
