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

import Foundation

final class ProjectorScreenView: BaseWindowView<ProjectorScreenState> {
    override var isEnabled: Bool {
        didSet {
            logo = UIImage.logo?.withTintColor(colors.logoColor)
            setNeedsDisplay()
        }
    }
    
    override var touchRect: CGRect { dimens.canvasRect }
    
    private let dimens = RuntimeDimens()
    private lazy var colors = ProjectorScreenColors.standard(traitCollection)
    private lazy var logo = UIImage.logo?.withTintColor(colors.logoColor)
    
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
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setShouldAntialias(true)
        context.setLineWidth(1)
        
        let position = (windowState?.markers.isEmpty == true || isMoving ? windowState?.position.value : windowState?.markers.max()) ?? 0
        let screenHeight = dimens.screenMaxHeight * position / 100
        let bottomRect = dimens.bottomRect.offsetBy(dx: 0, dy: screenHeight)
        let bottomRectRadius = bottomRect.height / 2
        
        // screen
        let screenRect = CGRect(origin: dimens.screenTopLeft, size: CGSize(width: dimens.screenWidth, height: screenHeight))
        drawPath(context, fillColor: colors.screen) {
            return UIBezierPath(rect: screenRect).cgPath
        }
        // Logo
        context.saveGState()
        context.clip(to: screenRect)
        if let logo = logo {
            let verticalCorrection = screenHeight - dimens.screenMaxHeight
            context.setShadow(offset: .zero, blur: 0)
            logo.draw(in: dimens.logoRect.offsetBy(dx: 0, dy: verticalCorrection))
        }
        context.restoreGState()
        // top part
        drawPath(context, fillColor: colors.topRect, withShadow: true) {
            UIBezierPath(rect: dimens.topRect).cgPath
        }
        // Bottom part
        drawPath(context, fillColor: colors.bottomRect) {
            UIBezierPath(roundedRect: bottomRect, cornerRadius: bottomRectRadius).cgPath
        }
        drawHandle(context, bottomRect, colors.bottomRect)
        // Markers
        drawMarkers(context, bottomRect, position)
        
        if (!isEnabled) {
            context.setBlendMode(.destinationOut)
            drawPath(context, fillColor: colors.disabledOverlay) { UIBezierPath(rect: dimens.frame).cgPath }
        }
    }
    
    private func drawHandle(_ context: CGContext, _ bottomRect: CGRect, _ color: UIColor) {
        context.setLineWidth(1.5)
        drawPath(context, strokeColor: color) {
            let topPoint = CGPoint(x: (bottomRect.maxX - bottomRect.minX) / 2, y: bottomRect.maxY)
            let bottomPoint = topPoint.insetBy(x: 0, y: 6)
            let path = UIBezierPath(ovalIn: CGRect(origin: bottomPoint.insetBy(x: -4, y: 0), size: CGSize(width: 8, height: 8)))
            path.move(to: topPoint)
            path.addLine(to: bottomPoint)
            return path.cgPath
        }
    }
    
    private func drawMarkers(_ context: CGContext, _ bottomRect: CGRect, _ position: CGFloat) {
        if let markers = windowState?.markers, !markers.isEmpty {
            let markerColor = colors.bottomRect.copy(alpha: 0.5)
            let radius = bottomRect.height / 2
            for marker in markers {
                if (marker != position) {
                    let markerScreenHeight = dimens.screenMaxHeight * marker / 100
                    let markerBottomRect = dimens.bottomRect.offsetBy(dx: 0, dy: markerScreenHeight)
                    drawPath(context, fillColor: markerColor) {
                        UIBezierPath(roundedRect: markerBottomRect, cornerRadius: radius).cgPath
                    }
                    drawHandle(context, markerBottomRect, markerColor)
                }
            }
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .transparent
        clipsToBounds = false
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private enum DefaultDimens {
    static let width: CGFloat = 320
    static let height: CGFloat = 260
    static var ratio: CGFloat { width / height }
    
    static let topRectHeight: CGFloat = 16
    static let bottomRectHeight: CGFloat = 8
    static let bottomRectWidth: CGFloat = 304
    static let screenWidth: CGFloat = 288
    
    static let logoWidth: CGFloat = 120
    static let logoHeight: CGFloat = 137
    static let logoTopMargin: CGFloat = 50
}

private class RuntimeDimens: BaseWindowViewDimens {
    var topRect: CGRect = .zero
    var bottomRect: CGRect = .zero
    var screenTopLeft: CGPoint = .zero
    var screenWidth: CGFloat = 0
    var screenMaxHeight: CGFloat = 0
    var logoRect: CGRect = .zero
    
    override func calculateDimens(_ frame: CGRect) {
        createCanvasRect(frame)
        scale = canvasRect.width / DefaultDimens.width
        topRect = CGRect(origin: canvasRect.origin, size: CGSize(width: canvasRect.width, height: DefaultDimens.topRectHeight * scale))
        bottomRect = createBottomRect()
        screenWidth = DefaultDimens.screenWidth * scale
        screenTopLeft = createScreenTopLeft()
        screenMaxHeight = canvasRect.height - topRect.height - bottomRect.height
        logoRect = createLogoRect()
    }
    
    private func createCanvasRect(_ frame: CGRect) {
        let size = getSize(frame)
        canvasRect = CGRect(origin: CGPoint(x: (frame.width - size.width) / 2, y: (frame.height - size.height) / 2), size: size)
    }
    
    private func createBottomRect() -> CGRect {
        let size = CGSize(width: DefaultDimens.bottomRectWidth * scale, height: DefaultDimens.bottomRectHeight * scale)
        let left = topRect.minX + (topRect.width - size.width) / 2
        return CGRect(origin: CGPoint(x: left, y: topRect.maxY), size: size)
    }
    
    private func createScreenTopLeft() -> CGPoint {
        let screenWidth = DefaultDimens.screenWidth * scale
        return CGPoint(x: topRect.minX + (topRect.width - screenWidth) / 2, y: topRect.maxY)
    }
    
    private func createLogoRect() -> CGRect {
        let logoWidth = DefaultDimens.logoWidth * scale
        let logoHeight = DefaultDimens.logoHeight * scale
        let left = (topRect.width - logoWidth) / 2
        return CGRect(
            origin: CGPoint(x: left, y: topRect.maxY + DefaultDimens.logoTopMargin * scale),
            size: CGSize(width: logoWidth, height: logoHeight)
        )
    }
    
    private func getSize(_ frame: CGRect) -> CGSize {
        let canvasRatio = frame.width / frame.height
        if (canvasRatio > DefaultDimens.ratio) {
            return CGSize(width: frame.height * DefaultDimens.ratio, height: frame.height)
        } else {
            return CGSize(width: frame.width, height: frame.width / DefaultDimens.ratio)
        }
    }
}
