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

class ThermostatTimerDetailVC: BaseViewControllerVM<ThermostatTimerDetailViewState, ThermostatTimerDetailViewEvent, ThermostatTimerDetailVM> {
    
    private let remoteId: Int32
    private var timer: Timer? = nil
    
    private lazy var deviceStateView: DeviceStateView = {
        DeviceStateView(iconSize: 16)
    }()
    
    private lazy var timerProgressGuide: UILayoutGuide = {
        let guide = UILayoutGuide()
        guide.identifier = "timerProgressGuide"
        return guide
    }()
    
    private lazy var timerProgressView: TimerProgressView = {
        let view = TimerProgressView()
        view.indeterminate = true
        return view
    }()
    
    private lazy var progressTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .thermostatTimerTime
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var editButton: UIPlainButton = {
        let button = UIPlainButton()
        button.setAttributedTitle(Strings.TimerDetail.editTime)
        button.titleLabel?.font = .body2
        button.icon = .pencil
        button.textColor = .onBackground
        return button
    }()
    
    private lazy var cancelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.text = Strings.TimerDetail.cancelThermostat
        return label
    }()
    
    private lazy var manualButtonView: RoundedControlButtonView = {
        let view = RoundedControlButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = Strings.ThermostatDetail.modeManual
        return view
    }()
    
    private lazy var programButtonView: RoundedControlButtonView = {
        let view = RoundedControlButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = Strings.ThermostatDetail.modeWeeklySchedule
        return view
    }()
    
    private lazy var configurationView: ThermostatTimerConfigurationView = {
        let view = ThermostatTimerConfigurationView()
        return view
    }()
    
    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(nibName: nil, bundle: nil)
        viewModel = ThermostatTimerDetailVM()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBackgroundView.isHidden = true
        view.backgroundColor = .background
        
        viewModel.observeData(remoteId: remoteId)
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadData(remoteId: remoteId)
        
        observeNotification(
            name: NSNotification.Name.saChannelValueChanged,
            selector: #selector(handleChannelValueChange)
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    override func handle(event: ThermostatTimerDetailViewEvent) {
    }
    
    override func handle(state: ThermostatTimerDetailViewState) {
        timer?.invalidate()
        timer = nil
        
        configurationView.isHidden = state.isTimerOn && !state.editTime
        configurationView.mode = state.selectedMode
        configurationView.showCalendar = state.showCalendar
        configurationView.minTemperature = state.minTemperature
        configurationView.maxTemperature = state.maxTemperature
        configurationView.setCurrentTemperature(state.currentTemperature ?? 0, text: state.currentTemperatureText)
        configurationView.numberPickerValue = state.pickerValue
        configurationView.setInfoText(state.timerInfoText)
        configurationView.setCalendarDates(state.minDate, state.maxDate)
        configurationView.setCalendarValue(state.calendarValue)
        configurationView.startEnabled = state.startEnabled
        configurationView.setpointType = state.setpointType
        configurationView.editMode = state.editTime
        
        deviceStateView.label = state.endDateText
        deviceStateView.icon = state.currentStateIcon
        deviceStateView.iconTint = state.currentStateIconColor
        deviceStateView.value = state.currentStateValue
        
        if let timerEndDate = state.timerEndDate {
            timer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(handleTimerUpdate(timer:)),
                userInfo: timerEndDate,
                repeats: true
            )
        }
    }
    
    private func setupView() {
        view.addSubview(deviceStateView)
        view.addSubview(timerProgressView)
        view.addSubview(progressTimeLabel)
        view.addSubview(editButton)
        view.addSubview(manualButtonView)
        view.addSubview(programButtonView)
        view.addSubview(cancelLabel)
        view.addLayoutGuide(timerProgressGuide)
        view.addSubview(configurationView)
        
        viewModel.bind(configurationView.modeObservable) { [weak self] in
            self?.viewModel.toggleDeviceMode(deviceMode: $0)
        }
        viewModel.bind(configurationView.selectionModeButtonObservable) { [weak self] in
            self?.viewModel.toggleSelectorMode()
        }
        viewModel.bind(configurationView.calendarDateObservable) { [weak self] in
            self?.viewModel.onDateChanged(date: $0)
        }
        viewModel.bind(configurationView.numberPickerObservable) { [weak self] in
            self?.viewModel.onTimerValueChanged(value: $0)
        }
        viewModel.bind(configurationView.temperatureObservable) { [weak self] in
            self?.viewModel.onTemperatureChange(temperature: $0)
        }
        viewModel.bind(configurationView.startTaps) { [weak self] in
            self?.viewModel.onStartTimer()
        }
        viewModel.bind(configurationView.cancelTaps) { [weak self] in
            self?.viewModel.editTimerCancel()
        }
        viewModel.bind(manualButtonView.tapObservable) { [weak self] in
            self?.viewModel.cancelTimerStartManual()
        }
        viewModel.bind(programButtonView.tapObservable) { [weak self] in
            self?.viewModel.cancelTimerStartProgram()
        }
        viewModel.bind(editButton.rx.tap) { [weak self] in self?.viewModel.editTimer() }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            deviceStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceStateView.topAnchor.constraint(equalTo: view.topAnchor, constant: Dimens.distanceDefault),
            
            manualButtonView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            manualButtonView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            manualButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Dimens.distanceDefault),
            
            programButtonView.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
            programButtonView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            programButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Dimens.distanceDefault),
            
            cancelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelLabel.bottomAnchor.constraint(equalTo: manualButtonView.topAnchor, constant: -Dimens.distanceSmall),
            
            timerProgressGuide.topAnchor.constraint(equalTo: deviceStateView.bottomAnchor),
            timerProgressGuide.bottomAnchor.constraint(equalTo: cancelLabel.topAnchor),
            
            timerProgressView.centerYAnchor.constraint(equalTo: timerProgressGuide.centerYAnchor),
            timerProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            progressTimeLabel.centerXAnchor.constraint(equalTo: timerProgressView.centerXAnchor),
            progressTimeLabel.centerYAnchor.constraint(equalTo: timerProgressView.centerYAnchor),
            
            editButton.topAnchor.constraint(equalTo: timerProgressView.bottomAnchor, constant: Dimens.distanceDefault),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            configurationView.leftAnchor.constraint(equalTo: view.leftAnchor),
            configurationView.topAnchor.constraint(equalTo: view.topAnchor),
            configurationView.rightAnchor.constraint(equalTo: view.rightAnchor),
            configurationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    private func handleChannelValueChange(notification: Notification) {
        if
            let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
            let remoteId = notification.userInfo?["remoteId"] as? NSNumber {
            if (!isGroup.boolValue && remoteId.int32Value == self.remoteId) {
                viewModel.loadData(remoteId: self.remoteId)
            }
        }
    }
    
    @objc
    private func handleTimerUpdate(timer: Timer) {
        if let date = timer.userInfo as? Date {
            handleTimerUpdate(timerEndDate: date)
        } else {
            self.timer?.invalidate()
            self.timer = nil
            progressTimeLabel.text = ""
        }
    }
    
    private func handleTimerUpdate(timerEndDate: Date) {
        let currentDate = Date()
        
        if (currentDate.timeIntervalSince1970 > timerEndDate.timeIntervalSince1970) {
            timer?.invalidate()
            timer = nil
            return
        }
        
        let leftTime = timerEndDate.differenceInSeconds(currentDate)
        
        @Singleton<ValuesFormatter> var formatter
        let timeString = formatter.getTimeString(
            hour: leftTime.hoursInDay,
            minute: leftTime.minutesInHour,
            second: leftTime.secondsInMinute
        )
        
        let days = leftTime.days
        if (days == 0) {
            progressTimeLabel.text = timeString
        } else if (days == 1) {
            let daysString = Strings.TimerDetail.dayPattern.arguments(days)
            progressTimeLabel.text = "\(daysString)\n\(timeString)"
        } else {
            let daysString = Strings.TimerDetail.daysPattern.arguments(days)
            progressTimeLabel.text = "\(daysString)\n\(timeString)"
        }
    }
}
