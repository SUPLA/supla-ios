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

class AddNewProfileCell: UITableViewCell {

    private let _label = UILabel()
    private let _plusIcon = UIImageView()

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier ident: String?) {
        super.init(style: style, reuseIdentifier: ident)
        initCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initCell()
    }

    private func initCell() {
        separatorInset = UIEdgeInsets(top: 0,
                                      left: UIScreen.main.bounds.size.width,
                                      bottom: 0, right: 0)
        

        [ _label, _plusIcon ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
            $0.centerYAnchor.constraint(equalTo: self.contentView
                                          .centerYAnchor).isActive = true
        }

        _label.topAnchor.constraint(equalTo: contentView.topAnchor,
                                    constant: Dimens.Form.elementSpacing)
          .isActive = true
        _label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                       constant: -Dimens.Form.elementSpacing)
          .isActive = true

        backgroundColor = .clear

        _label.text = Strings.Profiles.addNew
        _label.font = .formLabelFont
        _label.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                     constant: Dimens.Form.elementSpacing)
          .isActive = true

        _plusIcon.leftAnchor.constraint(equalTo: _label.rightAnchor,
                                        constant: Dimens.elementOffset)
          .isActive = true
        _plusIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        _plusIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        _plusIcon.image = UIImage(named: "Plus")
    }
}
