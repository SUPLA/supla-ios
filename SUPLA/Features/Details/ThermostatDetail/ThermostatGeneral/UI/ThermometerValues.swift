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

final class ThermometerValues: UIStackView {
    
    var measurements: [MeasurementValue] = [] {
        didSet {
            if (measurements != oldValue) {
                createSubviews()
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    private var measurementViews: [ThermometerValueView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }
    
    private func setupView() {
        ShadowValues.apply(toLayer: layer)
        backgroundColor = .surface
        
        axis = .horizontal
        distribution = .fillProportionally
        alignment = .center
        layoutMargins = UIEdgeInsets(top: 0, left: Dimens.distanceSmall, bottom: 0, right: Dimens.distanceDefault)
        isLayoutMarginsRelativeArrangement = true
    }
    
    private func createSubviews() {
        if (!measurementViews.isEmpty) {
            measurementViews.forEach { $0.removeFromSuperview() }
            measurementViews.removeAll()
        }
        
        for value in measurements {
            let view = measurementView(value: value, makeSmall: measurements.count > 3)
            measurementViews.append(view)
            addArrangedSubview(view)
        }
    }
    
    private func measurementView(value: MeasurementValue, makeSmall: Bool) -> ThermometerValueView {
        let view = ThermometerValueView(small: makeSmall)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.icon = value.icon
        view.label = value.value
        return view
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

fileprivate final class ThermometerValueView: UIView {
    
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
        view.font = small ? .body1 : .h5
        view.isHidden = true
        view.textColor = .onBackground
        return view
    }()
    
    private let small: Bool
    
    init(small: Bool) {
        self.small = small
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let width = (small ? 24 : 36) + Dimens.distanceTiny + labelView.intrinsicContentSize.width
        return CGSize(width: width, height: 80)
    }
    
    private func setupView() {
        addSubview(iconView)
        addSubview(labelView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: small ? 24 : 36),
            iconView.heightAnchor.constraint(equalToConstant: small ? 24 : 36),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.leftAnchor.constraint(equalTo: leftAnchor),
            
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelView.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: Dimens.distanceTiny),
            labelView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
