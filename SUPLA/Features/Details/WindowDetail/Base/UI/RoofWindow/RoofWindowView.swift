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

private let windowRotationX: CGFloat = 30
private let windowRotationY: CGFloat = 330
private let maxOpenedOffset: CGFloat = 35

private enum DefaultDimens {
    static let width: CGFloat = 231
    static let height: CGFloat = 336
    static var ratio: CGFloat { width / (height + 80) }
    
    static let widthCorrection: CGFloat = 0.69
    
    static let windowFrameWidth: CGFloat = 10
    static let windowTopCoverWidth: CGFloat = 10
}

final class RoofWindowView: BaseWindowView<RoofWindowState> {
    override var isEnabled: Bool {
        didSet {
            if (isEnabled) {
                colors = RoofWindowColors.standard(traitCollection)
            } else {
                colors = RoofWindowColors.offline(traitCollection)
            }
            setNeedsDisplay()
        }
    }
    
    override var touchRect: CGRect { dimens.canvasRect }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: DefaultDimens.width, height: DefaultDimens.height)
    }
    
    private lazy var staticTransformation: CGAffineTransform = {
        let firstTransformation = CATransform3DMakeRotation(degreesToRadians(windowRotationY), 0, 1, 0)
        let secondTransformation = CATransform3DRotate(firstTransformation, degreesToRadians(windowRotationX), 1, 0, 0)
        return CATransform3DGetAffineTransform(secondTransformation)
    }()
    
    private var openedOffset: CGFloat { toXOffset(windowState?.position.value ?? 0) }

    private let dimens = RuntimeDimens()
    private lazy var colors = RoofWindowColors.standard(traitCollection)
    
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
        
        dimens.update(frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.masksToBounds = false
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setShouldAntialias(true)
        context.translateBy(x: bounds.size.width / 2, y: bounds.size.height / 2)
        context.setLineWidth(1.5)
        
        drawShadow(context)
        drawCoverableJamb(context)
        if let markers = windowState?.markers,
           !markers.isEmpty && !isMoving
        {
            drawMarkers(context)
        } else {
            drawSash(context)
        }
        drawJamb(context)
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .transparent
    }
    
    private func drawShadow(_ context: CGContext) {
        drawPath(context, fillColor: colors.window, withShadow: true) {
            let path = RoofWindowDimensBuilder.framePoints(dimens.canvasRect)
                .map { CGPointApplyAffineTransform($0, staticTransformation) }
                .toPath()
            path.append(
                RoofWindowDimensBuilder.windowSashOutsidePoints(dimens.canvasRect, dimens.windowFrameWidth)
                    .map { CGPointApplyAffineTransform($0, staticTransformation) }
                    .toPath()
                    .reversing()
            )
            
            return path.cgPath
        }
    }
    
    private func drawCoverableJamb(_ context: CGContext) {
        drawPath(context, fillColor: colors.window) {
            RoofWindowDimensBuilder.windowCoverableJambPoints(dimens.canvasRect, dimens.windowFrameWidth)
                .map { CGPointApplyAffineTransform($0, staticTransformation) }
                .toPath()
                .cgPath
        }
    }
    
    private func drawSash(_ context: CGContext) {
        let dynamicTransformation = dynamicTransformation()
        let position = windowState?.position.value ?? 0
        
        drawPath(context, fillColor: colors.window, withShadow: position != 100) {
            let path = RoofWindowDimensBuilder.windowSashOutsidePoints(dimens.canvasRect, dimens.windowFrameWidth)
                .map { CGPointApplyAffineTransform($0, dynamicTransformation) }
                .toPath()
            path.append(
                RoofWindowDimensBuilder.windowSashInsidePoints(dimens.canvasRect, dimens.windowFrameWidth, dimens.windowTopCoverWidth)
                    .map { CGPointApplyAffineTransform($0, dynamicTransformation) }
                    .toPath()
                    .reversing()
            )
            
            return path.cgPath
        }
        
        drawPath(context, fillColor: colors.glassTop.copy(alpha: 0.4)) {
            RoofWindowDimensBuilder.windowSashInsidePoints(dimens.canvasRect, dimens.windowFrameWidth, dimens.windowTopCoverWidth)
                .map { CGPointApplyAffineTransform($0, dynamicTransformation) }
                .toPath()
                .cgPath
        }
    }
    
    private func drawJamb(_ context: CGContext) {
        drawPath(context, fillColor: colors.window) {
            RoofWindowDimensBuilder.windowJambPoints(dimens.canvasRect, dimens.windowFrameWidth, dimens.windowTopCoverWidth)
                .map { CGPointApplyAffineTransform($0, staticTransformation) }
                .toPath()
                .cgPath
        }
    }
    
    private func drawMarkers(_ context: CGContext) {
        let markers = windowState?.markers ?? []
        
        for marker in markers {
            let dynamicTransformation = dynamicTransformation(toXOffset(marker))
            
            drawPath(context, strokeColor: colors.glassTop) {
                RoofWindowDimensBuilder.windowSashInsidePoints(dimens.canvasRect, dimens.windowFrameWidth, dimens.windowTopCoverWidth)
                    .map { CGPointApplyAffineTransform($0, dynamicTransformation) }
                    .toPath()
                    .cgPath
            }
        }
    }
    
    private func dynamicTransformation(_ offset: CGFloat? = nil) -> CGAffineTransform {
        let xOffset = offset == nil ? openedOffset : offset!
        let firstTransformation = CATransform3DMakeRotation(degreesToRadians(windowRotationY), 0, 1, 0)
        let secondTransformation = CATransform3DRotate(firstTransformation, degreesToRadians(windowRotationX + xOffset), 1, 0, 0)
        return CATransform3DGetAffineTransform(secondTransformation)
    }
    
    private func toXOffset(_ position: CGFloat) -> CGFloat {
        maxOpenedOffset * (100.0 - position) / 100.00
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private class RuntimeDimens {
    var scale: CGFloat = 1
    
    var canvasRect: CGRect = .zero
    
    var windowFrameWidth: CGFloat = 0
    var windowTopCoverWidth: CGFloat = 0
    
    func update(_ frame: CGRect) {
        createCanvasRect(frame)
        scale = canvasRect.width / DefaultDimens.width
        windowFrameWidth = DefaultDimens.windowFrameWidth * scale
        windowTopCoverWidth = DefaultDimens.windowTopCoverWidth * scale
    }
    
    private func createCanvasRect(_ frame: CGRect) {
        let size = getSize(frame)
        canvasRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }
    
    private func getSize(_ frame: CGRect) -> CGSize {
        let canvasRatio = frame.width / frame.height
        if (canvasRatio > DefaultDimens.ratio) {
            return CGSize(width: frame.height * DefaultDimens.ratio, height: frame.height)
        } else {
            return CGSize(
                width: frame.width * DefaultDimens.widthCorrection,
                height: frame.width / DefaultDimens.ratio * DefaultDimens.widthCorrection
            )
        }
    }
}

private func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
    .pi * degrees / 180
}

private extension Array where Iterator.Element == CGPoint {
    func toPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: self[0])
        for i in 1 ..< count {
            path.addLine(to: self[i])
        }
        path.close()
        return path
    }
}
