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

final class ThermostatTimerConfigurationView: UIView {
    var mode: TimerDetailDeviceMode = .off {
        didSet {
            switch (mode) {
            case .off:
                modeSwitch.selectedSegmentIndex = 0
                configureTemperatureView.isHidden = true
            case .manual:
                modeSwitch.selectedSegmentIndex = 1
                configureTemperatureView.isHidden = false
            }
        }
    }
    
    var modeObservable: Observable<TimerDetailDeviceMode> {
        modeSwitch.rx.selectedSegmentIndex.map { TimerDetailDeviceMode.from(value: $0) }
    }
    
    var setpointType: SetpointType? {
        get { configureTemperatureView.type }
        set { configureTemperatureView.type = newValue }
    }
    
    var showCalendar: Bool = false {
        didSet {
            numberSelectorView.isHidden = showCalendar
            datePicker.isHidden = !showCalendar
            timeSelectionHeaderView.setCalendarVisible(visible: showCalendar)
        }
    }
    
    var selectionModeButtonObservable: Observable<Void> {
        timeSelectionHeaderView.modeButtonObservable
    }
    
    var calendarDateObservable: Observable<Date> {
        calendarDateRelay.asObservable()
    }
    
    var numberPickerValue: TrippleNumberSelectorView.Value {
        get { numberSelectorView.value }
        set { numberSelectorView.value = newValue }
    }
    
    var numberPickerObservable: Observable<TrippleNumberSelectorView.Value> {
        numberSelectorView.valueObservable
    }
    
    var minTemperature: Float? {
        get { configureTemperatureView.minTemperature }
        set { configureTemperatureView.minTemperature = newValue ?? 0 }
    }
    
    var maxTemperature: Float? {
        get { configureTemperatureView.maxTemperature }
        set { configureTemperatureView.maxTemperature = newValue ?? 1 }
    }
    
    var temperatureObservable: Observable<Float> {
        configureTemperatureView.temperatureObservable
    }
    
    var startTaps: ControlEvent<Void> {
        startButton.rx.tap
    }
    
    var cancelTaps: ControlEvent<Void> {
        cancelButton.rx.tap
    }
    
    var plusTaps: ControlEvent<Void> {
        configureTemperatureView.plusButtonTaps
    }
    
    var minusTaps: ControlEvent<Void> {
        configureTemperatureView.minusButtonTaps
    }
    
    var startEnabled: Bool {
        get { startButton.isEnabled }
        set { startButton.isEnabled = newValue }
    }
    
    var editMode: Bool = false {
        didSet {
            startButton.setAttributedTitle(editMode ? Strings.General.save : Strings.TimerDetail.start)
            cancelButton.isHidden = !editMode
            setupChangeableConstraints()
        }
    }
    
    private lazy var modeLabel: UILabel = {
        let label = label()
        label.text = Strings.TimerDetail.selectMode.uppercased()
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var scrollContainerView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Dimens.distanceDefault
        view.alignment = .fill
        return view
    }()
    
    private lazy var modeSwitch: UISegmentedControl = {
        let view = UISegmentedControl(items: TimerDetailDeviceMode.allOptions())
        view.selectedSegmentIndex = 0
        view.setTitleTextAttributes([.font: UIFont.body2], for: .normal)
        return view
    }()
    
    private lazy var configureTemperatureView: ConfigureTemperatureView = .init()
    
    private lazy var timeSelectionHeaderView: TimeSelectionHeaderView = .init()
    
    private lazy var numberSelectorView: TrippleNumberSelectorView = {
        let view = TrippleNumberSelectorView()
        view.firstColumnCount = 365
        view.secondColumnCount = 24
        view.thirdColumnCount = 60
        view.firstColumnValueFormatter = {
            if ($0 == 1) {
                Strings.TimerDetail.dayPattern.arguments($0)
            } else {
                Strings.TimerDetail.daysPattern.arguments($0)
            }
        }
        view.secondColumnValueFormatter = {
            if ($0 == 1) {
                Strings.TimerDetail.hourPattern.arguments($0)
            } else {
                Strings.TimerDetail.hoursPattern.arguments($0)
            }
        }
        view.thirdColumnValueFormatter = { Strings.TimerDetail.minutePattern.arguments($0) }
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .dateAndTime
        view.tintColor = .primary
        view.preferredDatePickerStyle = .inline
        view.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
        let currentDate = Date()
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .body2
        label.textAlignment = .center
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        return label
    }()
    
    private lazy var separatorView: SeparatorView = {
        let view = SeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIBorderedButton = {
        let button = UIBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(Strings.General.cancel)
        button.isHidden = true
        return button
    }()
    
    private lazy var startButton: UIFilledButton = {
        let button = UIFilledButton()
        button.setAttributedTitle(Strings.TimerDetail.start)
        return button
    }()
    
    private lazy var calendarDateRelay = PublishRelay<Date>()
    private lazy var changeableConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setCurrentTemperature(_ value: Float, text: String) {
        configureTemperatureView.setCurrentTemperature(value, text: text)
    }
    
    func setInfoText(_ text: String) {
        infoLabel.text = text
    }
    
    func setCalendarDates(_ min: Date?, _ max: Date?) {
        datePicker.minimumDate = min
        datePicker.maximumDate = max
    }
    
    func setCalendarValue(_ date: Date?) {
        guard let date = date else { return }
        datePicker.setDate(date, animated: false)
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .surface
        
        addSubview(scrollView)
        scrollView.addSubview(scrollContainerView)
        scrollContainerView.addArrangedSubview(modeLabel)
        scrollContainerView.addArrangedSubview(modeSwitch)
        scrollContainerView.addArrangedSubview(configureTemperatureView)
        scrollContainerView.addArrangedSubview(timeSelectionHeaderView)
        scrollContainerView.addArrangedSubview(numberSelectorView)
        scrollContainerView.addArrangedSubview(datePicker)
        scrollContainerView.addArrangedSubview(infoLabel)
        
        addSubview(separatorView)
        addSubview(cancelButton)
        addSubview(startButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        setupChangeableConstraints()
        
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            scrollContainerView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            scrollContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Dimens.distanceDefault),
            scrollContainerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            scrollContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Dimens.distanceDefault),
            
            startButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            startButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Dimens.distanceSmall),
            
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    @objc
    private func onDateChanged(_ sender: UIDatePicker) {
        calendarDateRelay.accept(sender.date)
    }
    
    private func setupChangeableConstraints() {
        if (!changeableConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(changeableConstraints)
            changeableConstraints.removeAll()
        }
        
        if (editMode) {
            changeableConstraints.append(contentsOf: [
                cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
                cancelButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
                cancelButton.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -Dimens.distanceSmall),
                
                separatorView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -Dimens.distanceSmall)
            ])
        } else {
            changeableConstraints.append(contentsOf: [
                separatorView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -Dimens.distanceSmall)
            ])
        }
        
        NSLayoutConstraint.activate(changeableConstraints)
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension ThermostatTimerConfigurationView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

private class ConfigureTemperatureView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: currentTemperatureLabel.intrinsicContentSize.height + plusButton.intrinsicContentSize.height + Dimens.distanceTiny
        )
    }
    
    var type: SetpointType? = nil {
        didSet {
            plusButton.setColor(activeSetpointType: type)
            minusButton.setColor(activeSetpointType: type)
            
            if let type = type {
                let thumbImage = switch (type) {
                case .cool: UIImage.thumbCool
                case .heat: UIImage.thumbHeat
                }
                temperatureSlider.setThumbImage(thumbImage, for: .normal)
            }
        }
    }
    
    var minTemperature: Float {
        get { temperatureSlider.minimumValue }
        set { temperatureSlider.minimumValue = newValue }
    }
    
    var maxTemperature: Float {
        get { temperatureSlider.maximumValue }
        set { temperatureSlider.maximumValue = newValue }
    }
    
    var temperatureObservable: Observable<Float> {
        temperatureSlider.rx.value.asObservable()
    }
    
    var plusButtonTaps: ControlEvent<Void> {
        plusButton.rx.tap
    }
    
    var minusButtonTaps: ControlEvent<Void> {
        minusButton.rx.tap
    }
    
    private lazy var minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .gray
        label.text = Strings.TimerDetail.minTemp.uppercased()
        return label
    }()
    
    private lazy var maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .gray
        label.text = Strings.TimerDetail.maxTemp.uppercased()
        return label
    }()
    
    private lazy var currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .onBackground
        label.font = .button
        return label
    }()
    
    private lazy var plusButton: UIIconButton = {
        let button = UIIconButton(config: .bordered(color: .disabled))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconPlus
        return button
    }()
    
    private lazy var minusButton: UIIconButton = {
        let button = UIIconButton(config: .bordered(color: .disabled))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconMinus
        return button
    }()
    
    private lazy var temperatureSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .separatorLight
        slider.maximumTrackTintColor = .separatorLight
        slider.setThumbImage(.thumbHeat, for: .normal)
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setCurrentTemperature(_ value: Float, text: String) {
        temperatureSlider.value = value
        currentTemperatureLabel.text = text
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(minTemperatureLabel)
        addSubview(maxTemperatureLabel)
        addSubview(currentTemperatureLabel)
        addSubview(plusButton)
        addSubview(minusButton)
        addSubview(temperatureSlider)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            currentTemperatureLabel.topAnchor.constraint(equalTo: topAnchor),
            currentTemperatureLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            minTemperatureLabel.centerYAnchor.constraint(equalTo: currentTemperatureLabel.centerYAnchor),
            minTemperatureLabel.leftAnchor.constraint(equalTo: leftAnchor),
            
            maxTemperatureLabel.centerYAnchor.constraint(equalTo: currentTemperatureLabel.centerYAnchor),
            maxTemperatureLabel.rightAnchor.constraint(equalTo: rightAnchor),
            
            minusButton.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor, constant: Dimens.distanceTiny),
            minusButton.leftAnchor.constraint(equalTo: leftAnchor),
            
            plusButton.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor, constant: Dimens.distanceTiny),
            plusButton.rightAnchor.constraint(equalTo: rightAnchor),
            
            temperatureSlider.leftAnchor.constraint(equalTo: minusButton.rightAnchor, constant: Dimens.distanceTiny),
            temperatureSlider.rightAnchor.constraint(equalTo: plusButton.leftAnchor, constant: -Dimens.distanceTiny),
            temperatureSlider.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private class TimeSelectionHeaderView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: editInputModeButton.intrinsicContentSize.height
        )
    }
    
    var modeButtonObservable: Observable<Void> {
        editInputModeButton.rx.tap.asObservable()
    }
    
    private lazy var selectTimeLabel: UILabel = {
        let label = label()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.TimerDetail.selectTime.uppercased()
        return label
    }()
    
    private lazy var editInputModeButton: UIPlainButton = {
        let button = UIPlainButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(Strings.TimerDetail.calendar)
        button.titleLabel?.font = .body2
        button.icon = .iconSchedule
        button.textColor = .onBackground
        button.iconPosition = .leading
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setCalendarVisible(visible: Bool) {
        editInputModeButton.icon = visible ? .iconTimer : .iconSchedule
        editInputModeButton.setAttributedTitle(visible ? Strings.TimerDetail.counter : Strings.TimerDetail.calendar)
    }
    
    private func setupView() {
        addSubview(selectTimeLabel)
        addSubview(editInputModeButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            selectTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectTimeLabel.leftAnchor.constraint(equalTo: leftAnchor),
            
            editInputModeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            editInputModeButton.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}

enum TimerDetailDeviceMode: Int, CaseIterable {
    case off = 0
    case manual = 1
    
    var text: String {
        switch (self) {
        case .off: Strings.General.turnOff
        case .manual: Strings.TimerDetail.manualMode
        }
    }
    
    static func allOptions() -> [String] {
        TimerDetailDeviceMode.allCases.map { $0.text }
    }
    
    static func from(value: Int) -> TimerDetailDeviceMode {
        for mode in TimerDetailDeviceMode.allCases {
            if (mode.rawValue == value) {
                return mode
            }
        }
        
        fatalError("TimerDetailDeviceMode: Invalid value: \(value)")
    }
}

private func label() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .body2
    label.textColor = .gray
    return label
}
