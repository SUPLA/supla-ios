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

class SwitchGeneralVC : BaseViewControllerVM<SwitchGeneralViewState, SwitchGeneralViewEvent, SwitchGeneralVM>, DeviceStateHelperVCI {
    
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    
    private let remoteId: Int32
    
    private lazy var deviceStateView: DeviceStateView = {
        return DeviceStateView()
    }()
    
    private lazy var powerOnButtonView: CircleControlButtonView = {
        let view = CircleControlButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.type = .positive
        view.text = Strings.General.on
        return view
    }()
    
    private lazy var powerOffButtonView: CircleControlButtonView = {
        let view = CircleControlButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.type = .negative
        view.text = Strings.General.off
        return view
    }()
    
    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(nibName: nil, bundle: nil)
        viewModel = SwitchGeneralVM()
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
    
    override func handle(event: SwitchGeneralViewEvent) {
    }
    
    override func handle(state: SwitchGeneralViewState) {
        if let iconData = state.deviceState?.iconData {
            powerOnButtonView.icon = getChannelBaseIconUseCase.invoke(
                iconData: iconData.changing(path: \.state, to: .on)
            )
            powerOffButtonView.icon = getChannelBaseIconUseCase.invoke(
                iconData: iconData.changing(path: \.state, to: .off)
            )
        }
        
        powerOnButtonView.isEnabled = state.deviceState?.isOnline == true
        powerOffButtonView.isEnabled = state.deviceState?.isOnline == true
        
        if let deviceState = state.deviceState {
            updateDeviceStateView(deviceStateView, with: deviceState)
        }
    }
    
    private func setupView() {
        view.addSubview(deviceStateView)
        view.addSubview(powerOnButtonView)
        view.addSubview(powerOffButtonView)
        
        viewModel.bind(powerOnButtonView.tapObservable) { [weak self] in
            guard let self = self else { return }
            self.viewModel.turnOn(remoteId: self.remoteId)
        }
        viewModel.bind(powerOffButtonView.tapObservable) { [weak self] in
            guard let self = self else { return }
            self.viewModel.turnOff(remoteId: self.remoteId)
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            deviceStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceStateView.topAnchor.constraint(equalTo: view.topAnchor, constant: Dimens.distanceDefault),
            
            powerOnButtonView.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 12),
            powerOnButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Dimens.distanceDefault),
            powerOnButtonView.widthAnchor.constraint(equalToConstant: CircleControlButtonView.SIZE),
            powerOnButtonView.heightAnchor.constraint(equalToConstant: CircleControlButtonView.SIZE),
            
            powerOffButtonView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -12),
            powerOffButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Dimens.distanceDefault),
            powerOffButtonView.widthAnchor.constraint(equalToConstant: CircleControlButtonView.SIZE),
            powerOffButtonView.heightAnchor.constraint(equalToConstant: CircleControlButtonView.SIZE)
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

