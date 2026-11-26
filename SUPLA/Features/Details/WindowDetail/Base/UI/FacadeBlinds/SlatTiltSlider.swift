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

import RxSwift

struct SlatTiltSliderMarker: Equatable {
    let value: CGFloat
    let tilt: CGFloat?
}

final class SlatTiltSlider: UISlider {
    static let trackHeight: CGFloat = 16
    static let thumbSize: CGFloat = 40
    static let thumbRectSize: CGFloat = 60
    static let defaultMinDegrees: Float = 0
    static let defaultMaxDegrees: Float = 180
    static let slatMaxAngle: Float = 60
    
    override var intrinsicContentSize: CGSize {
        CGSizeMake(super.intrinsicContentSize.width, 40)
    }
    
    override var isEnabled: Bool {
        didSet {
            minimumTrackTintColor = isEnabled ? .grayLight : .grayLighter
            maximumTrackTintColor = isEnabled ? .grayLight : .grayLighter
            drawingView.setNeedsDisplay()
        }
    }
    
    override var value: Float {
        didSet {
            if !updatingFromState {
                displayValue = CGFloat(value)
                if slatsTiltDegrees != nil {
                    slatsTiltDegrees = CGFloat(minDegree + (maxDegree - minDegree) * value / 100)
                }
            }
            drawingView.setNeedsDisplay()
        }
    }
    
    var minDegree: Float = SlatTiltSlider.defaultMinDegrees
    var maxDegree: Float = SlatTiltSlider.defaultMaxDegrees

    private(set) var displayValue: CGFloat? {
        didSet { drawingView.setNeedsDisplay() }
    }

    private(set) var slatsTiltDegrees: CGFloat? {
        didSet { drawingView.setNeedsDisplay() }
    }

    private(set) var markers: [SlatTiltSliderMarker] = [] {
        didSet { drawingView.setNeedsDisplay() }
    }

    private var updatingFromState = false
    private lazy var drawingView = SlatTiltSliderDrawingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawingView.frame = bounds
        bringSubviewToFront(drawingView)
        drawingView.setNeedsDisplay()
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let height = min(SlatTiltSlider.trackHeight, bounds.height)
        let top = (bounds.height - height) / 2
        return CGRect(x: 0, y: top, width: bounds.width, height: height)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let width = rect.width - 40
        let left = width * CGFloat(value / maximumValue) - 10
        let top = (bounds.height - SlatTiltSlider.thumbRectSize) / 2
        return CGRect(x: left, y: top, width: SlatTiltSlider.thumbRectSize, height: SlatTiltSlider.thumbRectSize)
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        minimumValue = 0
        maximumValue = 100
        minimumTrackTintColor = .grayLight
        maximumTrackTintColor = .grayLight

        let invisibleThumb = invisibleThumbImage()
        setThumbImage(invisibleThumb, for: .normal)
        setThumbImage(invisibleThumb, for: .disabled)

        drawingView.isUserInteractionEnabled = false
        drawingView.isOpaque = false
        drawingView.backgroundColor = .clear
        drawingView.drawContent = { [weak self] context in self?.drawDecorations(in: context) }
        addSubview(drawingView)
    }

    func setDisplayState(value: CGFloat?, degrees: CGFloat?, markers: [SlatTiltSliderMarker]) {
        updatingFromState = true
        super.value = Float(value ?? 0)
        updatingFromState = false

        displayValue = value
        slatsTiltDegrees = degrees
        self.markers = markers
        drawingView.setNeedsDisplay()
    }

    private func invisibleThumbImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: Self.thumbRectSize, height: Self.thumbRectSize))
        return renderer.image { context in
            context.cgContext.clear(CGRect(origin: .zero, size: CGSize(width: Self.thumbRectSize, height: Self.thumbRectSize)))
        }
    }

    private func drawDecorations(in context: CGContext) {
        let track = trackRect(forBounds: bounds)
        for marker in markers {
            let center = CGPoint(x: xPosition(for: marker.value, track: track), y: track.midY)
            drawCircle(at: center, radius: 12, in: context, shadow: false)
            drawBorder(at: center, radius: 12, color: isEnabled ? .disabled : .outline, in: context)

            if let degrees = marker.tilt {
                drawSlatLines(at: center, degrees: degrees, color: isEnabled ? .onSurface : .outline, halfWidth: 5, in: context)
            } else {
                drawText("?", at: center, color: isEnabled ? .onSurface : .outline, fontSize: 10, in: context)
            }
        }

        guard let displayValue else { return }
        let center = CGPoint(x: xPosition(for: displayValue, track: track), y: track.midY)
        drawCircle(at: center, radius: Self.thumbSize / 2, in: context, shadow: isEnabled)
        drawBorder(at: center, radius: Self.thumbSize / 2, color: .disabled, in: context)

        guard isEnabled else { return }
        if let slatsTiltDegrees {
            drawSlatLines(at: center, degrees: slatsTiltDegrees, color: .onSurface, halfWidth: 6, in: context)
        } else {
            drawText(getPercentageString(Double(displayValue / 100)), at: center, color: .onSurface, fontSize: 10, in: context)
        }
    }

    private func xPosition(for value: CGFloat, track: CGRect) -> CGFloat {
        let travelWidth = max(0, track.width - 40)
        return track.minX + 20 + travelWidth * min(max(value / 100, 0), 1)
    }

    private func drawCircle(at center: CGPoint, radius: CGFloat, in context: CGContext, shadow: Bool) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.saveGState()
        if shadow {
            context.setShadow(offset: CGSize(width: 0, height: 4), blur: 3, color: UIColor.black.withAlphaComponent(0.2).cgColor)
        }
        UIColor.surface.setFill()
        context.fillEllipse(in: rect)
        context.restoreGState()
    }

    private func drawBorder(at center: CGPoint, radius: CGFloat, color: UIColor, in context: CGContext) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        color.setStroke()
        context.setLineWidth(1)
        context.strokeEllipse(in: rect.insetBy(dx: 0.5, dy: 0.5))
    }

    private func drawSlatLines(at center: CGPoint, degrees: CGFloat, color: UIColor, halfWidth: CGFloat, in context: CGContext) {
        let angle = CGFloat(Self.trimAngle(Float(degrees))) * .pi / 180
        color.setStroke()
        context.setLineWidth(1)
        context.setLineCap(.square)

        for offset in [CGFloat(-4), 0, 4] {
            context.saveGState()
            context.translateBy(x: center.x, y: center.y + offset)
            context.rotate(by: angle)
            context.move(to: CGPoint(x: -halfWidth, y: 0))
            context.addLine(to: CGPoint(x: halfWidth, y: 0))
            context.strokePath()
            context.restoreGState()
        }
    }

    private func drawText(_ text: String, at center: CGPoint, color: UIColor, fontSize: CGFloat, in context: CGContext) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: color
        ]
        let size = (text as NSString).size(withAttributes: attributes)
        let rect = CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
        (text as NSString).draw(in: rect, withAttributes: attributes)
    }
    
    override class var requiresConstraintBasedLayout: Bool { true }
    
    static func trimAngle(_ angle: Float) -> Float {
        angle * 2 * slatMaxAngle / 180 - slatMaxAngle
    }
}

private final class SlatTiltSliderDrawingView: UIView {
    var drawContent: ((CGContext) -> Void)?

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawContent?(context)
    }
}

extension Reactive where Base: SlatTiltSlider {
    var valueChanged: Observable<Float> {
        base.rx.controlEvent(.valueChanged)
            .filter { base.isTracking }
            .map { base.value }
    }

    var tiltSet: Observable<CGFloat> {
        Observable.merge([
            base.rx.controlEvent(.touchUpInside).asObservable(),
            base.rx.controlEvent(.touchUpOutside).asObservable(),
            base.rx.controlEvent(.touchCancel).asObservable()
        ]).map { _ in CGFloat(base.value) }
    }
}
