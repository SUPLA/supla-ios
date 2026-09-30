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

extension RelayScheduleFeature {
    final class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<DelayedWeeklyScheduleConfigSubject> var delayedWeeklyScheduleConfigSubject
        @Singleton<DateProvider> private var dateProvider
        @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
        @Singleton<DeviceConfigEventsManager> private var deviceConfigEventsManager
        @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
        @Singleton<GetDeviceConfigUseCase> private var getDeviceConfigUseCase
        @Singleton<SuplaSchedulers> private var schedulers

        private let reloadRelay = PublishRelay<Void>()
        private let item: ItemBundle

        init(item: ItemBundle) {
            self.item = item
            super.init(state: ViewState())
        }

        override func onViewCreated() {
            observeConfig()
        }

        func onProgramTap(_ program: WeeklyScheduleProgram) {
            guard program.program == .off || state.programs.first(where: { $0.program == program.program })?.mode.isProgramMode == true else { return }
            state.activeProgram = state.activeProgram == program.program ? nil : program.program
        }

        func onProgramLongPress(_ program: WeeklyScheduleProgram) {
            guard let relayProgram = state.programs.first(where: { $0.program == program.program }), relayProgram.program != .off else { return }
            state.programSettings = ProgramSettings(
                program: relayProgram.program,
                mode: relayProgram.mode.isProgramMode ? relayProgram.mode : .startOn,
                duration: String(relayProgram.modeDurationS),
                oppositeDuration: String(relayProgram.oppositeModeDurationS)
            )
        }

        func onBoxTap(_ key: ScheduleDetailBoxKey) {
            guard let activeProgram = state.activeProgram else { return }
            var schedule = state.schedule
            schedule[key] = WeeklyScheduleBoxValue(oneProgram: activeProgram)
            state.schedule = schedule
            state.changing = true
            emitChanges()
        }

        func onBoxTapFinished() {
            guard state.activeProgram != nil else { return }
            state.changing = false
            state.lastInteractionTime = dateProvider.currentTimestamp()
        }

        func onShowQuarters(_ key: ScheduleDetailBoxKey) {
            guard let hourPrograms = state.schedule[key] else { return }
            state.quarters = QuartersState(key: key, programs: relayProgramsForView(state.programs), activeProgram: state.activeProgram, hourPrograms: hourPrograms)
        }

        func onQuartersDismiss() { state.quarters = nil }

        func onQuartersProgramChange(_ program: SuplaScheduleProgram) {
            state.activeProgram = program
            state.quarters?.activeProgram = program
        }

        func onQuartersChange(_ quarter: QuarterOfHour) {
            guard let activeProgram = state.quarters?.activeProgram else { return }
            guard let quarters = state.quarters else { return }
            quarters.hourPrograms = quarters.hourPrograms.withQuarterProgram(quarter, activeProgram)
        }

        func onQuartersSave() {
            guard let quarters = state.quarters else { return }
            state.schedule[quarters.key] = quarters.hourPrograms
            state.quarters = nil
            state.lastInteractionTime = dateProvider.currentTimestamp()
            emitChanges()
        }

        func onProgramSettingsDismiss() { state.programSettings = nil }
        func onProgramSettingsModeChange(_ mode: SuplaRelayMode) {
            guard state.programSettings?.availableModes.contains(mode) == true else { return }
            state.programSettings?.mode = mode
        }
        func onProgramSettingsDurationChange(_ value: String) { updateDuration(.relayMode, value: value) }
        func onProgramSettingsOppositeDurationChange(_ value: String) { updateDuration(.oppositeMode, value: value) }
        func onProgramSettingsDurationMinus(_ duration: ProgramDuration) { changeDuration(duration, by: -1) }
        func onProgramSettingsDurationPlus(_ duration: ProgramDuration) { changeDuration(duration, by: 1) }

        func onProgramSettingsSave() {
            guard let settings = state.programSettings,
                  let current = state.programs.first(where: { $0.program == settings.program }) else { return }
            let updated = current.copy(
                mode: settings.mode,
                modeDurationS: UInt16(settings.duration) ?? 0,
                oppositeModeDurationS: UInt16(settings.oppositeDuration) ?? 0
            )
            state.programs = state.programs.map {
                $0.program == updated.program ? updated : $0
            }
            state.activeProgram = updated.program
            state.programSettings = nil
            state.lastInteractionTime = dateProvider.currentTimestamp()
            emitChanges()
        }

        private func changeDuration(_ duration: ProgramDuration, by change: Int) {
            guard let settings = state.programSettings else { return }
            let current = switch duration {
            case .relayMode: Int(settings.duration) ?? 0
            case .oppositeMode: Int(settings.oppositeDuration) ?? 0
            }
            updateDuration(duration, value: String(min(max(current + change, 0), Int(UInt16.max))))
        }

        private func updateDuration(_ duration: ProgramDuration, value: String) {
            guard value.allSatisfy(\.isNumber), value.isEmpty || UInt16(value) != nil else { return }
            switch duration {
            case .relayMode: state.programSettings?.duration = value
            case .oppositeMode: state.programSettings?.oppositeDuration = value
            }
        }

        private func observeConfig() {
            Observable.combineLatest(
                channelConfigEventsManager.observeConfig(id: item.remoteId)
                    .filter { $0.config is SuplaChannelWeeklyScheduleConfig },
                deviceConfigEventsManager.observeConfig(id: item.deviceId),
                resultSelector: { ($0.config as! SuplaChannelWeeklyScheduleConfig, $0.result, $1.config) }
            )
            .asDriverWithoutError()
            .debounce(.milliseconds(50))
            .drive(onNext: { [weak self] config, result, deviceConfig in
                self?.onConfigLoaded(config, result: result, deviceConfig: deviceConfig)
            })
            .disposed(by: disposeBag)

            reloadRelay
                .subscribe(on: schedulers.background)
                .asDriverWithoutError()
                .debounce(.seconds(1))
                .drive(onNext: { [weak self] _ in self?.triggerConfigLoad() })
                .disposed(by: disposeBag)

            triggerConfigLoad()
            getDeviceConfigUseCase.invoke(deviceId: item.deviceId).subscribe().disposed(by: disposeBag)
        }

        private func triggerConfigLoad() {
            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .weeklyScheduleConfig).subscribe().disposed(by: disposeBag)
        }

        private func onConfigLoaded(_ config: SuplaChannelWeeklyScheduleConfig, result: SuplaConfigResult, deviceConfig: SuplaDeviceConfig?) {
            guard result == .resultTrue, !state.changing else { return }
            if let last = state.lastInteractionTime, last + 3 >= dateProvider.currentTimestamp() {
                reloadRelay.accept(())
                return
            }

            guard let relayPrograms = config.programConfigurations.relayPrograms else { return }
            state.programs = relayPrograms
            state.schedule = config.viewWeeklyScheduleBoxes()
            if deviceConfig?.isAutomaticTimeSyncDisabled() == false {
                let date = dateProvider.currentDate()
                let calendar = Calendar.current
                state.currentDay = DayOfWeek.from(value: UInt8(calendar.component(.weekday, from: date) - 1))
                state.currentHour = calendar.component(.hour, from: date)
            }
        }

        private func emitChanges() {
            delayedWeeklyScheduleConfigSubject.emit(data: WeeklyScheduleConfigData(
                remoteId: item.remoteId,
                programs: .relay(state.programs.filter { $0.program != .off }),
                schedule: state.schedule.flatMap { (key, value) in value.suplaScheduleEntries(key) }
            ))
        }
    }

    final class ViewState: ObservableObject {
        @Published var programs: [SuplaRelayWeeklyScheduleProgram] = []
        @Published var activeProgram: SuplaScheduleProgram?
        @Published var schedule: [ScheduleDetailBoxKey: WeeklyScheduleBoxValue] = [:]
        @Published var currentDay: DayOfWeek?
        @Published var currentHour: Int?
        @Published var changing = false
        @Published var lastInteractionTime: TimeInterval?
        @Published var quarters: QuartersState?
        @Published var programSettings: ProgramSettings?
    }

    final class QuartersState: ObservableObject {
        let key: ScheduleDetailBoxKey
        let programs: [WeeklyScheduleProgram]
        @Published var activeProgram: SuplaScheduleProgram?
        @Published var hourPrograms: WeeklyScheduleBoxValue
        init(key: ScheduleDetailBoxKey, programs: [WeeklyScheduleProgram], activeProgram: SuplaScheduleProgram?, hourPrograms: WeeklyScheduleBoxValue) {
            self.key = key; self.programs = programs; self.activeProgram = activeProgram; self.hourPrograms = hourPrograms
        }
    }

    final class ProgramSettings: ObservableObject {
        let program: SuplaScheduleProgram
        @Published var mode: SuplaRelayMode
        @Published var duration: String
        @Published var oppositeDuration: String
        init(program: SuplaScheduleProgram, mode: SuplaRelayMode, duration: String, oppositeDuration: String) {
            self.program = program; self.mode = mode; self.duration = duration; self.oppositeDuration = oppositeDuration
        }
        var availableModes: [SuplaRelayMode] { [.startOn, .startOff, .forcedOn, .forcedOff, .automatic] }
        var showsDurations: Bool { mode == .startOn || mode == .startOff }
    }
}

private extension SuplaChannelWeeklyScheduleConfig {
    func viewWeeklyScheduleBoxes() -> [ScheduleDetailBoxKey: WeeklyScheduleBoxValue] {
        var result: [ScheduleDetailBoxKey: WeeklyScheduleBoxValue] = [:]
        for entry in schedule {
            let key = ScheduleDetailBoxKey(dayOfWeek: entry.dayOfWeek, hour: Int(entry.hour))
            var value = result[key] ?? WeeklyScheduleBoxValue(oneProgram: .off)
            value = value.withQuarterProgram(entry.quarterOfHour, entry.program)
            result[key] = value
        }
        return result
    }
}

private extension SuplaRelayMode {
    var isProgramMode: Bool {
        switch self {
        case .startOn, .startOff, .forcedOn, .forcedOff, .automatic: true
        case .notSet, .cmdWeeklySchedule, .cmdSwitchToManual: false
        }
    }
}

private extension WeeklyScheduleBoxValue {
    func suplaScheduleEntries(_ key: ScheduleDetailBoxKey) -> [SuplaWeeklyScheduleEntry] {
        QuarterOfHour.allCases.map {
            SuplaWeeklyScheduleEntry(dayOfWeek: key.dayOfWeek, hour: UInt8(key.hour), quarterOfHour: $0, program: programForQuarter($0))
        }
    }
}
