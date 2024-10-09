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

class BaseControlButtonView: UIView {
    var tapObservable: Observable<Void> {
        tapRelay.asObservable()
    }

    var longPress: PublishRelay<Void> {
        longPressEnabled = true
        return longPressRelay
    }

    let iconSize: CGFloat = 20
    let height: CGFloat

    var type = ButtonType.positive

    var isEnabled: Bool = true {
        didSet {
            disabledOverlay.isHidden = isEnabled
        }
    }

    var isClickable: Bool = true

    var text: String? = nil {
        didSet {
            textView.text = text
            textView.isHidden = text == nil
            setupLayout()
        }
    }

    var icon: IconResult? = nil {
        didSet {
            switch (icon) {
            case .suplaIcon(let icon):
                iconView.image = .init(named: icon)?.withRenderingMode(.alwaysTemplate)
                iconView.tintColor = iconColor
            case .userIcon(let icon):
                iconView.image = icon
            default:
                iconView.image = icon?.uiImage
            }

            iconView.isHidden = icon == nil
            setupLayout()
        }
    }

    var iconColor: UIColor = .onBackground {
        didSet {
            iconView.tintColor = iconColor
        }
    }

    var textFont: UIFont? {
        get { fatalError("Not implemented!") }
        set {
            textView.font = newValue
        }
    }

    var active: Bool = false {
        didSet {
            traitCollection.performAsCurrent {
                layer.shadowColor = active ? type.pressedColor.cgColor : UIColor.black.cgColor
                layer.borderColor = active ? type.pressedColor.cgColor : UIColor.disabled.cgColor
                textView.textColor = active ? type.textColor : type.inactiveColor
                iconView.tintColor = active ? type.textColor : iconColor
            }
            innerShadowView.isHidden = !active

            setNeedsLayout()
        }
    }

    lazy var textView: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = .button
        text.isHidden = true
        text.textAlignment = .center
        text.textColor = active ? type.textColor : type.inactiveColor
        return text
    }()

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        view.isHidden = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var containerView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var innerShadowView: InnerShadowView = {
        let view = InnerShadowView(height: height)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var disabledOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = height / 2
        view.backgroundColor = .disabledOverlay
        view.isHidden = true
        return view
    }()

    private let tapRelay: PublishRelay<Void> = PublishRelay()
    private let longPressRelay: PublishRelay<Void> = PublishRelay()
    private var longPressEnabled = false
    private var activeConstraints: [NSLayoutConstraint] = []

    init(height: CGFloat) {
        self.height = height
        super.init(frame: CGRect.zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if (isEnabled && isClickable) {
            BaseControlButtonView.setupPressedLayer(layer, type)
            textView.textColor = type.textColor
            iconView.tintColor = type.textColor
            innerShadowView.isHidden = false
        }
    }

    private func setupView() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongPress)))

        layer.cornerRadius = height / 2

        BaseControlButtonView.setupLayer(layer)

        addSubview(innerShadowView)
        addSubview(textView)
        addSubview(iconView)
        addSubview(disabledOverlay)
        addSubview(containerView)

        setupLayout()
    }

    private func setupLayout() {
        if (!activeConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(activeConstraints)
            activeConstraints.removeAll()
        }

        activeConstraints.append(contentsOf: [
            innerShadowView.leftAnchor.constraint(equalTo: leftAnchor, constant: -1),
            innerShadowView.rightAnchor.constraint(equalTo: rightAnchor, constant: 1),
            innerShadowView.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            innerShadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),

            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),

            disabledOverlay.leftAnchor.constraint(equalTo: leftAnchor),
            disabledOverlay.rightAnchor.constraint(equalTo: rightAnchor),
            disabledOverlay.topAnchor.constraint(equalTo: topAnchor),
            disabledOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if (!textView.isHidden && !iconView.isHidden) {
            activeConstraints.append(contentsOf: textAndIconConstraints(textView, iconView, containerView))
        }
        else if (!textView.isHidden) {
            activeConstraints.append(contentsOf: textConstraints(textView))
        }
        else if (!iconView.isHidden) {
            activeConstraints.append(contentsOf: iconConstraints(iconView))
        }

        NSLayoutConstraint.activate(activeConstraints)
    }

    func textConstraints(_ textView: UILabel) -> [NSLayoutConstraint] { return [] }

    func iconConstraints(_ iconView: UIImageView) -> [NSLayoutConstraint] { return [] }

    func textAndIconConstraints(_ textView: UILabel, _ iconView: UIImageView, _ container: UIView) -> [NSLayoutConstraint] { return [] }

    @objc private func onTap() {
        if (isEnabled && isClickable) {
            tapRelay.accept(())
        }

        layer.shadowRadius = 3
        layer.shadowColor = active ? type.pressedColor.cgColor : UIColor.black.cgColor
        layer.borderColor = active ? type.pressedColor.cgColor : UIColor.disabled.cgColor
        textView.textColor = active ? type.textColor : type.inactiveColor
        iconView.tintColor = active ? type.textColor : iconColor
        innerShadowView.isHidden = active ? false : true
    }

    @objc private func onLongPress(_ sender: UILongPressGestureRecognizer) {
        if (sender.state != .began) {
            return
        }

        if (isEnabled) {
            if (longPressEnabled) {
                longPressRelay.accept(())
            } else if (isClickable) {
                tapRelay.accept(())
            }
        }

        layer.shadowRadius = 3
        layer.shadowColor = active ? type.pressedColor.cgColor : UIColor.black.cgColor
        layer.borderColor = active ? type.pressedColor.cgColor : UIColor.disabled.cgColor
        textView.textColor = active ? type.textColor : .onBackground
        iconView.tintColor = active ? type.textColor : iconColor
        innerShadowView.isHidden = active ? false : true
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    enum ButtonType {
        case positive, negative, neutral

        var pressedColor: UIColor {
            switch (self) {
            case .positive: return .green
            case .negative: return .negativeBorder
            case .neutral: return .onBackground
            }
        }

        var textColor: UIColor {
            switch (self) {
            case .positive: return .onBackground
            case .negative: return .negativeBorder
            case .neutral: return .black
            }
        }

        var inactiveColor: UIColor {
            switch (self) {
            case .positive: return .onBackground
            case .negative: return .onBackground
            case .neutral: return .black
            }
        }
    }

    static func setupLayer(_ layer: CALayer) {
        layer.backgroundColor = UIColor.surface.cgColor

        ShadowValues.apply(toButton: layer)

        layer.borderColor = UIColor.disabled.cgColor
        layer.borderWidth = 1
    }

    static func setupPressedLayer(_ layer: CALayer, _ type: ButtonType) {
        layer.shadowRadius = 6
        layer.shadowColor = type.pressedColor.cgColor
        layer.borderColor = type.pressedColor.cgColor
    }
}

private class InnerShadowView: UIView {
    private lazy var innerShadow: CALayer = {
        let innerShadow = CALayer()
        return innerShadow
    }()

    private let height: CGFloat

    init(height: CGFloat) {
        self.height = height
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
        innerShadow.cornerRadius = frame.size.height / 2
    }

    private func setupView() {
        layer.addSublayer(innerShadow)
        layer.cornerRadius = height / 2
    }

    private func createPath() -> CGPath {
        // Shadow path (1pt ring around bounds)
        let radius = frame.size.height / 2
        let path = UIBezierPath(roundedRect: innerShadow.frame.insetBy(dx: -3, dy: -3), cornerRadius: radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.frame, cornerRadius: radius).reversing()
        path.append(cutout)

        return path.cgPath
    }
}
