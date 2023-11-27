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

import RxSwift
import RxRelay

class BaseControlButtonView: UIView {

    let tap: PublishRelay<Void> = PublishRelay()
    var longPress: PublishRelay<Void> {
        get {
            longPressEnabled = true
            return longPressRelay
        }
    }

    let iconSize: CGFloat = 20
    let height: CGFloat

    var type = ButtonType.positive
    
    var isEnabled: Bool = true {
        didSet {
            disabledOverlay.isHidden = isEnabled
        }
    }
    
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
                iconView.image = icon?.withRenderingMode(.alwaysTemplate)
            case .userIcon(let icon) :
                iconView.image = icon
            default:
                iconView.image = icon?.icon
            }

            iconView.isHidden = icon?.icon == nil
            setupLayout()
        }
    }

    var iconColor: UIColor = .black {
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
            layer.shadowColor = active ? type.pressedColor.cgColor : UIColor.black.cgColor
            layer.borderColor = active ? type.pressedColor.cgColor : UIColor.border.cgColor
            textView.textColor = active ? type.textColor : .black
            iconView.tintColor = active ? type.textColor : iconColor
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
    
    private let longPressRelay: PublishRelay<Void> = PublishRelay()
    private var longPressEnabled = false
    private var activeConstraints: [NSLayoutConstraint] = []

    init(height: CGFloat) {
        self.height = height
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if (isEnabled) {
            layer.shadowRadius = 6
            layer.shadowColor = type.pressedColor.cgColor
            layer.borderColor = type.pressedColor.cgColor
            textView.textColor = type.textColor
            iconView.tintColor = type.textColor
            innerShadowView.isHidden = false
        }
    }

    private func setupView() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongPress)))

        backgroundColor = .surface
        
        layer.cornerRadius = height / 2
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSizeMake(0, 4)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
        
        layer.borderColor = UIColor.border.cgColor
        layer.borderWidth = 1
        
        addSubview(innerShadowView)
        addSubview(textView)
        addSubview(iconView)
        addSubview(disabledOverlay)

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
            activeConstraints.append(contentsOf: textAndIconConstraints(textView, iconView))
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

    func textAndIconConstraints(_ textView: UILabel, _ iconView: UIImageView) -> [NSLayoutConstraint] { return [] }

    @objc private func onTap() {
        if (isEnabled) {
            tap.accept(())
        }

        layer.shadowRadius = 3
        layer.shadowColor = active ? type.pressedColor.cgColor : UIColor.black.cgColor
        layer.borderColor = active ? type.pressedColor.cgColor : UIColor.border.cgColor
        textView.textColor = active ? type.textColor : .black
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
            } else {
                tap.accept(())
            }
        }

        layer.shadowRadius = 3
        layer.shadowColor = active ? type.pressedColor.cgColor : UIColor.black.cgColor
        layer.borderColor = active ? type.pressedColor.cgColor : UIColor.border.cgColor
        textView.textColor = active ? type.textColor : .black
        iconView.tintColor = active ? type.textColor : iconColor
        innerShadowView.isHidden = active ? false : true
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    enum ButtonType {
        case positive, negative, neutral

        var pressedColor: UIColor {
            get {
                switch(self) {
                case .positive: return .primaryVariant
                case .negative: return .negativeBorder
                case .neutral: return .onBackground
                }
            }
        }

        var textColor: UIColor {
            get {
                switch(self) {
                case .positive: return .primary
                case .negative: return .negativeBorder
                case .neutral: return .onBackground
                }
            }
        }
    }
}

fileprivate class InnerShadowView: UIView {
    
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
        innerShadow.cornerRadius = self.frame.size.height/2
    }
    
    private func setupView() {
        layer.addSublayer(innerShadow)
        layer.cornerRadius = height / 2
    }

    private func createPath() -> CGPath {
        // Shadow path (1pt ring around bounds)
        let radius = self.frame.size.height/2
        let path = UIBezierPath(roundedRect: innerShadow.frame.insetBy(dx: -3, dy:-3), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.frame, cornerRadius:radius).reversing()
        path.append(cutout)

        return path.cgPath
    }
}
