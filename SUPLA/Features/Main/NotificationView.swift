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

final class NotificationView: UIView {
    
    var text: String? = nil {
        didSet {
            textView.text = text
        }
    }
    
    var icon: UIImage? = nil {
        didSet {
            iconView.image = icon
        }
    }
    
    private lazy var iconView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private lazy var textView: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textAlignment = .center
        text.font = UIFont(name: "Open Sans", size: 11)
        text.numberOfLines = 0
        return text
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .yellow
        addSubview(iconView)
        addSubview(textView)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -8),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            getTextBottomConstraint()
        ])
    }
    
    private func getTextBottomConstraint() -> NSLayoutConstraint {
        if #available(iOS 11, *) {
            return textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        } else {
            return textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        }
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
