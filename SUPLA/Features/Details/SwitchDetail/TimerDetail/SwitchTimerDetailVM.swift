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
import SwiftUI

final class SwitchTimerDetailVM: SuplaCore.ViewModel<SwitchTimerDetailFeature.ViewState>, SwitchTimerDetailFeature.ViewDelegate {
    @Singleton<ObserveChannelWithChildren.UseCase> private var observeChannelWithChildrenUseCase
    @Singleton<StartTimerUseCase> private var startTimerUseCase
    @Singleton<ExecuteSimpleAction.UseCase> private var executeSimpleActionUseCase
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<ObserveRelayProgramState.UseCase> private var observeRelayProgramStateUseCase
    @Singleton<DateProvider> private var dateProvider
    @Singleton<RuntimeConfig> private var runtimeConfig

    private let remoteId: Int32

    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(state: SwitchTimerDetailFeature.ViewState())

        state.setTimeInSeconds(runtimeConfig.getLastTimerValue(remoteId: remoteId))
    }

    override func onViewAppear() {
        let channel = observeChannelWithChildrenUseCase.invoke(remoteId: remoteId)
        let programState = observeRelayProgramStateUseCase.invoke(remoteId: remoteId)

        Observable.combineLatest(channel, programState)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] channelWithChildren, programState in
                self?.handleChannel(channelWithChildren.channel, programState: programState)
            })
            .disposedWhenDisappear(by: self)
    }

    func onEditTimer() {
        if let timerEndDate = state.timerEndDate {
            state.setTimeInSeconds(Int(timerEndDate.timeIntervalSince(dateProvider.currentDate())))
        }
        state.editMode = true
    }

    func onStopTimer() {
        doAbort(turnOn: state.isOn)
            .asDriverWithoutError()
            .drive()
            .disposed(by: disposeBag)
    }

    func onCancelTimer() {
        doAbort(turnOn: !state.isOn)
            .asDriverWithoutError()
            .drive()
            .disposed(by: disposeBag)
    }

    func onTargetActionChange(_ action: TimerTargetAction) {
        state.targetAction = action
    }

    func onTimeChange(_ timeInSeconds: Int) {
        runtimeConfig.setLastTimerValue(remoteId: remoteId, value: timeInSeconds)
    }

    func onStartTimer() {
        guard state.isOnline == true, !state.timerStartDisabled else { return }

        startTimerUseCase.invoke(
            remoteId: remoteId,
            turnOn: state.targetAction == .turnOn,
            durationInSecs: Int32(state.timeInSeconds)
        )
        .subscribe(onError: { [weak self] error in
            if (error is StartTimerUseCaseImpl.InvalidTimeError) {
                self?.state.invalidTimeAlertPresented = true
            }
        })
        .disposed(by: disposeBag)

        state.editMode = false
    }

    func onCancelEditMode() {
        state.editMode = false
    }

    func onInvalidTimeAlertDismiss() {
        state.invalidTimeAlertPresented = false
    }

    func calculateProgressViewData(startTime: Date, endTime: Date) -> ProgressViewData? {
        let leftTime = endTime.timeIntervalSince(dateProvider.currentDate())
        if (leftTime < 0) { return nil }

        let wholeTime = endTime.timeIntervalSince(startTime)
        return ProgressViewData(
            progres: 1 - leftTime / wholeTime,
            leftTimeValues: TimeValues.from(time: leftTime + 1)
        )
    }

    private func handleChannel(_ channel: SAChannel, programState: [ChannelProgramState.Data]) {
        let value = channel.value?.asRelayValue()
        let isOn = value?.on ?? false
        let isOnline = value?.status.online ?? false
        
        let forced = value?.mode == .forcedOn || value?.mode == .forcedOff

        state.isOn = isOn
        state.isOnline = isOnline
        state.timerEndDate = channel.timerEndDate
        state.timerStartDate = channel.ev?.timerStartTime
        state.channelCurrentStateData = ChannelCurrentState.Data.from(channel, isOnline, isOn)
        state.timerStartDisabled = forced
        
        let weeklyScheduleEnabled = value?.flags.contains(.weeklyScheduleEnabled) == true
        state.channelProgramState = state.isOnline && weeklyScheduleEnabled && !forced && state.timerEndDate == nil ? programState : []
        state.channelProgramState = value?.showProgram(programState, state.timerEndDate) ?? []
    }

    private func doAbort(turnOn: Bool) -> Observable<Void> {
        executeSimpleActionUseCase.invoke(
            action: turnOn ? .turnOn : .turnOff,
            type: .channel,
            remoteId: remoteId
        )
    }
}

struct ProgressViewData {
    let progres: CGFloat
    let leftTimeValues: TimeValues
}

struct TimeValues {
    let hours: Int
    let minutes: Int
    let seconds: Int

    static func from(time: TimeInterval) -> TimeValues {
        TimeValues(hours: Int(time / 3600), minutes: Int(time / 60) % 60, seconds: Int(time) % 60)
    }
}
