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

final class NewGestureInfoView: UIView {
    
    var delegate: NewGestureInfoDelegate? = nil
    
    private lazy var icon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "tap_gesture"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        return icon
    }()
    
    private lazy var close: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "icon_close"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        icon.isUserInteractionEnabled = true
        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCloseTapped)))
        return icon
    }()
    
    private lazy var text: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textAlignment = .center
        text.font = UIFont(name: "Open Sans", size: 15)
        text.numberOfLines = 0
        text.text = Strings.Main.newGestureInfo
        text.textColor = .white
        return text
    }()
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        gradientLayer.type = .radial
        gradientLayer.colors = [ UIColor.newGestureBackgroundDarker.cgColor, UIColor.newGestureBackgroundLighter.cgColor]
        gradientLayer.locations = [0.25, 1.3]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 2.0, y:1.25)
    }
    
    private func setupView() {
        addSubview(icon)
        addSubview(close)
        addSubview(text)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            icon.heightAnchor.constraint(equalToConstant: 120),
            icon.widthAnchor.constraint(equalToConstant: 120),
            
            close.bottomAnchor.constraint(equalTo: icon.topAnchor, constant: -16),
            close.rightAnchor.constraint(equalTo: rightAnchor, constant: -32),
            close.heightAnchor.constraint(equalToConstant: 24),
            close.widthAnchor.constraint(equalToConstant: 24),
            
            text.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            text.topAnchor.constraint(equalTo: centerYAnchor, constant: 8)
        ])
    }
    
    @objc
    private func onCloseTapped() {
        delegate?.onCloseTapped()
    }
}

protocol NewGestureInfoDelegate {
    func onCloseTapped()
}
