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
            firstSlatLineLayer.isHidden = !isEnabled
            secondSlatLineLayer.isHidden = !isEnabled
            thirdSlatLineLayer.isHidden = !isEnabled
            
            minimumTrackTintColor = isEnabled ? .grayLight : .grayLighter
            maximumTrackTintColor = isEnabled ? .grayLight : .grayLighter
        }
    }
    
    override var value: Float {
        didSet {
            rotateSlat(value)
        }
    }
    
    var minDegree: Float = SlatTiltSlider.defaultMinDegrees
    var maxDegree: Float = SlatTiltSlider.defaultMaxDegrees
    
    private var thumbFrame: CGRect {
        thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
    private lazy var firstSlatLineLayer: CAShapeLayer = createSlatLayer()
    
    private lazy var secondSlatLineLayer: CAShapeLayer = createSlatLayer()
    
    private lazy var thirdSlatLineLayer: CAShapeLayer = createSlatLayer()
    
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
        CALayer.performWithoutAnimation {
            firstSlatLineLayer.frame = thumbFrame.offsetBy(dx: 0, dy: -4)
            secondSlatLineLayer.frame = thumbFrame
            thirdSlatLineLayer.frame = thumbFrame.offsetBy(dx: 0, dy: 4)
        }
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
        
        layer.addSublayer(firstSlatLineLayer)
        layer.addSublayer(secondSlatLineLayer)
        layer.addSublayer(thirdSlatLineLayer)
        
        setThumbImage(thumbImage(withShadow: true), for: .normal)
        setThumbImage(thumbImage(withShadow: false), for: .disabled)
    }
    
    private func thumbImage(withShadow: Bool) -> UIImage {
        let layer = thumbLayer()
        if (withShadow) {
            ShadowValues.apply(toButton: layer)
        }
        
        let thumbView = UIView()
        thumbView.frame = CGRect(x: 0, y: 0, width: SlatTiltSlider.thumbRectSize, height: SlatTiltSlider.thumbRectSize)
        thumbView.layer.addSublayer(layer)
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    private func thumbLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        let margin = (SlatTiltSlider.thumbRectSize - SlatTiltSlider.thumbSize) / 2
        layer.frame = CGRect(x: margin, y: margin, width: SlatTiltSlider.thumbSize, height: SlatTiltSlider.thumbSize)
        layer.backgroundColor = UIColor.surface.cgColor
        layer.borderColor = UIColor.disabled.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 20
        
        return layer
    }
    
    private func rotateSlat(_ value: Float) {
        let degree = minDegree + (maxDegree - minDegree) * value / 100
        let correctedDegree = SlatTiltSlider.trimAngle(degree)
        let angle = CGFloat(correctedDegree) * .pi / 180
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 24, y: 30))
        path.addLine(to: CGPoint(x: 36, y: 30))
        path.apply(CGAffineTransform(translationX: -30, y: -30))
        path.apply(CGAffineTransform(rotationAngle: angle))
        path.apply(CGAffineTransform(translationX: 30, y: 30))
        let cgPath = path.cgPath
        
        firstSlatLineLayer.path = cgPath
        secondSlatLineLayer.path = cgPath
        thirdSlatLineLayer.path = cgPath
    }
    
    private func createSlatLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineWidth = 1
        layer.strokeColor = UIColor.gray.cgColor
        return layer
    }
    
    override class var requiresConstraintBasedLayout: Bool { true }
    
    static func trimAngle(_ angle: Float) -> Float {
        angle * 2 * slatMaxAngle / 180 - slatMaxAngle
    }
}

extension Reactive where Base: SlatTiltSlider {
    var tiltSet: Observable<CGFloat> {
        Observable.merge([
            base.rx.controlEvent(.touchUpInside).asObservable(),
            base.rx.controlEvent(.touchUpOutside).asObservable()
        ]).map { _ in CGFloat(base.value) }
    }
}
