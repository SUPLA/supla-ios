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
import RxCocoa

class SALabeledTextField: UIView {
    var label: String? {
        get { labelView.text }
        set { labelView.text = newValue }
    }
    
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    var isError: Bool {
        get { false }
        set {
            if (newValue) {
                layer.borderColor = UIColor.error.cgColor
            } else {
                layer.borderColor = UIColor.grayLighter.cgColor
            }
        }
    }
    
    var isEnabled: Bool {
        get { textField.isEnabled }
        set { textField.isEnabled = newValue }
    }
    
    var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    fileprivate lazy var labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = .caption
        return label
    }()
    
    fileprivate lazy var textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .body1
        return view
    }()
    
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
        
        addSubview(labelView)
        addSubview(textField)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayLighter.cgColor
        layer.cornerRadius = Dimens.radiusDefault
        
        setupLayout()
    }
    
    fileprivate func setupLayout() {
        NSLayoutConstraint.activate([
            labelView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceSmall),
            labelView.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceTiny),
            labelView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceSmall),
            
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceSmall),
            textField.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 4),
            textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceSmall),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Dimens.distanceTiny)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension Reactive where Base: SALabeledTextField {
    var text: ControlProperty<String?> {
        base.textField.rx.text
    }
    
    var returnEvent: ControlEvent<()> {
        base.textField.rx.controlEvent(.editingDidEndOnExit)
    }
}

class SALabeledPasswordField: SALabeledTextField {
    
    private var passwordVisible = false
    
    private lazy var visibilityIcon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .iconInvisible?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .gray
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override func setupLayout() {
        addSubview(visibilityIcon)
        
        visibilityIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(visibilityIconClick)))
        textField.isSecureTextEntry = true
        
        NSLayoutConstraint.activate([
            visibilityIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            visibilityIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceSmall),
            visibilityIcon.widthAnchor.constraint(equalToConstant: Dimens.iconSize),
            visibilityIcon.heightAnchor.constraint(equalToConstant: Dimens.iconSize),
            
            labelView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceSmall),
            labelView.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceTiny),
            labelView.rightAnchor.constraint(equalTo: visibilityIcon.leftAnchor, constant: -Dimens.distanceSmall),
            
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceSmall),
            textField.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 4),
            textField.rightAnchor.constraint(equalTo: visibilityIcon.leftAnchor, constant: -Dimens.distanceSmall),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Dimens.distanceTiny)
            
        ])
    }
    
    @objc 
    private func visibilityIconClick() {
        if (passwordVisible) {
            textField.isSecureTextEntry = true
            visibilityIcon.image = .iconInvisible?.withRenderingMode(.alwaysTemplate)
        } else {
            textField.isSecureTextEntry = false
            visibilityIcon.image = .iconVisible?.withRenderingMode(.alwaysTemplate)
        }
        passwordVisible = !passwordVisible
    }
}
