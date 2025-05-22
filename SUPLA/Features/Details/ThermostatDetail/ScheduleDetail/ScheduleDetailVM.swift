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

private let REFRESH_DELAY_S: Double = 3
private let DEFAULT_HEAT_TEMPERATURE: Float = 21
private let DEFAULT_WATER_TEMPERATURE: Float = 40

class ScheduleDetailVM: BaseViewModel<ScheduleDetailViewState, ScheduleDetailViewEvent> {
    @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
    @Singleton<DeviceConfigEventsManager> private var deviceConfigEventsManager
    @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
    @Singleton<GetDeviceConfigUseCase> private var getDeviceConfigUseCase
    @Singleton<DelayedWeeklyScheduleConfigSubject> private var dealyedWeeklyScheduleConfigSubject
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<DateProvider> private var dateProvider
    @Singleton<SuplaSchedulers> private var schedulers
    @Singleton<GlobalSettings> private var globalSettings
    
    private let reloadConfigRelay = PublishRelay<Void>()
    
    override func defaultViewState() -> ScheduleDetailViewState { ScheduleDetailViewState() }
    
    override func onViewDidLoad() {
        updateView { $0.changing(path: \.showHelp, to: globalSettings.shouldShowThermostatScheduleInfo) }
    }
    
    func observeConfig(remoteId: Int32, deviceId: Int32) {
        Observable.combineLatest(
            channelConfigEventsManager.observeConfig(id: remoteId)
                .filter { $0.config is SuplaChannelWeeklyScheduleConfig },
            channelConfigEventsManager.observeConfig(id: remoteId)
                .filter { $0.config is SuplaChannelHvacConfig },
            deviceConfigEventsManager.observeConfig(id: deviceId),
            resultSelector: { ($0.config as! SuplaChannelWeeklyScheduleConfig, $0.result, $1.config as! SuplaChannelHvacConfig, $1.result, $2.config) }
        )
        .asDriverWithoutError()
        .debounce(.milliseconds(50))
        .drive(onNext: { [weak self] in self?.onConfigLoaded(configs: $0) })
        .disposed(by: self)
        
        reloadConfigRelay
            .subscribe(on: schedulers.background)
            .asDriverWithoutError()
            .debounce(.seconds(1))
            .drive(onNext: { [weak self] _ in self?.triggerConfigLoad(remoteId: remoteId) })
            .disposed(by: self)
        
        triggerConfigLoad(remoteId: remoteId)
        getDeviceConfigUseCase.invoke(deviceId: deviceId)
            .subscribe()
            .disposed(by: self)
    }
    
    func loadConfig() {
        reloadConfigRelay.accept(())
    }
    
    func onProgramTap(_ program: SuplaScheduleProgram) {
        updateView {
            $0.changing(path: \.activeProgram, to: $0.activeProgram == program ? nil : program)
        }
    }
    
    func onProgramLongPress(_ program: SuplaScheduleProgram) {
        if let state = currentState(),
           let configMin = state.configMin,
           let configMax = state.configMax,
           let program = state.programs.first(where: { $0.scheduleProgram.program == program }),
           let channelFunc = state.channelFunction,
           let subfunction = state.thermostatSubfunction
        {
            let isHeat = channelFunc == SUPLA_CHANNELFNC_HVAC_THERMOSTAT && subfunction == .heat
            let isCool = channelFunc == SUPLA_CHANNELFNC_HVAC_THERMOSTAT && subfunction == .cool
            let heatTemperature = state.alignTemperature(program.scheduleProgram.setpointTemperatureHeat?.fromSuplaTemperature())
            let coolTemperature = state.alignTemperature(program.scheduleProgram.setpointTemperatureCool?.fromSuplaTemperature())
            
            let programState = EditProgramDialogViewState(
                program: program.scheduleProgram.program,
                mode: program.scheduleProgram.mode,
                setpointTemperatureHeat: heatTemperature,
                setpointTemperatureCool: coolTemperature,
                heatTemperatureText: heatTemperature.toTemperatureString(),
                coolTemperatureText: coolTemperature.toTemperatureString(),
                showHeatEdit: isHeat || channelFunc == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER,
                showCoolEdit: isCool,
                configMin: configMin,
                configMax: configMax,
                heatPlusActive: heatTemperature < configMax,
                heatMinusActive: heatTemperature > configMin,
                coolPlusActive: coolTemperature < configMax,
                coolMinusActive: coolTemperature > configMin
            )
            send(event: .editProgram(state: programState))
        }
    }
    
    func onBoxEvent(_ event: PanningEvent) {
        switch (event) {
        case .panning(let boxKey):
            boxTap(boxKey)
        case .finished:
            if (currentState()?.activeProgram != nil) {
                updateView {
                    $0.changing(path: \.changing, to: false)
                        .changing(path: \.lastInteractionTime, to: dateProvider.currentTimestamp())
                }
            }
        }
    }
    
    func onBoxLongPress(_ key: ScheduleDetailBoxKey) {
        if let currentState = currentState(),
           let programs = currentState.schedule[key]
        {
            let state = EditQuartersDialogViewState(
                key: key,
                activeProgram: currentState.activeProgram,
                availablePrograms: currentState.programs,
                quarterPrograms: programs
            )
            send(event: .editScheduleBox(state: state))
        }
    }
    
    func onQuartersChanged(key: ScheduleDetailBoxKey, value: ScheduleDetailBoxValue, activeProgram: SuplaScheduleProgram?) {
        updateView { state in
            var schedule = state.schedule
            schedule[key] = value
            
            return publishChanges(
                state
                    .changing(path: \.schedule, to: schedule)
                    .changing(path: \.activeProgram, to: activeProgram)
                    .changing(path: \.lastInteractionTime, to: dateProvider.currentTimestamp())
            )
        }
    }
    
    func onProgramChanged(_ program: SuplaWeeklyScheduleProgram) {
        updateView { state in
            let programs = state.programs.map { $0.scheduleProgram.program == program.program ? $0.changing(path: \.scheduleProgram, to: program) : $0 }
            return publishChanges(
                state.changing(path: \.programs, to: programs)
                    .changing(path: \.activeProgram, to: program.program)
                    .changing(path: \.lastInteractionTime, to: dateProvider.currentTimestamp())
            )
        }
    }
    
    func onHelpClosed() {
        globalSettings.shouldShowThermostatScheduleInfo = false
        updateView { $0.changing(path: \.showHelp, to: false) }
    }
    
    private func triggerConfigLoad(remoteId: Int32) {
        getChannelConfigUseCase.invoke(remoteId: remoteId, type: .defaultConfig).subscribe().disposed(by: self)
        getChannelConfigUseCase.invoke(remoteId: remoteId, type: .weeklyScheduleConfig).subscribe().disposed(by: self)
    }
    
    private func onConfigLoaded(configs: (SuplaChannelWeeklyScheduleConfig, SuplaConfigResult, SuplaChannelHvacConfig, SuplaConfigResult, SuplaDeviceConfig)) {
        SALog.debug("Schedule detail got data: `\(configs)`")
        let weeklyScheduleConfig = configs.0
        let weeklyScheduleResult = configs.1
        let hvacConfig = configs.2
        let hvacResult = configs.3
        
        if (weeklyScheduleResult != .resultTrue || hvacResult != .resultTrue) {
            SALog.info("Got unsuccessfull result (schedule: \(weeklyScheduleResult), hvac: \(hvacResult))")
            return
        }
        guard let configMin = hvacConfig.minTemperature,
              let configMax = hvacConfig.maxTemperature
        else { return }
        
        updateView { state in
            if (state.changing) {
                return state // Do not change anything, when user makes manual operations
            }
            if let lastInteractionTime = state.lastInteractionTime,
               lastInteractionTime + REFRESH_DELAY_S >= dateProvider.currentTimestamp()
            {
                reloadConfigRelay.accept(())
                return state // Do not change anything during 3 secs after last user interaction
            }
            
            return state
                .changing(path: \.channelFunction, to: hvacConfig.channelFunc)
                .changing(path: \.thermostatSubfunction, to: hvacConfig.subfunction)
                .changing(path: \.remoteId, to: hvacConfig.remoteId)
                .changing(path: \.programs, to: weeklyScheduleConfig.viewProgramsList())
                .changing(path: \.configMin, to: configMin)
                .changing(path: \.configMax, to: configMax)
                .changing(path: \.schedule, to: weeklyScheduleConfig.viewScheduleBoxes())
                .changing(path: \.showDayIndicator, to: !configs.4.isAutomaticTimeSyncDisabled())
        }
        
        if (hvacConfig.subfunction == .notSet) {
            loadSubfunction(hvacConfig.remoteId)
        }
    }
    
    private func boxTap(_ key: ScheduleDetailBoxKey) {
        if let state = currentState(),
           let activeProgram = state.activeProgram
        {
            return updateView { state in
                var schedule = state.schedule
                schedule[key] = ScheduleDetailBoxValue(oneProgram: activeProgram)
                return publishChanges(
                    state.changing(path: \.schedule, to: schedule)
                        .changing(path: \.changing, to: true)
                )
            }
        }
    }
    
    private func publishChanges(_ state: ScheduleDetailViewState) -> ScheduleDetailViewState {
        guard let remoteId = state.remoteId else { return state }
        dealyedWeeklyScheduleConfigSubject.emit(
            data: WeeklyScheduleConfigData(
                remoteId: remoteId,
                programs: state.suplaPrograms(),
                schedule: state.suplaSchedule()
            )
        )
        
        return state
    }
    
    private func loadSubfunction(_ remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] channel in
                self?.updateView {
                    $0.changing(
                        path: \.thermostatSubfunction,
                        to: channel.value?.asThermostatValue().subfunction
                    )
                }
            })
            .disposed(by: self)
    }
}

// MARK: - Event & State

enum ScheduleDetailViewEvent: ViewEvent {
    case editProgram(state: EditProgramDialogViewState)
    case editScheduleBox(state: EditQuartersDialogViewState)
}

struct ScheduleDetailViewState: ViewState {
    var channelFunction: Int32? = nil
    var thermostatSubfunction: ThermostatSubfunction? = nil
    var remoteId: Int32? = nil
    var activeProgram: SuplaScheduleProgram? = nil
    var schedule: [ScheduleDetailBoxKey: ScheduleDetailBoxValue] = [:]
    var programs: [ScheduleDetailProgram] = []
    var configMin: Float? = nil
    var configMax: Float? = nil
    
    var lastInteractionTime: TimeInterval? = nil
    var changing: Bool = false
    
    var showDayIndicator: Bool = true
    var showHelp: Bool = false
    
    func alignTemperature(_ temperature: Float?) -> Float {
        let temperatureToAlign = temperature
            ?? (channelFunction == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER ? DEFAULT_WATER_TEMPERATURE : DEFAULT_HEAT_TEMPERATURE)
        
        if let configMin, let configMax {
            if (temperatureToAlign < configMin) {
                return configMin
            } else if (temperatureToAlign > configMax) {
                return configMax
            } else {
                return temperatureToAlign
            }
        }
        
        return temperatureToAlign
    }
}

struct ScheduleDetailProgram: Equatable, Changeable {
    var scheduleProgram: SuplaWeeklyScheduleProgram
    var icon: String? = nil
    
    var text: String { scheduleProgram.description }
}

struct ScheduleDetailBoxKey: Equatable, Hashable {
    let dayOfWeek: DayOfWeek
    let hour: Int
}

struct ScheduleDetailBoxValue: Equatable {
    var firstQuarterProgram: SuplaScheduleProgram
    var secondQuarterProgram: SuplaScheduleProgram
    var thirdQuarterProgram: SuplaScheduleProgram
    var fourthQuarterProgram: SuplaScheduleProgram
    
    var hasSingleProgram: Bool {
        return firstQuarterProgram == secondQuarterProgram
            && secondQuarterProgram == thirdQuarterProgram
            && thirdQuarterProgram == fourthQuarterProgram
    }
    
    init(_ first: SuplaScheduleProgram, _ second: SuplaScheduleProgram, _ third: SuplaScheduleProgram, _ fourth: SuplaScheduleProgram) {
        firstQuarterProgram = first
        secondQuarterProgram = second
        thirdQuarterProgram = third
        fourthQuarterProgram = fourth
    }
    
    init(oneProgram: SuplaScheduleProgram) {
        firstQuarterProgram = oneProgram
        secondQuarterProgram = oneProgram
        thirdQuarterProgram = oneProgram
        fourthQuarterProgram = oneProgram
    }
}

private extension SuplaChannelWeeklyScheduleConfig {
    func viewProgramsList() -> [ScheduleDetailProgram] {
        var result: [ScheduleDetailProgram] = []
        
        for program in programConfigurations {
            result.append(ScheduleDetailProgram(
                scheduleProgram: program,
                icon: getProgramIcon(program)
            ))
        }
        
        result.append(ScheduleDetailProgram(
            scheduleProgram: SuplaWeeklyScheduleProgram.OFF,
            icon: SuplaHvacMode.off.icon
        ))
        
        return result
    }
    
    func viewScheduleBoxes() -> [ScheduleDetailBoxKey: ScheduleDetailBoxValue] {
        var result: [ScheduleDetailBoxKey: ScheduleDetailBoxValue] = [:]
        
        for entry in schedule {
            let key = ScheduleDetailBoxKey(dayOfWeek: entry.dayOfWeek, hour: Int(entry.hour))
            
            if var value = result[key] {
                switch (entry.quarterOfHour) {
                case .first: value.firstQuarterProgram = entry.program
                case .second: value.secondQuarterProgram = entry.program
                case .third: value.thirdQuarterProgram = entry.program
                case .fourth: value.fourthQuarterProgram = entry.program
                }
                result[key] = value
            } else {
                var value = ScheduleDetailBoxValue(oneProgram: .off)
                switch (entry.quarterOfHour) {
                case .first: value.firstQuarterProgram = entry.program
                case .second: value.secondQuarterProgram = entry.program
                case .third: value.thirdQuarterProgram = entry.program
                case .fourth: value.fourthQuarterProgram = entry.program
                }
                result[key] = value
            }
        }
        
        return result
    }
    
    private func getProgramIcon(_ program: SuplaWeeklyScheduleProgram) -> String? {
        if (channelFunc == SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL) {
            return program.mode.icon
        }
        
        return nil
    }
}

private extension ScheduleDetailViewState {
    func suplaPrograms() -> [SuplaWeeklyScheduleProgram] {
        var result: [SuplaWeeklyScheduleProgram] = []
        
        for program in programs {
            if (program.scheduleProgram.program != .off) {
                result.append(program.scheduleProgram)
            }
        }
        
        return result
    }
    
    func suplaSchedule() -> [SuplaWeeklyScheduleEntry] {
        var result: [SuplaWeeklyScheduleEntry] = []
        
        for entry in schedule {
            result.append(
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: entry.key.dayOfWeek,
                    hour: UInt8(entry.key.hour),
                    quarterOfHour: .first,
                    program: entry.value.firstQuarterProgram
                )
            )
            result.append(
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: entry.key.dayOfWeek,
                    hour: UInt8(entry.key.hour),
                    quarterOfHour: .second,
                    program: entry.value.secondQuarterProgram
                )
            )
            result.append(
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: entry.key.dayOfWeek,
                    hour: UInt8(entry.key.hour),
                    quarterOfHour: .third,
                    program: entry.value.thirdQuarterProgram
                )
            )
            result.append(
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: entry.key.dayOfWeek,
                    hour: UInt8(entry.key.hour),
                    quarterOfHour: .fourth,
                    program: entry.value.fourthQuarterProgram
                )
            )
        }
        
        return result
    }
}
