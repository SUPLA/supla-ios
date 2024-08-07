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

class SwitchTimerDetailVM: BaseViewModel<SwitchTimerDetailViewState, SwitchTimerDetailViewEvent>, DeviceStateHelperVMI {
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<StartTimerUseCase> private var startTimerUseCase
    @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleAxtionUseCase
    @Singleton<DateProvider> private var dateProvider
    
    override func defaultViewState() -> SwitchTimerDetailViewState { SwitchTimerDetailViewState() }
    
    func loadChannel(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] in self?.handleChannel(channel: $0) })
            .disposed(by: self)
    }
    
    func startTimer(remoteId: Int32, action: TimerTargetAction, durationInSecs: Int) {
        startTimerUseCase.invoke(remoteId: remoteId, turnOn: action == .turnOn, durationInSecs: Int32(durationInSecs))
            .subscribe(onError: { [weak self] in self?.handleStartTimerError(error: $0) })
            .disposed(by: self)
    }
    
    func stopTimer(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { [weak self] in
                guard let self = self else { return Observable.just(()) }
                return self.doAbort(remoteId: remoteId, turnOn: $0.value?.hiValue() ?? 0 > 0)
            }
            .asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    func cancelTimer(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { [weak self] in
                guard let self = self else { return Observable.just(()) }
                return self.doAbort(remoteId: remoteId, turnOn: $0.value?.hiValue() ?? 0 == 0)
            }
            .asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    func startEditMode() {
        updateView() { $0.changing(path: \.editMode, to: true) }
    }
    
    func stopEditMode() {
        updateView() { $0.changing(path: \.editMode, to: false) }
    }
    
    func calculateProgressViewData(startTime: Date, endTime: Date) -> ProgressViewData? {
        let leftTime = endTime.timeIntervalSince(dateProvider.currentDate())
        if (leftTime < 0) {
            return nil
        }
        
        let wholeTime = endTime.timeIntervalSince(startTime)
        return ProgressViewData(
            progres: 1 - leftTime / wholeTime,
            leftTimeValues: TimeValues.from(time: leftTime + 1)
        )
    }
    
    private func doAbort(remoteId: Int32, turnOn: Bool) -> Observable<Void> {
        executeSimpleAxtionUseCase.invoke(
            action: turnOn ? .turnOn : .turnOff,
            type: .channel,
            remoteId: remoteId
        )
    }
    
    private func handleChannel(channel: SAChannel) {
        updateView { state in
            let deviceState = createDeviceState(from: channel)
            var editMode = state.editMode
            if (editMode && deviceState.timerEndDate != nil) {
                // To avoid screen blinking, edit mode is canceled when new timer values will come
                editMode = false
            }
            var targetAction = state.targetAction
            if (targetAction == nil) {
                targetAction = deviceState.isOn ? .turnOff : .turnOn
            }
            
            return state
                .changing(path: \.deviceState, to: deviceState)
                .changing(path: \.editMode, to: editMode)
                .changing(path: \.targetAction, to: targetAction)
        }
    }
    
    private func handleStartTimerError(error: Error) {
        if (error is StartTimerUseCaseImpl.InvalidTimeError) {
            send(event: .showInvalidTime)
        }
    }
}

enum SwitchTimerDetailViewEvent: ViewEvent {
    case showInvalidTime
}

struct SwitchTimerDetailViewState: ViewState {
    var deviceState: DeviceStateViewState? = nil
    var editMode: Bool = false
    var targetAction: TimerTargetAction? = nil
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
        TimeValues (hours: Int(time/3600), minutes: Int((time / 60)) % 60, seconds: Int(time) % 60)
    }
}
