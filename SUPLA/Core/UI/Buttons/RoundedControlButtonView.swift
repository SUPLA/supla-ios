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

final class RoundedControlButtonView: BaseControlButtonView {
    
    override init(height: CGFloat = Dimens.buttonHeight) {
        super.init(height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var width: CGFloat = 0
            
            if (icon != nil && text != nil) {
                // left margin + icon size + margin between icon & text, right margin
                width = 12 + iconSize + Dimens.distanceSmall + Dimens.distanceSmall
                width += textView.intrinsicContentSize.width
            } else if (icon != nil) {
                width += iconSize + 24
                if (width < height) {
                    width = height
                }
            } else if (text != nil) {
                width += textView.intrinsicContentSize.width + (Dimens.distanceSmall * 2)
            }
            
            return CGSize(width: width, height: height)
        }
    }
    
    override func textConstraints(_ textView: UILabel) -> [NSLayoutConstraint] {
        return [
            textView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceSmall),
            textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceSmall)
        ]
    }
    
    override func iconConstraints(_ iconView: UIImageView) -> [NSLayoutConstraint] {
        let padding = (height - iconSize) / 2
        return [
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.leftAnchor.constraint(equalTo: leftAnchor, constant: padding),
            iconView.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding)
        ]
    }
    
    override func textAndIconConstraints(_ textView: UILabel, _ iconView: UIImageView, _ container: UIView) -> [NSLayoutConstraint] {
        [
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.leftAnchor.constraint(equalTo: container.leftAnchor),
            textView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textView.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: Dimens.distanceSmall),
            textView.rightAnchor.constraint(equalTo: container.rightAnchor)
        ]
    }
}

