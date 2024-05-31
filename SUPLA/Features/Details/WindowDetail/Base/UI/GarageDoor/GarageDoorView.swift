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

final class GarageDoorView: BaseWindowView<GarageDoorState> {
    override var isEnabled: Bool {
        didSet {
            if (isEnabled) {
                colors = GarageDoorColors.standard(traitCollection)
            } else {
                colors = GarageDoorColors.offline(traitCollection)
            }
            setNeedsDisplay()
        }
    }
    
    override var touchRect: CGRect { dimens.canvasRect }
    
    private let dimens = RuntimeDimens()
    private lazy var colors = GarageDoorColors.standard(traitCollection)
    private lazy var garageInsideImage = UIImage(named: .Image.garageContent)
    
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
        
        let position = (windowState?.markers.isEmpty == true ? windowState?.position.value : windowState?.markers.max()) ?? 0
        let topCorrection = dimens.movementMaxHeight * (100 - position) / 100
        
        // Garage
        drawPath(context, fillColor: colors.building, withShadow: true) { dimens.garagePath.cgPath }
        
        // Cliping
        context.saveGState()
        context.addPath(dimens.doorClipingPath.cgPath)
        context.clip()
        
        // Garage inside
        if let garageInsideImage = garageInsideImage {
            context.setShadow(offset: .zero, blur: 0)
            garageInsideImage.draw(in: dimens.doorRect)
        }
        
        // Slats
        for slat in dimens.slats {
            let path = UIBezierPath(rect: CGRect(x: slat.minX, y: slat.minY - topCorrection, width: slat.width, height: slat.height)).cgPath
            drawPath(context, fillColor: colors.slatBackground) { path }
            drawPath(context, strokeColor: colors.slatBorder) { path }
        }
        
        context.restoreGState() // remove cliping
        
        // Markers
        if let markers = windowState?.markers {
            for marker in markers {
                let markerTopCorrection = dimens.movementMaxHeight * marker / 100
                
                dimens.markerPath.apply(CGAffineTransform(translationX: 0, y: markerTopCorrection))
                drawPath(context, fillColor: colors.markerBackground) { dimens.markerPath.cgPath }
                drawPath(context, strokeColor: colors.markerBorder) { dimens.markerPath.cgPath }
                dimens.markerPath.apply(CGAffineTransform(translationX: 0, y: -markerTopCorrection))
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
    static let width: CGFloat = 304
    static let height: CGFloat = 304
    static var ratio: CGFloat { width / height }
    
    static let wallHeight: CGFloat = 216
    static let doorWidth: CGFloat = 256
    static let doorHeight: CGFloat = 196
    static let slatHeight: CGFloat = 24
    static let doorRadius: CGFloat = 4
    
    static let markerHeight: CGFloat = 8
    static let markerWidth: CGFloat = 28
}

private class RuntimeDimens {
    var frame = CGRect()
    var scale: CGFloat = 1
    
    var canvasRect: CGRect = .zero
    let garagePath: UIBezierPath = .init()
    var doorRect: CGRect = .zero
    var doorClipingPath: UIBezierPath = .init()
    var slats: [CGRect] = []
    var movementMaxHeight: CGFloat = 0
    var markerPath: UIBezierPath = .init()
    
    func update(_ frame: CGRect) {
        if (frame == self.frame) {
            return // skip calcuation when frame is same as previous
        }
        self.frame = frame
        
        createCanvasRect(frame)
        scale = canvasRect.width / DefaultDimens.width
        
        createGaragePath()
        doorRect = createDoorRect()
        let doorRadius = DefaultDimens.doorRadius * scale
        doorClipingPath = UIBezierPath(roundedRect: doorRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: doorRadius, height: doorRadius))
        createSlats()
        movementMaxHeight = doorRect.height - DefaultDimens.slatHeight * scale
        createMarkerPath()
    }
    
    private func createGaragePath() {
        let wallHeight = DefaultDimens.wallHeight * scale
        
        garagePath.removeAllPoints()
        garagePath.move(to: CGPoint(x: canvasRect.minX, y: canvasRect.maxY))
        garagePath.addLine(to: CGPoint(x: canvasRect.minX, y: canvasRect.maxY - wallHeight))
        garagePath.addLine(to: CGPoint(x: canvasRect.midX, y: canvasRect.minY))
        garagePath.addLine(to: CGPoint(x: canvasRect.maxX, y: canvasRect.maxY - wallHeight))
        garagePath.addLine(to: CGPoint(x: canvasRect.maxX, y: canvasRect.maxY))
        garagePath.close()
    }

    private func createDoorRect() -> CGRect {
        let doorWidth = DefaultDimens.doorWidth * scale
        let doorHeight = DefaultDimens.doorHeight * scale
        let left = canvasRect.midX - doorWidth / 2
        let top = canvasRect.maxY - doorHeight
        return CGRect(x: left, y: top, width: doorWidth, height: doorHeight)
    }
    
    private func createSlats() {
        let slatWidth = doorRect.width
        let slatHeight = DefaultDimens.slatHeight * scale
        let slatCount = Int(ceil(doorRect.height / slatHeight))
        
        let top = doorRect.maxY - slatHeight
        let left = doorRect.minX
        
        slats.removeAll()
        for i in 0 ..< slatCount {
            slats.append(CGRect(x: left, y: top - slatHeight * CGFloat(i), width: slatWidth, height: slatHeight))
        }
    }
    
    private func createMarkerPath() {
        let left = doorRect.minX
        let top = doorRect.minY + DefaultDimens.slatHeight * scale
        
        let width = DefaultDimens.markerWidth * scale
        let height = DefaultDimens.markerHeight * scale
        let halfHeight = height / 2
        
        markerPath.removeAllPoints()
        markerPath.move(to: CGPoint(x: left, y: top))
        markerPath.addLine(to: CGPoint(x: left + halfHeight, y: top - halfHeight))
        markerPath.addLine(to: CGPoint(x: left + width, y: top - halfHeight))
        markerPath.addLine(to: CGPoint(x: left + width, y: top + halfHeight))
        markerPath.addLine(to: CGPoint(x: left + halfHeight, y: top + halfHeight))
        markerPath.close()
    }
    
    private func createCanvasRect(_ frame: CGRect) {
        let size = getSize(frame)
        canvasRect = CGRect(
            origin: CGPoint(x: (frame.width - size.width) / 2, y: (frame.height - size.height) / 2),
            size: size
        )
    }
    
    private func getSize(_ frame: CGRect) -> CGSize {
        let ratio = frame.width / frame.height
        if (ratio > DefaultDimens.ratio) {
            let height = frame.height - WindowDimens.padding * 2
            return CGSize(width: height * DefaultDimens.ratio, height: height)
        } else {
            let width = frame.width - WindowDimens.padding * 2
            return CGSize(width: width, height: width / DefaultDimens.ratio)
        }
    }
}
