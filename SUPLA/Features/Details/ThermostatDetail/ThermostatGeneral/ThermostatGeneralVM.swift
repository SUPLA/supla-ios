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

import RxRelay
import RxSwift
import SharedCore
import SwiftUI

private let REFRESH_DELAY_S: Double = 3

extension ThermostatGeneralFeature {
    final class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
        @Singleton<DelayedThermostatActionSubject> private var delayedThermostatActionSubject
        @Singleton<CheckIsSlaveThermostat.UseCase> private var checkIsSlaveThermostatUseCase
        @Singleton<CreateTemperaturesListUseCase> private var createTemperaturesListUseCase
        @Singleton<ChannelConfigEventsManager> private var channelConfigEventManager
        @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
        @Singleton<DeviceConfigEventsManager> private var deviceConfigEventManager
        @Singleton<ThermostatIssuesProvider> private var thermostatIssuesProvider
        @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
        @Singleton<GetDeviceConfigUseCase> private var getDeviceConfigUseCase
        @Singleton<UpdateEventsManager> private var updateEventsManager
        @Singleton<VibrationService> private var vibrationService
        @Singleton<DateProvider> private var dateProvider
        
        @Inject<LoadingTimeoutManager> private var loadingTimeoutManager

        private let updateRelay = PublishRelay<Void>()
        private let channelRelay = PublishRelay<ChannelWithChildren>()
        private let itemBundle: ItemBundle

        init(item: ItemBundle) {
            self.itemBundle = item
            super.init(state: ViewState())

            observeData(remoteId: itemBundle.remoteId, deviceId: itemBundle.deviceId)
        }

        override func onViewCreated() {
            loadingTimeoutManager.watch(
                stateProvider: { [weak self] in self?.state.loadingState }
            ) { [weak self] in
                guard let self else { return }
                if let remoteId = self.state.remoteId { self.triggerDataLoad(remoteId: remoteId) }
                self.state.loadingState = self.state.loadingState.copy(loading: false)
            }
            .disposed(by: disposeBag)

            loadData(remoteId: itemBundle.remoteId, deviceId: itemBundle.deviceId)
        }

        override func onViewAppear() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleValueChange(_:)),
                name: .saChannelValueChanged,
                object: nil
            )
        }

        override func onViewDisappear() {
            NotificationCenter.default.removeObserver(self, name: .saChannelValueChanged, object: nil)
            super.onViewDisappear()
        }

        @objc private func handleValueChange(_ notification: Notification) {
            if let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
               let remoteId = notification.userInfo?["remoteId"] as? NSNumber,
               !isGroup.boolValue
            {
                if remoteId.int32Value == itemBundle.remoteId {
                    triggerDataLoad(remoteId: itemBundle.remoteId)
                } else if state.childrenIds.contains(remoteId.int32Value) {
                    triggerDataLoad(remoteId: itemBundle.remoteId)
                }
            }
        }

        private func observeData(remoteId: Int32, deviceId: Int32) {
            updateEventsManager.observeChannelsUpdate()
                .debounce(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(onNext: { [weak self] in self?.triggerDataLoad(remoteId: remoteId) })
                .disposed(by: disposeBag)
            updateRelay
                .debounce(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(onNext: { [weak self] in self?.triggerDataLoad(remoteId: remoteId) })
                .disposed(by: disposeBag)

            Observable.combineLatest(
                channelRelay.asObservable().map { [weak self] in
                    ($0, self?.createTemperaturesListUseCase.invoke(channelWithChildren: $0))
                },
                channelConfigEventManager.observeConfig(id: remoteId)
                    .filter { $0.config is SuplaChannelHvacConfig && $0.result == .resultTrue },
                channelConfigEventManager.observeConfig(id: remoteId)
                    .filter { $0.config is SuplaChannelWeeklyScheduleConfig },
                deviceConfigEventManager.observeConfig(id: deviceId),
                checkIsSlaveThermostatUseCase.invoke(remoteId: remoteId),
                resultSelector: {
                    ($0, $1.config as? SuplaChannelHvacConfig,
                     $2.config as? SuplaChannelWeeklyScheduleConfig, $3.config, $4)
                }
            )
            .asDriverWithoutError()
            .debounce(.milliseconds(50))
            .drive(onNext: { [weak self] in self?.handleData(data: $0) })
            .disposed(by: disposeBag)
        }

        private func loadData(remoteId: Int32, deviceId: Int32) {
            getChannelConfigUseCase.invoke(remoteId: remoteId, type: .defaultConfig).subscribe().disposed(by: disposeBag)
            getChannelConfigUseCase.invoke(remoteId: remoteId, type: .weeklyScheduleConfig).subscribe().disposed(by: disposeBag)
            getDeviceConfigUseCase.invoke(deviceId: deviceId).subscribe().disposed(by: disposeBag)
            triggerDataLoad(remoteId: remoteId)
        }

        private func triggerDataLoad(remoteId: Int32) {
            readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
                .subscribe(onNext: { [weak self] in self?.channelRelay.accept($0) })
                .disposed(by: disposeBag)
        }

        func onPowerButtonTap() { updateMode(for: .power) }
        func onManualButtonTap() { updateMode(for: .manual) }
        func onWeeklyScheduleButtonTap() { updateMode(for: .weekly) }
        
        func onCoolButtonTap() {
            let newMode: SuplaHvacMode? = switch(state.mode) {
            case .heatCool, .heat, .off: .cool
            default: state.mode
            }

            if (newMode != state.mode) {
                state.mode = newMode
                state.thermostatAutoMode = .cool
                delayedThermostatActionSubject.emit(data: ThermostatActionData(remoteId: itemBundle.remoteId, mode: newMode))
                vibrationService.vibrate()
            }
        }
        
        func onHeatButtonTap() {
            let newMode: SuplaHvacMode? = switch(state.mode) {
            case .heatCool, .cool, .off: .heat
            default: state.mode
            }

            if (newMode != state.mode) {
                state.mode = newMode
                state.thermostatAutoMode = .heat
                delayedThermostatActionSubject.emit(data: ThermostatActionData(remoteId: itemBundle.remoteId, mode: newMode))
                vibrationService.vibrate()
            }
        }
        
        func onHeatCoolButtonTap() {
            let newMode: SuplaHvacMode? = switch(state.mode) {
            case .heat, .cool, .off: .heatCool
            default: state.mode
            }

            if (newMode != state.mode) {
                state.mode = newMode
                state.thermostatAutoMode = .heatCool
                delayedThermostatActionSubject.emit(data: ThermostatActionData(remoteId: itemBundle.remoteId, mode: newMode))
                vibrationService.vibrate()
            }
        }

        func onPositionEvent(_ event: SetpointEvent) {
            guard state.controlButtonsEnabled else { return }
            switch event {
            case .mooving(let type, let position): setpointPositionChanged(type, position.float)
            case .finished:
                state.changing = false
                updateChannelStatePresentation()
            }
        }

        func onTemperatureChange(_ step: TemperatureChangeStep) {
            let old = state
            guard let remoteId = old.remoteId, let setpointType = old.activeSetpointType else { return }
            let temperature = getNewTemperature(
                setpointType == .heat ? old.setpointHeat : old.setpointCool,
                state: old,
                step: step
            )
            delayedThermostatActionSubject.emit(data: ThermostatActionData(
                remoteId: remoteId,
                mode: old.weeklyScheduleActive ? .notSet : nil,
                setpointHeat: setpointType == .heat ? temperature : nil,
                setpointCool: setpointType == .cool ? temperature : nil
            ))
            state.lastInteractionTime = dateProvider.currentTimestamp()
            if setpointType == .heat {
                state.setpointHeat = temperature
            } else {
                state.setpointCool = temperature
            }
            state.mode = getModeForOffChanges(
                mode: old.mode,
                offline: old.offline,
                weeklyScheduleActive: old.weeklyScheduleActive,
                activeSetpointType: old.activeSetpointType
            )
            updateChannelStatePresentation()
        }

        private enum ModeAction { case power, manual, weekly }

        private func updateMode(for action: ModeAction) {
            let old = state
            guard let remoteId = old.remoteId else { return }
            var mode: SuplaHvacMode
            switch action {
            case .power:
                mode = old.weeklyScheduleActive && old.off ? .off : (old.off ? .cmdTurnOn : .off)
            case .manual:
                guard !old.manualActive else { return }
                mode = .cmdSwitchToManual
            case .weekly:
                guard !old.weeklyScheduleActive || old.temporaryChangeActive else { return }
                mode = .cmdWeeklySchedule
            }
            delayedThermostatActionSubject.sendImmediately(data: ThermostatActionData(remoteId: remoteId, mode: mode))
                .subscribe().disposed(by: disposeBag)
            if action == .power, mode == .cmdTurnOn {
                mode = old.channelFunc == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER || old.setpointHeat != nil ? .heat : .cool
            }
            state.mode = mode
            state.lastInteractionTime = nil
            state.loadingState = old.loadingState.copy(loading: true)
            if action == .manual {
                state.manualActive = true
                state.weeklyScheduleActive = false
            } else if action == .weekly {
                state.manualActive = false
                state.weeklyScheduleActive = true
            }
            updateChannelStatePresentation()
        }

        private func handleData(data: ((ChannelWithChildren, [MeasurementValue]?), SuplaChannelHvacConfig?, SuplaChannelWeeklyScheduleConfig?, SuplaDeviceConfig, Bool)) {
            let channel = data.0.0
            guard let temperatures = data.0.1,
                  let config = data.1,
                  let thermostatValue = channel.channel.value?.asThermostatValue() else { return }
            state.thermometerValues.measurements = temperatures
            if state.changing { return }
            if let interaction = state.lastInteractionTime,
               interaction + REFRESH_DELAY_S > dateProvider.currentTimestamp()
            {
                updateRelay.accept(())
                return
            }
            let online = channel.channel.status().online
            let slave = data.4
            state.remoteId = channel.channel.remote_id
            state.channelFunc = channel.channel.func
            state.mode = thermostatValue.mode
            state.childrenIds = channel.allDescendantFlat.map { $0.channel.remote_id }
            state.offline = !online
            state.controlButtonsEnabled = online && !slave
            state.configMin = config.minTemperature
            state.configMax = config.maxTemperature
            state.loadingState = state.loadingState.copy(loading: false)
            state.issues = thermostatIssuesProvider.provide(channelWithChildren: channel.shareable)
            state.sensorIssue = SensorIssue.build(value: thermostatValue, children: channel.children)
            state.temporaryChangeActive = online && thermostatValue.flags.contains(.weeklyScheduleTemporalOverride)
            state.programInfo = createProgramInfo(data.2, thermostatValue, online, data.3)
            state.timerEndDate = channel.channel.timerEndDate
            state.currentPower = thermostatValue.state.power?.intValue
            handleSetpoints(channel: channel.channel)
            handleFlags(channelWithChildren: channel)
            handleButtons(channel: channel.channel, isSlave: slave)
            state.currentTemperaturePercentage = getCurrentTemperature(channel, online: online)
            state.pumpSwitchIcon = pumpSwitchIcon(channel)
            state.heatOrColdSourceSwitchIcon = heatOrColdSourceSwitchIcon(channel)
            state.thermostatAutoMode = thermostatAutoMode(function: channel.function, value: thermostatValue)
            updateChannelStatePresentation()
        }

        private func updateChannelStatePresentation() {
            if state.timerInfoHidden {
                state.channelCurrentStateData = nil
                if state.sensorIssue == nil {
                    state.channelProgramState = state.programInfo.map { info in
                        ChannelProgramState.Data(
                            label: info.type.text(),
                            description: info.description,
                            time: info.time,
                            icon: info.icon.flatMap { UIImage(named: $0)?.withRenderingMode(.alwaysTemplate) }.map(Image.init(uiImage:)),
                            iconColor: info.iconColor.map(Color.init(uiColor:)),
                            indicatorIcon: info.manualActive ? UIImage.iconManual.map { Image(uiImage: $0.withRenderingMode(.alwaysTemplate)) } : nil,
                            indicatorColor: info.manualActive ? Color.Supla.onBackground : nil
                        )
                    }
                } else {
                    state.channelProgramState = []
                }
            } else {
                state.channelProgramState = []
                state.channelCurrentStateData = ChannelCurrentState.Data(
                    label: state.endDateText,
                    icon: state.mode?.icon.map { .suplaIcon(name: $0) },
                    value: state.currentStateValue,
                    iconColor: Color(uiColor: state.currentStateIconColor)
                )
            }
        }

        private func setpointPositionChanged(_ type: SetpointType, _ position: Float) {
            let oldMode = state.mode
            let oldOffline = state.offline
            let oldWeeklyScheduleActive = state.weeklyScheduleActive
            let oldSetpointHeat = state.setpointHeat
            let oldSetpointCool = state.setpointCool
            guard let min = state.configMin, let max = state.configMax, let remoteId = state.remoteId else { return }
            let temperature = (min + (max - min) * position).roundToTenths()
            delayedThermostatActionSubject.emit(data: ThermostatActionData(
                remoteId: remoteId,
                mode: oldWeeklyScheduleActive ? .notSet : nil,
                setpointHeat: type == .heat ? temperature : nil,
                setpointCool: type == .cool ? temperature : nil
            ))
            state.activeSetpointType = type
            state.lastInteractionTime = dateProvider.currentTimestamp()
            state.changing = true
            if type == .heat, (oldSetpointCool == nil || temperature < oldSetpointCool!) {
                state.setpointHeat = temperature
                state.mode = getModeForOffChanges(mode: oldMode, offline: oldOffline, weeklyScheduleActive: oldWeeklyScheduleActive, activeSetpointType: type)
            } else if type == .cool, (oldSetpointHeat == nil || temperature > oldSetpointHeat!) {
                state.setpointCool = temperature
                state.mode = getModeForOffChanges(mode: oldMode, offline: oldOffline, weeklyScheduleActive: oldWeeklyScheduleActive, activeSetpointType: type)
            }
            updateChannelStatePresentation()
        }

        private func getNewTemperature(_ temperature: Float?, state: ViewState, step: TemperatureChangeStep) -> Float? {
            guard let minimum = state.configMin, let maximum = state.configMax else { return temperature }
            guard let temperature else { return step.rawValue }
            return min(max(temperature + step.rawValue, minimum), maximum).roundToTenths()
        }

        private func getModeForOffChanges(
            mode: SuplaHvacMode?,
            offline: Bool,
            weeklyScheduleActive: Bool,
            activeSetpointType: SetpointType?
        ) -> SuplaHvacMode? {
            if mode == .off && !offline && weeklyScheduleActive {
                return activeSetpointType == .heat ? .heat : .cool
            }
            return mode
        }

        private func createProgramInfo(_ config: SuplaChannelWeeklyScheduleConfig?, _ value: ThermostatValue, _ online: Bool, _ device: SuplaDeviceConfig) -> [ThermostatProgramInfo] {
            guard let config else { return [] }
            let builder = ThermostatProgramInfo.Builder()
            builder.channelConfig = config
            builder.deviceConfig = device
            builder.thermostatFlags = value.flags
            builder.currentMode = value.mode
            builder.channelOnline = online
            if value.mode == .heat || value.mode == .heatCool { builder.currentTemperature = value.setpointTemperatureHeat }
            if value.mode == .cool || value.mode == .heatCool { builder.currentTemperature = value.setpointTemperatureCool }
            return builder.build()
        }

        private func handleSetpoints(channel: SAChannel) {
            guard let value = channel.value?.asThermostatValue() else { return }
            if channel.status().offline {
                state.setpointHeat = nil
                state.setpointCool = nil
                state.activeSetpointType = nil
                return
            }
            let heatSet = value.flags.contains(.setpointTempMinSet)
            if (channel.isDhw() || channel.isThermostatAuto() || (channel.isThermostatOnly() && value.subfunction == .heat)) && heatSet {
                state.setpointHeat = value.setpointTemperatureHeat.roundToTenths()
            } else { state.setpointHeat = nil }
            let coolSet = value.flags.contains(.setpointTempMaxSet)
            if ((channel.isThermostatAuto() || (channel.isThermostatOnly() && value.subfunction == .cool)) && coolSet) {
                state.setpointCool = value.setpointTemperatureCool.roundToTenths()
            } else { state.setpointCool = nil }
            if state.activeSetpointType == nil || state.subfunction != value.subfunction {
                switch value.mode {
                case .heat, .heatCool: state.activeSetpointType = .heat
                case .cool: state.activeSetpointType = .cool
                case .off:
                    if value.subfunction == .heat { state.activeSetpointType = .heat }
                    if value.subfunction == .cool { state.activeSetpointType = .cool }
                default: break
                }
                state.subfunction = value.subfunction
            }
        }

        private func getCurrentTemperature(_ channel: ChannelWithChildren, online: Bool) -> Float? {
            guard online,
                  let thermometer = channel.children.first(where: {
                      channel.channel.temperatureControlType.filterRelationType($0.relation.relationType)
                  }),
                  let min = state.configMin,
                  let max = state.configMax
            else { return nil }

            return (Float(thermometer.channel.temperatureValue()) - min) / (max - min)
        }

        private func handleFlags(channelWithChildren: ChannelWithChildren) {
            state.heatingIndicatorActive = isActive(channelWithChildren, .heating)
            state.coolingIndicatorActive = isActive(channelWithChildren, .cooling)
        }

        private func isActive(_ channel: ChannelWithChildren, _ flag: SuplaThermostatFlag) -> Bool {
            let children = channel.allDescendantFlat.filter { $0.relation.relationType == .masterThermostat }
            return channel.channel.isActive(flag) || children.contains { $0.channel.isActive(flag) }
        }

        private func handleButtons(channel: SAChannel, isSlave: Bool) {
            guard let value = channel.value?.asThermostatValue() else { return }
            state.manualActive = !channel.isThermostatOff() && !value.flags.contains(.weeklySchedule)
            state.weeklyScheduleActive = channel.status().online && value.flags.contains(.weeklySchedule)
            state.plusMinusHidden = channel.status().offline || (channel.isThermostatOff() && !value.flags.contains(.weeklySchedule)) || isSlave
        }

        private func pumpSwitchIcon(_ channel: ChannelWithChildren) -> IconResult? {
            if let child = channel.pumpSwitchChild { return getChannelBaseIconUseCase.invoke(channel: child.channel) }
            let values = channel.allDescendantFlat.filter { $0.relationType == .pumpSwitch }
            return values.count == 1 ? getChannelBaseIconUseCase.invoke(channel: values[0].channel) : nil
        }

        private func heatOrColdSourceSwitchIcon(_ channel: ChannelWithChildren) -> IconResult? {
            if let child = channel.heatOrColdSourceSwitchChild { return getChannelBaseIconUseCase.invoke(channel: child.channel) }
            let values = channel.allDescendantFlat.filter { $0.relationType == .heatOrColdSourceSwitch }
            return values.count == 1 ? getChannelBaseIconUseCase.invoke(channel: values[0].channel) : nil
        }

        private func thermostatAutoMode(function: Int32, value: ThermostatValue) -> ThermostatAutoMode? {
            if (function != SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL || value.flags.contains(.weeklySchedule)) {
                return nil
            }

            return switch (value.mode) {
            case .heat: .heat
            case .cool: .cool
            case .heatCool: .heatCool
            default: nil
            }
        }
    }
}

enum ThermostatOperationalMode: Equatable {
    case offline, off(heating: Bool, cooling: Bool), heating, cooling, standby

    var foregroundColor: UIColor {
        switch (self) {
        case .offline: .black
        case .off(let heating, let cooling):
            if (heating) {
                .error
            } else if (cooling) {
                .secondary
            } else {
                .black
            }
        case .heating: .error
        case .cooling: .secondary
        case .standby: .primary
        }
    }

    var backgroundColor: UIColor {
        switch (self) {
        case .heating: .errorContainer
        case .cooling: .secondaryContainer
        default: .transparent
        }
    }

    var isHeating: Bool {
        switch self {
        case .heating: true
        case .off(let heating, _): heating
        default: false
        }
    }

    var isCooling: Bool {
        switch self {
        case .cooling: true
        case .off(_, let cooling): cooling
        default: false
        }
    }

    var isStrictHeating: Bool {
        switch self {
        case .heating: true
        default: false
        }
    }

    var isStrictCooling: Bool {
        switch self {
        case .cooling: true
        default: false
        }
    }
}

private extension SAChannel {
    func isThermostatOff() -> Bool {
        guard let value = value?.asThermostatValue() else { return false }
        return status().offline || value.mode == .off || value.mode == .notSet
    }

    func isDhw() -> Bool {
        return self.func == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER
    }

    func isThermostatAuto() -> Bool {
        return self.func == SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL
    }

    func isThermostatOnly() -> Bool {
        return self.func == SUPLA_CHANNELFNC_HVAC_THERMOSTAT
    }
}

private extension SAChannel {
    func isActive(_ flag: SuplaThermostatFlag) -> Bool {
        guard let value = value?.asThermostatValue() else { return false }
        return status().online && value.state.isOn() && value.flags.contains(flag)
    }
}
