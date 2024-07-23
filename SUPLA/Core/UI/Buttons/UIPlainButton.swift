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

class UIPlainButton: UIButton {
    
    override open var isHighlighted: Bool {
        didSet {
            setTitleColor(getTextColor(), for: .normal)
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            setTitleColor(getTextColor(), for: .normal)
        }
    }
    
    var icon: UIImage? {
        get { nil }
        set {
            if let newIcon = newValue {
                setImage(newIcon.withRenderingMode(.alwaysTemplate))
                tintColor = .primary
            }
        }
    }
    
    var textColor: UIColor = .primary {
        didSet {
            setTitleColor(getTextColor(), for: .normal)
        }
    }
    
    var iconPosition: IconPosition = .trailing {
        didSet { setupIconPosition() }
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
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setTitleColor(getTextColor(), for: .normal)
        titleLabel?.font = .button
        setupIconPosition()
    }
    
    private func getTextColor() -> UIColor {
        if (!isEnabled) {
            return .disabled
        } else if (isHighlighted) {
            return .primaryVariant
        } else {
            return textColor
        }
    }
    
    private func setupIconPosition() {
        switch (iconPosition) {
        case .leading:
            semanticContentAttribute = .forceLeftToRight
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        case .trailing:
            semanticContentAttribute = .forceRightToLeft
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        }
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    enum IconPosition {
        case leading, trailing
    }
}
