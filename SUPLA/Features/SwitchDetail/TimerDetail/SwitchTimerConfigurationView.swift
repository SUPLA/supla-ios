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
import RxCocoa
import RxRelay

final class SwitchTimerConfigurationView: UIView {
    
    private let timeFormat = "%02d:%02d:%02d"
    
    var header: String? = nil {
        didSet { headerView.text = header }
    }
    
    var enabled: Bool = true {
        didSet {
            startButton.isEnabled = enabled
        }
    }
    
    var editMode: Bool = false {
        didSet {
            updateInfoText()
        }
    }
    
    var action: TimerTargetAction {
        get {
            if (actionSwitch.selectedSegmentIndex == 0) {
                return .turnOn
            } else {
                return .turnOff
            }
        }
        set {
            actionSwitch.selectedSegmentIndex = newValue.rawValue
        }
    }
    
    var timeInSeconds: Int {
        get { calculateTimeInSeconds() }
        set {
            numberSelectorView.value = TrippleNumberSelectorView.Value(valueForHours: newValue)
            updateInfoText()
        }
    }
    
    var actionObservable: Observable<Int> { actionSwitch.rx.value.asObservable() }
    
    var cancelObservable: Observable<Void> { cancelRelay.asObservable() }
    
    var startObservable: Observable<Void> { startRelay.asObservable() }
    
    var timeObservable: Observable<Int> {
        numberSelectorView.valueObservable
            .map { $0.toHoursInSec() }
            .do(onNext: { _ in self.updateInfoText() })
    }
    
    private lazy var headerView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .subtitle2
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var actionSwitch: UISegmentedControl = {
        let view = UISegmentedControl(items: [Strings.TimerDetail.turnedOn, Strings.TimerDetail.turnedOff])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(updateInfoText), for: .valueChanged)
        view.setTitleTextAttributes([.font: UIFont.body2], for: .normal)
        return view
    }()
    
    private lazy var numberSelectorView: TrippleNumberSelectorView = {
        let view = TrippleNumberSelectorView()
        view.firstColumnCount = 24
        view.secondColumnCount = 60
        view.thirdColumnCount = 60
        view.firstColumnValueFormatter = {
            if ($0 == 1) {
                Strings.TimerDetail.hourPattern.arguments($0)
            } else {
                Strings.TimerDetail.hoursPattern.arguments($0)
            }
        }
        view.secondColumnValueFormatter = { Strings.TimerDetail.minutePattern.arguments($0) }
        view.thirdColumnValueFormatter = { Strings.TimerDetail.secondPattern.arguments($0) }
        return view
    }()
    
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        return view
    }()
    
    private lazy var infoTextView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .body2
        view.textAlignment = .center
        view.numberOfLines = 2
        return view
    }()
    
    private lazy var editCancelButton: UIBorderedButton = {
        let button = UIBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(Strings.TimerDetail.editCancel)
        return button
    }()
    
    private lazy var startButton: UIFilledButton = {
        let button = UIFilledButton()
        button.setAttributedTitle(Strings.TimerDetail.start)
        return button
    }()
    
    private lazy var normalModeConstraints: [NSLayoutConstraint] = {[
        numberSelectorView.topAnchor.constraint(equalTo: actionSwitch.bottomAnchor, constant: Dimens.distanceDefault),
        startButton.topAnchor.constraint(equalTo: infoTextView.bottomAnchor, constant: Dimens.distanceDefault)
    ]}()
    private lazy var editModeConstraints: [NSLayoutConstraint] = {[
        numberSelectorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Dimens.distanceDefault),
        editCancelButton.topAnchor.constraint(equalTo: numberSelectorView.bottomAnchor, constant: Dimens.distanceDefault),
        startButton.topAnchor.constraint(equalTo: editCancelButton.bottomAnchor, constant: Dimens.distanceDefault)
    ]}()
    
    private let cancelRelay = PublishRelay<Void>()
    private let startRelay = PublishRelay<Void>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(headerView)
        addSubview(actionSwitch)
        addSubview(numberSelectorView)
        addSubview(divider)
        addSubview(infoTextView)
        addSubview(editCancelButton)
        addSubview(startButton)
        backgroundColor = .surface

        startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStartTapped)))
        editCancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCancelEditTapped)))
        
        setupLayout()
        updateInfoText()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceDefault),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimens.distanceDefault),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Dimens.distanceDefault),
            
            actionSwitch.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Dimens.distanceDefault),
            actionSwitch.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimens.distanceDefault),
            actionSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Dimens.distanceDefault),
            actionSwitch.heightAnchor.constraint(equalToConstant: 44),
            
            numberSelectorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            divider.topAnchor.constraint(equalTo: numberSelectorView.bottomAnchor, constant: Dimens.distanceDefault),
            divider.leftAnchor.constraint(equalTo: leftAnchor),
            divider.rightAnchor.constraint(equalTo: rightAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            infoTextView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: Dimens.distanceDefault),
            infoTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimens.distanceDefault),
            infoTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Dimens.distanceDefault),
            
            editCancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            editCancelButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            
            startButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            startButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Dimens.distanceDefault)
        ])
    }
    
    @objc
    private func updateInfoText() {
        if (editMode) {
            NSLayoutConstraint.deactivate(normalModeConstraints)
            NSLayoutConstraint.activate(editModeConstraints)
        } else {
            NSLayoutConstraint.activate(normalModeConstraints)
            NSLayoutConstraint.deactivate(editModeConstraints)
        }
        infoTextView.isHidden = editMode
        actionSwitch.isHidden = editMode
        divider.isHidden = editMode
        editCancelButton.isHidden = !editMode
        
        startButton.setAttributedTitle(editMode ? Strings.TimerDetail.save : Strings.TimerDetail.start)
        
        if (actionSwitch.selectedSegmentIndex == 0) {
            infoTextView.text = Strings.TimerDetail.info.arguments(
                Strings.TimerDetail.infoOn,
                timeString(),
                Strings.TimerDetail.infoNextOff
            )
        } else if (actionSwitch.selectedSegmentIndex == 1) {
            infoTextView.text = Strings.TimerDetail.info.arguments(
                Strings.TimerDetail.infoOff,
                timeString(),
                Strings.TimerDetail.infoNextOn
            )
        }
        
        needsUpdateConstraints()
    }
    
    private func calculateTimeInSeconds() -> Int {
        return numberSelectorView.value.toHoursInSec()
    }
    
    private func timeString() -> String {
        String.init(
            format: timeFormat,
            numberSelectorView.value.firstValue,
            numberSelectorView.value.secondValue,
            numberSelectorView.value.thirdValue
        )
    }
    
    @objc
    private func onStartTapped() {
        startRelay.accept(())
    }
    
    @objc
    private func onCancelEditTapped() {
        cancelRelay.accept(())
    }
}

enum TimerTargetAction: Int {
    case turnOn = 0
    case turnOff = 1
}

extension TimerTargetAction {
    static func from(value: Int) -> TimerTargetAction {
        switch(value) {
        case 0: return .turnOn
        case 1: return .turnOff
        default: fatalError("Invalid value '\(value)' for target action")
        }
    }
}
