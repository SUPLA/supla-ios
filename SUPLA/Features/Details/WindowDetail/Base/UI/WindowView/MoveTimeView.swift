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

class MoveTimeView: UIView {
    var value: String? {
        get { label.text }
        set {
            label.text = newValue
            setNeedsLayout() // because label width will change
        }
    }
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .iconTouchHand?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .black
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        return label
    }()
    
    private let textLocation: TextLocation
    
    init(textLocation: TextLocation = .bottom) {
        self.textLocation = textLocation
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconView)
        addSubview(label)
        
        setupLayout()
    }
    
    private func setupLayout() {
        switch (textLocation) {
        case .bottom:
            NSLayoutConstraint.activate([
                iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
                iconView.topAnchor.constraint(equalTo: topAnchor),
                
                label.topAnchor.constraint(equalTo: iconView.bottomAnchor),
                label.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        case .right:
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: topAnchor),
                iconView.leftAnchor.constraint(equalTo: leftAnchor),
                iconView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.leftAnchor.constraint(equalTo: iconView.rightAnchor),
                label.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    enum TextLocation {
        case bottom, right
    }
}
