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

final class TimerConfigurationView: UIView {
    
    private let timeFormat = "%02d:%02d:%02d"
    
    var delegate: TimerConfigurationViewDelegate? = nil
    
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
    }
    
    var timeInSeconds: Int {
        get { calculateTimeInSeconds() }
        set {
            secondPickerView.selectRow((newValue % 60), inComponent: 0, animated: true)
            minutePickerView.selectRow(((newValue / 60) % 60), inComponent: 0, animated: true)
            hourPickerView.selectRow((newValue / 3600), inComponent: 0, animated: true)
            updateInfoText()
        }
    }
    
    private lazy var headerView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .subtitle2
        label.textAlignment = .center
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
    
    private lazy var selectedPickerRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayLight
        view.layer.cornerRadius = Dimens.radiusButton
        return view
    }()
    
    private lazy var hourPickerView: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private lazy var minutePickerView: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private lazy var secondPickerView: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.dataSource = self
        view.delegate = self
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(Strings.TimerDetail.start)
        return button
    }()
    
    private lazy var normalModeConstraints: [NSLayoutConstraint] = {[
        minutePickerView.topAnchor.constraint(equalTo: actionSwitch.bottomAnchor, constant: Dimens.distanceDefault),
        startButton.topAnchor.constraint(equalTo: infoTextView.bottomAnchor, constant: Dimens.distanceDefault)
    ]}()
    private lazy var editModeConstraints: [NSLayoutConstraint] = {[
        minutePickerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Dimens.distanceDefault),
        editCancelButton.topAnchor.constraint(equalTo: minutePickerView.bottomAnchor, constant: Dimens.distanceDefault),
        startButton.topAnchor.constraint(equalTo: editCancelButton.bottomAnchor, constant: Dimens.distanceDefault)
    ]}()
    
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
        addSubview(selectedPickerRowView)
        addSubview(hourPickerView)
        addSubview(minutePickerView)
        addSubview(secondPickerView)
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
            
            selectedPickerRowView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            selectedPickerRowView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            selectedPickerRowView.centerYAnchor.constraint(equalTo: minutePickerView.centerYAnchor),
            selectedPickerRowView.heightAnchor.constraint(equalToConstant: 40),
            
            hourPickerView.topAnchor.constraint(equalTo: minutePickerView.topAnchor),
            hourPickerView.trailingAnchor.constraint(equalTo: minutePickerView.leadingAnchor, constant: 8),
            hourPickerView.widthAnchor.constraint(equalToConstant: 130),
            hourPickerView.heightAnchor.constraint(equalToConstant: 160),
            
            minutePickerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            minutePickerView.widthAnchor.constraint(equalToConstant: 130),
            minutePickerView.heightAnchor.constraint(equalToConstant: 160),
            
            secondPickerView.topAnchor.constraint(equalTo: minutePickerView.topAnchor),
            secondPickerView.leadingAnchor.constraint(equalTo: minutePickerView.trailingAnchor, constant: -8),
            secondPickerView.widthAnchor.constraint(equalToConstant: 130),
            secondPickerView.heightAnchor.constraint(equalToConstant: 160),
            
            divider.topAnchor.constraint(equalTo: minutePickerView.bottomAnchor, constant: Dimens.distanceDefault),
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
        return secondPickerView.selectedRow(inComponent: 0) +
        minutePickerView.selectedRow(inComponent: 0) * 60 +
        hourPickerView.selectedRow(inComponent: 0) * 3600
    }
    
    private func timeString() -> String {
        String.init(
            format: timeFormat,
            hourPickerView.selectedRow(inComponent: 0),
            minutePickerView.selectedRow(inComponent: 0),
            secondPickerView.selectedRow(inComponent: 0)
        )
    }
    
    @objc
    private func onStartTapped() {
        delegate?.onStartTapped()
    }
    
    @objc
    private func onCancelEditTapped() {
        delegate?.onCancelEditTapped()
    }
}

extension TimerConfigurationView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == hourPickerView) {
            return 23
        } else {
            return 59
        }
    }
}

extension TimerConfigurationView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.subviews[1].backgroundColor = .clear
        
        let label: UILabel
        if (view == nil) {
            label = UILabel()
            label.font = .button
            label.textAlignment = .center
        } else {
            label = view as! UILabel
        }
        
        if (pickerView == hourPickerView) {
            if (row == 1) {
                label.text = Strings.TimerDetail.hourPattern.arguments(row)
            } else {
                label.text = Strings.TimerDetail.hoursPattern.arguments(row)
            }
        } else if (pickerView == minutePickerView) {
            label.text = Strings.TimerDetail.minutePattern.arguments(row)
        } else {
            label.text = Strings.TimerDetail.secondPattern.arguments(row)
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateInfoText()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
}

protocol TimerConfigurationViewDelegate {
    func onStartTapped()
    func onCancelEditTapped()
}

enum TimerTargetAction: Int {
    case turnOn = 0
    case turnOff = 1
}
