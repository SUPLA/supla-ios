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
import SwiftUI

private let REFRESH_DELAY_S: Double = 3

extension ThermostatScheduleDetailFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<DelayedWeeklyScheduleConfigSubject> private var dealyedWeeklyScheduleConfigSubject
        @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
        @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
        @Singleton<DeviceConfigEventsManager> private var deviceConfigEventsManager
        @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
        @Singleton<GetDeviceConfigUseCase> private var getDeviceConfigUseCase
        @Singleton<GlobalSettings> private var globalSettings
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<DateProvider> private var dateProvider
        
        private let reloadConfigRelay = PublishRelay<Void>()
        private let item: ItemBundle
        
        init(item: ItemBundle) {
            self.item = item
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            state.showHelp = globalSettings.shouldShowThermostatScheduleInfo
        }
        
        func onProgramTap(_ program: ScheduleDetailProgram) {
            let suplaProgram = program.scheduleProgram.program
            state.activeProgram = suplaProgram == state.activeProgram ? nil : suplaProgram
        }
        
        func onBoxTap(_ key: ScheduleDetailBoxKey) {
            guard let activeProgram = state.activeProgram else { return }
            
            var schedule = state.schedule
            schedule[key] = ThermostatScheduleDetailBoxValue(oneProgram: activeProgram)
            state.schedule = schedule
            state.changing = true
            
            publishChanges()
        }
        
        func onBoxTapFinished() {
            guard state.activeProgram != nil else { return }
            
            state.changing = false
            state.lastInteractionTime = dateProvider.currentTimestamp()
        }
        
        func onShowQuartersDialog(_ key: ScheduleDetailBoxKey) {
            if let hourPrograms = state.schedule[key] {
                state.editQuartersState = EditQuartersState(
                    key: key,
                    programs: state.programs,
                    activeProgram: state.activeProgram,
                    hourPrograms: hourPrograms
                )
            }
        }
        
        // MARK: - Program Dialog
        
        func onShowProgramDialog(_ program: ScheduleDetailProgram) {
            guard let configMin = state.configMin,
                  let configMax = state.configMax,
                  program.scheduleProgram.mode != .off
            else { return }
            
            let heatTemperature = state.temperature(setpointType: .heat, program.scheduleProgram)
            let coolTemperature = state.temperature(setpointType: .cool, program.scheduleProgram)
            
            state.editProgramState = EditProgramState(
                program: program.scheduleProgram.program,
                modes: SelectableList(selected: program.scheduleProgram.mode, items: state.availableModes),
                temperatureUnit: globalSettings.temperatureUnit,
                heatSetpoint: heatTemperature?.let {
                    SetpointData(
                        plusDisabled: $0 >= configMax,
                        minusDisabled: $0 <= configMin,
                        valueCorrect: $0 >= configMin && $0 <= configMax,
                        value: state.temperatureString($0)
                    )
                },
                coolSetpoint: coolTemperature?.let {
                    SetpointData(
                        plusDisabled: $0 >= configMax,
                        minusDisabled: $0 <= configMin,
                        valueCorrect: $0 >= configMin && $0 <= configMax,
                        value: state.temperatureString($0)
                    )
                }
            )
        }
        
        func onProgramDialogDismiss() {
            state.editProgramState = nil
        }
        
        func onProgramDialogChange(_ setpointType: SetpointType, _ value: String) {
            guard let configMin = state.configMin,
                  let configMax = state.configMax else { return }

            if (value.isEmpty) {
                state.editProgramState = state.editProgramState?.copy(
                    setpointType: setpointType,
                    plusDisabled: false,
                    minusDisabled: true,
                    valueCorrect: false
                )
            }
            
            if let valueAsFloat = value.toFloat() {
                state.editProgramState = state.editProgramState?.copy(
                    setpointType: setpointType,
                    plusDisabled: valueAsFloat >= configMax,
                    minusDisabled: valueAsFloat <= configMin,
                    valueCorrect: valueAsFloat >= configMin && valueAsFloat <= configMax
                )
            } else {
                state.editProgramState = state.editProgramState?.copy(
                    setpointType: setpointType,
                    plusDisabled: true,
                    minusDisabled: true,
                    valueCorrect: false
                )
            }
        }
        
        func onProgramDialogModeChange(_ mode: SuplaHvacMode) {
            state.editProgramState = state.editProgramState?.copy(modes: state.editProgramState?.modes.changing(path: \.selected, to: mode))
        }
        
        func onProgramDialogPlus(_ setpointType: SetpointType, _ value: String) {
            guard let configMin = state.configMin,
                  let configMax = state.configMax
            else { return }
            
            if (value.isEmpty) {
                let temperatureString = SharedCore.DefaultValueFormatter.format(configMin)
                state.editProgramState = state.editProgramState?.copy(
                    setpointType: setpointType,
                    plusDisabled: configMin >= configMax,
                    minusDisabled: true,
                    valueCorrect: true,
                    updateValue: temperatureString
                )
            } else {
                let temperature = (value.toFloat() ?? 0) + 0.1
                let temperatureString = SharedCore.DefaultValueFormatter.format(temperature)
                
                state.editProgramState = state.editProgramState?.copy(
                    setpointType: setpointType,
                    plusDisabled: temperature >= configMax,
                    minusDisabled: temperature <= configMin,
                    valueCorrect: temperature >= configMin && temperature <= configMax,
                    updateValue: temperatureString
                )
            }
        }
        
        func onProgramDialogMinus(_ setpointType: SetpointType, _ value: String) {
            guard let configMin = state.configMin,
                  let configMax = state.configMax else { return }
            
            let temperature = (value.toFloat() ?? 0) - 0.1
            let temperatureString = SharedCore.DefaultValueFormatter.format(temperature)
            
            state.editProgramState = state.editProgramState?.copy(
                setpointType: setpointType,
                plusDisabled: temperature >= configMax,
                minusDisabled: temperature <= configMin,
                valueCorrect: temperature >= configMin && temperature <= configMax,
                updateValue: temperatureString
            )
        }
        
        func onProgramDialogSave(_ heatValue: String, _ coolValue: String) {
            guard let programState = state.editProgramState,
                  let program = state.programs.first(where: { $0.scheduleProgram.program == programState.program })
            else { return }
            
            let updatedProgram: SuplaWeeklyScheduleProgram? =
                switch (programState.modes.selected) {
                case .heat:
                    program.scheduleProgram.copy(
                        mode: .heat,
                        newHeatTemperature: heatValue.toFloat()?.toSuplaTemperature(),
                    )
                case .cool:
                    program.scheduleProgram.copy(
                        mode: .cool,
                        newCoolTemperature: coolValue.toFloat()?.toSuplaTemperature()
                    )
                case .heatCool:
                    program.scheduleProgram.copy(
                        mode: .heatCool,
                        newHeatTemperature: heatValue.toFloat()?.toSuplaTemperature(),
                        newCoolTemperature: coolValue.toFloat()?.toSuplaTemperature()
                    )
                default: nil
                }
            
            if let updatedProgram {
                state.programs = state.programs.map {
                    if ($0.scheduleProgram.program == programState.program) {
                        $0.changing(path: \.scheduleProgram, to: updatedProgram)
                    } else {
                        $0
                    }
                }
            }
            state.activeProgram = programState.program
            state.editProgramState = nil
            
            publishChanges()
        }
        
        // MARK: - Quarters Dialog
        
        func onQuartersDialogDismiss() {
            state.editQuartersState = nil
        }
        
        func onQuartersDialogProgramChange(_ program: SuplaScheduleProgram) {
            state.activeProgram = program
            state.editQuartersState = state.editQuartersState?.withActiveProgram(program)
        }
        
        func onQuartersDialogQuarterChange(_ quarter: QuarterOfHour) {
            guard let editQuartersState = state.editQuartersState,
                  let activeProgram = editQuartersState.activeProgram
            else { return }
            
            let newHourPrograms = editQuartersState.hourPrograms.withQuarterProgram(quarter, activeProgram)
            state.editQuartersState = editQuartersState.withHourPrograms(newHourPrograms)
        }
        
        func onQuartersDialogSave() {
            guard let editQuarterState = state.editQuartersState else { return }
            var schedule = state.schedule
            schedule[editQuarterState.key] = editQuarterState.hourPrograms
            state.schedule = schedule
            state.editQuartersState = nil
            
            publishChanges()
        }
        
        // MARK: - Data loading
        
        func observeConfig() {
            Observable.combineLatest(
                channelConfigEventsManager.observeConfig(id: item.remoteId)
                    .filter { $0.config is SuplaChannelWeeklyScheduleConfig },
                channelConfigEventsManager.observeConfig(id: item.remoteId)
                    .filter { $0.config is SuplaChannelHvacConfig },
                deviceConfigEventsManager.observeConfig(id: item.deviceId),
                resultSelector: { ($0.config as! SuplaChannelWeeklyScheduleConfig, $0.result, $1.config as! SuplaChannelHvacConfig, $1.result, $2.config) }
            )
            .asDriverWithoutError()
            .debounce(.milliseconds(50))
            .drive(onNext: { [weak self] in self?.onConfigLoaded(configs: $0) })
            .disposed(by: disposeBag)
            
            reloadConfigRelay
                .subscribe(on: schedulers.background)
                .asDriverWithoutError()
                .debounce(.seconds(1))
                .drive(onNext: { [weak self] _ in self?.triggerConfigLoad() })
                .disposed(by: disposeBag)
            
            triggerConfigLoad()
            getDeviceConfigUseCase.invoke(deviceId: item.deviceId)
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        private func triggerConfigLoad() {
            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .defaultConfig).subscribe().disposed(by: disposeBag)
            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .weeklyScheduleConfig).subscribe().disposed(by: disposeBag)
        }
        
        private func onConfigLoaded(configs: (SuplaChannelWeeklyScheduleConfig, SuplaConfigResult, SuplaChannelHvacConfig, SuplaConfigResult, SuplaDeviceConfig)) {
            SALog.debug("Thermostat schedule detail got data: `\(configs)`")
            let weeklyScheduleConfig = configs.0
            let weeklyScheduleResult = configs.1
            let hvacConfig = configs.2
            let hvacResult = configs.3
            
            if (weeklyScheduleResult != .resultTrue || hvacResult != .resultTrue) {
                SALog.info("Got unsuccessfull result (schedule: \(weeklyScheduleResult), hvac: \(hvacResult))")
                return
            }
            
            guard let configMin = hvacConfig.minTemperature,
                  let configMax = hvacConfig.maxTemperature,
                  !state.changing
            else { return }
            
            if let lastInteractionTime = state.lastInteractionTime,
               lastInteractionTime + REFRESH_DELAY_S >= dateProvider.currentTimestamp()
            {
                reloadConfigRelay.accept(())
                return
            }
            
            state.channelFunction = hvacConfig.channelFunc
            state.thermostatSubfunction = hvacConfig.subfunction
            state.programs = weeklyScheduleConfig.viewProgramsList()
            state.configMin = configMin
            state.configMax = configMax
            state.schedule = weeklyScheduleConfig.viewScheduleBoxes()
            
            if (configs.4.isAutomaticTimeSyncDisabled() == false) {
                let date = dateProvider.currentDate()
                let calendar = Calendar.current
                state.currentDay = DayOfWeek.from(value: UInt8(calendar.component(.weekday, from: date) - 1))
                state.currentHour = calendar.component(.hour, from: date)
            }
            
            if (hvacConfig.subfunction == .notSet) {
                loadSubfunction(hvacConfig.remoteId)
            }
        }
        
        private func publishChanges() {
            dealyedWeeklyScheduleConfigSubject.emit(
                data: WeeklyScheduleConfigData(
                    remoteId: item.remoteId,
                    programs: state.suplaPrograms,
                    schedule: state.suplaSchedule
                )
            )
        }
        
        private func loadSubfunction(_ remoteId: Int32) {
            readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] channel in
                    self?.state.thermostatSubfunction = channel.value?.asThermostatValue().subfunction
                })
                .disposed(by: disposeBag)
        }
    }
}

private extension String {
    func toFloat() -> Float? {
        Float(replacingOccurrences(of: ",", with: "."))
    }
}

struct ScheduleDetailProgram: Equatable, Changeable, Identifiable {
    var id: UInt8 { scheduleProgram.program.rawValue }
    
    var scheduleProgram: SuplaWeeklyScheduleProgram
    var icon: String? = nil
    
    var text: String { scheduleProgram.description }
    
    func buttonState(_ activeProgram: SuplaScheduleProgram?) -> ScheduleProgramButtonState {
        if (scheduleProgram.program == activeProgram) {
            .active(color: scheduleProgram.program.color, label: text, icon: icon)
        } else {
            .default(color: scheduleProgram.program.color, label: text, icon: icon)
        }
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
    
    func viewScheduleBoxes() -> [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] {
        var result: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [:]
        
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
                var value = ThermostatScheduleDetailBoxValue(oneProgram: .off)
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
