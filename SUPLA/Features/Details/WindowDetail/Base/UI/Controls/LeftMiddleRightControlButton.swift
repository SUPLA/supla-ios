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

import RxCocoa
import RxRelay
import RxSwift


// MARK: - Button self

class LeftMiddleRightControlButton: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: ControlButtonType.left.width * 2, height: ControlButtonType.left.height)
    }
    
    var isEnabled: Bool = true {
        didSet {
            leftButton.isEnabled = isEnabled
            rightButton.isEnabled = isEnabled
        }
    }
    
    var leftIcon: UIImage? {
        get { leftButton.icon }
        set { leftButton.icon = newValue }
    }
    
    var middleIcon: UIImage? {
        get { middleButton.icon }
        set { middleButton.icon = newValue }
    }
    
    var rightIcon: UIImage? {
        get { rightButton.icon }
        set { rightButton.icon = newValue }
    }
    
    fileprivate lazy var leftButton: WindowControlButton = .init(buttonType: .left)
    fileprivate lazy var middleButton: WindowControlButton = .init(buttonType: .middle)
    fileprivate lazy var rightButton: WindowControlButton = .init(buttonType: .right)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(leftButton)
        addSubview(middleButton)
        addSubview(rightButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            middleButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            middleButton.topAnchor.constraint(equalTo: topAnchor),
            middleButton.widthAnchor.constraint(equalToConstant: ControlButtonType.middle.width),
            
            leftButton.leftAnchor.constraint(equalTo: leftAnchor),
            leftButton.topAnchor.constraint(equalTo: topAnchor),
            leftButton.rightAnchor.constraint(equalTo: middleButton.leftAnchor),
            
            rightButton.leftAnchor.constraint(equalTo: middleButton.rightAnchor),
            rightButton.rightAnchor.constraint(equalTo: rightAnchor),
            rightButton.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension Reactive where Base: LeftMiddleRightControlButton {
    var tap: Observable<ControlButtonType> {
        Observable.merge(
            base.leftButton.rx.tap.map { .up },
            base.rightButton.rx.tap.map { .down },
            base.middleButton.rx.tap.map { .middle }
        )
    }

    var touchDown: Observable<ControlButtonType> {
        Observable.merge(
            base.leftButton.rx.touchDown.map { .up },
            base.rightButton.rx.touchDown.map { .down },
            base.middleButton.rx.tap.map { .middle }
        )
    }

    var touchUp: Observable<ControlButtonType> {
        Observable.merge(
            base.leftButton.rx.touchUp.map { .up },
            base.rightButton.rx.touchUp.map { .down },
            base.middleButton.rx.tap.map { .middle }
        )
    }
}


