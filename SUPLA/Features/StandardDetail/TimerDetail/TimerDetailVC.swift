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

class TimerDetailVC: BaseViewControllerVM<TimerDetailViewState, TimerDetailViewEvent, TimerDetailVM>, DeviceStateHelperVCI {
    
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<RuntimeConfig> private var runtimeConfig
    
    private let remoteId: Int32
    private var timer: Timer? = nil
    private let current = Date()
    
    private lazy var deviceStateView: DeviceStateView = {
        let view = DeviceStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timerProgressGuide: UILayoutGuide = {
        let guide = UILayoutGuide()
        guide.identifier = "timerProgressGuide"
        return guide
    }()
    
    private lazy var timerProgressView: TimerProgressView = {
        let view = TimerProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .h5
        return label
    }()
    
    private lazy var progressEndHourLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body1
        return label
    }()
    
    private lazy var timerConfigurationView: TimerConfigurationView = {
        let view = TimerConfigurationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.timeInSeconds = runtimeConfig.getLastTimerValue(remoteId: remoteId)
        return view
    }()
    
    private lazy var editButton: UIPlainButton = {
        let button = UIPlainButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(Strings.TimerDetail.editTime)
        button.icon = .pencil
        return button
    }()
    
    private lazy var stopButton: UIBorderedButton = {
        let button = UIBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIFilledButton = {
        let button = UIFilledButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(nibName: nil, bundle: nil)
        viewModel = TimerDetailVM()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBackgroundView.isHidden = true
        view.backgroundColor = .background
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadChannel(remoteId: remoteId)
        
        observeNotification(
            name: NSNotification.Name.saChannelValueChanged,
            selector: #selector(handleChannelValueChange)
        )
    }
    
    override func handle(event: TimerDetailViewEvent) {
        switch(event) {
        case .showInvalidTime:
            let alert = UIAlertController(
                title: Strings.TimerDetail.wrongTimeTitle,
                message: Strings.TimerDetail.wrongTimeMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: Strings.General.ok, style: .default))
            self.present(alert, animated: true)
        }
    }
    
    override func handle(state: TimerDetailViewState) {
        timer?.invalidate()
        timerProgressView.progressPercentage = 0
        
        if let deviceState = state.deviceState {
            updateDeviceStateView(deviceStateView, with: deviceState)
        }
        
        timerConfigurationView.header = Strings.TimerDetail.header // Must be before edit mode
        if (state.editMode) {
            let headerArgument = state.deviceState?.isOn ?? false ?
                Strings.TimerDetail.editHeaderOn : Strings.TimerDetail.editHeaderOff
            timerConfigurationView.header = Strings.TimerDetail.editHeader.arguments(headerArgument)
            
            if let timerEndDate = state.deviceState?.timerEndDate {
                timerConfigurationView.timeInSeconds = Int(timerEndDate.timeIntervalSince(Date()))
            }
        }
        if let timerEndDate = state.deviceState?.timerEndDate {
            let timerData = TimerData(
                timerStartDate: state.deviceState?.timerStartDate,
                timerEndDate: timerEndDate
            )
            timer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(handleTimerUpdate(timer:)),
                userInfo: timerData,
                repeats: true
            )
            handleTimerUpdate(timerData: timerData)
        }
        
        if let isOn = state.deviceState?.isOn {
            let stopArgument = isOn ? Strings.TimerDetail.infoOn : Strings.TimerDetail.infoOff
            stopButton.setAttributedTitle(Strings.TimerDetail.stop.arguments(stopArgument))
            
            let cancelArgument = isOn ? Strings.TimerDetail.cancelOff : Strings.TimerDetail.cancelOn
            cancelButton.setAttributedTitle(Strings.TimerDetail.cancel.arguments(cancelArgument))
        }
        
        timerConfigurationView.editMode = state.editMode
        timerConfigurationView.enabled = state.deviceState?.isOnline ?? false == true
        timerConfigurationView.isHidden = !state.editMode && state.deviceState?.timerEndDate != nil
        timerProgressView.isHidden = state.deviceState?.timerEndDate == nil
        progressTimeLabel.isHidden = state.deviceState?.timerEndDate == nil
        progressEndHourLabel.isHidden = state.deviceState?.timerEndDate == nil
    }
    
    private func setupView() {
        view.addSubview(deviceStateView)
        view.addSubview(progressTimeLabel)
        view.addSubview(progressEndHourLabel)
        view.addSubview(timerProgressView)
        view.addSubview(editButton)
        view.addSubview(stopButton)
        view.addSubview(cancelButton)
        view.addSubview(timerConfigurationView)
        view.addLayoutGuide(timerProgressGuide)
        
        viewModel.bind(stopButton.rx.tap.asObservable()) {
            self.viewModel.stopTimer(remoteId: self.remoteId)
            
        }
        viewModel.bind(cancelButton.rx.tap.asObservable()) {
            self.viewModel.cancelTimer(remoteId: self.remoteId)
        }
        viewModel.bind(editButton.rx.tap.asObservable()) {
            self.viewModel.startEditMode()
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            deviceStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceStateView.topAnchor.constraint(equalTo: view.topAnchor, constant: Dimens.distanceDefault),
            
            progressTimeLabel.bottomAnchor.constraint(equalTo: timerProgressView.centerYAnchor, constant: -4),
            progressTimeLabel.centerXAnchor.constraint(equalTo: timerProgressView.centerXAnchor),
            
            progressEndHourLabel.topAnchor.constraint(equalTo: timerProgressView.centerYAnchor, constant: 4),
            progressEndHourLabel.centerXAnchor.constraint(equalTo: timerProgressView.centerXAnchor),
            
            timerProgressGuide.topAnchor.constraint(equalTo: deviceStateView.bottomAnchor),
            timerProgressGuide.bottomAnchor.constraint(equalTo: editButton.topAnchor),
            
            timerProgressView.centerYAnchor.constraint(equalTo: timerProgressGuide.centerYAnchor),
            timerProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerConfigurationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timerConfigurationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timerConfigurationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.bottomAnchor.constraint(equalTo: stopButton.topAnchor, constant: -Dimens.distanceDefault),
            
            stopButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            stopButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            stopButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -Dimens.distanceDefault),
            
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Dimens.distanceDefault)
        ])
    }
    
    @objc
    private func handleChannelValueChange(notification: Notification) {
        if
            let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
            let remoteId = notification.userInfo?["remoteId"] as? NSNumber {
            if (!isGroup.boolValue && remoteId.int32Value == self.remoteId) {
                viewModel.loadChannel(remoteId: self.remoteId)
            }
        }
    }
    
    @objc
    private func handleTimerUpdate(timer: Timer) {
        if let timerData = timer.userInfo as? TimerData {
            handleTimerUpdate(timerData: timerData)
        } else {
            timer.invalidate()
            progressTimeLabel.text = ""
            progressEndHourLabel.text = ""
        }
    }
    
    private func handleTimerUpdate(timerData: TimerData) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Strings.General.hourFormat
        let dateString = dateFormatter.string(from: timerData.timerEndDate)
        progressEndHourLabel.text = Strings.TimerDetail.endHour.arguments(dateString)
        
        let data = viewModel.calculateProgressViewData(
            startTime: timerData.timerStartDate ?? current,
            endTime: timerData.timerEndDate
        )
        timerProgressView.progressPercentage = data.progres
        progressTimeLabel.text = Strings.TimerDetail.format.arguments(
            data.leftTimeValues.hours,
            data.leftTimeValues.minutes,
            data.leftTimeValues.seconds
        )
    }
    
    struct TimerData {
        let timerStartDate: Date?
        let timerEndDate: Date
    }
}

extension TimerDetailVC: TimerConfigurationViewDelegate {
    func onStartTapped() {
        viewModel.startTimer(
            remoteId: remoteId,
            action: timerConfigurationView.action,
            durationInSecs: timerConfigurationView.timeInSeconds
        )
    }
    
    func onCancelEditTapped() {
        viewModel.stopEditMode()
    }
    
    func onTimeChanged() {
        runtimeConfig.setLastTimerValue(remoteId: remoteId, value: timerConfigurationView.timeInSeconds)
    }
}
