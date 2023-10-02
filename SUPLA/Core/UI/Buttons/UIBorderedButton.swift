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

class UIBorderedButton: UIButton {
    
    override open var isHighlighted: Bool {
        didSet {
            layer.borderColor = isHighlighted ? UIColor.primary.cgColor : UIColor.primaryVariant.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .surface
        setTitleColor(.primaryVariant, for: .normal)
        setTitleColor(.primary, for: .highlighted)
        layer.borderWidth = 1
        layer.borderColor = UIColor.primaryVariant.cgColor
        layer.cornerRadius = Dimens.radiusButton
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        
        titleLabel?.font = .button
    }
}

