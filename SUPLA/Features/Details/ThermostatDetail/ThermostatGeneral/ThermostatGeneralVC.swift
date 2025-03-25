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

import SwiftUI
import RxSwift

class ThermostatGeneralVC: BaseViewControllerVM<ThermostatGeneralViewState, ThermostatGeneralViewEvent, ThermostatGeneralVM> {
    @Singleton<ValuesFormatter> private var formatter
    
    private let item: ItemBundle
    
    private lazy var temperaturesViewController: UIHostingController = {
        let view = UIHostingController(rootView: ThermometerValues(state: viewModel.thermometerValuesState))
        view.view.translatesAutoresizingMaskIntoConstraints = false
        ShadowValues.apply(toLayer: view.view.layer)
        return view
    }()
    
    private lazy var buttonsView: ThermostatGeneralButtons = {
        let view = ThermostatGeneralButtons()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var firstProgramInfoView: ProgramView = {
        let view = ProgramView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var secondProgramInfoView: ProgramView = {
        let view = ProgramView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sensorIssueView: SensorIssueView = {
        let view = SensorIssueView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var deviceStateView: DeviceStateView = .init(iconSize: 16)
    
    private lazy var thermostatControlView: ThermostatControlView = {
        let view = ThermostatControlView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var plusButton: UIIconButton = {
        let button = UIIconButton(config: .bordered(color: .disabled, backgroundColor: .surface))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconPlus
        return button
    }()
    
    private lazy var minusButton: UIIconButton = {
        let button = UIIconButton(config: .bordered(color: .disabled, backgroundColor: .surface))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconMinus
        return button
    }()
    
    // MARK: Pump/Source switches icons
    
    private lazy var pumpSwitchImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var heatOrColdSourceSwitchImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loaderView: LoadingScrimView = .init()
    
    private lazy var firstIssueRowView: IssueView = {
        let view = IssueView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var secondIssueRowView: IssueView = {
        let view = IssueView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(item: ItemBundle) {
        self.item = item
        super.init(viewModel: ThermostatGeneralVM())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.observeData(remoteId: item.remoteId, deviceId: item.deviceId)
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadData(remoteId: item.remoteId, deviceId: item.deviceId)
        
        observeNotification(
            name: NSNotification.Name.saChannelValueChanged,
            selector: #selector(handleValueChange)
        )
    }
    
    override func handle(state: ThermostatGeneralViewState) {
        if (state.activeSetpointType != nil && thermostatControlView.setpointToDrag == nil) {
            // Set it only once at the begining.
            thermostatControlView.setpointToDrag = state.activeSetpointType
        }
        thermostatControlView.minTemperatureText = formatter.temperatureToString(state.configMin, withUnit: false)
        thermostatControlView.maxTemperatureText = formatter.temperatureToString(state.configMax, withUnit: false)
        thermostatControlView.minMaxHidden = state.configMinMaxHidden
        thermostatControlView.setpointText = state.setpointText
        thermostatControlView.setpointHeatPercentage = state.setpointHeatPercentage?.cg
        thermostatControlView.setpointCoolPercentage = state.setpointCoolPercentage?.cg
        thermostatControlView.temperaturePercentage = state.currentTemperaturePercentage?.cg
        thermostatControlView.operationalMode = state.operationalMode
        thermostatControlView.currentPower = state.currentPower
        thermostatControlView.greyOutSetpoins = state.grayOutSetpoints
        pumpSwitchImage.image = state.pumpSwitchIcon?.uiImage
        heatOrColdSourceSwitchImage.image = state.heatOrColdSourceSwitchIcon?.uiImage
        minusButton.isEnabled = state.minusButtonEnabled
        minusButton.isHidden = state.plusMinusHidden
        minusButton.setColor(activeSetpointType: state.activeSetpointType)
        plusButton.isEnabled = state.plusButtonEnabled
        plusButton.isHidden = state.plusMinusHidden
        plusButton.setColor(activeSetpointType: state.activeSetpointType)
        buttonsView.isEnabled = state.controlButtonsEnabled
        buttonsView.manualModeActive = state.manualActive
        buttonsView.weeklyScheduleModeActive = state.weeklyScheduleActive
        buttonsView.powerIconColor = state.powerIconColor
        loaderView.isHidden = !state.loadingState.loading

        firstIssueRowView.isHidden = state.issues.count <= 0
        secondIssueRowView.isHidden = state.issues.count <= 1
        for (idx, issue) in state.issues.enumerated() {
            if (idx == 0) {
                firstIssueRowView.icon = issue.icon.resource
                firstIssueRowView.text = issue.message.string
            }
            if (idx == 1) {
                secondIssueRowView.icon = issue.icon.resource
                secondIssueRowView.text = issue.message.string
            }
        }
        
        deviceStateView.isHidden = state.timerInfoHidden
        deviceStateView.label = state.endDateText
        deviceStateView.icon = state.currentStateIcon
        deviceStateView.iconTint = state.currentStateIconColor
        deviceStateView.value = state.currentStateValue
        
        firstProgramInfoView.isHidden = !state.timerInfoHidden || state.sensorIssue != nil || state.programInfo.isEmpty
        secondProgramInfoView.isHidden = !state.timerInfoHidden || state.sensorIssue != nil || state.programInfo.count < 2
        for (idx, program) in state.programInfo.enumerated() {
            if (idx == 0) {
                firstProgramInfoView.info = program
            }
            if (idx == 1) {
                secondProgramInfoView.info = program
            }
        }
        
        sensorIssueView.isHidden = state.sensorIssue == nil
        sensorIssueView.icon = state.sensorIssue?.sensorIcon?.uiImage
        sensorIssueView.message = state.sensorIssue?.message
    }
    
    private func setupView() {
        viewModel.bind(thermostatControlView.setpointPositionEvents) { [weak self] event in
            self?.viewModel.onPositionEvent(event)
        }
        viewModel.bind(minusButton.rx.tap.asObservable()) { [weak self] _ in
            self?.viewModel.onTemperatureChange(.smallDown)
        }
        viewModel.bind(plusButton.rx.tap.asObservable()) { [weak self] _ in
            self?.viewModel.onTemperatureChange(.smallUp)
        }
        viewModel.bind(buttonsView.powerTapEvents) { [weak self] _ in
            self?.viewModel.onPowerButtonTap()
        }
        viewModel.bind(buttonsView.manualTapEvents) { [weak self] _ in
            self?.viewModel.onManualButtonTap()
        }
        viewModel.bind(buttonsView.weeklyScheduleTapEvents) { [weak self] _ in
            self?.viewModel.onWeeklyScheduleButtonTap()
        }
        
        addChild(temperaturesViewController)
        
        view.addSubview(temperaturesViewController.view)
        view.addSubview(buttonsView)
        view.addSubview(thermostatControlView)
        view.addSubview(plusButton)
        view.addSubview(minusButton)
        view.addSubview(loaderView)
        view.addSubview(firstIssueRowView)
        view.addSubview(secondIssueRowView)
        view.addSubview(firstProgramInfoView)
        view.addSubview(secondProgramInfoView)
        view.addSubview(sensorIssueView)
        view.addSubview(deviceStateView)
        view.addSubview(pumpSwitchImage)
        view.addSubview(heatOrColdSourceSwitchImage)
        
        temperaturesViewController.didMove(toParent: self)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            temperaturesViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            temperaturesViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            temperaturesViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            firstProgramInfoView.topAnchor.constraint(equalTo: temperaturesViewController.view.bottomAnchor, constant: Dimens.distanceDefault),
            firstProgramInfoView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            firstProgramInfoView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            
            secondProgramInfoView.topAnchor.constraint(equalTo: firstProgramInfoView.bottomAnchor, constant: 10),
            secondProgramInfoView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            secondProgramInfoView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            
            sensorIssueView.topAnchor.constraint(equalTo: temperaturesViewController.view.bottomAnchor, constant: Dimens.distanceDefault),
            sensorIssueView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            sensorIssueView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            
            deviceStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceStateView.topAnchor.constraint(equalTo: temperaturesViewController.view.bottomAnchor, constant: Dimens.distanceDefault),
            
            buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            thermostatControlView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thermostatControlView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
            
            plusButton.topAnchor.constraint(equalTo: thermostatControlView.centerYAnchor, constant: 108),
            plusButton.leftAnchor.constraint(equalTo: thermostatControlView.centerXAnchor, constant: 20),
            minusButton.topAnchor.constraint(equalTo: thermostatControlView.centerYAnchor, constant: 108),
            minusButton.rightAnchor.constraint(equalTo: thermostatControlView.centerXAnchor, constant: -20),
            
            pumpSwitchImage.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            pumpSwitchImage.rightAnchor.constraint(equalTo: minusButton.leftAnchor, constant: -Dimens.distanceSmall),
            pumpSwitchImage.widthAnchor.constraint(equalToConstant: Dimens.iconSizeBig),
            pumpSwitchImage.heightAnchor.constraint(equalToConstant: Dimens.iconSizeBig),
            
            heatOrColdSourceSwitchImage.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            heatOrColdSourceSwitchImage.leftAnchor.constraint(equalTo: plusButton.rightAnchor, constant: Dimens.distanceSmall),
            heatOrColdSourceSwitchImage.widthAnchor.constraint(equalToConstant: Dimens.iconSizeBig),
            heatOrColdSourceSwitchImage.heightAnchor.constraint(equalToConstant: Dimens.iconSizeBig),
            
            loaderView.topAnchor.constraint(equalTo: view.topAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            firstIssueRowView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            firstIssueRowView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            firstIssueRowView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),
            
            secondIssueRowView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            secondIssueRowView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            secondIssueRowView.bottomAnchor.constraint(equalTo: firstIssueRowView.topAnchor, constant: -Dimens.distanceTiny)
        ])
    }
    
    @objc
    private func handleValueChange(notification: Notification) {
        if
            let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
            let remoteId = notification.userInfo?["remoteId"] as? NSNumber,
            !isGroup.boolValue
        {
            if (remoteId.int32Value == item.remoteId) {
                viewModel.triggerDataLoad(remoteId: item.remoteId)
            } else {
                viewModel.handleDataChangedEvent(remoteId: item.remoteId, otherId: remoteId.int32Value)
            }
        }
    }
}

// MARK: - Buttons view

private class ThermostatGeneralButtons: UIView {
    var powerTapEvents: Observable<Void> { powerButtonView.tapObservable }
    var manualTapEvents: Observable<Void> { manualModeButtonView.tapObservable }
    var weeklyScheduleTapEvents: Observable<Void> { weeklyScheduleModeButtonView.tapObservable }
    
    var isEnabled: Bool {
        get {
            powerButtonView.isEnabled && manualModeButtonView.isEnabled && weeklyScheduleModeButtonView.isEnabled
        }
        set {
            powerButtonView.isEnabled = newValue
            manualModeButtonView.isEnabled = newValue
            weeklyScheduleModeButtonView.isEnabled = newValue
        }
    }

    var powerIconColor: UIColor {
        get { powerButtonView.iconColor }
        set { powerButtonView.iconColor = newValue }
    }
    
    var manualModeActive: Bool {
        get { manualModeButtonView.active }
        set { manualModeButtonView.active = newValue }
    }
    
    var weeklyScheduleModeActive: Bool {
        get { weeklyScheduleModeButtonView.active }
        set { weeklyScheduleModeButtonView.active = newValue }
    }
    
    private lazy var powerButtonView: RoundedControlButtonView = {
        let view = RoundedControlButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.icon = .suplaIcon(name: .Icons.powerButton)
        view.iconColor = .primary
        return view
    }()
    
    private lazy var manualModeButtonView: RoundedControlButtonView = {
        let view = RoundedControlButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = Strings.ThermostatDetail.modeManual
        return view
    }()
    
    private lazy var weeklyScheduleModeButtonView: RoundedControlButtonView = {
        let view = RoundedControlButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = Strings.ThermostatDetail.modeWeeklySchedule
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: 96) }
    
    private func setupView() {
        addSubview(powerButtonView)
        addSubview(manualModeButtonView)
        addSubview(weeklyScheduleModeButtonView)
        addSubview(containerView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            powerButtonView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            powerButtonView.centerYAnchor.constraint(equalTo: centerYAnchor),
            powerButtonView.widthAnchor.constraint(equalToConstant: Dimens.buttonHeight),
            
            containerView.leftAnchor.constraint(equalTo: powerButtonView.rightAnchor, constant: Dimens.distanceDefault),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),

            manualModeButtonView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            manualModeButtonView.rightAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -Dimens.distanceDefault/2),
            manualModeButtonView.centerYAnchor.constraint(equalTo: centerYAnchor),

            weeklyScheduleModeButtonView.leftAnchor.constraint(equalTo: containerView.centerXAnchor, constant: Dimens.distanceDefault/2),
            weeklyScheduleModeButtonView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            weeklyScheduleModeButtonView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: - Program view -

private class ProgramView: UIView {
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: 20) }
    
    var info: ThermostatProgramInfo? {
        get { nil }
        set {
            guard let info = newValue else { return }
            
            infoTypeLabel.text = info.type.text().uppercased()
            iconView.isHidden = info.icon == nil || info.iconColor == nil
            if let icon = info.icon,
               let color = info.iconColor
            {
                iconView.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
                iconView.tintColor = color
            }
            descriptionLabel.isHidden = info.description == nil
            descriptionLabel.text = info.description
            timeLabel.isHidden = info.time == nil
            timeLabel.text = info.time
            manualIconView.isHidden = !info.manualActive
            
            setupLayout()
            setNeedsLayout()
        }
    }
    
    private lazy var infoTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .gray
        return label
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .openSansSemiBold(style: .body, size: 14)
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var manualIconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .iconManual
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var allConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(infoTypeLabel)
        addSubview(iconView)
        addSubview(descriptionLabel)
        addSubview(timeLabel)
        addSubview(manualIconView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.deactivate(allConstraints)
        allConstraints.removeAll()
        
        allConstraints.append(contentsOf: [
            infoTypeLabel.leftAnchor.constraint(equalTo: leftAnchor),
            infoTypeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoTypeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            iconView.widthAnchor.constraint(equalToConstant: Dimens.iconSizeSmall),
            iconView.heightAnchor.constraint(equalToConstant: Dimens.iconSizeSmall),
            
            manualIconView.widthAnchor.constraint(equalToConstant: Dimens.iconSizeSmall),
            manualIconView.heightAnchor.constraint(equalToConstant: Dimens.iconSizeSmall)
        ])
        var lastRightAnchor = infoTypeLabel.rightAnchor
        
        if (!iconView.isHidden) {
            allConstraints.append(contentsOf: [
                iconView.leftAnchor.constraint(equalTo: lastRightAnchor, constant: Dimens.distanceTiny),
                iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            lastRightAnchor = iconView.rightAnchor
        }

        if (!descriptionLabel.isHidden) {
            allConstraints.append(contentsOf: [
                descriptionLabel.leftAnchor.constraint(equalTo: lastRightAnchor, constant: Dimens.distanceTiny),
                descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            lastRightAnchor = descriptionLabel.rightAnchor
        }

        if (!timeLabel.isHidden) {
            allConstraints.append(contentsOf: [
                timeLabel.leftAnchor.constraint(equalTo: lastRightAnchor, constant: Dimens.distanceTiny),
                timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            lastRightAnchor = timeLabel.rightAnchor
        }

        if (!manualIconView.isHidden) {
            allConstraints.append(contentsOf: [
                manualIconView.leftAnchor.constraint(equalTo: lastRightAnchor, constant: Dimens.distanceTiny),
                manualIconView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
        
        NSLayoutConstraint.activate(allConstraints)
    }
}

private class SensorIssueView: UIView {
    var icon: UIImage? {
        get { iconView.image }
        set {
            iconView.image = newValue
            iconView.isHidden = newValue == nil
            setupChangeableConstraints()
        }
    }
    
    var message: String? {
        get { messageView.text }
        set { messageView.text = newValue }
    }
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var warningIconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = .iconSensorAlertCircle
        return view
    }()
    
    private lazy var messageView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .onBackground
        return label
    }()
    
    private var changeableConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(iconView)
        addSubview(warningIconView)
        addSubview(messageView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        setupChangeableConstraints()
        
        NSLayoutConstraint.activate([
            messageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupChangeableConstraints() {
        if (!changeableConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(changeableConstraints)
            changeableConstraints.removeAll()
        }
        
        if (icon != nil) {
            changeableConstraints.append(contentsOf: [
                iconView.topAnchor.constraint(equalTo: topAnchor),
                iconView.leftAnchor.constraint(equalTo: leftAnchor),
                iconView.bottomAnchor.constraint(equalTo: bottomAnchor),
                iconView.heightAnchor.constraint(equalToConstant: Dimens.iconSizeBig),
                iconView.widthAnchor.constraint(equalToConstant: Dimens.iconSizeBig),
                
                messageView.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: Dimens.distanceTiny),
                
                warningIconView.leftAnchor.constraint(equalTo: iconView.leftAnchor, constant: -4),
                warningIconView.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4)
            ])
        } else {
            changeableConstraints.append(contentsOf: [
                warningIconView.topAnchor.constraint(equalTo: topAnchor),
                warningIconView.leftAnchor.constraint(equalTo: leftAnchor),
                warningIconView.bottomAnchor.constraint(equalTo: bottomAnchor),
                warningIconView.heightAnchor.constraint(equalToConstant: Dimens.iconSizeSmall),
                warningIconView.widthAnchor.constraint(equalToConstant: Dimens.iconSizeSmall),
                
                messageView.leftAnchor.constraint(equalTo: warningIconView.rightAnchor, constant: Dimens.distanceTiny)
            ])
        }
        
        NSLayoutConstraint.activate(changeableConstraints)
    }
}
