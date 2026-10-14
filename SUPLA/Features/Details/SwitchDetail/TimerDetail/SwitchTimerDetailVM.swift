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

final class SwitchTimerDetailVM: SuplaCore.ViewModel<SwitchTimerDetailFeature.ViewState>, SwitchTimerDetailFeature.ViewDelegate, DeviceStateHelperVMI {
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
        if let timerEndDate = state.deviceState?.timerEndDate {
            state.setTimeInSeconds(Int(timerEndDate.timeIntervalSince(dateProvider.currentDate())))
        }
        state.editMode = true
    }

    func onStopTimer() {
        guard let deviceState = state.deviceState else { return }
        doAbort(turnOn: deviceState.isOn)
            .asDriverWithoutError()
            .drive()
            .disposed(by: disposeBag)
    }

    func onCancelTimer() {
        guard let deviceState = state.deviceState else { return }
        doAbort(turnOn: !deviceState.isOn)
            .asDriverWithoutError()
            .drive()
            .disposed(by: disposeBag)
    }

    func onTargetActionChange(_ action: TimerTargetAction) {
        guard state.deviceState != nil else { return }
        state.targetAction = action
    }

    func onTimeChange(_ timeInSeconds: Int) {
        runtimeConfig.setLastTimerValue(remoteId: remoteId, value: timeInSeconds)
    }

    func onStartTimer() {
        guard state.deviceState?.isOnline == true, !state.timerStartDisabled else { return }

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
        let deviceState = createDeviceState(from: channel)

        state.deviceState = deviceState
        state.channelCurrentStateData = createChannelCurrentStateData(from: deviceState)
        let relayValue = channel.value?.asRelayValue()
        let weeklyScheduleEnabled = relayValue?.flags.contains(.weeklyScheduleEnabled) == true
        let forced = relayValue?.mode == .forcedOn || relayValue?.mode == .forcedOff
        state.timerStartDisabled = forced
        state.channelProgramState = deviceState.isOnline && weeklyScheduleEnabled ? programState : []
    }

    private func doAbort(turnOn: Bool) -> Observable<Void> {
        executeSimpleActionUseCase.invoke(
            action: turnOn ? .turnOn : .turnOff,
            type: .channel,
            remoteId: remoteId
        )
    }

    private func createChannelCurrentStateData(from deviceState: DeviceStateViewState) -> ChannelCurrentState.Data {
        let label: String
        if let timerEndDate = deviceState.timerEndDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Strings.General.hourFormat
            label = .init(
                format: Strings.SwitchDetail.stateLabelForTimer,
                dateFormatter.string(from: timerEndDate)
            )
        } else {
            label = Strings.SwitchDetail.stateLabel
        }

        let value = if (!deviceState.isOnline) {
            Strings.SwitchDetail.stateOffline
        } else if (deviceState.isOn) {
            Strings.SwitchDetail.stateOn
        } else {
            Strings.SwitchDetail.stateOff
        }

        return ChannelCurrentState.Data(
            label: label,
            icon: getChannelBaseIconUseCase.invoke(iconData: deviceState.iconData),
            value: value
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
