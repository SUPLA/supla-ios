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

class CurtainView: BaseWallWindowView<CurtainWindowState, CurtainRuntimeDimens> {
    override var windowState: CurtainWindowState? {
        didSet {
            setNeedsLayout()
        }
    }

    init() {
        super.init(CurtainRuntimeDimens())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawShadowingElements(_ context: CGContext, _ dimens: CurtainRuntimeDimens) {
        guard let positionValue = windowState?.position.value,
              let markers = windowState?.markers
        else { return }
        
        let position: CGFloat = markers.isEmpty ? positionValue : (markers.max() ?? 0)
        let widthDiff = (dimens.leftCurtainRect.width - dimens.curtainMinWidth) * (100 - position) / 100

        drawCurtain(context, dimens.leftCurtainRect.narrowToLeft(by: widthDiff))
        drawCurtain(context, dimens.rightCurtainRect.narrowToRight(by: widthDiff))
    }
    
    override func drawMarkers(_ context: CGContext, _ dimens: CurtainRuntimeDimens) {
        guard let markers = windowState?.markers else { return }
        
        markers.forEach {
            let widthDiff = (dimens.leftCurtainRect.width - dimens.curtainMinWidth) * (100 - $0) / 100
            
            drawMarker(context, dimens.leftCurtainRect.maxX - widthDiff)
            drawMarker(context, dimens.rightCurtainRect.minX + widthDiff)
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
        positionRelay.accept(position)
    }
    
    private func drawCurtain(_ context: CGContext, _ rect: CGRect) {
        drawPath(context, fillColor: colors.slatBackground) { UIBezierPath(rect: rect).cgPath }
        drawPath(context, strokeColor: colors.slatBorder) { UIBezierPath(rect: rect).cgPath }
    }
    
    private func drawMarker(_ context: CGContext, _ offsetX: CGFloat) {
        let transformation = CGAffineTransform(translationX: offsetX-dimens.halfMarkerWidth, y: 0)
        dimens.markerPath.apply(transformation)
        drawPath(context, fillColor: colors.markerBackground) { dimens.markerPath.cgPath }
        drawPath(context, strokeColor: colors.markerBorder) { dimens.markerPath.cgPath }
        dimens.markerPath.apply(transformation.inverted())
    }
}

// MARK: - Runtime dimensions

class CurtainRuntimeDimens: BaseWallWindowDimens {
    static let curtainWidth: CGFloat = 142
    static let curtainHeight: CGFloat = 328
    static let curtainMinWidth: CGFloat = 24
    static let markerWidth: CGFloat = 8
    static let markerHeight: CGFloat = 28
    
    var curtainMinWidth: CGFloat = 0
    var leftCurtainRect: CGRect = .zero
    var rightCurtainRect: CGRect = .zero
    var markerPath: UIBezierPath = .init()
    var halfMarkerWidth: CGFloat = 0
    
    override func update(_ frame: CGRect) {
        super.update(frame)
        
        curtainMinWidth = CurtainRuntimeDimens.curtainMinWidth * scale
        
        createLeftCurtainRect()
        createRightCurtainRect()
        createMarkerPath()
    }
    
    private func createLeftCurtainRect() {
        let curtainWidth = CurtainRuntimeDimens.curtainWidth * scale
        let curtainHeight = CurtainRuntimeDimens.curtainHeight * scale - topLineRect.height
        
        leftCurtainRect = CGRect(
            x: topLineRect.minX,
            y: topLineRect.maxY,
            width: curtainWidth,
            height: curtainHeight
        )
    }
    
    private func createRightCurtainRect() {
        let curtainWidth = CurtainRuntimeDimens.curtainWidth * scale
        let curtainHeight = CurtainRuntimeDimens.curtainHeight * scale - topLineRect.height
        
        rightCurtainRect = CGRect(
            x: topLineRect.maxX - curtainWidth,
            y: topLineRect.maxY,
            width: curtainWidth,
            height: curtainHeight
        )
    }
    
    private func createMarkerPath() {
        let height = CurtainRuntimeDimens.markerHeight * scale
        let width = CurtainRuntimeDimens.markerWidth * scale
        halfMarkerWidth = width / 2
        let left = topLineRect.minX
        let top = topLineRect.maxY
        
        markerPath.removeAllPoints()
        markerPath.move(to: CGPoint(x: left, y: top))
        markerPath.addLine(to: CGPoint(x: left + halfMarkerWidth, y: top + halfMarkerWidth))
        markerPath.addLine(to: CGPoint(x: left + halfMarkerWidth, y: top + height))
        markerPath.addLine(to: CGPoint(x: left - halfMarkerWidth, y: top + height))
        markerPath.addLine(to: CGPoint(x: left - halfMarkerWidth, y: top + halfMarkerWidth))
        markerPath.close()
    }
}
