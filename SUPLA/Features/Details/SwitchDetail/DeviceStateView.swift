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

import SharedCore

final class DeviceStateUIView: UIStackView {
    var label: String? = nil {
        didSet { labelView.text = label?.uppercased() }
    }
    
    var icon: UIImage? = nil {
        didSet {
            iconView.image = icon
            iconView.isHidden = icon == nil
        }
    }
    
    var value: String? = nil {
        didSet { valueView.text = value }
    }
    
    var iconTint: UIColor? {
        get { iconView.tintColor }
        set { iconView.tintColor = newValue }
    }
    
    private lazy var labelView: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.textColor = .gray
        return label
    }()
    
    private lazy var iconView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private lazy var valueView: UILabel = {
        let label = UILabel()
        label.font = .openSansBold(style: .body, size: 14)
        return label
    }()
    
    private let iconSize: CGFloat
    
    init(iconSize: CGFloat = Dimens.iconSize) {
        self.iconSize = iconSize
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        spacing = Dimens.distanceTiny
        
        addArrangedSubview(labelView)
        addArrangedSubview(iconView)
        addArrangedSubview(valueView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: iconSize),
            iconView.widthAnchor.constraint(equalToConstant: iconSize),
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
