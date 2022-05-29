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

class ProfileItemCell: UITableViewCell {

    let editProfileTrigger = PublishSubject<Void>()
    var disposeBag = DisposeBag()
    
    private let _userAvatar = UIImageView()
    private let _profileNameLabel = UILabel()
    private let _activeIndicator = UILabel()
    private let _editProfileButton = UIButton()

    private let _avatarActiveImg = UIImage(named: "ProfileItemActive")
    private let _avatarInactiveImg = UIImage(named: "ProfileItemInactive")


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

    func setProfileItem(_ item: ProfileListItem) {
        guard case let .profileItem(data) = item else {
            fatalError("this shouldn't happen")
        }

        _profileNameLabel.text = data.name

        if data.isActive {
            _userAvatar.image = _avatarActiveImg
        } else {
            _userAvatar.image = _avatarInactiveImg
        }

    }

    private func initCell() {
        [ _userAvatar, _profileNameLabel, _activeIndicator,
          _editProfileButton ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }

        _userAvatar.leftAnchor
          .constraint(equalTo: contentView.leftAnchor,
                      constant: Dimens.Form.elementSpacing)
          .isActive = true
        _userAvatar.topAnchor
          .constraint(equalTo: contentView.topAnchor,
                      constant: Dimens.Form.verticalMargin)
          .isActive = true
        _userAvatar.bottomAnchor
          .constraint(equalTo: contentView.bottomAnchor,
                      constant: -Dimens.Form.verticalMargin)
          .isActive = true
        _profileNameLabel.leftAnchor
          .constraint(equalTo: _userAvatar.rightAnchor,
                      constant: Dimens.elementOffset)
          .isActive = true
        _profileNameLabel.centerYAnchor
          .constraint(equalTo: _userAvatar.centerYAnchor)
          .isActive = true

        _editProfileButton
          .setBackgroundImage(UIImage(named: "pencil"),
                              for: .normal)
        _editProfileButton.rightAnchor
          .constraint(equalTo: contentView.rightAnchor,
                      constant: -Dimens.Form.elementSpacing)
          .isActive = true
        _editProfileButton.centerYAnchor
          .constraint(equalTo: _userAvatar.centerYAnchor)
          .isActive = true

        _activeIndicator.text = "active"
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
