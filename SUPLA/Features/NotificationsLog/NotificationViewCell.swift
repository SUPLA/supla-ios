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

final class NotificationViewCell: UITableViewCell {
    
    private lazy var profileLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .captionSemiBold
        label.text = Strings.Notifications.profile
        return label
    }()
    
    private lazy var profileNameView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        return label
    }()
    
    private lazy var dateLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .captionSemiBold
        label.text = Strings.Notifications.date
        return label
    }()
    
    private lazy var dateView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        return label
    }()
    
    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .h6
        return label
    }()
    
    private lazy var messageView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        return label
    }()
    
    var profileName: String? {
        get { profileNameView.text }
        set {
            profileNameView.text = newValue
            profileNameView.isHidden = newValue == nil
            profileLabelView.isHidden = newValue == nil
        }
    }
    
    var date: String? {
        get { dateView.text }
        set { dateView.text = newValue }
    }
    
    var title: String? {
        get { titleView.text }
        set { titleView.text = newValue }
    }
    
    var message: String? {
        get { messageView.text }
        set { messageView.text = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        contentView.backgroundColor = .surface
        
        contentView.addSubview(profileLabelView)
        contentView.addSubview(profileNameView)
        contentView.addSubview(dateLabelView)
        contentView.addSubview(dateView)
        contentView.addSubview(titleView)
        contentView.addSubview(messageView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            dateView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimens.distanceTiny),
            dateView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimens.distanceTiny),
            
            dateLabelView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimens.distanceTiny),
            dateLabelView.rightAnchor.constraint(equalTo: dateView.leftAnchor, constant: -4),
            
            profileNameView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimens.distanceTiny),
            profileNameView.rightAnchor.constraint(equalTo: dateLabelView.leftAnchor, constant: -Dimens.distanceTiny),
            
            profileLabelView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimens.distanceTiny),
            profileLabelView.rightAnchor.constraint(equalTo: profileNameView.leftAnchor, constant: -4),
            
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimens.distanceDefault),
            titleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimens.distanceDefault),
            titleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimens.distanceDefault),
            
            messageView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Dimens.distanceTiny),
            messageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimens.distanceDefault),
            messageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimens.distanceDefault),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimens.distanceDefault)
        ])
    }
}
