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

class VerticalBlindsView: BaseWallWindowView<VerticalBlindWindowState, VerticalBlindRuntimeDimens> {
    override var windowState: VerticalBlindWindowState? {
        didSet {
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
    
    private let markerPath: UIBezierPath = .init()
    
    init() {
        super.init(VerticalBlindRuntimeDimens())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawShadowingElements(_ context: CGContext, _ dimens: VerticalBlindRuntimeDimens) {
        guard let position = windowState?.markers.isEmpty == true || isMoving ? windowState?.position.value : windowState?.markers.map({ $0.position }).max() else { return }
        let tiltDegrees = windowState?.slatTiltDegrees ?? 0
        
        let correctedTilt = tiltDegrees <= tiltHalfRangeDegrees ? tiltDegrees : tiltRangeDegrees - tiltDegrees
        let verticalSlatCorrection = ((maxTilt * correctedTilt / tiltHalfRangeDegrees / 2) + minTilt)
            .also { tiltDegrees <= tiltHalfRangeDegrees ? $0 : -$0 }
        
        let leftCorrection = position * dimens.movementLimit / 100
        
        drawSlats(context, dimens.leftSlats, leftCorrection - dimens.movementLimit, correctedTilt, verticalSlatCorrection)
        drawSlats(context, dimens.rightSlats, dimens.movementLimit - leftCorrection, correctedTilt, verticalSlatCorrection)
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
        let positionDiffAsPercentage = (currentPosition.x - startPosition.x)
            .divideToPercentage(value: touchRect.width / 2)
            .run { startPosition.x < touchRect.midX ? $0 : -$0 }
        
        
        let position = (startPercentage + positionDiffAsPercentage).limit(max: 100)
        windowState?.position = .similar(position)
        
        guard let startTilt = startTilt else { return }
        
        let minHorizontalDistance: CGFloat = 15
        tiltChangeAllowed = tiltChangeAllowed || abs(currentPosition.y - startPosition.y) > minHorizontalDistance
        
        let tiltDiffAsPercentage = (currentPosition.y - startPosition.y)
            .divideToPercentage(value: touchRect.width / 2)
        let tilt = (startTilt + tiltDiffAsPercentage).limit(max: 100)
        
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
    
    override func drawMarkers(_ context: CGContext, _ dimens: VerticalBlindRuntimeDimens) {
        if (isMoving) {
            return // No markers when user interacts with view
        }
        
        let markers = windowState?.markers ?? []
        let markerDiameter = dimens.markerInfoRadius * 2
        
        let tilt0 = windowState?.tilt0Angle ?? DEFAULT_TILT_0_ANGLE
        let tilt100 = windowState?.tilt100Angle ?? DEFAULT_TILT_100_ANGLE
        
        for marker in markers {
            markerPath.removeAllPoints()
            let leftCorrection = marker.position * dimens.movementLimit / 100
            let markerRect = CGRect(
                x: dimens.topLineRect.minX + leftCorrection + dimens.slatWidth - dimens.markerInfoRadius,
                y: dimens.topLineRect.maxY - dimens.markerInfoRadius,
                width: markerDiameter,
                height: markerDiameter
            )
            markerPath.append(UIBezierPath(ovalIn: markerRect))
            
            let degrees = tilt0 + (tilt100 - tilt0) * marker.tilt / 100
            let correctedDegree = SlatTiltSlider.trimAngle(Float(degrees))
            let angle = CGFloat(correctedDegree) * .pi / 180
            
            let translationX = -markerRect.minX - dimens.markerInfoRadius
            let translationY = -markerRect.minY - dimens.markerInfoRadius
            let startPoint = CGPoint(x: -dimens.markerInfoRadius / 2, y: 0)
            let endPoint = CGPoint(x: dimens.markerInfoRadius / 2, y: 0)
            
            markerPath.apply(CGAffineTransform(translationX: translationX, y: translationY))
            markerPath.apply(CGAffineTransform(rotationAngle: -angle))
            markerPath.move(to: startPoint)
            markerPath.addLine(to: endPoint)
            markerPath.apply(CGAffineTransform(rotationAngle: angle))
            markerPath.apply(CGAffineTransform(translationX: -translationX, y: -translationY))
            
            markerPath.apply(CGAffineTransform(translationX: translationX, y: translationY - 3))
            markerPath.apply(CGAffineTransform(rotationAngle: -angle))
            markerPath.move(to: startPoint)
            markerPath.addLine(to: endPoint)
            markerPath.apply(CGAffineTransform(rotationAngle: angle))
            markerPath.apply(CGAffineTransform(translationX: -translationX, y: -translationY + 3))
            
            markerPath.apply(CGAffineTransform(translationX: translationX, y: translationY + 3))
            markerPath.apply(CGAffineTransform(rotationAngle: -angle))
            markerPath.move(to: startPoint)
            markerPath.addLine(to: endPoint)
            markerPath.apply(CGAffineTransform(rotationAngle: angle))
            markerPath.apply(CGAffineTransform(translationX: -translationX, y: -translationY - 3))
            
            drawPath(context, fillColor: colors.slatBackground) { markerPath.cgPath }
            drawPath(context, strokeColor: colors.markerBorder) { markerPath.cgPath }
        }
    }
    
    private func drawSlats(_ context: CGContext, _ slats: [CGRect], _ correction: CGFloat, _ correctedTilt: CGFloat, _ verticalSlatCorrection: CGFloat) {
        for slat in slats {
            let frame = slat.offsetBy(dx: correction, dy: 0)
            
            let maxSlatCorrection = frame.width - 4
            let horizontalSlatCorrection = maxSlatCorrection * correctedTilt / tiltHalfRangeDegrees / 2
            
            let rect = if (frame.minX < dimens.topLineRect.minX) {
                CGRect(x: dimens.topLineRect.minX, y: frame.minY, width: frame.width, height: frame.height)
            } else if (frame.maxX > dimens.topLineRect.maxX) {
                CGRect(x: dimens.topLineRect.maxX - frame.width, y: frame.minY, width: frame.width, height: frame.height)
            } else {
                frame
            }
            
            if (rect.maxY > dimens.topLineRect.maxY) {
                let path = getSlatPath(rect, verticalSlatCorrection, horizontalSlatCorrection)
                
                drawPath(context, fillColor: colors.slatBackground) { path }
                drawPath(context, strokeColor: colors.slatBorder) { path }
            }
        }
    }
    
    private func getSlatPath(
        _ rect: CGRect,
        _ verticalSlatCorrection: CGFloat,
        _ horizontalSlatCorrection: CGFloat
    ) -> CGPath {
        dimens.slatPath.removeAllPoints()
        dimens.slatPath.move(
            to: CGPoint(
                x: rect.minX + horizontalSlatCorrection,
                y: rect.minY
            )
        )
        dimens.slatPath.addLine(
            to: CGPoint(
                x: rect.maxX - horizontalSlatCorrection,
                y: rect.minY
            )
        )
        dimens.slatPath.addLine(
            to: CGPoint(
                x: rect.maxX - horizontalSlatCorrection,
                y: rect.maxY + verticalSlatCorrection
            )
        )
        dimens.slatPath.addLine(
            to: CGPoint(
                x: rect.minX + horizontalSlatCorrection,
                y: rect.maxY - verticalSlatCorrection
            )
        )
        dimens.slatPath.close()
        return dimens.slatPath.cgPath
    }
}

extension Reactive where Base: VerticalBlindsView {
    var positionAndTilt: Observable<CGPoint> {
        base.moveRelay.asObservable()
    }
    
    var positionAndTiltSet: Observable<CGPoint> {
        base.moveFinishedRelay.asObservable()
    }
}

// MARK: - Runtime dimensions

class VerticalBlindRuntimeDimens: BaseWallWindowDimens {
    static let markerInfoRadius: CGFloat = 14
    static let slatsCount = 5
    static let slatDistance: CGFloat = 4
    static let slatWidth: CGFloat = 24
    static let slatHeight: CGFloat = 308
    
    var leftSlats: [CGRect] = .init(repeating: .zero, count: slatsCount)
    var rightSlats: [CGRect] = .init(repeating: .zero, count: slatsCount)
    var markerInfoRadius: CGFloat = 0
    var slatPath: UIBezierPath = .init()
    var movementLimit: CGFloat = 0
    
    var slatWidth: CGFloat = 0
    var slatHeight: CGFloat = 0
    var slatDistance: CGFloat = 0
    
    override func calculateDimens(_ frame: CGRect) {
        super.calculateDimens(frame)
        
        slatDistance = VerticalBlindRuntimeDimens.slatDistance * scale
        slatWidth = VerticalBlindRuntimeDimens.slatWidth * scale
        slatHeight = VerticalBlindRuntimeDimens.slatHeight * scale
        
        createLeftSlatRects()
        createRightSlatRects()
        
        let slatWidth = VerticalBlindRuntimeDimens.slatWidth * scale
        let slatDistance = VerticalBlindRuntimeDimens.slatDistance * scale
        movementLimit = topLineRect.width / 2 - slatWidth - slatDistance
        
        markerInfoRadius = VerticalBlindRuntimeDimens.markerInfoRadius * scale
    }
    
    private func createLeftSlatRects() {
        let slatSize = CGSize(width: slatWidth, height: slatHeight)
        let slatSpace = slatSize.width + slatDistance
        let top = topLineRect.maxY
        
        for i in 0 ..< VerticalBlindRuntimeDimens.slatsCount {
            leftSlats[i] = CGRect(
                origin: CGPoint(x: topLineRect.minX + slatSpace * CGFloat(i), y: top),
                size: slatSize
            )
        }
    }
    
    private func createRightSlatRects() {
        let slatSize = CGSize(width: slatWidth, height: slatHeight)
        let slatSpace = slatSize.width + slatDistance
        let top = topLineRect.maxY
        let left = topLineRect.maxX - slatSize.width
        
        for i in 0 ..< VerticalBlindRuntimeDimens.slatsCount {
            rightSlats[i] = CGRect(
                origin: CGPoint(x: left - slatSpace * CGFloat(i), y: top),
                size: slatSize
            )
        }
    }
}
