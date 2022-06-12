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


class EditableProfileItemCell: ProfileItemCell {
    let editProfileTrigger = PublishSubject<Void>()
    var disposeBag = DisposeBag()

    private let _activeIndicator = UILabel()
    private let _editProfileButton = UIButton()


    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier ident: String?) {
        super.init(style: style, reuseIdentifier: ident)
        initCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initCell()
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
        bindControls()
    }

    override func setProfileItem(_ item: ProfileListItem) {
        guard case let .profileItem(data) = item else {
            fatalError("this shouldn't happen")
        }
        _activeIndicator.isHidden = !data.isActive
        super.setProfileItem(item)
    }

    private func initCell() {
        [ _activeIndicator, _editProfileButton ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }

        _activeIndicator.font = .formLabelFont
        _activeIndicator.textColor = UIColor(red: 0.706,
                                             green: 0.718,
                                             blue: 0.729,
                                             alpha: 1)


        _editProfileButton
          .setBackgroundImage(UIImage(named: "pencil"),
                              for: .normal)
        _editProfileButton.rightAnchor
          .constraint(equalTo: contentView.rightAnchor,
                      constant: -Dimens.Form.elementSpacing)
          .isActive = true
        _editProfileButton.centerYAnchor
          .constraint(equalTo: contentView.centerYAnchor)
          .isActive = true

        _activeIndicator.text = Strings.Profiles.activeIndicator
        _activeIndicator.rightAnchor
          .constraint(equalTo: _editProfileButton.leftAnchor,
                      constant: -Dimens.elementOffset)
          .isActive = true
        _activeIndicator.centerYAnchor
          .constraint(equalTo: contentView.centerYAnchor)
          .isActive = true

            
        bindControls()
    }

    private func bindControls() {
        _editProfileButton.rx.tap.bind {
            self.editProfileTrigger.onNext(())
        }.disposed(by: disposeBag)
    }    
}
