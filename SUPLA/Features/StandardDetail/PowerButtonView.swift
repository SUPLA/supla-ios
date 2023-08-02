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

final class PowerButtonView: UIView {
    
    static let SIZE: CGFloat = 120
    
    let tap: PublishRelay<Void> = PublishRelay()
    
    var type = ButtonType.positive
    
    var disabled: Bool = false {
        didSet {
            disabledOverlay.isHidden = !disabled
        }
    }
    
    var text: String? = nil {
        didSet { textView.text = text }
    }
    
    var icon: IconResult? = nil {
        didSet {
            switch (icon) {
            case .suplaIcon(let icon):
                iconView.image = icon?.withRenderingMode(.alwaysTemplate)
                break
            case .userIcon(let icon) :
                iconView.image = icon
                break
            default:
                iconView.image = icon?.icon
                break
            }
        }
    }
    
    private lazy var textView: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = .button
        return text
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var innerShadowView: InnerShadowView = {
        let view = InnerShadowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var disabledOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = PowerButtonView.SIZE / 2
        view.backgroundColor = .disabledOverlay
        view.isHidden = true
        return view
    }()
    
    private var activeShadowColor: UIColor {
        get {
            switch (type) {
            case .positive: return .primary
            case .negative: return .negativeBorder
            }
        }
    }
    
    private var activeBorderColor: UIColor {
        get {
            switch(type) {
            case .positive: return .primaryVariant
            case .negative: return .negativeBorder
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if (!disabled) {
            layer.shadowRadius = 6
            layer.shadowColor = activeShadowColor.cgColor
            layer.borderColor = activeBorderColor.cgColor
            textView.textColor = activeBorderColor
            iconView.tintColor = activeBorderColor
            innerShadowView.isHidden = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.borderColor = UIColor.border.cgColor
        textView.textColor = .black
        iconView.tintColor = .black
        innerShadowView.isHidden = true
        
        if (!disabled) {
            guard let touch = touches.first else { return }
            let point = touch.location(in: self)
            if (self.point(inside: point, with: event)) {
                tap.accept(())
            }
        }
    }
    
    private func setupView() {
        backgroundColor = .surface
        
        layer.cornerRadius = PowerButtonView.SIZE / 2
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSizeMake(0, 4)
        layer.shadowRadius = 4
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
        NSLayoutConstraint.activate([
            innerShadowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            innerShadowView.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerShadowView.heightAnchor.constraint(equalToConstant: PowerButtonView.SIZE+2),
            innerShadowView.widthAnchor.constraint(equalToConstant: PowerButtonView.SIZE+2),
            
            textView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textView.topAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            
            disabledOverlay.centerXAnchor.constraint(equalTo: centerXAnchor),
            disabledOverlay.centerYAnchor.constraint(equalTo: centerYAnchor),
            disabledOverlay.heightAnchor.constraint(equalToConstant: PowerButtonView.SIZE),
            disabledOverlay.widthAnchor.constraint(equalToConstant: PowerButtonView.SIZE)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    enum ButtonType {
        case positive, negative
    }
}

fileprivate class InnerShadowView: UIView {
    
    private lazy var innerShadow: CALayer = {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.type = .radial
        gradient.colors = [ UIColor.white.cgColor, UIColor.innerShadow.cgColor ]
        gradient.locations = [0.9, 1.4]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.51)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.size.width/2, y: bounds.size.height/2),
            radius: (bounds.size.width/2) - 2,
            startAngle: 0,
            endAngle: (2*Double.pi),
            clockwise: true
        ).cgPath
        gradient.mask = mask
        
        return gradient
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
        super.layoutSubviews()
        innerShadow.frame = bounds
        layer.addSublayer(innerShadow)
    }
    
    private func setupView() {
        layer.cornerRadius = PowerButtonView.SIZE / 2
    }
}

