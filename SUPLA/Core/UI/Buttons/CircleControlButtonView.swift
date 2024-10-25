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

import RxSwift
import RxRelay

final class CircleControlButtonView: BaseControlButtonView {
    
    static let SIZE: CGFloat = 120
    
    init(size: CGFloat = CircleControlButtonView.SIZE) {
        super.init(height: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            // This button is always a circle
            return CGSize(width: height, height: height)
        }
    }
    
    override func textConstraints(_ textView: UILabel) -> [NSLayoutConstraint] {
        return [
            textView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
    }
    
    override func iconConstraints(_ iconView: UIImageView) -> [NSLayoutConstraint] {
        return [
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
    }
    
    override func textAndIconConstraints(_ textView: UILabel, _ iconView: UIImageView, _ container: UIView) -> [NSLayoutConstraint] {
        return [
            textView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textView.topAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2)
        ]
    }
}
