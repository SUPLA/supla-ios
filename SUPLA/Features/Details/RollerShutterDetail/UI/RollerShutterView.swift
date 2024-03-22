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

// MARK: - Default dimensions

let ROLLER_SHUTTER_VIEW_RATIO = DefaultDimens.ratio

private enum DefaultDimens {
    static let width: CGFloat = 288
    static let height: CGFloat = 336
    static var ratio: CGFloat { width / height }
    
    static let topLineHeight: CGFloat = 16
    static let slatsCount: Int = .init(ceil((height - topLineHeight) / slatHeight))
    static let slatHeight: CGFloat = 24
    static let slatDistance: CGFloat = 5
    
    static let windowHorizontalMargin: CGFloat = 16
    static let glassMiddelMargin: CGFloat = 20
    static let glassHorizontalMargin: CGFloat = 18
    static let glassVerticalMargin: CGFloat = 24
    static let slatHorizontalMargin: CGFloat = 8
    
    static let markerHeight: CGFloat = 8
    static let markerWidth: CGFloat = 28
    
    static let windowCornerRadius: CGFloat = 8
    
    static let shadowRadius: CGFloat = 3
    static let shadowOffset: CGSize = .init(width: 0, height: 1.5)
    static let shadowOpacity: Float = 0.15
}

// MARK: - RollerShutterView

class RollerShutterView: UIView {
    var isEnabled: Bool {
        get { fatalError("Not implemented!") }
        set {
            if (newValue) {
                colors = WindowColors.standard()
            } else {
                colors = WindowColors.offline()
            }
            updateColors()
        }
    }
    
    var position: CGFloat = 95 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var bottomPosition: CGFloat = 80 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var markers: [CGFloat] = [] {
        didSet {
            if (oldValue.count != markers.count) {
                dimens.setMarkers(markers.count)
                setupMarkers(markers.count)
            }
            setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: DefaultDimens.width, height: DefaultDimens.height)
    }
    
    private lazy var windowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = colors.window.cgColor
        layer.cornerRadius = DefaultDimens.windowCornerRadius
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.setupShadow(colors.shadow)
        return layer
    }()
    
    private lazy var topLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = colors.window.cgColor
        layer.setupShadow(colors.shadow)
        return layer
    }()
    
    private lazy var leftGlassLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        return layer
    }()
    
    private lazy var rightGlassLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        return layer
    }()
    
    private lazy var slatsLayers: [CAShapeLayer] = {
        var layers: [CAShapeLayer] = []
        
        for i in 0 ..< DefaultDimens.slatsCount {
            let layer = CAShapeLayer()
            layer.setupSlat(colors)
            layers.append(layer)
        }
        
        return layers
    }()
    
    private lazy var markersLayers: [CAShapeLayer] = []
    
    private let dimens = RuntimeDimens()
    private var colors = WindowColors.standard()
    
    // Touch handling
    private var startPosition: CGPoint? = nil
    private var startPercentage: CGFloat? = nil
    fileprivate let positionRelay: PublishRelay<CGFloat> = PublishRelay()
    fileprivate let positionChangeRelay: PublishRelay<CGFloat> = PublishRelay()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        dimens.update(frame)
        
        windowLayer.frame = dimens.windowRect
        leftGlassLayer.frame = dimens.leftGlassRect
        rightGlassLayer.frame = dimens.rightGlassRect
        updateSlatsPositions()
        topLineLayer.frame = dimens.topLineRect
        updateMarkersPositions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = event?.allTouches?.first?.location(in: self) else { return }
        if (dimens.canvasRect.contains(point)) {
            startPosition = point
            startPercentage = position
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startPosition = startPosition,
              let startPercentage = startPercentage,
              let currentPosition = event?.allTouches?.first?.location(in: self) else { return }
        
        let positionDiffAsPercentage = (currentPosition.y - startPosition.y)
            .divideToPercentage(value: dimens.windowRect.height)
        position = (startPercentage + positionDiffAsPercentage).toPercentage(max: 100)
        positionRelay.accept(position)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (startPosition != nil && startPercentage != nil) {
            positionChangeRelay.accept(position)
            startPosition = nil
            startPercentage = nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        CALayer.performWithoutAnimation {
            updateSlatsPositions()
            updateMarkersPositions()
        }
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.addSublayer(windowLayer)
        layer.addSublayer(leftGlassLayer)
        layer.addSublayer(rightGlassLayer)
        slatsLayers.forEach { layer.addSublayer($0) }
        layer.addSublayer(topLineLayer)
    }
    
    private func updateSlatsPositions() {
        let positionCorrectedByBottomPosition = (position / bottomPosition)
            .run { $0 > 1 ? 1 : $0 }
        
        let topCorrection = dimens.windowRect.height * (1 - positionCorrectedByBottomPosition)
        let slatDistancesPercentage = bottomPosition == 100 ? 1 : (100 - position)
            .run { $0 / (100 - bottomPosition) }
            .run { $0 > 1 ? 1 : $0 }
        
        var availableSpaceForDistances = dimens.slatsDistances * slatDistancesPercentage
        var currentCorrection = topCorrection + dimens.slatsDistances * slatDistancesPercentage
        for i in 0 ..< DefaultDimens.slatsCount {
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
    
    private func updateMarkersPositions() {
        for i in 0 ..< markers.count {
            let topCorrection = (dimens.windowRect.height - dimens.topLineRect.height/2) * markers[i] / 100
            let frame = dimens.markers[i].offsetBy(dx: 0, dy: topCorrection)
            markersLayers[i].path = dimens.markerPath.cgPath
            markersLayers[i].frame = frame
        }
    }
    
    private func updateColors() {
        windowLayer.backgroundColor = colors.window.cgColor
        windowLayer.setupShadow(colors.shadow)
        
        topLineLayer.backgroundColor = colors.window.cgColor
        topLineLayer.setupShadow(colors.shadow)
        
        leftGlassLayer.colors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        rightGlassLayer.colors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        
        for slatsLayer in slatsLayers {
            slatsLayer.backgroundColor = colors.slatBackground.cgColor
            slatsLayer.borderColor = colors.slatBorder.cgColor
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
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension Reactive where Base: RollerShutterView {
    var position: Observable<CGFloat> {
        base.positionRelay.asObservable()
    }
    
    var positionChange: Observable<CGFloat> {
        base.positionChangeRelay.asObservable()
    }
}

// MARK: - Runtime dimensions

private class RuntimeDimens {
    var scale: CGFloat = 1
    
    var canvasRect: CGRect = .zero
    var topLineRect: CGRect = .zero
    var windowRect: CGRect = .zero
    var leftGlassRect: CGRect = .zero
    var rightGlassRect: CGRect = .zero
    var slats: [CGRect] = .init(repeating: .zero, count: DefaultDimens.slatsCount)
    var markerPath: UIBezierPath = .init()
    var markers: [CGRect] = []
    var slatDistance: CGFloat = 0
    var slatsDistances: CGFloat = 0
    
    func update(_ frame: CGRect) {
        createCanvasRect(frame)
        scale = canvasRect.width / DefaultDimens.width
        
        createTopLineRect()
        createWindowRect()
        createGlassRects()
        createSlatRects()
        
        slatDistance = DefaultDimens.slatDistance * scale
        slatsDistances = slatDistance * CGFloat(DefaultDimens.slatsCount - 1)
        createMarkersRects()
    }
    
    func setMarkers(_ markersCount: Int) {
        markers = .init(repeating: .zero, count: markersCount)
    }
    
    private func createCanvasRect(_ frame: CGRect) {
        let size = getSize(frame)
        canvasRect = CGRect(origin: CGPoint(x: (frame.width - size.width) / 2.0, y: 0.0), size: size)
    }
    
    private func createTopLineRect() {
        topLineRect = CGRect(
            origin: canvasRect.origin,
            size: CGSize(width: canvasRect.width, height: DefaultDimens.topLineHeight * scale)
        )
    }
    
    private func createWindowRect() {
        let windowHorizontalMargin = DefaultDimens.windowHorizontalMargin * scale
        let windowTop = topLineRect.height / 2
        let windowSize = CGSize(
            width: canvasRect.width - windowHorizontalMargin * 2,
            height: canvasRect.height - windowTop
        )
        let windowOrigin = CGPoint(x: canvasRect.minX + windowHorizontalMargin, y: windowTop)
        
        windowRect = CGRect(origin: windowOrigin, size: windowSize)
    }
    
    private func createGlassRects() {
        let glassHorizontalMargin = DefaultDimens.glassHorizontalMargin * scale
        let glassVerticalMargin = DefaultDimens.glassVerticalMargin * scale
        let glassMiddleMargin = DefaultDimens.glassMiddelMargin * scale
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
    
    private func createSlatRects() {
        let slatHorizontalMargin = DefaultDimens.slatHorizontalMargin * scale
        let slatSize = CGSize(
            width: canvasRect.width - slatHorizontalMargin * 2,
            height: DefaultDimens.slatHeight * scale
        )
        
        let top = windowRect.maxY - CGFloat(DefaultDimens.slatsCount) * slatSize.height
        
        for i in 0 ..< DefaultDimens.slatsCount {
            slats[i] = CGRect(
                origin: CGPoint(x: canvasRect.minX + slatHorizontalMargin, y: top + CGFloat(i) * slatSize.height),
                size: slatSize
            )
        }
    }
    
    private func createMarkersRects() {
        let markerWidth = DefaultDimens.markerWidth * scale
        let markerHeight = DefaultDimens.markerHeight * scale
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
    
    private func getSize(_ frame: CGRect) -> CGSize {
        let ratio = frame.width / frame.height
        if (ratio > DefaultDimens.ratio) {
            return CGSize(width: frame.height * DefaultDimens.ratio, height: frame.height)
        } else {
            return CGSize(width: frame.width, height: frame.width / DefaultDimens.ratio)
        }
    }
}

// MARK: - Extensions

private extension CAShapeLayer {
    func setupShadow(_ color: UIColor) {
        shadowColor = color.cgColor
        shadowRadius = DefaultDimens.shadowRadius
        shadowOpacity = DefaultDimens.shadowOpacity
        shadowOffset = DefaultDimens.shadowOffset
    }
    
    func setupSlat(_ colors: WindowColors) {
        backgroundColor = colors.slatBackground.cgColor
        borderWidth = 1
        borderColor = colors.slatBorder.cgColor
    }
}
