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

struct ObserveRelayProgramState {
    protocol UseCase {
        func invoke(remoteId: Int32) -> Observable<[ChannelProgramState.Data]>
    }

    final class Implementation: UseCase {
        @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
        @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
        @Singleton<DateProvider> private var dateProvider
        @Singleton<ValuesFormatter> private var valuesFormatter

        func invoke(remoteId: Int32) -> Observable<[ChannelProgramState.Data]> {
            let weeklyScheduleConfig = channelConfigEventsManager.observeConfig(id: remoteId)
                .filter { $0.result == .resultTrue && $0.config is SuplaChannelWeeklyScheduleConfig }
                .compactMap { $0.config as? SuplaChannelWeeklyScheduleConfig }

            let refresh = Observable<Int>.interval(.seconds(60), scheduler: MainScheduler.instance)
                .startWith(0)

            let programState = Observable.combineLatest(weeklyScheduleConfig, refresh) { config, _ in config }
                .map { [weak self] config in self?.relayProgramState(from: config) ?? [] }

            return Observable.concat(
                .just([]),
                Observable.create { [weak self] observer in
                    guard let self else {
                        observer.onCompleted()
                        return Disposables.create()
                    }

                    let programStateDisposable = programState
                        .observe(on: MainScheduler.instance)
                        .subscribe(observer)
                    // Subscribing sends the config request; its response arrives through channelConfigEventsManager.
                    let configRequestDisposable = self.getChannelConfigUseCase
                        .invoke(remoteId: remoteId, type: .weeklyScheduleConfig)
                        .subscribe()

                    return Disposables.create(programStateDisposable, configRequestDisposable)
                }
            )
        }

        private func relayProgramState(from config: SuplaChannelWeeklyScheduleConfig) -> [ChannelProgramState.Data] {
            guard !config.schedule.isEmpty else { return [] }

            let minute = dateProvider.currentMinute()
            let currentDay = dateProvider.currentDayOfWeek()
            let currentHour = dateProvider.currentHour()
            let currentQuarter = QuarterOfHour.from(minute: minute)
            guard let currentEntryIndex = config.schedule.firstIndex(where: {
                $0.dayOfWeek == currentDay &&
                    Int($0.hour) == currentHour &&
                    $0.quarterOfHour == currentQuarter
            }) else { return [] }

            let currentProgram = config.schedule[currentEntryIndex].program
            guard let currentDescription = relayProgramDescription(currentProgram, config: config) else { return [] }

            var nextProgram: SuplaScheduleProgram?
            var quartersBeforeNextProgram = 0
            for offset in 1...config.schedule.count {
                let program = config.schedule[(currentEntryIndex + offset) % config.schedule.count].program
                if program != currentProgram {
                    nextProgram = program
                    break
                }
                quartersBeforeNextProgram += 1
            }

            let nextDescription = nextProgram.flatMap { relayProgramDescription($0, config: config) }
            let time = nextDescription.map { _ in
                Strings.ThermostatDetail.programTime.arguments(
                    valuesFormatter.minutesToString(minutes: quartersBeforeNextProgram * 15 + (15 - minute % 15))
                )
            }

            let current = ChannelProgramState.Data(
                label: Strings.ThermostatDetail.programCurrent,
                description: currentDescription,
                time: time
            )
            let next = nextDescription.map {
                ChannelProgramState.Data(label: Strings.ThermostatDetail.programNext, description: $0)
            }
            return [current] + (next.map { [$0] } ?? [])
        }

        private func relayProgramDescription(
            _ program: SuplaScheduleProgram,
            config: SuplaChannelWeeklyScheduleConfig
        ) -> String? {
            if program == .off {
                return Strings.General.turnOff
            }

            return config.programConfigurations.relayPrograms?
                .first(where: { $0.program == program })?
                .description
        }
    }
}
