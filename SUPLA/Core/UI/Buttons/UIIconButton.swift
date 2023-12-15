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

class UIIconButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        get { CGSize(width: config.size, height: config.size) }
    }
    
    override var isEnabled: Bool {
        didSet {
            setColors()
        }
    }
    
    var icon: UIImage? {
        get { fatalError("Not implemented") }
        set {
            setImage(newValue?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    var config: Configuration {
        didSet {
            setColors()
        }
    }
    
    init(config: Configuration = .primary()) {
        self.config = config
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(activeSetpointType: SetpointType?) {
        let color = activeSetpointType?.color ?? .disabled
        
        var configuration = config
        configuration.contentColor = color
        configuration.borderColor = color
        config = configuration
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if (isEnabled) {
            backgroundColor = config.backgroundPressedColor
            tintColor = config.contentPressedColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if (isEnabled) {
            backgroundColor = config.backgroundColor
            tintColor = config.contentColor
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if (isEnabled) {
            backgroundColor = config.backgroundColor
            tintColor = config.contentColor
        }
    }
    
    private func setupView() {
        layer.cornerRadius = config.size / 2
        
        if let borderColor = config.borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        }
        
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        imageView?.contentMode = .scaleAspectFit
        
        setColors()
    }
    
    private func setColors() {
        backgroundColor = isEnabled ? config.backgroundColor : config.backgroundDisabledColor
        tintColor = isEnabled ? config.contentColor : config.contentDisabledColor
        
        if let borderColor = config.borderColor {
            layer.borderColor = isEnabled ? borderColor.cgColor : config.contentDisabledColor.cgColor
            layer.borderWidth = 1
        }
    }
    
    struct Configuration {
        var backgroundColor: UIColor
        var backgroundDisabledColor: UIColor
        var backgroundPressedColor: UIColor
        var contentColor: UIColor
        var contentDisabledColor: UIColor
        var contentPressedColor: UIColor
        var borderColor: UIColor?
        var size: CGFloat
        
        static func primary(size: CGFloat = Dimens.buttonSmallHeight) -> Configuration {
            Configuration(
                backgroundColor: .primary,
                backgroundDisabledColor: .disabled,
                backgroundPressedColor: .primaryVariant,
                contentColor: .white,
                contentDisabledColor: .white,
                contentPressedColor: .white,
                borderColor: nil,
                size: size)
        }
        
        static func transparent(
            size: CGFloat = Dimens.buttonSmallHeight,
            contentColor: UIColor = .primary,
            contentPressedColor: UIColor = .primaryVariant
        ) -> Configuration {
            Configuration(
                backgroundColor: .transparent,
                backgroundDisabledColor: .transparent,
                backgroundPressedColor: .transparent,
                contentColor: contentColor,
                contentDisabledColor: .disabled,
                contentPressedColor: contentPressedColor,
                borderColor: nil,
                size: Dimens.buttonSmallHeight
            )
        }
        
        static func bordered(color: UIColor) -> Configuration {
            Configuration(
                backgroundColor: .transparent,
                backgroundDisabledColor: .transparent,
                backgroundPressedColor: .transparent,
                contentColor: color,
                contentDisabledColor: color,
                contentPressedColor: color,
                borderColor: color,
                size: 48
            )
        }
    }
}

