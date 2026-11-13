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

private let allowedButtonModes: [SuplaButtonMode] = [.notSet, .locked, .lockedTemporaryUnlockAllowed]

extension ActionTriggerScheduleFeature {
    final class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<DelayedWeeklyScheduleConfigSubject> private var delayedWeeklyScheduleConfigSubject
        @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
        @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
        @Singleton<DeviceConfigEventsManager> private var deviceConfigEventsManager
        @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
        @Singleton<GetDeviceConfigUseCase> private var getDeviceConfigUseCase
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<DateProvider> private var dateProvider

        private let reloadRelay = PublishRelay<Void>()
        private let item: ItemBundle
        private var defaultTemporaryUnlockDurationS = 0

        init(item: ItemBundle) { self.item = item; super.init(state: ViewState()) }
        override func onViewCreated() { observeConfig() }

        func onProgramTap(_ program: WeeklyScheduleProgram) {
            guard program.program == .off || state.programs.first(where: { $0.program == program.program && allowedButtonModes.contains($0.mode) }) != nil else { return }
            state.activeProgram = state.activeProgram == program.program ? nil : program.program
        }

        func onProgramLongPress(_ program: WeeklyScheduleProgram) {
            guard let current = state.programs.first(where: { $0.program == program.program }), current.program != .off else { return }
            state.programSettings = AtProgramSettings.State(
                program: current.program,
                mode: current.mode,
                duration: Int(current.buttonTemporaryUnlockDurationS),
                defaultDuration: defaultTemporaryUnlockDurationS
            )
        }

        func onBoxTap(_ key: ScheduleDetailBoxKey) {
            guard let active = state.activeProgram else { return }
            state.schedule[key] = WeeklyScheduleBoxValue(oneProgram: active)
            state.changing = true
            emitChanges()
        }

        func onBoxTapFinished() {
            guard state.activeProgram != nil else { return }
            state.changing = false
            state.lastInteractionTime = dateProvider.currentTimestamp()
        }

        func onShowQuarters(_ key: ScheduleDetailBoxKey) {
            guard let value = state.schedule[key] else { return }
            state.quarters = QuartersSelectionData(
                key: key,
                programs: actionTriggerProgramsForView(state.programs),
                activeProgram: state.activeProgram,
                hourPrograms: value
            )
        }

        func onQuartersDismiss() {
            state.quarters = nil
        }

        func onQuartersProgramChange(_ program: SuplaScheduleProgram) {
            state.activeProgram = program
            state.quarters?.activeProgram = program
        }

        func onQuartersChange(_ quarter: QuarterOfHour) {
            guard let quarters = state.quarters,
                  let active = quarters.activeProgram
            else { return }

            quarters.hourPrograms = quarters.hourPrograms.withQuarterProgram(quarter, active)
        }

        func onQuartersSave() {
            guard let q = state.quarters else { return }
            state.schedule[q.key] = q.hourPrograms
            state.quarters = nil
            state.lastInteractionTime = dateProvider.currentTimestamp()
            emitChanges()
        }

        func onProgramSettingsDismiss() {
            state.programSettings = nil
        }

        func onProgramSettingsModeChange(_ mode: SuplaButtonMode) {
            guard allowedButtonModes.contains(mode) else { return }
            state.programSettings?.mode = mode
        }

        func onProgramSettingsDurationOptionChange(_ option: AtProgramSettings.DurationOption) {
            state.programSettings?.selectDurationOption(option)
        }

        func onProgramSettingsDurationChange(_ value: Int) {
            state.programSettings?.updateDuration(value)
        }

        func onProgramSettingsSave() {
            guard let settings = state.programSettings,
                  let current = state.programs.first(where: { $0.program == settings.program })
            else { return }

            let updated = current.copy(mode: settings.mode, buttonTemporaryUnlockDurationS: UInt16(settings.selectedDuration))
            state.programs = state.programs.map { $0.program == updated.program ? updated : $0 }
            state.activeProgram = updated.program
            state.programSettings = nil
            state.lastInteractionTime = dateProvider.currentTimestamp()
            emitChanges()
        }

        private func observeConfig() {
            let actionTriggerConfig = channelConfigEventsManager.observeConfig(id: item.remoteId)
                .filter { $0.result == .resultTrue && $0.config is SuplaChannelActionTriggerConfig }
                .map { $0.config as? SuplaChannelActionTriggerConfig }
                .startWith(nil as SuplaChannelActionTriggerConfig?)

            Observable.combineLatest(
                channelConfigEventsManager.observeConfig(id: item.remoteId).filter { $0.config is SuplaChannelWeeklyScheduleConfig },
                actionTriggerConfig,
                deviceConfigEventsManager.observeConfig(id: item.deviceId),
                readChannelByRemoteIdUseCase.invoke(remoteId: item.remoteId),
                resultSelector: { ($0.config as! SuplaChannelWeeklyScheduleConfig, $0.result, $1, $2.config, $3) }
            )
            .asDriverWithoutError()
            .debounce(.milliseconds(50))
            .drive(onNext: { [weak self] config, result, actionTrigger, device, channel in
                self?.onConfigLoaded(config, result: result, actionTriggerConfig: actionTrigger, deviceConfig: device, channel: channel)
            })
            .disposed(by: disposeBag)

            reloadRelay.subscribe(on: schedulers.background)
                .asDriverWithoutError()
                .debounce(.seconds(1))
                .drive(onNext: { [weak self] _ in self?.triggerConfigLoad() })
                .disposed(by: disposeBag)

            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .weeklyScheduleConfig)
                .subscribe()
                .disposed(by: disposeBag)
            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .defaultConfig)
                .subscribe()
                .disposed(by: disposeBag)
            getDeviceConfigUseCase.invoke(deviceId: item.deviceId)
                .subscribe()
                .disposed(by: disposeBag)
        }

        private func triggerConfigLoad() {
            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .weeklyScheduleConfig)
                .subscribe()
                .disposed(by: disposeBag)
            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .defaultConfig)
                .subscribe()
                .disposed(by: disposeBag)
        }

        private func onConfigLoaded(_ config: SuplaChannelWeeklyScheduleConfig, result: SuplaConfigResult, actionTriggerConfig: SuplaChannelActionTriggerConfig?, deviceConfig: SuplaDeviceConfig?, channel: SAChannel) {
            defaultTemporaryUnlockDurationS = ActionTriggerTemporaryUnlockDuration.clamp(Int(actionTriggerConfig?.temporaryUnlockDurationSec ?? 0))
            guard result == .resultTrue, !state.changing else { return }

            if let last = state.lastInteractionTime, last + 3 >= dateProvider.currentTimestamp() {
                reloadRelay.accept(())
                return
            }

            guard let programs = config.programConfigurations.buttonPrograms else { return }

            state.programs = programs
            state.schedule = config.viewWeeklyScheduleBoxes()
            if deviceConfig?.isAutomaticTimeSyncDisabled() == false {
                let date = dateProvider.currentDate()
                state.currentDay = DayOfWeek.from(value: UInt8(Calendar.current.component(.weekday, from: date) - 1))
                state.currentHour = Calendar.current.component(.hour, from: date)
            } else {
                state.currentDay = nil; state.currentHour = nil
            }
        }

        private func emitChanges() {
            delayedWeeklyScheduleConfigSubject.emit(
                data: WeeklyScheduleConfigData(
                    remoteId: item.remoteId,
                    programs: .actionTrigger(state.programs.filter { $0.program != .off }),
                    schedule: state.schedule.flatMap { $0.value.suplaScheduleEntries($0.key) }
                )
            )
        }
    }

}

private extension SuplaChannelWeeklyScheduleConfig {
    func viewWeeklyScheduleBoxes() -> [ScheduleDetailBoxKey: WeeklyScheduleBoxValue] {
        var result: [ScheduleDetailBoxKey: WeeklyScheduleBoxValue] = [:]
        for entry in schedule {
            let key = ScheduleDetailBoxKey(dayOfWeek: entry.dayOfWeek, hour: Int(entry.hour))
            result[key] = (result[key] ?? WeeklyScheduleBoxValue(oneProgram: .off)).withQuarterProgram(entry.quarterOfHour, entry.program)
        }
        return result
    }
}

private extension WeeklyScheduleBoxValue {
    func suplaScheduleEntries(_ key: ScheduleDetailBoxKey) -> [SuplaWeeklyScheduleEntry] {
        QuarterOfHour.allCases.map { SuplaWeeklyScheduleEntry(dayOfWeek: key.dayOfWeek, hour: UInt8(key.hour), quarterOfHour: $0, program: programForQuarter($0)) }
    }
}

func actionTriggerProgramsForView(_ programs: [SuplaButtonWeeklyScheduleProgram]) -> [WeeklyScheduleProgram] {
    programs.map { WeeklyScheduleProgram(program: $0) } + [WeeklyScheduleProgram(program: SuplaButtonWeeklyScheduleProgram.default(), label: Strings.Schedule.programDefault)]
}
