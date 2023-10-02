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
import RxSwift
import RxRelay

fileprivate let OUTER_RADIUS = CGFloat(136)

final class ThermostatControlView: UIView {
    
    private let desiredSize = CGFloat(280)
    private let setpointRadius = CGFloat(128)
    private let innerShadow = UIColor(red: 209/255.0, green: 209/255.0, blue: 209/255.0, alpha: 1)
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: desiredSize, height: desiredSize)
    }
    
    var setpointPositionEvents: Observable<SetpointEvent> {
        get { positionRelay.asObservable() }
    }
    
    var setpointHeatPercentage: CGFloat? {
        get { setpointHeat }
        set {
            setpointHeat = newValue?.toPercentage()
            setpointHeatPoint.isHidden = newValue == nil
            setNeedsDisplay()
        }
    }
    
    var setpointCoolPercentage: CGFloat? {
        get { setpointCool }
        set {
            setpointCool = newValue?.toPercentage()
            setpointCoolPoint.isHidden = newValue == nil
            setNeedsDisplay()
        }
    }
    
    var temperaturePercentage: CGFloat? {
        get { temperature }
        set {
            temperature = newValue?.toPercentage() ?? 0
            currentTemperaturePoint.isHidden = newValue == nil
            setNeedsDisplay()
        }
    }
    
    var minTemperatureText: String? {
        get { minTemperatureView.text }
        set { minTemperatureView.text = newValue }
    }
    
    var maxTemperatureText: String? {
        get { maxTemperatureView.text }
        set { maxTemperatureView.text = newValue }
    }
    
    var minMaxHidden: Bool {
        get { minTemperatureView.isHidden && maxTemperatureView.isHidden }
        set {
            minTemperatureView.isHidden = newValue
            maxTemperatureView.isHidden = newValue
        }
    }
    
    var setpointText: String? {
        get { setpointTemperatureView.text }
        set {
            if let value = newValue {
                if (value.count > 5) {
                    setpointTemperatureView.font = .thermostatControlSmallTemperature
                } else {
                    setpointTemperatureView.font = .thermostatControlBigTemperature
                }
            }
            setpointTemperatureView.text = newValue
            
        }
    }
    
    var indicatorHeatingHidden: Bool {
        get { indicatorHeatingShape.isHidden }
        set {
            indicatorHeatingShape.isHidden = newValue
            setNeedsDisplay()
        }
    }
    
    var indicatorCoolingHidden: Bool {
        get { indicatorCoolingShape.isHidden }
        set {
            indicatorCoolingShape.isHidden = newValue
            setNeedsDisplay()
        }
    }
    
    var indicationColor: CGColor? {
        get { temperatureCircleShape.shadowColor }
        set { temperatureCircleShape.shadowColor = newValue }
    }
    
    var greyOutSetpoins: Bool {
        get { false }
        set {
            setpointHeatPoint.greyOut = newValue
            setpointCoolPoint.greyOut = newValue
        }
    }
    
    private var setpointHeat: CGFloat? = 0
    private var setpointCool: CGFloat? = 0
    private var temperature: CGFloat = 0.2
    private var isDragging: Bool = false
    private var setpointToDrag: SetpointType = .heat
    private var positionRelay: PublishRelay<SetpointEvent> = PublishRelay()
    
    private lazy var temperatureCircleShape: CAShapeLayer = { TemperatureCircleLayer() }()
    
    private lazy var controlCircleShape: CAShapeLayer = { ControlCircleLayer() }()
    
    private lazy var controlCircleInnerTopShadowShape: CAShapeLayer = {
        return ControlCircleInnerTopShadow()
    }()
    
    private lazy var controlCircleInnerBottomShadow: CAShapeLayer = {
        return ControlCircleInnerBottomShadow()
    }()
    
    // MARK: Setpoint
    
    private var setpointHeatPoint = SetpointLayers(type: .heat)
    private var setpointCoolPoint = SetpointLayers(type: .cool)
    
    // MARK: Current temperature point
    
    private var currentTemperaturePoint = GreenPointLayers()
    
    // MARK: Indicators
    
    private lazy var indicatorHeatingShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0,y: 0,width: 24,height: 24)
        layer.contents = UIImage.iconHeating?.cgImage
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    private lazy var indicatorCoolingShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0,y: 0,width: 24,height: 24)
        layer.contents = UIImage.iconCooling?.cgImage
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    private lazy var minTemperatureView: UILabel = {
        let label = UILabel()
        label.font = .body2
        return label
    }()
    
    private lazy var maxTemperatureView: UILabel = {
        let label = UILabel()
        label.font = .body2
        return label
    }()
    
    private lazy var setpointTemperatureView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .thermostatControlBigTemperature
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        temperatureCircleShape.frame = bounds
        controlCircleShape.frame = bounds
        controlCircleInnerTopShadowShape.frame = bounds
        controlCircleInnerBottomShadow.frame = bounds
        currentTemperaturePoint.frame = bounds
        setpointHeatPoint.frame = bounds
        setpointCoolPoint.frame = bounds
        minTemperatureView.frame = CGRect(
            x: self.frame.width / 2 - 120,
            y: self.frame.height * 0.75 - 6,
            width: minTemperatureView.intrinsicContentSize.width,
            height: minTemperatureView.intrinsicContentSize.height
        )
        maxTemperatureView.frame = CGRect(
            x: self.frame.width / 2 + 90,
            y: self.frame.height * 0.75 - 6,
            width: maxTemperatureView.intrinsicContentSize.width,
            height: maxTemperatureView.intrinsicContentSize.height
        )
        indicatorHeatingShape.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 55)
        indicatorCoolingShape.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 55)
    }
    
    override func draw(_ rect: CGRect) {
        drawSetpoint()
        drawTemperature()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = event?.allTouches?.first?.location(in: self) else { return }
        
        let centerX = self.frame.width / 2
        let centerY = self.frame.height / 2
        
        let distance = sqrt(pow(centerX - point.x, 2) + pow(centerY - point.y, 2))
        let tolerance: CGFloat = 24
        
        if (abs(distance - setpointRadius) < tolerance) {
            isDragging = true
        }
        
        if (point.inside(point: setpointHeatPoint.position)) {
            setpointToDrag = .heat
        } else if (point.inside(point: setpointCoolPoint.position)) {
            setpointToDrag = .cool
        }
        
        if (isDragging) {
            moveActiveSetpointTo(point: point)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = event?.allTouches?.first?.location(in: self), isDragging {
            moveActiveSetpointTo(point: point)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        positionRelay.accept(.finished)
        isDragging = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        positionRelay.accept(.finished)
        isDragging = false
    }
    
    private func setupView() {
        layer.addSublayer(controlCircleShape)
        layer.addSublayer(controlCircleInnerBottomShadow)
        layer.addSublayer(temperatureCircleShape)
        layer.addSublayer(controlCircleInnerTopShadowShape)
        layer.addSublayer(setpointHeatPoint)
        layer.addSublayer(setpointCoolPoint)
        layer.addSublayer(currentTemperaturePoint)
        layer.addSublayer(indicatorHeatingShape)
        layer.addSublayer(indicatorCoolingShape)
        
        addSubview(minTemperatureView)
        addSubview(maxTemperatureView)
        addSubview(setpointTemperatureView)
        
        NSLayoutConstraint.activate([
            setpointTemperatureView.centerXAnchor.constraint(equalTo: centerXAnchor),
            setpointTemperatureView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func moveActiveSetpointTo(point: CGPoint) {
        switch (setpointToDrag) {
        case .heat:
            positionRelay.accept(.mooving(setpointType: .heat, position: alignToCircle(point: point)))
        case .cool:
            positionRelay.accept(.mooving(setpointType: .cool, position: alignToCircle(point: point)))
        }
    }
    
    private func drawSetpoint() {
        if let setpointHeat = setpointHeat {
            let alpha = (setpointHeat * 4 / 3 * .pi) + (5 / 6.0 * .pi)
            let x = setpointRadius * cos(alpha) + self.frame.width / 2
            let y = setpointRadius * sin(alpha) + self.frame.height / 2
            
            setpointHeatPoint.move(to: CGPoint(x: x, y: y))
        } else {
            setpointHeatPoint.isHidden = true
        }
        
        if let setpointCool = setpointCool {
            let alpha = (setpointCool * 4 / 3 * .pi) + (5 / 6.0 * .pi)
            let x = setpointRadius * cos(alpha) + self.frame.width / 2
            let y = setpointRadius * sin(alpha) + self.frame.height / 2
            
            setpointCoolPoint.move(to: CGPoint(x: x, y: y))
        } else {
            setpointCoolPoint.isHidden = true
        }
    }
    
    private func drawTemperature() {
        let alpha = (temperature * 4 / 3 * .pi) + (5 / 6.0 * .pi)
        let x = setpointRadius * cos(alpha) + self.frame.width / 2
        let y = setpointRadius * sin(alpha) + self.frame.height / 2
        
        currentTemperaturePoint.move(to: CGPoint(x: x, y: y))
    }
    
    private func alignToCircle(point: CGPoint) -> CGFloat {
        let circleCenter = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        // Move circle center to 0,0
        let correctedPoint = point.insetBy(x: -circleCenter.x, y: -circleCenter.y)
        
        // Get sin(alpha) for the touch point
        let touchPointRadius = sqrt((correctedPoint.x * correctedPoint.x) + (correctedPoint.y * correctedPoint.y))
        let sinAlpha = correctedPoint.y / touchPointRadius
        
        let alpha = getAlphaValue(radians: asin(sinAlpha), point: correctedPoint)
        if (alpha < 60) {
            return 0
        } else if (alpha > 300) {
            return 1
        } else {
            return (alpha - 60) / 240
        }
    }
    
    private func getAlphaValue(radians: CGFloat, point: CGPoint) -> CGFloat {
        let alpha = radians * 180 / .pi
        if (point.x < 0) {
            return 90 - alpha
        } else {
            return 270 + alpha
        }
    }
}

// MARK: - Temperature circle

fileprivate class TemperatureCircleLayer: CAShapeLayer {
    
    override var frame: CGRect {
        didSet {
            updatePath()
        }
    }
    
    
    private let radius: CGFloat = 100
    
    override init() {
        super.init()
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override class func defaultAction(forKey event: String) -> CAAction? {
        return unsafeBitCast(NSNull(), to: CAAction?.self)
    }
    
    private func setupView() {
        fillColor = UIColor.white.cgColor
        
        // shadow
        shadowRadius = 12
        shadowOpacity = 0.25
        shadowColor = UIColor.primary.cgColor
        shadowOffset = CGSize.zero
    }
    
    private func updatePath() {
        path = UIBezierPath(
            arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        ).cgPath
    }
}

// MARK: - Control circle

fileprivate class ControlCircleLayer: CAShapeLayer {
    
    override var frame: CGRect {
        didSet {
            updatePath()
        }
    }
    
    override init() {
        super.init()
        fillColor = UIColor.white.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updatePath() {
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let path = UIBezierPath(
            arcCenter: centerPoint,
            radius: OUTER_RADIUS,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        path.append(
            UIBezierPath(
                arcCenter: centerPoint,
                radius: 120,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            ).reversing()
        )
        
        mask = createMask(centerPoint: centerPoint)
        self.path = path.cgPath
    }
}

// MARK: - Control circle inner top shadow

fileprivate class ControlCircleInnerTopShadow: CAShapeLayer {
    
    override var frame: CGRect {
        didSet {
            updatePaths()
        }
    }
    
    override init() {
        super.init()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        fillColor = nil
        strokeColor = UIColor.clear.cgColor
        lineWidth = 1
        
        shadowRadius = 3
        shadowOpacity = 0.4
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSizeMake(0, 1)
    }
    
    private func updatePaths() {
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        path = UIBezierPath(
            arcCenter: centerPoint,
            radius: 137,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        ).cgPath
        mask = createMask(centerPoint: centerPoint)
        
        let shadowPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: 134,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        shadowPath.append(
            UIBezierPath(
                arcCenter: centerPoint,
                radius: OUTER_RADIUS,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            ).reversing()
        )
        self.shadowPath = shadowPath.cgPath
    }
}

// MARK: - Control circle inner bottom shadow

fileprivate class ControlCircleInnerBottomShadow: CAShapeLayer {
    
    override var frame: CGRect {
        didSet {
            updatePath()
        }
    }
    
    override init() {
        super.init()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        fillColor = UIColor.background.cgColor
        strokeColor = UIColor.clear.cgColor
        lineWidth = 1
        
        shadowRadius = 2
        shadowOpacity = 0.2
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSizeMake(0, 1)
    }
    
    private func updatePath() {
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        path = UIBezierPath(
            arcCenter: centerPoint,
            radius: 120,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        ).cgPath
        mask = createMask(centerPoint: centerPoint)
    }
}

fileprivate func createMask(centerPoint: CGPoint) -> CAShapeLayer {
    
    let layer = CAShapeLayer()
    layer.path = UIBezierPath(
        arcCenter: centerPoint,
        radius: OUTER_RADIUS,
        startAngle: 5/6.0 * .pi,
        endAngle: 13/6.0 * .pi,
        clockwise: true
    ).cgPath
    layer.fillColor = UIColor.white.cgColor
    return layer
}

// MARK: - Setpoint layers

fileprivate class SetpointLayers: LayerGroup {
    
    var frame: CGRect {
        get { fatalError("Not implemented") }
        set {
            backgroundShape.frame = newValue
            shadowShape.frame = newValue
        }
    }
    
    var isHidden: Bool {
        get { fatalError("Not implemented") }
        set {
            shadowShape.isHidden = newValue
            backgroundShape.isHidden = newValue
            iconShape.isHidden = newValue
        }
    }
    
    var position: CGPoint {
        get { currentPosition }
    }
    
    var greyOut: Bool {
        get { false }
        set {
            if (newValue) {
                shadowShape.fillColor = UIColor.disabled.cgColor
                backgroundShape.fillColor = UIColor.disabled.copy(alpha: 0.6).cgColor
            } else {
                shadowShape.fillColor = type.color.cgColor
                backgroundShape.fillColor = type.color.copy(alpha: 0.6).cgColor
            }
        }
    }
    
    private lazy var shadowShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = type.color.cgColor
        return layer
    }()
    
    private lazy var backgroundShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = type.color.copy(alpha: 0.6).cgColor
        return layer
    }()
    
    private lazy var iconShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: 18, height: 18)
        layer.contents = type.icon
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    private var type: SetpointType
    private var currentPosition: CGPoint = CGPoint()
    
    init(type: SetpointType) {
        self.type = type
    }
    
    func move(to position: CGPoint) {
        currentPosition = position
        
        backgroundShape.path = UIBezierPath(
            arcCenter: position,
            radius: 16,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        ).cgPath
        shadowShape.path = UIBezierPath(
            arcCenter: position,
            radius: 12,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        ).cgPath
        
        CALayer.performWithoutAnimation {
            iconShape.position = position
        }
    }
    
    func sublayers() -> [CALayer] {
        [shadowShape, backgroundShape, iconShape]
    }
}
