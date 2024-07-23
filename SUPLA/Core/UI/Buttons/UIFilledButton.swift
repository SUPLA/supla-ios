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

class UIFilledButton: UIButton {
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = getBackgroundColor()
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            backgroundColor = getBackgroundColor()
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
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .primary
        setTitleColor(.onPrimary, for: .normal)
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 118/255.0, green: 120/255.0, blue: 128/255.0, alpha: 0.12).cgColor
        layer.cornerRadius = Dimens.buttonRadius
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        
        titleLabel?.font = .button
    }
    
    private func getBackgroundColor() -> UIColor {
        if (!isEnabled) {
            return .disabled
        } else if (isHighlighted) {
            return .primaryVariant
        } else {
            return .primary
        }
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
