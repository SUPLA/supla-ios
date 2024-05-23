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

class WindowHorizontalControls: WindowControls {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: ControlButtonType.left.width * 2, height: ControlButtonType.up.height * 2)
    }
    
    override var isEnabled: Bool {
        get { holdToMoveButton.isEnabled }
        set {
            holdToMoveButton.isEnabled = newValue
        }
    }
    
    override var moveTime: CGFloat? {
        get { nil }
        set {
            moveTimeView.isHidden = newValue == nil
            if let touchTime = newValue {
                moveTimeView.value = String(format: "%.1fs", touchTime)
            }
        }
    }
    
    override var action: Observable<RollerShutterAction> {
        Observable.merge(
            holdToMoveButton.rx.touchDown.map { $0.holdAction },
            holdToMoveButton.rx.touchUp.map { _ in .stop },
            pressToMoveButton.rx.tap.map { $0.pressAction }
        )
    }
    
    fileprivate lazy var holdToMoveButton: LeftRightControlButton = {
        let button = LeftRightControlButton()
        button.leftIcon = .iconArrowRevealHold
        button.rightIcon = .iconArrowCoverHold
        return button
    }()
    
    fileprivate lazy var pressToMoveButton: LeftMiddleRightControlButton = {
        let button = LeftMiddleRightControlButton()
        button.leftIcon = .iconArrowRevealTap
        button.middleIcon = .iconStop
        button.rightIcon = .iconArrowCoverTap
        return button
    }()
    
    private lazy var moveTimeView: MoveTimeView = {
        let view = MoveTimeView(textLocation: .right)
        return view
    }()
    
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
        
        addSubview(holdToMoveButton)
        addSubview(pressToMoveButton)
        addSubview(moveTimeView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            holdToMoveButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            holdToMoveButton.leftAnchor.constraint(equalTo: leftAnchor),
            holdToMoveButton.rightAnchor.constraint(equalTo: rightAnchor),
            
            pressToMoveButton.topAnchor.constraint(equalTo: holdToMoveButton.bottomAnchor, constant: Dimens.distanceSmall),
            pressToMoveButton.leftAnchor.constraint(equalTo: leftAnchor),
            pressToMoveButton.rightAnchor.constraint(equalTo: rightAnchor),
            
            moveTimeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            moveTimeView.bottomAnchor.constraint(equalTo: holdToMoveButton.topAnchor, constant: -Dimens.distanceSmall)
        ])
    }
}
