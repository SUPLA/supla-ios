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

class BaseWallWindowView<T: WindowState>: BaseWindowView<T> {
    override var isEnabled: Bool {
        didSet {
            if (isEnabled) {
                colors = WindowColors.standard(traitCollection)
            } else {
                colors = WindowColors.offline(traitCollection)
            }
            updateColors()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: DefaultWindowDimens.width, height: DefaultWindowDimens.height)
    }
    
    override var touchRect: CGRect { dimens.windowRect }
    
    private lazy var windowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = colors.window.cgColor
        layer.cornerRadius = DefaultWindowDimens.windowCornerRadius
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
        
        for i in 0 ..< DefaultWindowDimens.slatsCount {
            let layer = CAShapeLayer()
            setupSlat(layer, colors)
            layers.append(layer)
        }
        
        return layers
    }()
    
    let dimens: RuntimeWindowDimens
    lazy var colors = WindowColors.standard(traitCollection)
    
    init(_ dimens: RuntimeWindowDimens) {
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
        
        windowLayer.frame = dimens.windowRect
        leftGlassLayer.frame = dimens.leftGlassRect
        rightGlassLayer.frame = dimens.rightGlassRect
        CALayer.performWithoutAnimation {
            updateSlatsPositions(slatsLayers, dimens)
        }
        topLineLayer.frame = dimens.topLineRect
        updateMarkersPositions()
    }
    
    override func draw(_ rect: CGRect) {
        CALayer.performWithoutAnimation {
            updateSlatsPositions(slatsLayers, dimens)
            updateMarkersPositions()
        }
    }
    
    func updateSlatsPositions(_ slatsLayers: [CAShapeLayer], _ dimens: RuntimeWindowDimens) {
        fatalError("updateSlatsPositions(:,:) needs to be implemented")
    }
    
    func setupSlat(_ layer: CAShapeLayer, _ colors: WindowColors) {
        layer.backgroundColor = colors.slatBackground.cgColor
        layer.borderWidth = 1
        layer.borderColor = colors.slatBorder.cgColor
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.addSublayer(windowLayer)
        layer.addSublayer(leftGlassLayer)
        layer.addSublayer(rightGlassLayer)
        slatsLayers.forEach { layer.addSublayer($0) }
        layer.addSublayer(topLineLayer)
    }
    
    func updateMarkersPositions() {
        // intentionally left empty
    }
    
    private func updateColors() {
        windowLayer.backgroundColor = colors.window.cgColor
        windowLayer.setupShadow(colors.shadow)
        
        topLineLayer.backgroundColor = colors.window.cgColor
        topLineLayer.setupShadow(colors.shadow)
        
        leftGlassLayer.colors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        rightGlassLayer.colors = [colors.glassTop.cgColor, colors.glassBottom.cgColor]
        
        for slatLayer in slatsLayers {
            setupSlat(slatLayer, colors)
        }
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private extension CAShapeLayer {
    func setupShadow(_ color: UIColor) {
        shadowColor = color.cgColor
        shadowRadius = DefaultWindowDimens.shadowRadius
        shadowOpacity = DefaultWindowDimens.shadowOpacity
        shadowOffset = DefaultWindowDimens.shadowOffset
    }
}
