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

final class PermissionCell: BaseSettingsCell<UIImageView> {
    
    static let id = "PermissionCell"
    var callback: () -> Void = {}
    
    private lazy var status: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont(name: "Open Sans", size: 16)
        return label
    }()
    
    override func provideActionView() -> UIImageView {
        let view = UIImageView(image: .iconArrowRight)
        view.tintColor = .suplaGreen
        return view
    }
    
    override func setupLayout() {
        contentView.addSubview(status)
        
        NSLayoutConstraint.activate([
            
            labelView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            labelView.leftAnchor.constraint(equalTo: status.rightAnchor, constant: 8),
            labelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelView.rightAnchor.constraint(lessThanOrEqualTo: actionView.leftAnchor, constant: -24),
            
            
            status.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 24),
            status.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            actionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -24),
            actionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.addGestureRecognizer(NSUITapGestureRecognizer(target: self, action: #selector(onViewTapped)))
    }
    
    @objc
    private func onViewTapped() {
        callback()
    }
    
    static func configure(_ label: String, _ active: Bool, _ callback: @escaping () -> Void, cellProvider: () -> PermissionCell) -> PermissionCell {
        let cell = cellProvider()
        cell.setLabel(label)
        cell.callback = callback
        
        if (active) {
            cell.status.text = "✓"
            cell.status.textColor = .suplaGreen
        } else {
            cell.status.text = "𐄂"
            cell.status.textColor = .red
        }
        return cell
    }
}

