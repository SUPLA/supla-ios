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

import UIKit
import RxSwift

class BaseSettingsCell<T: UIView>: UITableViewCell {
    
    lazy var labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont(name: "Open Sans", size: 14)
        return label
    }()
    
    lazy var actionView: T = {
        let view = provideActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    func provideActionView() -> T {
        fatalError("provideActionView() has not been implemented")
    }
    
    func setLabel(_ label: String) {
        labelView.text = label
    }
    
    private func setupView() {
        selectionStyle = .none
        contentView.addSubview(labelView)
        contentView.addSubview(actionView)
        setupLayout()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            labelView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 24),
            labelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelView.rightAnchor.constraint(lessThanOrEqualTo: actionView.leftAnchor, constant: -24),
            
            actionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -24),
            actionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
