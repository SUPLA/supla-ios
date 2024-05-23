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

class FacadeBlindsView: BaseWallWindowView<FacadeBlindWindowState, FacadeBlindRuntimeDimens> {
    
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
        super.init(FacadeBlindRuntimeDimens())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawShadowingElements(_ context: CGContext, _ dimens: FacadeBlindRuntimeDimens) {
        guard let position = windowState?.position.value
        else {
            return
        }
        let tiltDegrees = windowState?.slatTiltDegrees ?? 0
        
        let correctedTilt = tiltDegrees <= tiltHalfRangeDegrees ? tiltDegrees : tiltRangeDegrees - tiltDegrees
        let horizontalSlatCorrection = ((maxTilt * correctedTilt / tiltHalfRangeDegrees / 2) + minTilt)
            .also { tiltDegrees <= tiltHalfRangeDegrees ? $0 : -$0 }
        
        var currentCorrection = dimens.windowRect.height * (1 - position / 100)
        
        for i in 0 ..< SlatDimens.count {
            let frame = dimens.slats[i].offsetBy(dx: 0, dy: -currentCorrection)
            
            let maxSlatCorrection = frame.height - 4
            let verticalSlatCorrection = maxSlatCorrection * correctedTilt / tiltHalfRangeDegrees / 2
            
            let rect = if (frame.maxY < 0) {
                CGRect(x: frame.minX, y: 0, width: frame.width, height: 0)
            } else if (frame.minY < 0) {
                CGRect(x: frame.minX, y: 0, width: frame.width, height: frame.maxY)
            } else {
                frame
            }
            
            if (rect.maxY > dimens.topLineRect.maxY) {
                let path = getSlatPath(rect, horizontalSlatCorrection, verticalSlatCorrection)
                
                drawPath(context, fillColor: colors.slatBackground) { path }
                drawPath(context, strokeColor: colors.slatBorder) { path }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let point = event?.allTouches?.first?.location(in: self) else { return }
        
        if (isEnabled && touchRect.contains(point)) {
            startTilt = windowState?.slatTilt?.value
            tiltChangeAllowed = false
        }
    }
    
    override func handleMovement(
        _ positionRelay: PublishRelay<CGFloat>,
        _ startPosition: CGPoint,
        _ startPercentage: CGFloat,
        _ currentPosition: CGPoint
    ) {
        super.handleMovement(positionRelay, startPosition, startPercentage, currentPosition)
        
        guard let startTilt = startTilt else { return }
        
        let minHorizontalDistance: CGFloat = 15
        tiltChangeAllowed = tiltChangeAllowed || abs(currentPosition.x - startPosition.x) > minHorizontalDistance
        
        let tiltDiffAsPercentage = (currentPosition.x - startPosition.x)
            .divideToPercentage(value: touchRect.width / 2)
        let tilt = (startTilt + tiltDiffAsPercentage).limit(max: 100)
        
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
    
    private func getSlatPath(
        _ rect: CGRect,
        _ horizontalSlatCorrection: CGFloat,
        _ verticalSlatCorrection: CGFloat
    ) -> CGPath {
        dimens.slatPath.removeAllPoints()
        dimens.slatPath.move(
            to: CGPoint(
                x: rect.minX + horizontalSlatCorrection,
                y: rect.minY + 1 + verticalSlatCorrection
            )
        )
        dimens.slatPath.addLine(
            to: CGPoint(
                x: rect.maxX - horizontalSlatCorrection,
                y: rect.minY + 1 + verticalSlatCorrection
            )
        )
        dimens.slatPath.addLine(
            to: CGPoint(
                x: rect.maxX + horizontalSlatCorrection,
                y: rect.maxY - verticalSlatCorrection
            )
        )
        dimens.slatPath.addLine(
            to: CGPoint(
                x: rect.minX - horizontalSlatCorrection,
                y: rect.maxY - verticalSlatCorrection
            )
        )
        dimens.slatPath.close()
        return dimens.slatPath.cgPath
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

class FacadeBlindRuntimeDimens: BaseWallWindowDimens {
    
    static let markerInfoRadius: CGFloat = 14
    
    var slats: [CGRect] = .init(repeating: .zero, count: SlatDimens.count)
    var markerInfoRadius: CGFloat = 0
    var markers: [CGRect] = []
    var slatPath: UIBezierPath = .init()
    
    override func update(_ frame: CGRect) {
        super.update(frame)
        
        createSlatRects()
        
        markerInfoRadius = FacadeBlindRuntimeDimens.markerInfoRadius * scale
        createMarkersRects()
    }
    
    func setMarkers(_ markersCount: Int) {
        markers = .init(repeating: .zero, count: markersCount)
    }
    
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
