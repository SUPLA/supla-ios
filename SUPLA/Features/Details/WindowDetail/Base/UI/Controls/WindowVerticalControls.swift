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

class WindowVerticalControls: WindowControls {
    override var intrinsicContentSize: CGSize {
        let width = ControlButtonType.up.width * 3 + Dimens.distanceDefault * 2
        return CGSize(width: width, height: ControlButtonType.up.height * 2)
    }
    
    override var isEnabled: Bool {
        get { leftControlButton.isEnabled && rightControlButton.isEnabled && stopControlButton.isEnabled }
        set {
            leftControlButton.isEnabled = newValue
            rightControlButton.isEnabled = newValue
            stopControlButton.isEnabled = newValue
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
            leftControlButton.rx.touchDown.map { $0.holdAction },
            leftControlButton.rx.touchUp.map { _ in .stop },
            rightControlButton.rx.tap.map { $0.pressAction },
            stopControlButton.tapObservable.map { _ in .stop }
        )
    }
    
    fileprivate lazy var leftControlButton: UpDownControlButton = {
        let button = UpDownControlButton()
        button.upIcon = .iconArrowUp
        button.downIcon = .iconArrowDown
        return button
    }()
    
    fileprivate lazy var rightControlButton: UpDownControlButton = {
        let button = UpDownControlButton()
        button.upIcon = .iconArrowOpen
        button.downIcon = .iconArrowClose
        return button
    }()
    
    fileprivate lazy var stopControlButton: CircleControlButtonView = {
        let button = CircleControlButtonView(size: ControlButtonType.up.width)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .suplaIcon(icon: .iconStop)
        return button
    }()
    
    private lazy var moveTimeView: MoveTimeView = {
        let view = MoveTimeView()
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
        
        addSubview(leftControlButton)
        addSubview(rightControlButton)
        addSubview(stopControlButton)
        addSubview(moveTimeView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            leftControlButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftControlButton.rightAnchor.constraint(equalTo: centerXAnchor, constant: -56),
            
            rightControlButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightControlButton.leftAnchor.constraint(equalTo: centerXAnchor, constant: 56),
            
            stopControlButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            stopControlButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            moveTimeView.topAnchor.constraint(equalTo: topAnchor),
            moveTimeView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

