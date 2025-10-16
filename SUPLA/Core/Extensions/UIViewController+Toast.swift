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

private let FADE_IN_OUT_DURATION: Double = 0.3

enum ToastLenght: Double {
    case short = 1.4
    case long = 2.9
}

extension UIViewController {
    
    func showToast(_ message: String, lenght: ToastLenght = .short) {
        let toastView = UIToastView()
        toastView.message = message
        
        let constraints: [NSLayoutConstraint] = [
            toastView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -Dimens.distanceDefault),
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        view.addSubview(toastView)
        NSLayoutConstraint.activate(constraints)
        
        UIView.animate(withDuration: FADE_IN_OUT_DURATION) {
            toastView.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + lenght.rawValue) {
            UIView.animate(
                withDuration: FADE_IN_OUT_DURATION,
                animations: { toastView.alpha = 0 },
                completion: { _ in
                    NSLayoutConstraint.deactivate(constraints)
                    toastView.removeFromSuperview()
                }
            )
        }
    }
}

private class UIToastView: UIView {
    
    var message: String? {
        get { labelView.text }
        set { labelView.text = newValue }
    }
    
    override var alpha: CGFloat {
        didSet {
            iconBackgroundView.alpha = alpha
            iconView.alpha = alpha
            labelView.alpha = alpha
        }
    }
    
    private lazy var iconBackgroundView: UIView = {
        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = .primary
        iconBackground.layer.cornerRadius = 15
        return iconBackground
    }()
    
    private lazy var iconView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = .logo
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .black
        return icon
    }()
    
    private lazy var labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .onBackground
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(iconBackgroundView)
        addSubview(iconView)
        addSubview(labelView)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .surface
        layer.cornerRadius = 25
        alpha = 0
        ShadowValues.apply(toButton: layer)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconBackgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceSmall),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 30),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 30),
            iconBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            iconView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            
            labelView.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: Dimens.distanceSmall),
            labelView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceSmall),
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
