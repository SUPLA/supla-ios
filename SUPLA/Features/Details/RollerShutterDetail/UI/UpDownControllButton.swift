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

import RxCocoa
import RxRelay
import RxSwift

private let BUTTON_WIDTH: CGFloat = 64
private let BUTTON_HEIGHT: CGFloat = 94

let UP_DOWN_CONTROLL_BUTTON_HEIGHT = BUTTON_HEIGHT * 2

// MARK: - Button type

enum ControlButtonType {
    case up, down
    
    fileprivate var maskedCorners: CACornerMask {
        switch (self) {
        case .up:
            [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .down:
            [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    fileprivate var roundingCorners: UIRectCorner {
        switch (self) {
        case .up:
            [.topLeft, .topRight]
        case .down:
            [.bottomLeft, .bottomRight]
        }
    }
}

// MARK: - Button self

class UpDownControlButton: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: BUTTON_WIDTH, height: UP_DOWN_CONTROLL_BUTTON_HEIGHT)
    }
    
    var isEnabled: Bool = true {
        didSet {
            upButton.isEnabled = isEnabled
            downButton.isEnabled = isEnabled
        }
    }
    
    var upIcon: UIImage? {
        get { upButton.icon }
        set { upButton.icon = newValue }
    }
    
    var downIcon: UIImage? {
        get { downButton.icon }
        set { downButton.icon = newValue }
    }
    
    fileprivate lazy var upButton: ControlButton = .init(buttonType: .up)
    fileprivate lazy var downButton: ControlButton = .init(buttonType: .down)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(upButton)
        addSubview(downButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            upButton.leftAnchor.constraint(equalTo: leftAnchor),
            upButton.topAnchor.constraint(equalTo: topAnchor),
            
            downButton.leftAnchor.constraint(equalTo: leftAnchor),
            downButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension Reactive where Base: UpDownControlButton {
    var tap: Observable<ControlButtonType> {
        Observable.merge(
            base.upButton.rx.tap.map { .up },
            base.downButton.rx.tap.map { .down }
        )
    }

    var touchDown: Observable<ControlButtonType> {
        Observable.merge(
            base.upButton.rx.touchDown.map { .up },
            base.downButton.rx.touchDown.map { .down }
        )
    }

    var touchUp: Observable<ControlButtonType> {
        Observable.merge(
            base.upButton.rx.touchUp.map { .up },
            base.downButton.rx.touchUp.map { .down }
        )
    }
}

// MARK: - Control button

private class ControlButton: UIView {
    var isEnabled: Bool = true {
        didSet {
            disabledOverlay.isHidden = isEnabled
        }
    }
    
    var icon: UIImage? {
        get { iconView.image }
        set { iconView.image = newValue?.withRenderingMode(.alwaysTemplate) }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
    }
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .onBackground
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var innerShadowView: InnerShadowView = {
        let view = InnerShadowView(type: controlType)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var disabledOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = BUTTON_WIDTH / 2
        view.backgroundColor = .disabledOverlay
        view.isHidden = true
        return view
    }()
    
    private let type = BaseControlButtonView.ButtonType.positive
    private let controlType: ControlButtonType
    
    fileprivate let tapRelay = PublishRelay<Void>()
    fileprivate let touchDownRelay = PublishRelay<Void>()
    fileprivate let touchUpRelay = PublishRelay<Void>()
    
    init(buttonType: ControlButtonType) {
        controlType = buttonType
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if (isEnabled) {
            BaseControlButtonView.setupPressedLayer(layer, type)
            innerShadowView.isHidden = false
            iconView.tintColor = type.textColor
            
            touchDownRelay.accept(())
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if (isEnabled) {
            BaseControlButtonView.setupLayer(layer)
            innerShadowView.isHidden = true
            iconView.tintColor = .onBackground
            
            touchUpRelay.accept(())
            
            if let point = event?.allTouches?.first?.location(in: superview),
               frame.contains(point)
            {
                tapRelay.accept(())
            }
        }
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        BaseControlButtonView.setupLayer(layer)
        
        layer.cornerRadius = BUTTON_WIDTH / 2
        layer.maskedCorners = controlType.maskedCorners
        disabledOverlay.layer.maskedCorners = controlType.maskedCorners
        
        addSubview(innerShadowView)
        addSubview(iconView)
        addSubview(disabledOverlay)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            innerShadowView.leftAnchor.constraint(equalTo: leftAnchor, constant: -1),
            innerShadowView.rightAnchor.constraint(equalTo: rightAnchor, constant: 1),
            innerShadowView.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            innerShadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),
            
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            disabledOverlay.leftAnchor.constraint(equalTo: leftAnchor),
            disabledOverlay.rightAnchor.constraint(equalTo: rightAnchor),
            disabledOverlay.topAnchor.constraint(equalTo: topAnchor),
            disabledOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension Reactive where Base: ControlButton {
    var tap: Observable<Void> { base.tapRelay.asObservable() }

    var touchDown: Observable<Void> { base.touchDownRelay.asObservable() }

    var touchUp: Observable<Void> { base.touchUpRelay.asObservable() }
}

// MARK: - Buttons inner shadow

private class InnerShadowView: UIView {
    private lazy var innerShadow: CALayer = {
        let innerShadow = CALayer()
        return innerShadow
    }()
    
    private let type: ControlButtonType
    
    init(type: ControlButtonType) {
        self.type = type
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        innerShadow.frame = bounds
        innerShadow.shadowPath = createPath()
        innerShadow.masksToBounds = true
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 3)
        innerShadow.shadowOpacity = 0.4
        innerShadow.shadowRadius = 3
        innerShadow.cornerRadius = frame.size.width / 2
        innerShadow.maskedCorners = type.maskedCorners
    }
    
    private func setupView() {
        layer.addSublayer(innerShadow)
        layer.cornerRadius = BUTTON_WIDTH / 2
        layer.maskedCorners = type.maskedCorners
    }

    private func createPath() -> CGPath {
        // Shadow path (1pt ring around bounds)
        let radius = frame.size.width / 2
        let radiusSize = CGSize(width: radius, height: radius)
        
        let path = UIBezierPath(roundedRect: innerShadow.frame.insetBy(dx: -3, dy: -3), byRoundingCorners: type.roundingCorners, cornerRadii: radiusSize)
        let cutout = UIBezierPath(roundedRect: innerShadow.frame, byRoundingCorners: type.roundingCorners, cornerRadii: radiusSize).reversing()
        path.append(cutout)

        return path.cgPath
    }
}
