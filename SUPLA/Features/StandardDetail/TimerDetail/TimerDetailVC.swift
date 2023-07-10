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
    
    private let remoteId: Int32
    
    private lazy var deviceStateView: DeviceStateView = {
        let view = DeviceStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timerConfigurationView: TimerConfigurationView = {
        let view = TimerConfigurationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
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
    }
    
    override func handle(state: TimerDetailViewState) {
        if let deviceState = state.deviceState {
            updateDeviceStateView(deviceStateView, with: deviceState)
        }
        
        if let timerData = state.deviceState?.timerEndDate {
            timerConfigurationView.isHidden = true
        } else {
            timerConfigurationView.isHidden = false
        }
        
        if let isOn = state.deviceState?.isOn {
            stopButton.setAttributedTitle(
                Strings.TimerDetail.stop.arguments(
                    isOn ? Strings.TimerDetail.infoOn : Strings.TimerDetail.infoOff
                )
            )
            cancelButton.setAttributedTitle(
                Strings.TimerDetail.cancel.arguments(
                    isOn ? Strings.TimerDetail.cancelOff : Strings.TimerDetail.cancelOn
                )
            )
        }
        timerConfigurationView.header = Strings.TimerDetail.header
    }
    
    private func setupView() {
        view.addSubview(deviceStateView)
        view.addSubview(stopButton)
        view.addSubview(cancelButton)
        view.addSubview(timerConfigurationView)
        
        timerConfigurationView.timeInSeconds = 3 * 60
        viewModel.bind(stopButton.rx.tap.asObservable()) {
            self.viewModel.stopTimer(remoteId: self.remoteId)
            
        }
        viewModel.bind(cancelButton.rx.tap.asObservable()) {
            self.viewModel.cancelTimer(remoteId: self.remoteId)
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            deviceStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceStateView.topAnchor.constraint(equalTo: view.topAnchor, constant: Dimens.distanceDefault),
            
            timerConfigurationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timerConfigurationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timerConfigurationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
}

extension TimerDetailVC: TimerConfigurationViewDelegate {
    func onStartTapped() {
        viewModel.startTimer(
            remoteId: remoteId,
            action: timerConfigurationView.action,
            durationInSecs: timerConfigurationView.timeInSeconds
        )
    }
}
