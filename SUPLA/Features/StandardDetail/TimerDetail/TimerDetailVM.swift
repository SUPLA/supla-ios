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

class TimerDetailVM: BaseViewModel<TimerDetailViewState, TimerDetailViewEvent>, DeviceStateHelperVMI {
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<GetChannelBaseStateUseCase> private var getChannelBaseStateUseCase
    @Singleton<StartTimerUseCase> private var startTimerUseCase
    @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleAxtionUseCase
    @Singleton<DateProvider> private var dateProvider
    
    override func defaultViewState() -> TimerDetailViewState { TimerDetailViewState() }
    
    func loadChannel(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { channel in
                self.updateView() { $0.changing(path: \.deviceState, to: self.createDeviceState(from: channel)) }
            })
            .disposed(by: self)
    }
    
    func startTimer(remoteId: Int32, action: TimerTargetAction, durationInSecs: Int) {
        startTimerUseCase.invoke(remoteId: remoteId, turnOn: action == .turnOn, durationInSecs: Int32(durationInSecs))
            .subscribe(
                onError: { error in
                    if (error is StartTimerUseCaseImpl.InvalidTimeError) {
                        NSLog("Invalid time")
                    }
                }
            )
            .disposed(by: self)
    }
    
    func stopTimer(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { self.doAbort(remoteId: remoteId, turnOn: $0.value?.hiValue() ?? 0 >= 0) }
            .asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    func cancelTimer(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { self.doAbort(remoteId: remoteId, turnOn: $0.value?.hiValue() ?? 0 == 0) }
            .asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    private func doAbort(remoteId: Int32, turnOn: Bool) -> Observable<Void> {
        executeSimpleAxtionUseCase.invoke(
            action: turnOn ? .turn_on : .turn_off,
            type: .channel,
            remoteId: remoteId
        )
    }
}

enum TimerDetailViewEvent: ViewEvent {
}

struct TimerDetailViewState: ViewState {
    var deviceState: DeviceStateViewState? = nil
}
