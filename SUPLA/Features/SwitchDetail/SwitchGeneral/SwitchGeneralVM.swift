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

class SwitchGeneralVM: BaseViewModel<SwitchGeneralViewState, SwitchGeneralViewEvent>, DeviceStateHelperVMI {
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<GetChannelBaseStateUseCase> private var getChannelBaseStateUseCase
    @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleActionUseCase
    @Singleton<DateProvider> private var dateProvider
    
    override func defaultViewState() -> SwitchGeneralViewState { SwitchGeneralViewState() }
    
    func loadChannel(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { channel in
                self.updateView() { $0.changing(path: \.deviceState, to: self.createDeviceState(from: channel)) }
            })
            .disposed(by: self)
    }
    
    func turnOn(remoteId: Int32) {
        performAction(action: .turn_on, remoteId: remoteId)
    }
    
    func turnOff(remoteId: Int32) {
        performAction(action: .turn_off, remoteId: remoteId)
    }

    private func performAction(action: Action, remoteId: Int32) {
        executeSimpleActionUseCase.invoke(action: action, type: .channel, remoteId: remoteId)
            .asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
}

enum SwitchGeneralViewEvent: ViewEvent {
}

struct SwitchGeneralViewState: ViewState {
    var deviceState: DeviceStateViewState? = nil
}

