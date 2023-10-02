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

final class ThermometerValues: UIView {
    
    var firstTemperature: ThermostatTemperature? {
        set {
            firstValueView.icon = newValue?.icon
            firstValueView.label = newValue?.temperature
        }
        get { nil }
    }
    
    var secondTemperature: ThermostatTemperature? {
        set {
            secondValueView.icon = newValue?.icon
            secondValueView.label = newValue?.temperature
        }
        get { nil }
    }
    
    private lazy var firstValueView: TermometerValue = {
        let view = TermometerValue()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var secondValueView: TermometerValue = {
        let view = TermometerValue()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }
    
    private func setupView() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = Dimens.Shadow.radius
        layer.shadowOpacity = Dimens.Shadow.opacity
        layer.shadowOffset = Dimens.Shadow.offset
        backgroundColor = .background
        
        addSubview(firstValueView)
        addSubview(secondValueView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            firstValueView.leftAnchor.constraint(equalTo: leftAnchor),
            firstValueView.rightAnchor.constraint(equalTo: centerXAnchor, constant: -1),
            firstValueView.topAnchor.constraint(equalTo: topAnchor),
            
            secondValueView.leftAnchor.constraint(equalTo: centerXAnchor, constant: 1),
            secondValueView.rightAnchor.constraint(equalTo: rightAnchor),
            secondValueView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

fileprivate final class TermometerValue: UIView {
    
    var icon: UIImage? = nil {
        didSet {
            iconView.image = icon
            iconView.isHidden = icon == nil
        }
    }
    
    var label: String? = nil {
        didSet {
            labelView.text = label
            labelView.isHidden = label == nil
        }
    }
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()
    
    private lazy var labelView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .h5
        view.isHidden = true
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }
    
    private func setupView() {
        backgroundColor = UIColor.surface
        
        addSubview(containerView)
        addSubview(iconView)
        addSubview(labelView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelView.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: Dimens.distanceTiny),
            labelView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
