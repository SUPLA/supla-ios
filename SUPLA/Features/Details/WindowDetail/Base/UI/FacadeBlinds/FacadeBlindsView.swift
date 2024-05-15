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

class FacadeBlindsView: BaseWallWindowView<FacadeBlindWindowState> {
    
    override var windowState: FacadeBlindWindowState? {
        didSet {
            if let markers = windowState?.markers, oldValue?.markers.count != markers.count {
                dimens.setMarkers(markers.count)
                setupMarkers(markers.count)
            }
            setNeedsLayout()
        }
    }
    
    // Configuration
    private let maxTilt: CGFloat = 8
    private let minTilt: CGFloat = 1
    private let tiltRangeDegrees: CGFloat = 180
    private let tiltHalfRangeDegrees: CGFloat = 90
    
    // Events
    fileprivate let moveRelay: PublishRelay<CGPoint> = PublishRelay()
    fileprivate let moveFinishedRelay: PublishRelay<CGPoint> = PublishRelay()
    
    private var tiltChangeAllowed = false
    private var startTilt: CGFloat? = nil
    
    private lazy var markersLayers: [CAShapeLayer] = []
    private lazy var markerPath: UIBezierPath = .init()
    
    init() {
        super.init(RuntimeDimens())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateSlatsPositions(_ slatsLayers: [CAShapeLayer], _ dimens: RuntimeWindowDimens) {
        guard let position = windowState?.position.value
        else {
            return
        }
        let tiltDegrees = windowState?.slatTiltDegrees ?? 0
        
        let correctedTilt = tiltDegrees <= tiltHalfRangeDegrees ? tiltDegrees : tiltRangeDegrees - tiltDegrees
        let horizontalSlatCorrection = ((maxTilt * correctedTilt / tiltHalfRangeDegrees / 2) + minTilt)
            .also { tiltDegrees <= tiltHalfRangeDegrees ? $0 : -$0 }
        
        var currentCorrection = dimens.windowRect.height * (1 - position / 100)
        for i in 0 ..< DefaultWindowDimens.slatsCount {
            let frame = dimens.slats[i].offsetBy(dx: 0, dy: -currentCorrection)
            
            let maxSlatCorrection = frame.height - 4
            let verticalSlatCorrection = maxSlatCorrection * correctedTilt / tiltHalfRangeDegrees / 2
            
            if (frame.maxY < 0) {
                slatsLayers[i].frame = CGRect(x: frame.minX, y: 0, width: frame.width, height: 0)
            } else if (frame.minY < 0) {
                slatsLayers[i].frame = CGRect(x: frame.minX, y: 0, width: frame.width, height: frame.maxY)
            } else {
                slatsLayers[i].frame = frame
            }
            
            if (frame.maxY < dimens.topLineRect.maxY) {
                slatsLayers[i].path = nil
            } else {
                let path = UIBezierPath()
                path.move(
                    to: CGPoint(
                        x: horizontalSlatCorrection,
                        y: 1 + verticalSlatCorrection
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: slatsLayers[i].frame.width - horizontalSlatCorrection,
                        y: 1 + verticalSlatCorrection
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: slatsLayers[i].frame.width + horizontalSlatCorrection,
                        y: frame.height - verticalSlatCorrection
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: -horizontalSlatCorrection,
                        y: frame.height - verticalSlatCorrection
                    )
                )
                path.close()
                slatsLayers[i].path = path.cgPath
            }
            
            currentCorrection -= dimens.slatDistance
        }
    }
    
    override func setupSlat(_ layer: CAShapeLayer, _ colors: WindowColors) {
        layer.fillColor = colors.slatBackground.cgColor
        layer.strokeColor = colors.slatBorder.cgColor
        layer.lineWidth = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let point = event?.allTouches?.first?.location(in: self) else { return }
        
        if (isEnabled && touchRect.contains(point)) {
            startTilt = windowState?.slatTilt?.value
            tiltChangeAllowed = false
        }
    }
    
    override func handleMovement(_ startPosition: CGPoint, _ startPercentage: CGFloat, _ currentPosition: CGPoint) {
        super.handleMovement(startPosition, startPercentage, currentPosition)
        
        guard let startTilt = startTilt else { return }
        
        let minHorizontalDistance: CGFloat = 15
        tiltChangeAllowed = tiltChangeAllowed || abs(currentPosition.x - startPosition.x) > minHorizontalDistance
        
        let tiltDiffAsPercentage = (currentPosition.x - startPosition.x)
            .divideToPercentage(value: touchRect.width / 2)
        let tilt = (startTilt + tiltDiffAsPercentage).toPercentage(max: 100)
        
        let position = windowState?.position.value ?? 0
        if (tiltChangeAllowed) {
            moveRelay.accept(CGPoint(x: tilt, y: position))
        } else {
            moveRelay.accept(CGPoint(x: startTilt, y: position))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if (startTilt != nil), let tiltPercentage = windowState?.slatTilt?.value {
            let position = windowState?.position.value ?? 0
            moveFinishedRelay.accept(CGPoint(x: tiltPercentage, y: position))
        }
        startTilt = nil
    }
    
    override func updateMarkersPositions() {
        if (isMoving) {
            markersLayers.forEach { $0.path = nil }
        } else {
            let markers = windowState?.markers ?? []
            
            for i in 0 ..< markers.count {
                let topCorrection = (dimens.windowRect.height - dimens.topLineRect.height / 2) * markers[i].position / 100
                let frame = dimens.markers[i].offsetBy(dx: 0, dy: topCorrection)
                
                let tilt0 = windowState?.tilt0Angle ?? DEFAULT_TILT_0_ANGLE
                let tilt100 = windowState?.tilt100Angle ?? DEFAULT_TILT_100_ANGLE
                let degrees = tilt0 + (tilt100 - tilt0) * markers[i].tilt / 100
                let correctedDegree = SlatTiltSlider.trimAngle(Float(degrees))
                let angle = CGFloat(correctedDegree) * .pi / 180
                
                markerPath.removeAllPoints()
                markerPath.apply(CGAffineTransform(translationX: -dimens.markerInfoRadius, y: -dimens.markerInfoRadius))
                markerPath.apply(CGAffineTransform(rotationAngle: -angle))
                markerPath.move(to: CGPoint(x: -dimens.markerInfoRadius/2, y: 0))
                markerPath.addLine(to: CGPoint(x: dimens.markerInfoRadius/2, y: 0))
                markerPath.apply(CGAffineTransform(rotationAngle: angle))
                markerPath.apply(CGAffineTransform(translationX: dimens.markerInfoRadius, y: dimens.markerInfoRadius))
                
                markerPath.apply(CGAffineTransform(translationX: -dimens.markerInfoRadius, y: -dimens.markerInfoRadius-3))
                markerPath.apply(CGAffineTransform(rotationAngle: -angle))
                markerPath.move(to: CGPoint(x: -dimens.markerInfoRadius/2, y: 0))
                markerPath.addLine(to: CGPoint(x: dimens.markerInfoRadius/2, y: 0))
                markerPath.apply(CGAffineTransform(rotationAngle: angle))
                markerPath.apply(CGAffineTransform(translationX: dimens.markerInfoRadius, y: dimens.markerInfoRadius+3))
                
                markerPath.apply(CGAffineTransform(translationX: -dimens.markerInfoRadius, y: -dimens.markerInfoRadius+3))
                markerPath.apply(CGAffineTransform(rotationAngle: -angle))
                markerPath.move(to: CGPoint(x: -dimens.markerInfoRadius/2, y: 0))
                markerPath.addLine(to: CGPoint(x: dimens.markerInfoRadius/2, y: 0))
                markerPath.apply(CGAffineTransform(rotationAngle: angle))
                markerPath.apply(CGAffineTransform(translationX: dimens.markerInfoRadius, y: dimens.markerInfoRadius-3))
                
                markersLayers[i].path = markerPath.cgPath
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
            markerLayer.backgroundColor = colors.slatBackground.cgColor
            markerLayer.borderColor = colors.slatBorder.cgColor
            markerLayer.borderWidth = 1
            markerLayer.cornerRadius = dimens.markerInfoRadius
            markerLayer.strokeColor = colors.markerBorder.cgColor
    
            layer.addSublayer(markerLayer)
    
            markersLayers.append(markerLayer)
        }
    }
}

extension Reactive where Base: FacadeBlindsView {
    var positionAndTilt: Observable<CGPoint> {
        base.moveRelay.asObservable()
    }
    
    var positionAndTiltSet: Observable<CGPoint> {
        base.moveFinishedRelay.asObservable()
    }
}

// MARK: - Runtime dimensions

private class RuntimeDimens: RuntimeWindowDimens {
    override func getSlatDistance() -> CGFloat { 0 }
    
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
        let markerDiameter = markerInfoRadius * 2
        for i in 0 ..< markers.count {
            markers[i] = CGRect(
                x: windowRect.minX - markerInfoRadius,
                y: topLineRect.maxY - markerInfoRadius,
                width: markerDiameter,
                height: markerDiameter
            )
        }
    }
}
