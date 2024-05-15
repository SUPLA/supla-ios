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

class RollerShutterView: BaseWallWindowView<RollerShutterWindowState> {
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
        super.init(RuntimeDimens())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateSlatsPositions(_ slatsLayers: [CAShapeLayer], _ dimens: RuntimeWindowDimens) {
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
        for i in 0 ..< DefaultWindowDimens.slatsCount {
            let frame = dimens.slats[i].offsetBy(dx: 0, dy: -currentCorrection)
            if (frame.maxY < 0) {
                slatsLayers[i].frame = CGRect(x: frame.minX, y: 0, width: frame.width, height: 0)
            } else if (frame.minY < 0) {
                slatsLayers[i].frame = CGRect(x: frame.minX, y: 0, width: frame.width, height: frame.maxY)
            } else {
                slatsLayers[i].frame = frame
            }
            
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

private class RuntimeDimens: RuntimeWindowDimens {
    override func getSlatDistance() -> CGFloat { DefaultWindowDimens.slatDistance * scale }
    
    override func createSlatRects() {
        let slatHorizontalMargin = DefaultWindowDimens.slatHorizontalMargin * scale
        let slatSize = CGSize(
            width: canvasRect.width - slatHorizontalMargin * 2,
            height: DefaultWindowDimens.slatHeight * scale
        )
        
        let top = windowRect.maxY - CGFloat(DefaultWindowDimens.slatsCount) * slatSize.height
        
        for i in 0 ..< DefaultWindowDimens.slatsCount {
            slats[i] = CGRect(
                origin: CGPoint(x: canvasRect.minX + slatHorizontalMargin, y: top + CGFloat(i) * slatSize.height),
                size: slatSize
            )
        }
    }
    
    override func createMarkersRects() {
        let markerWidth = DefaultWindowDimens.markerWidth * scale
        let markerHeight = DefaultWindowDimens.markerHeight * scale
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
