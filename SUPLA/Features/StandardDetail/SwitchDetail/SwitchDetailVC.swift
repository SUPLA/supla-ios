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

class SwitchDetailVC : BaseViewControllerVM<SwitchDetailViewState, SwitchDetailViewEvent, SwitchDetailVM>, DeviceStateHelperVCI {
    
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    
    private let remoteId: Int32
    
    private lazy var deviceStateView: DeviceStateView = {
        let view = DeviceStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var powerOnButtonView: PowerButtonView = {
        let view = PowerButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.type = .positive
        view.text = Strings.General.turnOn
        return view
    }()
    
    private lazy var powerOffButtonView: PowerButtonView = {
        let view = PowerButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.type = .negative
        view.text = Strings.General.turnOff
        return view
    }()
    
    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(nibName: nil, bundle: nil)
        viewModel = SwitchDetailVM()
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
    
    override func handle(event: SwitchDetailViewEvent) {
    }
    
    override func handle(state: SwitchDetailViewState) {
        if let iconData = state.deviceState?.iconData {
            powerOnButtonView.icon = getChannelBaseIconUseCase.invoke(
                function: iconData.function,
                userIcon: iconData.userIcon,
                channelState: .on,
                altIcon: iconData.altIcon
            )
            powerOffButtonView.icon = getChannelBaseIconUseCase.invoke(
                function: iconData.function,
                userIcon: iconData.userIcon,
                channelState: .off,
                altIcon: iconData.altIcon
            )
        }
        
        powerOnButtonView.disabled = state.deviceState?.isOnline != true
        powerOffButtonView.disabled = state.deviceState?.isOnline != true

        if let deviceState = state.deviceState {
            updateDeviceStateView(deviceStateView, with: deviceState)
        }
    }
    
    private func setupView() {
        view.addSubview(deviceStateView)
        view.addSubview(powerOnButtonView)
        view.addSubview(powerOffButtonView)
        
        viewModel.bind(powerOnButtonView.tap.asObservable()) {
            self.viewModel.turnOn(remoteId: self.remoteId)
        }
        viewModel.bind(powerOffButtonView.tap.asObservable()) {
            self.viewModel.turnOff(remoteId: self.remoteId)
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            deviceStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceStateView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            
            powerOnButtonView.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 12),
            powerOnButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            powerOnButtonView.widthAnchor.constraint(equalToConstant: PowerButtonView.SIZE),
            powerOnButtonView.heightAnchor.constraint(equalToConstant: PowerButtonView.SIZE),
            
            powerOffButtonView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -12),
            powerOffButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            powerOffButtonView.widthAnchor.constraint(equalToConstant: PowerButtonView.SIZE),
            powerOffButtonView.heightAnchor.constraint(equalToConstant: PowerButtonView.SIZE)
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

extension ControlEvent {
    func hide() -> Observable<Void> {
        return self.map { _ in () }
    }
}
