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
    private lazy var markerTextLayers: [CATextLayer] = []
    
    init() {
        super.init(FacadeBlindRuntimeDimens())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawShadowingElements(_ context: CGContext, _ dimens: FacadeBlindRuntimeDimens) {
        guard let position = windowState?.markers.isEmpty == true || isMoving ? windowState?.position.value : windowState?.markers.map({ $0.position }).max()
        else {
            return
        }
        let tiltDegrees = windowState?.windowTiltDegrees ?? 0
        
        let correctedTilt = tiltDegrees <= tiltHalfRangeDegrees ? tiltDegrees : tiltRangeDegrees - tiltDegrees
        let horizontalSlatCorrection = ((maxTilt * correctedTilt / tiltHalfRangeDegrees / 2) + minTilt)
            .also { tiltDegrees <= tiltHalfRangeDegrees ? $0 : -$0 }
        
        let currentCorrection = dimens.windowRect.height * (1 - position / 100)
        
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
            startTilt = windowState?.windowTilt?.value(for: .window)
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
        if (startTilt != nil), let tiltPercentage = windowState?.windowTilt?.value {
            let position = windowState?.position.value ?? 0
            moveFinishedRelay.accept(CGPoint(x: tiltPercentage, y: position))
        }
        startTilt = nil
    }

    override func updateMarkersPositions() {
        markersLayers.forEach { $0.cornerRadius = dimens.markerInfoRadius }

        let markers = windowState?.markers ?? []
        markersLayers.forEach { $0.isHidden = false }
        markerTextLayers.forEach { $0.isHidden = true }

        var cluster = FacadeBlindMarkerCluster()
        var clusterStartIndex = 0

        for (index, marker) in markers.enumerated() {
            let topCorrection = (dimens.windowRect.height - dimens.topLineRect.height / 2) * marker.position / 100
            let frame = dimens.markers[index].offsetBy(dx: 0, dy: topCorrection)

            if cluster.y == nil {
                cluster.first(y: frame.midY, marker: marker)
                clusterStartIndex = index
            } else if cluster.covers(y: frame.midY, radius: dimens.markerInfoRadius) {
                cluster.append(marker)
            } else {
                drawMarkerCluster(cluster, startingAt: clusterStartIndex, centerY: cluster.safeY, isMoving: isMoving)
                cluster.first(y: frame.midY, marker: marker)
                clusterStartIndex = index
            }
        }

        if cluster.y != nil {
            drawMarkerCluster(cluster, startingAt: clusterStartIndex, centerY: cluster.safeY, isMoving: isMoving)
        }
    }

    private func drawMarkerCluster(
        _ cluster: FacadeBlindMarkerCluster,
        startingAt index: Int,
        centerY: CGFloat,
        isMoving: Bool
    ) {
        let radius = dimens.markerInfoRadius
        let diameter = radius * 2
        let layer = markersLayers[index]
        let textLayer = markerTextLayers[index]

        if cluster.count > 1 && !cluster.shouldDrawAsSingleMarker {
            let text = cluster.hasTilt ? cluster.tiltRangeText : cluster.percentageText
            let font = UIFont.openSansSemiBold(style: .body, size: 10)
            let textSize = (text as NSString).size(withAttributes: [.font: font])
            let width = max(diameter, textSize.width + 8)
            let frame = CGRect(x: dimens.windowRect.minX - radius, y: centerY - radius, width: width, height: diameter)

            layer.frame = frame
            layer.bounds = CGRect(origin: .zero, size: frame.size)
            layer.cornerRadius = radius
            layer.path = nil
            textLayer.string = text
            textLayer.font = font
            textLayer.fontSize = font.pointSize
            textLayer.frame = CGRect(x: 0, y: (diameter - font.lineHeight) / 2, width: width, height: font.lineHeight)
            textLayer.isHidden = false

            for mergedIndex in (index + 1)..<(index + cluster.count) {
                markersLayers[mergedIndex].isHidden = true
                markerTextLayers[mergedIndex].isHidden = true
            }
            return
        }

        let frame = dimens.markers[index].offsetBy(dx: 0, dy: centerY - dimens.markers[index].midY)
        layer.frame = frame
        layer.bounds = CGRect(origin: .zero, size: frame.size)
        layer.cornerRadius = radius

        if isMoving {
            layer.path = nil
            textLayer.isHidden = true
            return
        }

        if let degrees = cluster.minTilt {
            layer.path = BlindsMarkerPath.slats(
                in: CGRect(origin: .zero, size: layer.bounds.size),
                degrees: degrees
            )
            textLayer.isHidden = true
        } else {
            layer.path = nil
            let text = cluster.minValue.map { getPercentageString(Double($0 / 100)) } ?? "?"
            let font = UIFont.systemFont(ofSize: 8, weight: .semibold)
            textLayer.string = text
            textLayer.font = font
            textLayer.fontSize = font.pointSize
            textLayer.frame = CGRect(x: 0, y: (diameter - font.lineHeight) / 2, width: diameter, height: font.lineHeight)
            textLayer.isHidden = false
        }
    }

    private func setupMarkers(_ count: Int) {
        if (!markersLayers.isEmpty) {
            markersLayers.forEach { $0.removeFromSuperlayer() }
            markersLayers.removeAll()
            markerTextLayers.removeAll()
        }
    
        for _ in 0 ..< count {
            let markerLayer = CAShapeLayer()
            markerLayer.backgroundColor = colors.slatBackground.cgColor
            markerLayer.borderColor = colors.slatBorder.cgColor
            markerLayer.borderWidth = 1
            markerLayer.cornerRadius = dimens.markerInfoRadius
            markerLayer.strokeColor = colors.markerBorder.cgColor

            let textLayer = CATextLayer()
            textLayer.alignmentMode = .center
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.foregroundColor = colors.markerBorder.cgColor
            markerLayer.addSublayer(textLayer)
    
            layer.addSublayer(markerLayer)
    
            markersLayers.append(markerLayer)
            markerTextLayers.append(textLayer)
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
    
    override func calculateDimens(_ frame: CGRect) {
        super.calculateDimens(frame)
        
        createSlatRects()
        
        markerInfoRadius = FacadeBlindRuntimeDimens.markerInfoRadius * scale
        createMarkersRects()
    }
    
    func setMarkers(_ markersCount: Int) {
        markers = .init(repeating: .zero, count: markersCount)
        createMarkersRects()
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

struct FacadeBlindMarkerCluster {
    private(set) var y: CGFloat?
    private(set) var minTilt: CGFloat?
    private(set) var maxTilt: CGFloat?
    private(set) var minValue: CGFloat?
    private(set) var maxValue: CGFloat?
    private(set) var count = 0

    var safeY: CGFloat { y ?? 0 }
    var hasTilt: Bool { minTilt != nil && maxTilt != nil }

    var shouldDrawAsSingleMarker: Bool {
        count == 1 ||
        (hasTilt && minTilt?.roundToInt() == maxTilt?.roundToInt()) ||
            (!hasTilt && minValue != nil && minValue?.roundToInt() == maxValue?.roundToInt())
    }

    var percentageText: String {
        guard let minValue, let maxValue else { return "?" }
        let minText = getPercentageString(Double(minValue / 100))
        let maxText = getPercentageString(Double(maxValue / 100))
        return minValue == maxValue ? minText : "\(minText) - \(maxText)"
    }

    var tiltRangeText: String {
        guard let minTilt, let maxTilt else { return "?" }
        return String(format: "%.0f° - %.0f°", minTilt, maxTilt)
    }

    mutating func first(y: CGFloat, marker: ShadingBlindMarker) {
        self.y = y
        minTilt = marker.tilt
        maxTilt = marker.tilt
        minValue = marker.tiltValue
        maxValue = marker.tiltValue
        count = 1
    }

    mutating func append(_ marker: ShadingBlindMarker) {
        minTilt = minValueOf(minTilt, marker.tilt)
        maxTilt = maxValueOf(maxTilt, marker.tilt)
        minValue = minValueOf(minValue, marker.tiltValue)
        maxValue = maxValueOf(maxValue, marker.tiltValue)
        count += 1
    }

    func covers(y: CGFloat, radius: CGFloat) -> Bool {
        guard let currentY = self.y else { return false }
        return abs(y - currentY) < radius * 2
    }

    private func minValueOf(_ first: CGFloat?, _ second: CGFloat?) -> CGFloat? {
        guard let first else { return second }
        guard let second else { return first }
        return min(first, second)
    }

    private func maxValueOf(_ first: CGFloat?, _ second: CGFloat?) -> CGFloat? {
        guard let first else { return second }
        guard let second else { return first }
        return max(first, second)
    }
}
