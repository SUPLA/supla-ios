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

class UpDownControlButton: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: ControlButtonType.up.width, height: ControlButtonType.up.height * 2)
    }
    
    var isEnabled: Bool = true {
        didSet {
            upButton.isEnabled = isEnabled
            downButton.isEnabled = isEnabled
        }
    }
    
    var upIcon: UIImage? {
        get { upButton.icon }
        set { upButton.icon = newValue }
    }
    
    var downIcon: UIImage? {
        get { downButton.icon }
        set { downButton.icon = newValue }
    }
    
    fileprivate lazy var upButton: WindowControlButton = .init(buttonType: .up)
    fileprivate lazy var downButton: WindowControlButton = .init(buttonType: .down)
    
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
        
        addSubview(upButton)
        addSubview(downButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            upButton.leftAnchor.constraint(equalTo: leftAnchor),
            upButton.topAnchor.constraint(equalTo: topAnchor),
            
            downButton.leftAnchor.constraint(equalTo: leftAnchor),
            downButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension Reactive where Base: UpDownControlButton {
    var tap: Observable<ControlButtonType> {
        Observable.merge(
            base.upButton.rx.tap.map { .up },
            base.downButton.rx.tap.map { .down }
        )
    }

    var touchDown: Observable<ControlButtonType> {
        Observable.merge(
            base.upButton.rx.touchDown.map { .up },
            base.downButton.rx.touchDown.map { .down }
        )
    }

    var touchUp: Observable<ControlButtonType> {
        Observable.merge(
            base.upButton.rx.touchUp.map { .up },
            base.downButton.rx.touchUp.map { .down }
        )
    }
}

