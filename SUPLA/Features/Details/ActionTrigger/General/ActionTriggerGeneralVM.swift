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
import SharedCore

extension ActionTriggerGeneralFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<ObserveChannelWithChildren.UseCase> private var observeChannelWithChildrenUseCase
        @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
        @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
        @Singleton<DeviceConfigEventsManager> private var deviceConfigEventsManager
        @Singleton<GetDeviceConfigUseCase> private var getDeviceConfigUseCase
        @Singleton<ExecuteSimpleAction.UseCase> private var executeSimpleActionUseCase
        @Singleton<ExecuteActionTriggerActionUseCase.UseCase> private var executeActionTriggerActionUseCase
        @Singleton<DateProvider> private var dateProvider
        @Singleton<ValuesFormatter> private var valuesFormatter
        @Singleton<SuplaSchedulers> private var schedulers
        
        private let itemBundle: ItemBundle
        private var currentMode: SuplaButtonMode = .notSet
        private var temporaryUnlockActive: Bool = false
        private var currentTemporaryUnlockDurationS: Int?
        private var defaultTemporaryUnlockDurationS = 0

        init(itemBundle: ItemBundle) {
            self.itemBundle = itemBundle
            super.init(state: ViewState())
        }

        override func onViewCreated() {
            let channel = observeChannelWithChildrenUseCase.invoke(remoteId: itemBundle.remoteId)
            let weeklySchedule = channelConfigEventsManager.observeConfig(id: itemBundle.remoteId)
                .filter { $0.result == .resultTrue && $0.config is SuplaChannelWeeklyScheduleConfig }
                .map { $0.config as? SuplaChannelWeeklyScheduleConfig }
                .startWith(nil as SuplaChannelWeeklyScheduleConfig?)
            let actionTriggerConfig = channelConfigEventsManager.observeConfig(id: itemBundle.remoteId)
                .filter { $0.result == .resultTrue && $0.config is SuplaChannelActionTriggerConfig }
                .map { $0.config as? SuplaChannelActionTriggerConfig }
                .startWith(nil as SuplaChannelActionTriggerConfig?)
            let deviceConfig = observeDeviceConfig()
            let refresh = Observable<Int>.interval(.seconds(60), scheduler: schedulers.main).startWith(0)

            Observable.combineLatest(channel, weeklySchedule, actionTriggerConfig, deviceConfig, refresh) { channel, schedule, actionTrigger, device, _ in
                (channel, schedule, actionTrigger, device)
            }
            .observe(on: schedulers.main)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] channel, schedule, actionTrigger, device in
                let timeSyncDisabled = device.flatMap {
                    $0.availableFields.contains(.automaticTimeSync) ? $0.isAutomaticTimeSyncDisabled() : nil
                } ?? false
                self?.handleData(
                    channel: channel,
                    schedule: schedule,
                    actionTriggerConfig: actionTrigger,
                    timeSyncDisabled: timeSyncDisabled
                )
            })
            .disposed(by: disposeBag)

            getChannelConfigUseCase.invoke(remoteId: itemBundle.remoteId, type: .weeklyScheduleConfig).subscribe().disposed(by: disposeBag)
            getChannelConfigUseCase.invoke(remoteId: itemBundle.remoteId, type: .defaultConfig).subscribe().disposed(by: disposeBag)
            if itemBundle.deviceId != 0 {
                getDeviceConfigUseCase.invoke(deviceId: itemBundle.deviceId).subscribe().disposed(by: disposeBag)
            }
        }

        func onManual() {
            perform(.switchToManualMode)
        }
        
        func onWeekly() {
            perform(.switchToProgramMode)
        }
        
        func onAuto() {}
        
        func onLock() {
            guard currentMode != .locked,
                  currentMode != .lockedTemporaryUnlockAllowed || temporaryUnlockActive
            else { return }
            
            if (currentMode == .lockedTemporaryUnlockAllowed) {
                execute(.lockedTemporaryUnlockAllowed)
            } else {
                execute(.locked)
            }
        }
        
        func onUnlock() {
            guard currentMode == .lockedTemporaryUnlockAllowed else {
                execute(.notSet)
                return
            }

            let duration = currentTemporaryUnlockDurationS ?? defaultTemporaryUnlockDurationS
            state.unlockDialogDurationS = duration.clamped(to: 0...64_800)
            state.unlockTemporaryAllowed = duration > 0
            state.unlockDialogPresented = true
        }
        
        func onAllowTemporaryUnlockChanged(_ allow: Bool) {
            execute(allow ? .lockedTemporaryUnlockAllowed : .locked)
        }

        func onUnlockDialogDurationChange(_ duration: Int) {
            let duration = duration.clamped(to: 0...64_800)
            state.unlockDialogDurationS = duration
            state.unlockTemporaryAllowed = duration > 0
        }

        func onUnlockDialogDismiss() {
            state.unlockDialogPresented = false
        }

        func onUnlockDialogUnlock() {
            execute(.notSet)
            onUnlockDialogDismiss()
        }

        func onUnlockDialogTemporaryUnlock() {
            execute(.cmdTemporaryUnlock, durationSec: Int32(state.unlockDialogDurationS))
            onUnlockDialogDismiss()
        }

        private func perform(_ action: ActionId) {
            executeSimpleActionUseCase.invoke(action: action, type: .channel, remoteId: itemBundle.remoteId)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
        
        private func execute(_ mode: SuplaButtonMode, durationSec: Int32? = nil) {
            executeActionTriggerActionUseCase.invoke(type: .channel, remoteId: itemBundle.remoteId, mode: mode, durationSec: durationSec)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
        
        private func observeDeviceConfig() -> Observable<SuplaDeviceConfig?> {
            guard itemBundle.deviceId != 0 else { return .just(nil) }
            return deviceConfigEventsManager.observeConfig(id: itemBundle.deviceId)
                .filter { $0.result == .resultTrue }
                .map { $0.config }
                .startWith(nil as SuplaDeviceConfig?)
        }
        
        private func handleData(
            channel value: ChannelWithChildren,
            schedule: SuplaChannelWeeklyScheduleConfig?,
            actionTriggerConfig: SuplaChannelActionTriggerConfig?,
            timeSyncDisabled: Bool
        ) {
            let channel = value.channel
            let atValue = channel.value?.asActionTriggerValue()
            let weekly = atValue?.flags.contains(.weeklyScheduleEnabled) == true
            let lockedMode = atValue?.buttonMode == .locked || atValue?.buttonMode == .lockedTemporaryUnlockAllowed
            
            currentMode = atValue?.buttonMode ?? .notSet
            defaultTemporaryUnlockDurationS = Int(actionTriggerConfig?.temporaryUnlockDurationSec ?? 0)
            currentTemporaryUnlockDurationS = weekly ? currentProgramTemporaryUnlockDuration(schedule) : nil
            temporaryUnlockActive = atValue?.temporaryUnlockActive == true
            
            if channel.status().offline {
                state.channelCurrentStateData = .init(
                    label: "\(Strings.ActionTrigger.scheduleButtonMode):",
                    icon: nil,
                    value: Strings.SwitchDetail.stateOffline
                )
            } else if weekly {
                state.channelCurrentStateData = nil
            } else {
                state.channelCurrentStateData = .init(
                    label: "\(Strings.ActionTrigger.scheduleButtonMode):",
                    icon: nil,
                    value: currentModeLabel(atValue?.buttonMode ?? .notSet, temporaryUnlockActive: temporaryUnlockActive)
                )
            }
            state.channelProgramState = programState(
                schedule,
                !channel.status().offline,
                weekly,
                temporaryUnlockActive,
                timeSyncDisabled
            )
            state.online = !channel.status().offline
            state.showLockButtons = channel.flags & Int64(SUPLA_CHANNEL_FLAG_BUTTON_MODE_SUPPORTED) != 0
            state.lockActive = lockedMode && !temporaryUnlockActive
            state.unlockActive = !lockedMode || temporaryUnlockActive
            state.lockButtonDisabled = weekly
            state.unlockButtonDisabled = weekly && atValue?.buttonMode != .lockedTemporaryUnlockAllowed
            state.temporaryUnlockActive = temporaryUnlockActive
            state.showAllowTemporaryUnlock = channel.flags & Int64(SUPLA_CHANNEL_FLAG_BUTTON_TEMPORARY_UNLOCK_SUPPORTED) != 0 && lockedMode
            state.allowTemporaryUnlock = atValue?.buttonMode == .lockedTemporaryUnlockAllowed
            state.allowTemporaryUnlockDisabled = weekly
            state.manualAllowed = true
            state.weeklyAllowed = channel.flags & Int64(SUPLA_CHANNEL_FLAG_WEEKLY_SCHEDULE) != 0
            state.weeklyActive = weekly
            state.manualActive = !weekly
        }

        private func programState(
            _ schedule: SuplaChannelWeeklyScheduleConfig?,
            _ online: Bool,
            _ weeklyActive: Bool,
            _ temporaryUnlockActive: Bool,
            _ timeSyncDisabled: Bool
        ) -> [ChannelProgramState.Data] {
            guard online, weeklyActive, let schedule, !schedule.schedule.isEmpty else { return [] }
            
            let minute = dateProvider.currentMinute()
            let day = dateProvider.currentDayOfWeek()
            let hour = dateProvider.currentHour()
            let quarter = QuarterOfHour.from(minute: minute)
            guard let index = schedule.schedule.firstIndex(where: {
                $0.dayOfWeek == day && Int($0.hour) == hour && $0.quarterOfHour == quarter
            }) else {
                return []
            }
            
            let currentProgram = schedule.schedule[index].program
            guard let scheduledCurrentDescription = programDescription(currentProgram, schedule: schedule) else { return [] }
            let currentDescription = temporaryUnlockActive && currentProgram != .off
                ? Strings.ActionTrigger.temporaryUnlocked
                : scheduledCurrentDescription
            
            let (nextDescription, quartersToNext) = nextProgram(after: index, current: currentProgram, schedule: schedule)
            let current = ChannelProgramState.Data(
                label: Strings.ThermostatDetail.programCurrent,
                description: currentDescription,
                time: timeSyncDisabled || temporaryUnlockActive || nextDescription == nil ? nil : Strings.ThermostatDetail.programTime.arguments(
                    valuesFormatter.minutesToString(minutes: quartersToNext * 15 + (15 - minute % 15))
                )
            )
            guard !timeSyncDisabled, let nextDescription else { return [current] }
            return [current, ChannelProgramState.Data(label: Strings.ThermostatDetail.programNext, description: nextDescription)]
        }

        private func nextProgram(after index: Int, current: SuplaScheduleProgram, schedule: SuplaChannelWeeklyScheduleConfig) -> (String?, Int) {
            var quarters = 0
            for offset in 1...schedule.schedule.count {
                let program = schedule.schedule[(index + offset) % schedule.schedule.count].program
                if program != current {
                    return (programDescription(program, schedule: schedule), quarters)
                }
                quarters += 1
            }
            return (nil, quarters)
        }

        private func programDescription(_ program: SuplaScheduleProgram, schedule: SuplaChannelWeeklyScheduleConfig) -> String? {
            if program == .off { return Strings.General.unlocked }
            return schedule.programConfigurations.buttonPrograms?.first { $0.program == program }?.description
        }

        private func currentModeLabel(_ mode: SuplaButtonMode, temporaryUnlockActive: Bool) -> String {
            switch mode {
            case .locked:
                Strings.General.locked
            case .notSet:
                Strings.General.unlocked
            case .lockedTemporaryUnlockAllowed:
                temporaryUnlockActive ? Strings.ActionTrigger.temporaryUnlocked : Strings.General.locked
            case .cmdWeeklySchedule, .cmdSwitchToManual, .cmdTemporaryUnlock:
                NO_VALUE_TEXT
            default:
                NO_VALUE_TEXT
            }
        }

        private func currentProgramTemporaryUnlockDuration(_ schedule: SuplaChannelWeeklyScheduleConfig?) -> Int? {
            guard let schedule,
                  let entry = schedule.schedule.first(where: {
                      $0.dayOfWeek == dateProvider.currentDayOfWeek() &&
                          Int($0.hour) == dateProvider.currentHour() &&
                          $0.quarterOfHour == QuarterOfHour.from(minute: dateProvider.currentMinute())
                  }),
                  let program = schedule.programConfigurations.buttonPrograms?.first(where: { $0.program == entry.program })
            else { return nil }

            return Int(program.buttonTemporaryUnlockDurationS)
        }
    }
}
