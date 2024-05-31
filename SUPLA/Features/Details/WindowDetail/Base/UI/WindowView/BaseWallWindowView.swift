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

class BaseWallWindowView<T: WindowState, D: BaseWallWindowDimens>: BaseWindowView<T> {
    override var isEnabled: Bool {
        didSet {
            if (isEnabled) {
                colors = WindowColors.standard(traitCollection)
            } else {
                colors = WindowColors.offline(traitCollection)
            }
            setNeedsDisplay()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: WindowDimens.width, height: WindowDimens.height)
    }
    
    override var touchRect: CGRect { dimens.windowRect }
    
    let dimens: D
    lazy var colors = WindowColors.standard(traitCollection)
    
    init(_ dimens: D) {
        self.dimens = dimens
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        dimens.update(frame)
        
        updateMarkersPositions()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        CALayer.performWithoutAnimation {
            updateMarkersPositions()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setShouldAntialias(true)
        context.setLineWidth(1)
        
        // window frame
        drawPath(context, fillColor: colors.window, withShadow: true) {
            UIBezierPath(roundedRect: dimens.windowRect, cornerRadius: WindowDimens.cornerRadius).cgPath
        }
        
        // glasses
        let slatColors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        drawGlass(context, dimens.leftGlassRect, slatColors)
        drawGlass(context, dimens.rightGlassRect, slatColors)
        
        // shadowing elemnts (slats, curtain, etc)
        context.saveGState()
        let clipingRect = CGRect(
            origin: CGPoint(x: dimens.topLineRect.minX, y: dimens.topLineRect.maxY),
            size: CGSize(width: dimens.topLineRect.width, height: dimens.windowRect.height)
        )
        context.clip(to: [clipingRect])
        drawShadowingElements(context, dimens)
        context.restoreGState()
        
        // top line rect
        drawPath(context, fillColor: colors.window, withShadow: true) {
            UIBezierPath(rect: dimens.topLineRect).cgPath
        }
        
        // markers - for groups
        drawMarkers(context, dimens)
    }
    
    func drawShadowingElements(_ context: CGContext, _ dimens: D) {
        fatalError("updateSlatsPositions(:,:) needs to be implemented")
    }
    
    func drawMarkers(_ context: CGContext, _ dimens: D) {
        // intentionally left empty - markers may stay unsupported
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .transparent
        clipsToBounds = false
        
    }
    
    func updateMarkersPositions() {
        // intentionally left empty
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
