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

class ThermostatTimerDetailVM: BaseViewModel<ThermostatTimerDetailViewState, ThermostatTimerDetailViewEvent> {
    
    private let channelRelay = PublishRelay<SAChannel>()
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<ChannelConfigEventsManager> private var channelConfigEventManager
    @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
    @Singleton<ExecuteThermostatActionUseCase> private var executeThermostatActionUseCase
    @Singleton<DateProvider> private var dateProvider
    @Inject<LoadingTimeoutManager> private var loadingTimeoutManager
    
    override func defaultViewState() -> ThermostatTimerDetailViewState { ThermostatTimerDetailViewState() }
    
    override func onViewDidLoad() {
        loadingTimeoutManager.watch(
            stateProvider: { [weak self] in self?.currentState()?.loadingState }
        ) { [weak self] in
            self?.updateView { state in
                if let channelFunction = state.channelFunction {
                    self?.loadData(remoteId: channelFunction)
                }
                
                return state.changing(path: \.loadingState, to: state.loadingState.copy(loading: false))
            }
        }
        .disposed(by: self)
    }
    
    func loadData(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .subscribe(onNext: { [weak self] in self?.channelRelay.accept($0) })
            .disposed(by: self)
        getChannelConfigUseCase.invoke(remoteId: remoteId, type: .defaultConfig)
            .subscribe()
            .disposed(by: self)
    }
    
    func observeData(remoteId: Int32) {
        Observable.combineLatest(
            channelRelay,
            channelConfigEventManager.observeConfig(id: remoteId)
                .filter { $0.config is SuplaChannelHvacConfig && $0.result == .resultTrue}
        ).asDriverWithoutError()
            .debounce(.milliseconds(100))
            .drive(onNext: { [weak self] in
                self?.handleData($0.0, $0.1.config as! SuplaChannelHvacConfig)
            })
            .disposed(by: self)
    }
    
    func toggleDeviceMode(deviceMode: TimerDetailDeviceMode) {
        updateView {
            $0.changing(path: \.selectedMode, to: deviceMode)
        }
    }
    
    func toggleSelectorMode() {
        updateView {
            $0.changing(path: \.showCalendar, to: !$0.showCalendar)
        }
    }
    
    func onDateChanged(date: Date) {
        updateView {
            $0.changing(path: \.calendarValue, to: date)
        }
    }
    
    func onTimerValueChanged(value: TrippleNumberSelectorView.Value) {
        updateView {
            $0.changing(path: \.pickerValue, to: value)
        }
    }
    
    func onTemperatureChange(temperature: Float) {
        updateView {
            $0.changing(path: \.currentTemperature, to: temperature)
        }
    }
    
    func onTemperatureChange(step: TemperatureChangeStep) {
        updateView {
            $0.changing(path: \.currentTemperature, to: $0.currentTemperature?.plus(step.rawValue))
        }
    }
    
    func onStartTimer() {
        guard let state = currentState(),
              let remoteId = state.remoteId,
              let duration = state.getTimerDuration(date: dateProvider.currentDate())
        else { return }
        
        updateView {
            $0.changing(path: \.loadingState, to: $0.loadingState.copy(loading: true))
                .changing(path: \.editTime, to: false)
        }
        
        let mode: SuplaHvacMode = if (state.selectedMode == .off) {
            .off
        } else if (state.usingHeatSetpoint) {
            .heat
        } else {
            .cool
        }
        let sendTemperature = state.selectedMode == .manual
        
        executeThermostatActionUseCase.invoke(
            type: .channel,
            remoteId: remoteId,
            mode: mode,
            setpointTemperatureHeat: sendTemperature && state.usingHeatSetpoint ? state.currentTemperature : nil,
            setpointTemperatureCool: sendTemperature && !state.usingHeatSetpoint ? state.currentTemperature : nil,
            durationInSec: Int32(duration)
        ).asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    func cancelTimerStartManual() {
        guard let remoteId = currentState()?.remoteId else { return }
        
        updateView { $0.changing(path: \.loadingState, to: $0.loadingState.copy(loading: true)) }
        
        executeThermostatActionUseCase.invoke(
            type: .channel,
            remoteId: remoteId,
            mode: .cmdSwitchToManual,
            setpointTemperatureHeat: nil,
            setpointTemperatureCool: nil,
            durationInSec: nil
        ).asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    func cancelTimerStartProgram() {
        guard let remoteId = currentState()?.remoteId else { return }
        
        updateView { $0.changing(path: \.loadingState, to: $0.loadingState.copy(loading: true)) }
        
        executeThermostatActionUseCase.invoke(
            type: .channel,
            remoteId: remoteId,
            mode: .cmdWeeklySchedule,
            setpointTemperatureHeat: nil,
            setpointTemperatureCool: nil,
            durationInSec: nil
        ).asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    func editTimer() {
        updateView {
            guard let timerEndDate = $0.timerEndDate,
                  let currentDate = $0.currentDate
            else {
                return $0.changing(path: \.editTime, to: true)
            }
            let timeDiff = timerEndDate.differenceInSeconds(currentDate)
            
            return $0.changing(path: \.editTime, to: true)
                .changing(path: \.pickerValue, to: TrippleNumberSelectorView.Value(valueForDays: timeDiff))
                .changing(path: \.calendarValue, to: timerEndDate)
                .changing(path: \.selectedMode, to: $0.currentMode == .off ? .off : .manual)
        }
    }
    
    func editTimerCancel() {
        updateView { $0.changing(path: \.editTime, to: false) }
    }
    
    private func handleData(_ channel: SAChannel, _ config: SuplaChannelHvacConfig) {
        SALog.debug("Handle data")
        let currentDate = dateProvider.currentDate()
        let timerEndDate = channel.getTimerEndDate()
        let isTimerOn = timerEndDate != nil && timerEndDate!.timeIntervalSince1970 > currentDate.timeIntervalSince1970
        
        guard let configMinTemperature = config.temperatures.roomMin,
              let configMaxTemperature = config.temperatures.roomMax,
              let thermostatValue = channel.value?.asThermostatValue()
        else { return }
        
        updateView {
            $0.changing(path: \.remoteId, to: channel.remote_id)
                .changing(path: \.currentMode, to: thermostatValue.mode)
                .changing(path: \.currentDate, to: currentDate)
                .changing(path: \.calendarValue, to: currentDate.shift(days: 7))
                .changing(path: \.isTimerOn, to: isTimerOn)
                .changing(path: \.isChannelOnline, to: channel.isOnline())
                .changing(path: \.timerEndDate, to: isTimerOn ? timerEndDate : nil)
            
                .changing(path: \.subfunction, to: thermostatValue.subfunction)
                .changing(path: \.minTemperature, to: configMinTemperature.fromSuplaTemperature())
                .changing(path: \.maxTemperature, to: configMaxTemperature.fromSuplaTemperature())
                .changing(path: \.currentTemperature, to: getSetpointTemperature(channel, thermostatValue))
                .changing(path: \.usingHeatSetpoint, to: useHeatSetpoint(channel, thermostatValue))
                .changing(path: \.loadingState, to: $0.loadingState.copy(loading: false))
        }
    }
    
    private func getSetpointTemperature(_ channel: SAChannel, _ thermostatValue: ThermostatValue) -> Float? {
        switch (channel.func) {
        case SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            return thermostatValue.setpointTemperatureHeat
            
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT:
            switch (thermostatValue.subfunction) {
            case .heat:
                return thermostatValue.setpointTemperatureHeat
            case .cool:
                return thermostatValue.setpointTemperatureCool
            default:
                return nil
            }
            
        default:
            return nil
        }
    }
    
    private func useHeatSetpoint(_ channel: SAChannel, _ thermostatValue: ThermostatValue) -> Bool {
        channel.func == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER ||
        (channel.func == SUPLA_CHANNELFNC_HVAC_THERMOSTAT && thermostatValue.subfunction == .heat)
    }
}

enum ThermostatTimerDetailViewEvent: ViewEvent {
    
}

struct ThermostatTimerDetailViewState: ViewState {
    var remoteId: Int32? = nil
    var currentMode: SuplaHvacMode? = nil
    var currentDate: Date? = nil
    var channelFunction: Int32? = nil
    var subfunction: ThermostatSubfunction? = nil
    var minTemperature: Float? = nil
    var maxTemperature: Float? = nil
    var currentTemperature: Float? = nil
    var usingHeatSetpoint: Bool = false
    
    var selectedMode: TimerDetailDeviceMode = .off
    var isTimerOn: Bool = false
    var isChannelOnline: Bool = false
    var editTime: Bool = false
    var showCalendar: Bool = false
    
    var calendarValue: Date? = nil
    var pickerValue: TrippleNumberSelectorView.Value = .init(valueForDays: 3 * HOUR_IN_SEC)
    var timerEndDate: Date? = nil
    
    var loadingState: LoadingState = LoadingState()
    
    var currentTemperatureText: String {
        get {
            @Singleton<ValuesFormatter> var formatter
            return formatter.temperatureToString(currentTemperature, withUnit: false)
        }
    }
    
    var timerInfoText: String {
        get {
            guard let timeDiff = getTimerDuration(date: currentDate)
            else { return "" }
            
            let days = timeDiff.days
            let hours = timeDiff.hoursInDay
            let minutes = timeDiff.minutesInHour
            
            let daysString = if (days == 1 ) {
                Strings.TimerDetail.dayPattern.arguments(days)
            } else {
                Strings.TimerDetail.daysPattern.arguments(days)
            }
            let hoursString = if (hours == 1 ) {
                Strings.TimerDetail.hourPattern.arguments(hours)
            } else {
                Strings.TimerDetail.hoursPattern.arguments(hours)
            }
            let minutesString = Strings.TimerDetail.minutePattern.arguments(minutes)
            let timeString = "\(daysString) \(hoursString) \(minutesString)"
            
            switch (selectedMode) {
            case .off:
                return Strings.TimerDetail.infoThermostatOff.arguments(timeString)
            case .manual:
                if (channelFunction == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER || subfunction == .heat) {
                    return Strings.TimerDetail.infoThermostatHeating.arguments(timeString)
                } else {
                    return Strings.TimerDetail.infoThermostatCooling.arguments(timeString)
                }
            }
        }
    }
    
    var minDate: Date? {
        currentDate
    }
    
    var maxDate: Date? {
        if let currentDate = currentDate {
            return currentDate.shift(days: 365)
        }
        return nil
    }
    
    var startEnabled: Bool {
        isChannelOnline && getTimerDuration(date: Date()) ?? 0 > 0
    }
    
    var setpointType: SetpointType? {
        if (channelFunction == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER || subfunction == .heat) {
            return .heat
        } else {
            return .cool
        }
    }
    
    var endDateText: String { DeviceState.endDateText(timerEndDate) }
    
    var currentStateIcon: UIImage? { DeviceState.currentStateIcon(currentMode) }
    
    var currentStateIconColor: UIColor { DeviceState.currentStateIconColor(currentMode) }
    
    var currentStateValue: String {
        DeviceState.currentStateValue(
            currentMode,
            heatSetpoint: currentTemperature,
            coolSetpoint: currentTemperature
        )
    }
    
    func getTimerDuration(date: Date?) -> Int? {
        if (showCalendar) {
            guard let currentDate = date,
                  let calendarDate = calendarValue
            else { return nil }
            
            if (calendarDate.timeIntervalSince1970 < currentDate.timeIntervalSince1970) {
                return nil
            } else {
                return calendarDate.differenceInSeconds(currentDate)
            }
        } else {
            return pickerValue.toDaysInSec()
        }
    }
}

