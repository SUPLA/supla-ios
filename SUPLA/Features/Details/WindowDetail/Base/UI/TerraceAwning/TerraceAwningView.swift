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

final class TerraceAwningView: BaseWindowView<TerraceAwningWindowState> {
    
    override var isEnabled: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var touchRect: CGRect { dimens.touchRect }
    
    private let dimens = RuntimeDimens()
    private lazy var colors = TerraceAwningColors.standard(traitCollection)
    
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
        
        if let markers = windowState?.markers, !markers.isEmpty {
            drawAwningShadow(context, position: markers.max()!)
        } else {
            drawAwningShadow(context, position: windowState?.position.value ?? 0)
        }
        
        drawWindow(context)

        if let markers = windowState?.markers, !markers.isEmpty {
            for (index, marker) in markers.sorted(by: { first, second in first > second }).enumerated() {
                drawAwningLikeMarker(context, position: marker, withFront: index == 0)
            }
        } else {
            drawAwning(context)
        }
        
        if (!isEnabled) {
            context.setBlendMode(.destinationOut)
            drawPath(context, fillColor: colors.disabledOverlay) { UIBezierPath(rect: dimens.frame).cgPath }
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .transparent
    }
    
    private func drawWindow(_ context: CGContext) {
        let path = UIBezierPath(roundedRect: dimens.windowRect, cornerRadius: WindowDimens.cornerRadius)
        
        drawPath(context, fillColor: colors.window, withShadow: true) { path.cgPath }
        
        let glassMargin: CGFloat = DefaultDimens.glassMargin * dimens.scale
        let glassWidth: CGFloat = (dimens.windowRect.width - glassMargin * 3) / 2
        let glassHeight: CGFloat = dimens.windowRect.height - glassMargin * 2
        
        let glassRect = CGRect(
            origin: CGPoint(x: dimens.windowRect.minX + glassMargin, y: dimens.windowRect.minY + glassMargin),
            size: CGSize(width: glassWidth, height: glassHeight)
        )
        
        let colors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        drawGlass(context, glassRect, colors)
        drawGlass(context, glassRect.offsetBy(dx: glassWidth + glassMargin, dy: 0), colors)
    }
    
    private func drawAwning(_ context: CGContext) {
        let position = (windowState?.markers.isEmpty == true || isMoving ? windowState?.position.value : windowState?.markers.max()) ?? 0
        let awningLeft = dimens.canvasRect.minX + (dimens.canvasRect.width - dimens.awningClosedWidth) / 2
        let awningTop = dimens.canvasRect.minY + 1
        let frontMinHeight = dimens.awningFrontHeight * 0.6
        
        let deepByPosition = dimens.awninigMaxDepp * position / 100
        let widthDeltaByPosition = (dimens.awningOpenedWidth - dimens.awningClosedWidth) * position / 100
        let maxWidthByPosition = dimens.awningClosedWidth + widthDeltaByPosition
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: awningLeft, y: awningTop))
        path.addLine(to: CGPoint(x: awningLeft + dimens.awningClosedWidth, y: awningTop))
        path.addLine(to: CGPoint(x: awningLeft + dimens.awningClosedWidth + widthDeltaByPosition / 2, y: awningTop + deepByPosition))
        path.addLine(to: CGPoint(x: awningLeft - widthDeltaByPosition / 2, y: awningTop + deepByPosition))
        path.close()
        
        drawPath(context, fillColor: colors.awningBackground) { path.cgPath }
        drawPath(context, strokeColor: colors.awningBorder) { path.cgPath }
        
        let frontLeft = dimens.canvasRect.minX + (dimens.canvasRect.width - maxWidthByPosition) / 2
        let frontHeight = frontMinHeight + (dimens.awningFrontHeight - frontMinHeight) * position / 100
        let frontRect = CGRect(
            origin: CGPoint(x: frontLeft, y: awningTop + deepByPosition),
            size: CGSize(width: maxWidthByPosition, height: frontHeight)
        )
        let frontPath = UIBezierPath(rect: frontRect)
        
        drawPath(context, fillColor: colors.awningBackground) { frontPath.cgPath }
        drawPath(context, strokeColor: colors.awningBorder) { frontPath.cgPath }
    }
    
    private func drawAwningLikeMarker(_ context: CGContext, position: CGFloat, withFront: Bool) {
        let awningLeft = dimens.canvasRect.minX + (dimens.canvasRect.width - dimens.awningClosedWidth) / 2
        let awningTop = dimens.canvasRect.minY + 1
        let frontMinHeight = dimens.awningFrontHeight * 0.6
        
        let deepByPosition = dimens.awninigMaxDepp * position / 100
        let widthDeltaByPosition = (dimens.awningOpenedWidth - dimens.awningClosedWidth) * position / 100
        let maxWidthByPosition = dimens.awningClosedWidth + widthDeltaByPosition
        let maxWidthMarginByPosition = (dimens.canvasRect.width - maxWidthByPosition) / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: awningLeft, y: awningTop))
        path.addLine(to: CGPoint(x: awningLeft + dimens.awningClosedWidth, y: awningTop))
        path.addLine(to: CGPoint(x: awningLeft + dimens.awningClosedWidth + widthDeltaByPosition / 2, y: awningTop + deepByPosition))
        path.addLine(to: CGPoint(x: awningLeft - widthDeltaByPosition / 2, y: awningTop + deepByPosition))
        path.close()
        
        drawPath(context, fillColor: colors.awningBackground.copy(alpha: 0.06)) { path.cgPath }
        drawPath(context, strokeColor: colors.awningBorder) { path.cgPath }
        
        if (withFront) {
            let frontHeight = frontMinHeight + (dimens.awningFrontHeight - frontMinHeight) * position / 100
            let frontRect = CGRect(
                origin: CGPoint(x: maxWidthMarginByPosition, y: awningTop + deepByPosition),
                size: CGSize(width: maxWidthByPosition, height: frontHeight)
            )
            let frontPath = UIBezierPath(rect: frontRect)
            
            drawPath(context, fillColor: colors.awningBackground) { frontPath.cgPath }
            drawPath(context, strokeColor: colors.awningBorder) { frontPath.cgPath }
        }
    }
    
    private func drawAwningShadow(_ context: CGContext, position: CGFloat) {
        let shadowLeft = dimens.canvasRect.minX + (dimens.canvasRect.width - dimens.awningClosedWidth) / 2
        let shadowTop = dimens.windowRect.maxY
        
        let deepByPosition = dimens.awninigMaxDepp * position / 100
        let widthDeltaByPosition = (dimens.awningOpenedWidth - dimens.awningClosedWidth) * position / 100
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: shadowLeft, y: shadowTop))
        path.addLine(to: CGPoint(x: shadowLeft + dimens.awningClosedWidth, y: shadowTop))
        path.addLine(to: CGPoint(x: shadowLeft + dimens.awningClosedWidth + widthDeltaByPosition / 2, y: shadowTop + deepByPosition))
        path.addLine(to: CGPoint(x: shadowLeft - widthDeltaByPosition / 2, y: shadowTop + deepByPosition))
        path.close()
        
        drawPath(context, fillColor: colors.awningBackground.copy(alpha: 0.06)) { path.cgPath }
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private enum DefaultDimens {
    static let width: CGFloat = 328
    static let height: CGFloat = 352
    static var ratio: CGFloat { width / height }
    
    static let windowWidth: CGFloat = 182
    static let windowHeight: CGFloat = 240
    static let windowTopDistance: CGFloat = 24
    
    static let awningClosedWidth: CGFloat = 200
    static let awningOpenedWidth: CGFloat = 326
    static let awningMaxDepp: CGFloat = 88
    static let awningFrontHeight: CGFloat = 24
    
    static let glassMargin: CGFloat = 14
}

private class RuntimeDimens: BaseWindowViewDimens {
    var windowRect: CGRect = .zero
    var touchRect: CGRect = .zero
    var awningClosedWidth: CGFloat = 0
    var awningOpenedWidth: CGFloat = 0
    var awninigMaxDepp: CGFloat = 0
    var awningFrontHeight: CGFloat = 0
    
    override func calculateDimens(_ frame: CGRect) {
        createCanvasRect(frame)
        scale = canvasRect.width / DefaultDimens.width
        createWindowRect()
        touchRect = CGRect(x: windowRect.minX, y: canvasRect.minY, width: windowRect.width, height: windowRect.height)
        awningClosedWidth = DefaultDimens.awningClosedWidth * scale
        awningOpenedWidth = DefaultDimens.awningOpenedWidth * scale
        awninigMaxDepp = DefaultDimens.awningMaxDepp * scale
        awningFrontHeight = DefaultDimens.awningFrontHeight * scale
    }
    
    private func createCanvasRect(_ frame: CGRect) {
        let size = getSize(frame)
        canvasRect = CGRect(origin: CGPoint(x: (frame.width - size.width) / 2, y: (frame.height - size.height) / 2), size: size)
    }
    
    private func createWindowRect() {
        let windowWidth = DefaultDimens.windowWidth * scale
        let windowHeight = DefaultDimens.windowHeight * scale
        let windowTop = canvasRect.minY + DefaultDimens.windowTopDistance * scale
        let windowLeft = canvasRect.minX + (canvasRect.width - windowWidth) / 2
        
        windowRect = CGRect(
            origin: CGPoint(x: windowLeft, y: windowTop),
            size: CGSize(width: windowWidth, height: windowHeight)
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
