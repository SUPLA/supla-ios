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

class CfgCell: UITableViewCell {
    
    let titleLabel = UILabel()
    
    private let hMargin = CGFloat(24)
    private let vMargin = CGFloat(14)
    
    var actionView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let nv = actionView {
                contentView.addSubview(nv)
                nv.translatesAutoresizingMaskIntoConstraints = false
                nv.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -hMargin).isActive = true
                nv.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
                titleLabel.rightAnchor.constraint(lessThanOrEqualTo: nv.leftAnchor, constant: -8).isActive = true
            }
        }
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:hMargin).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        titleLabel.font = UIFont(name: "Open Sans", size: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
