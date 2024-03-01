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
import RxRelay

private let REFRESH_DELAY_S: Double = 3

class ThermostatGeneralVM: BaseViewModel<ThermostatGeneralViewState, ThermostatGeneralViewEvent> {
    
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
    @Singleton<CreateTemperaturesListUseCase> private var createTemperaturesListUseCase
    @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
    @Singleton<GetDeviceConfigUseCase> private var getDeviceConfigUseCase
    @Singleton<ChannelConfigEventsManager> private var channelConfigEventManager
    @Singleton<DeviceConfigEventsManager> private var deviceConfigEventManager
    @Singleton<DelayedThermostatActionSubject> private var delayedThermostatActionSubject
    @Singleton<DateProvider> private var dateProvider
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Inject<LoadingTimeoutManager> private var loadingTimeoutManager
    
    private let updateRelay = PublishRelay<Void>()
    private let channelRelay = PublishRelay<ChannelWithChildren>()
    
    override func defaultViewState() -> ThermostatGeneralViewState { ThermostatGeneralViewState() }
    
    override func onViewDidLoad() {
        loadingTimeoutManager.watch(
            stateProvider: { [weak self] in self?.currentState()?.loadingState }
        ) { [weak self] in
            self?.updateView { state in
                if let channelFunction = state.channelFunc {
                    self?.triggerDataLoad(remoteId: channelFunction)
                }
                
                return state.changing(path: \.loadingState, to: state.loadingState.copy(loading: false))
            }
        }
        .disposed(by: self)
    }
    
    func observeData(remoteId: Int32, deviceId: Int32) {
        updateEventsManager.observeChannelsUpdate()
            .debounce(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] in self?.triggerDataLoad(remoteId: remoteId) })
            .disposed(by: self)
        updateRelay
            .debounce(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] in self?.triggerDataLoad(remoteId: remoteId) })
            .disposed(by: self)
        
        Observable.combineLatest(
            channelRelay.asObservable()
                .map { [weak self] in ($0, self?.createTemperaturesListUseCase.invoke(channelWithChildren: $0))},
            channelConfigEventManager.observeConfig(id: remoteId)
                .filter { $0.config is SuplaChannelHvacConfig && $0.result == .resultTrue },
            channelConfigEventManager.observeConfig(id: remoteId)
                .filter { $0.config is SuplaChannelWeeklyScheduleConfig },
            deviceConfigEventManager.observeConfig(id: deviceId),
            resultSelector: { ($0, $1.config as? SuplaChannelHvacConfig, $2.config as? SuplaChannelWeeklyScheduleConfig, $3.config) }
        ).asDriverWithoutError()
            .debounce(.milliseconds(50))
            .drive(onNext: { [weak self] in self?.handleData(data: $0) })
            .disposed(by: self)
    }
    
    func loadData(remoteId: Int32, deviceId: Int32) {
        getChannelConfigUseCase.invoke(remoteId: remoteId, type: .defaultConfig)
            .subscribe()
            .disposed(by: self)
        getChannelConfigUseCase.invoke(remoteId: remoteId, type: .weeklyScheduleConfig)
            .subscribe()
            .disposed(by: self)
        getDeviceConfigUseCase.invoke(deviceId: deviceId)
            .subscribe()
            .disposed(by: self)
        
        triggerDataLoad(remoteId: remoteId)
    }
    
    func triggerDataLoad(remoteId: Int32) {
        readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
            .subscribe(onNext: { [weak self] in self?.channelRelay.accept($0) })
            .disposed(by: self)
    }
    
    func loadTemperatures(remoteId: Int32, otherId: Int32) {
        if let state = currentState(),
           state.childrenIds.contains(otherId) {
            triggerDataLoad(remoteId: remoteId)
        }
    }
    
    func onPositionEvent(_ event: SetpointEvent) {
        switch (event) {
        case .mooving(let setpointType, let position):
            setpointPositionChanged(setpointType, position.float)
        case .finished:
            updateView { $0.changing(path: \.changing, to: false) }
        }
    }
    
    func onTemperatureChange(_ step: TemperatureChangeStep) {
        updateView { state in
            guard let setpointType = state.activeSetpointType,
                  let remoteId = state.remoteId
            else { return state }
            
            let resultState = state.changing(path: \.lastInteractionTime, to: dateProvider.currentTimestamp())
            
            switch (setpointType) {
            case .cool:
                let temperature = getNewTemperature(state.setpointCool, state: state, step: step)
                delayedThermostatActionSubject.emit(
                    data: ThermostatActionData(
                        remoteId: remoteId,
                        mode: state.weeklyScheduleActive ? .notSet : nil,
                        setpointCool: temperature
                    )
                )
                return resultState.changing(path: \.setpointCool, to: temperature)
                    .changing(path: \.mode, to: getModeForOffChanges(state: state))
            case .heat:
                let temperature = getNewTemperature(state.setpointHeat, state: state, step: step)
                delayedThermostatActionSubject.emit(
                    data: ThermostatActionData(
                        remoteId: remoteId,
                        mode: state.weeklyScheduleActive ? .notSet : nil,
                        setpointHeat: temperature
                    )
                )
                return resultState.changing(path: \.setpointHeat, to: temperature)
                    .changing(path: \.mode, to: getModeForOffChanges(state: state))
            }
        }
    }
    
    func onPowerButtonTap() {
        updateView { state in
            guard let remoteId = state.remoteId else { return state }
            
            var mode: SuplaHvacMode
            if (state.weeklyScheduleActive && state.off) {
                mode = .off
            } else {
                mode = state.off ? .cmdTurnOn : .off
            }
            let data = ThermostatActionData(remoteId: remoteId, mode: mode)
            delayedThermostatActionSubject.sendImmediately(data: data)
                .subscribe()
                .disposed(by: self)
            
            if (mode == .cmdTurnOn) {
                if (state.channelFunc == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER || state.setpointHeat != nil) {
                    mode = .heat
                } else {
                    mode = .cool
                }
            }
            
            return state.changing(path: \.mode, to: mode)
                .changing(path: \.lastInteractionTime, to: nil)
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: true))
        }
    }
    
    func onManualButtonTap() {
        updateView { state in
            guard let remoteId = state.remoteId else { return state }
            if (state.manualActive) { return state }
            
            let mode: SuplaHvacMode = .cmdSwitchToManual
            
            let data = ThermostatActionData(remoteId: remoteId, mode: mode)
            delayedThermostatActionSubject.sendImmediately(data: data)
                .subscribe()
                .disposed(by: self)
            
            return state.changing(path: \.mode, to: mode)
                .changing(path: \.manualActive, to: true)
                .changing(path: \.weeklyScheduleActive, to: false)
                .changing(path: \.lastInteractionTime, to: nil)
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: true))
        }
    }
    
    func onWeeklyScheduleButtonTap() {
        updateView { state in
            guard let remoteId = state.remoteId else { return state }
            if (state.weeklyScheduleActive && !state.temporaryChangeActive) { return state }
            
            let mode: SuplaHvacMode = .cmdWeeklySchedule
            let data = ThermostatActionData(remoteId: remoteId, mode: mode)
            delayedThermostatActionSubject.sendImmediately(data: data)
                .subscribe()
                .disposed(by: self)
            
            return state.changing(path: \.mode, to: mode)
                .changing(path: \.manualActive, to: false)
                .changing(path: \.weeklyScheduleActive, to: true)
                .changing(path: \.lastInteractionTime, to: nil)
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: true))
        }
    }
    
    private func setpointPositionChanged(_ type: SetpointType, _ position: Float) {
        updateView { state in
            guard let min = state.configMin,
                  let max = state.configMax,
                  let remoteId = state.remoteId
            else { return state }
            
            let resultState = state.changing(path: \.activeSetpointType, to: type)
                .changing(path: \.lastInteractionTime, to: dateProvider.currentTimestamp())
                .changing(path: \.changing, to: true)
            
            let newTemperature = Float(Int((min + (max - min) * position) * 10)) / 10
            switch (type) {
            case .cool:
                delayedThermostatActionSubject.emit(
                    data: ThermostatActionData(
                        remoteId: remoteId,
                        mode: state.weeklyScheduleActive ? .notSet : nil,
                        setpointCool: newTemperature
                    )
                )
                return resultState.changing(path: \.setpointCool, to: newTemperature)
                    .changing(path: \.mode, to: getModeForOffChanges(state: state))
            case .heat:
                delayedThermostatActionSubject.emit(
                    data: ThermostatActionData(
                        remoteId: remoteId,
                        mode: state.weeklyScheduleActive ? .notSet : nil,
                        setpointHeat: newTemperature
                    )
                )
                return resultState.changing(path: \.setpointHeat, to: newTemperature)
                    .changing(path: \.mode, to: getModeForOffChanges(state: state))
            }
        }
    }
    
    private func handleData(data: ((ChannelWithChildren, [MeasurementValue]?), SuplaChannelHvacConfig?, SuplaChannelWeeklyScheduleConfig?, SuplaDeviceConfig)) {
        SALog.debug("General handle data")
        let channel = data.0.0
        
        guard let temperatures = data.0.1,
              let config = data.1,
              let thermostatValue = channel.channel.value?.asThermostatValue()
        else { return }
        
        updateView { state in
            if (state.changing) {
                SALog.info("Update skipped because of changing")
                return state // Do not change anything, when user makes manual operations
            }
            
            if let lastInteractionTime = state.lastInteractionTime,
               lastInteractionTime + REFRESH_DELAY_S > dateProvider.currentTimestamp() {
                SALog.info("Update skipped because of last interaction time")
                updateRelay.accept(())
                return state // Do not change anything during 3 secs after last user interaction
            }
            
            SALog.debug("Updating state with data")
            
            var changedState = state
                .changing(path: \.remoteId, to: channel.channel.remote_id)
                .changing(path: \.channelFunc, to: channel.channel.func)
                .changing(path: \.mode, to: thermostatValue.mode)
                .changing(path: \.measurements, to: temperatures)
                .changing(path: \.childrenIds, to: channel.children.map { $0.channel.remote_id })
                .changing(path: \.offline, to: !channel.channel.isOnline())
                .changing(path: \.configMin, to: config.temperatures.roomMin?.fromSuplaTemperature())
                .changing(path: \.configMax, to: config.temperatures.roomMax?.fromSuplaTemperature())
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: false))
                .changing(path: \.issues, to: createThermostatIssues(flags: thermostatValue.flags))
                .changing(path: \.sensorIssue, to: createSensorIssue(value: thermostatValue, children: channel.children))
                .changing(path: \.temporaryChangeActive, to: channel.channel.isOnline() && thermostatValue.flags.contains(.weeklyScheduleTemporalOverride))
                .changing(path: \.programInfo, to: createProgramInfo(data.2, thermostatValue, channel.channel.isOnline(), data.3))
                .changing(path: \.timerEndDate, to: channel.channel.getTimerEndDate())
            
            changedState = handleSetpoints(changedState, channel: channel.channel)
            changedState = handleFlags(changedState, value: thermostatValue, isOnline: channel.channel.isOnline())
            changedState = handleButtons(changedState, channel: channel.channel)
            
            if let mainTermometer = channel.children.first(where: { $0.relationType == .mainThermometer }),
               channel.channel.isOnline() {
                let temperature = mainTermometer.channel.temperatureValue()
                changedState = handleCurrentTemperture(changedState, temperature: Float(temperature))
            }
            
            return changedState
        }
    }
    
    private func getNewTemperature(_ temperature: Float?, state: ThermostatGeneralViewState, step: TemperatureChangeStep) -> Float? {
        guard let configMin = state.configMin,
              let configMax = state.configMax
        else { return temperature }
        
        guard let temperature = temperature
        else { return 0 + step.rawValue }
        
        let newTemperature = temperature + step.rawValue
        if (newTemperature < configMin) {
            return configMin
        } else if (newTemperature > configMax) {
            return configMax
        } else {
            return newTemperature
        }
    }
    
    private func handleSetpoints(_ state: ThermostatGeneralViewState, channel: SAChannel) -> ThermostatGeneralViewState {
        guard let value = channel.value?.asThermostatValue() else { return state }
        
        if (!channel.isOnline()) {
            return state
                .changing(path: \.setpointHeat, to: nil)
                .changing(path: \.setpointCool, to: nil)
                .changing(path: \.activeSetpointType, to: nil)
        }
        
        var changedState = state
        let setpointHeatSet = value.flags.contains(.setpointTempMinSet)
        let dhv = channel.isDhw() && setpointHeatSet
        let autoHeat = channel.isThermostatAuto() && setpointHeatSet
        let heat = channel.isThermostat() && setpointHeatSet && value.subfunction == .heat
        if (dhv || autoHeat || heat) {
            changedState = changedState.changing(path: \.setpointHeat, to: value.setpointTemperatureHeat)
        } else {
            changedState = changedState.changing(path: \.setpointHeat, to: nil)
        }
        
        let setpointCoolSet = value.flags.contains(.setpointTempMaxSet)
        let autoCool = channel.isThermostatAuto() && setpointCoolSet
        let cool = channel.isThermostat() && setpointCoolSet && value.subfunction == .cool
        if (autoCool || cool) {
            changedState = changedState.changing(path: \.setpointCool, to: value.setpointTemperatureCool)
        } else {
            changedState = changedState.changing(path: \.setpointCool, to: nil)
        }
        
        if (changedState.activeSetpointType == nil || changedState.subfunction != value.subfunction) {
            switch (value.mode) {
            case .heat, .auto:
                changedState = changedState.changing(path: \.activeSetpointType, to: .heat)
            case .cool:
                changedState = changedState.changing(path: \.activeSetpointType, to: .cool)
            case .off:
                if (value.subfunction == .heat) {
                    changedState = changedState.changing(path: \.activeSetpointType, to: .heat)
                } else if (value.subfunction == .cool) {
                    changedState = changedState.changing(path: \.activeSetpointType, to: .cool)
                }
            default: break
            }
            changedState = changedState.changing(path: \.subfunction, to: value.subfunction)
        }
        
        return changedState
    }
    
    private func handleCurrentTemperture(_ state: ThermostatGeneralViewState, temperature: Float) -> ThermostatGeneralViewState {
        guard let configMin = state.configMin,
              let configMax = state.configMax
        else { return state }
        
        let range = configMax - configMin
        let temperaturePercentage = (temperature - configMin) / range
        return state.changing(path: \.currentTemperaturePercentage, to: temperaturePercentage)
    }
    
    private func handleFlags(_ state: ThermostatGeneralViewState, value: ThermostatValue, isOnline: Bool) -> ThermostatGeneralViewState {
        return state
            .changing(
                path: \.heatingIndicatorInactive,
                to: !value.state.isOn() || !value.flags.contains(.heating) || !isOnline
            )
            .changing(
                path: \.coolingIndicatorInactive,
                to: !value.state.isOn() || !value.flags.contains(.cooling) || !isOnline
            )
    }
    
    private func handleButtons(_ state: ThermostatGeneralViewState, channel: SAChannel) -> ThermostatGeneralViewState {
        guard let value = channel.value?.asThermostatValue() else { return state }
        
        return state
            .changing(
                path: \.manualActive,
                to: !channel.isThermostatOff() && !value.flags.contains(.weeklySchedule)
            )
            .changing(
                path: \.weeklyScheduleActive,
                to: channel.isOnline() && value.flags.contains(.weeklySchedule)
            )
            .changing(
                path: \.plusMinusHidden,
                to: !channel.isOnline() || ((channel.isThermostatOff() && !value.flags.contains(.weeklySchedule)))
            )
    }
    
    private func createThermostatIssues(flags: [SuplaThermostatFlag]) -> [ThermostatIssueItem] {
        var result: [ThermostatIssueItem] = []
        if (flags.contains(.thermometerError)) {
            result.append(ThermostatIssueItem(
                issueIconType: .error,
                description: Strings.ThermostatDetail.thermometerError
            ))
        }
        if (flags.contains(.clockError)) {
            result.append(ThermostatIssueItem(
                issueIconType: .warning,
                description: Strings.ThermostatDetail.clockError
            ))
        }
        return result
    }
    
    private func createSensorIssue(value: ThermostatValue, children: [ChannelChild]) -> SensorIssue? {
        if (!value.flags.contains(.forcedOffBySensor)) {
            return nil
        }
        
        if let sensor = children.first(where: { $0.relationType == .defaultType }) {
            let message = switch(sensor.channel.func) {
            case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW, SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
                Strings.ThermostatDetail.offByWindow
            case SUPLA_CHANNELFNC_HOTELCARDSENSOR:
                Strings.ThermostatDetail.offByCard
            default: Strings.ThermostatDetail.offBySensor
            }
            return SensorIssue(
                sensorIcon: getChannelBaseIconUseCase.invoke(channel: sensor.channel),
                message: message
            )
        } else {
            return SensorIssue(
                sensorIcon: nil,
                message: Strings.ThermostatDetail.offBySensor
            )
        }
    }
    
    private func createProgramInfo(
        _ channelConfig: SuplaChannelWeeklyScheduleConfig?,
        _ value: ThermostatValue,
        _ channelOnline: Bool,
        _ deviceConfig: SuplaDeviceConfig
    ) -> [ThermostatProgramInfo] {
        guard let channelConfig = channelConfig else { return [] }
        
        let builder = ThermostatProgramInfo.Builder()
        builder.channelConfig = channelConfig
        builder.deviceConfig = deviceConfig
        builder.thermostatFlags = value.flags
        builder.currentMode = value.mode
        builder.channelOnline = channelOnline
        
        switch(value.subfunction) {
        case .heat: builder.currentTemperature = value.setpointTemperatureHeat
        case .cool: builder.currentTemperature = value.setpointTemperatureCool
        default: break
        }
        
        return builder.build()
    }
    
    private func getModeForOffChanges(state: ThermostatGeneralViewState) -> SuplaHvacMode? {
        if (state.mode == .off && !state.offline && state.weeklyScheduleActive) {
            return state.activeSetpointType == .heat ? .heat : .cool
        } else {
            return state.mode
        }
    }
}

enum ThermostatGeneralViewEvent: ViewEvent {
}

struct ThermostatGeneralViewState: ViewState {
    
    /* Logic properties */
    
    var remoteId: Int32? = nil
    var channelFunc: Int32? = nil
    var mode: SuplaHvacMode? = nil
    var offline: Bool = true
    var configMin: Float? = nil
    var configMax: Float? = nil
    var childrenIds: [Int32] = []
    var sent: Bool = false
    var lastInteractionTime: TimeInterval? = nil
    var changing: Bool = false
    var loadingState: LoadingState = LoadingState()
    var subfunction: ThermostatSubfunction? = nil
    var timerEndDate: Date? = nil
    
    /* View properties */
    
    var measurements: [MeasurementValue] = []
    var setpointHeat: Float? = nil
    var setpointCool: Float? = nil
    var activeSetpointType: SetpointType? = nil
    var currentTemperaturePercentage: Float? = nil
    var heatingIndicatorInactive: Bool? = nil
    var coolingIndicatorInactive: Bool? = nil
    var manualActive: Bool = false
    var weeklyScheduleActive: Bool = false
    var plusMinusHidden: Bool = false
    var temporaryChangeActive: Bool = false
    var programInfo: [ThermostatProgramInfo] = []
    var issues: [ThermostatIssueItem] = []
    var sensorIssue: SensorIssue? = nil
    
    /* All calculated properties below */
    
    var off: Bool {
        get {
            offline || mode == .off || mode == .notSet
        }
    }
    var setpointText: String? {
        get {
            @Singleton<ValuesFormatter> var formatter
            
            if (offline) {
                return "offline"
            } else if (off) {
                return "off"
            } else if (mode == .heat) {
                return formatter.temperatureToString(setpointHeat, withUnit: false)
            } else if (mode == .cool) {
                return formatter.temperatureToString(setpointCool, withUnit: false)
            }
            
            return nil
        }
    }
    var setpointHeatPercentage: Float? {
        get {
            guard let min = configMin,
                  let max = configMax,
                  let current = setpointHeat,
                  !off || weeklyScheduleActive
            else { return nil }
            return (current - min) / (max - min)
        }
    }
    var setpointCoolPercentage: Float? {
        get {
            guard let min = configMin,
                  let max = configMax,
                  let current = setpointCool,
                  !off || weeklyScheduleActive
            else { return nil }
            return (current - min) / (max - min)
        }
    }
    var plusButtonEnabled: Bool {
        get {
            if (mode == .off && !weeklyScheduleActive) {
                return false
            }
            switch (activeSetpointType) {
            case .heat: return (setpointHeat ?? 0) < (configMax ?? 0)
            case .cool: return (setpointCool ?? 0) < (configMax ?? 0)
            default: return false
            }
        }
    }
    var minusButtonEnabled: Bool {
        get {
            if (mode == .off && !weeklyScheduleActive) {
                return false
            }
            switch (activeSetpointType) {
            case .heat: return (setpointHeat ?? 0) > (configMin ?? 0)
            case .cool: return (setpointCool ?? 0) > (configMin ?? 0)
            default: return false
            }
        }
    }
    var modeIndicatorColor: UIColor {
        get {
            if (offline) {
                return .black
            } else if (heatingIndicatorInactive == false) {
                return .red
            } else if (coolingIndicatorInactive == false) {
                return .blue
            } else if (off) {
                return .black
            } else {
                return .primary
            }
        }
    }
    var powerIconColor: UIColor {
        get {
            if ((off && !weeklyScheduleActive) || offline) {
                return .red
            } else {
                return .primary
            }
        }
    }
    var controlButtonsEnabled: Bool { !offline }
    var configMinMaxHidden: Bool { offline }
    var grayOutSetpoints: Bool { !offline && off && weeklyScheduleActive }
    
    var timerInfoHidden: Bool {
        sensorIssue != nil || timerEndDate == nil || timerEndDate!.timeIntervalSince1970 < Date().timeIntervalSince1970
    }
    var endDateText: String { DeviceState.endDateText(timerEndDate) }
    var currentStateIcon: UIImage? { DeviceState.currentStateIcon(mode) }
    var currentStateIconColor: UIColor { DeviceState.currentStateIconColor(mode) }
    var currentStateValue: String {
        DeviceState.currentStateValue(
            mode,
            heatSetpoint: setpointHeat,
            coolSetpoint: setpointCool
        )
    }
}

fileprivate extension SAChannel {
    func isThermostatOff() -> Bool {
        guard let value = value?.asThermostatValue() else { return false }
        return !isOnline() || value.mode == .off || value.mode == .notSet
    }
    
    func isDhw() -> Bool {
        return self.func == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER
    }
    
    func isThermostatAuto() -> Bool {
        return self.func == SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL
    }
    
    func isThermostat() -> Bool {
        return self.func == SUPLA_CHANNELFNC_HVAC_THERMOSTAT
    }
}

struct ThermostatIssueItem: Equatable {
    let issueIconType: IssueIconType
    let description: String
}

struct SensorIssue: Equatable {
    let sensorIcon: UIImage?
    let message: String
}
