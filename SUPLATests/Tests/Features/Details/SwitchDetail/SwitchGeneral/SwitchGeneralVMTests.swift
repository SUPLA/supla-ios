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
import RxTest
import XCTest

@testable import SUPLA

final class SwitchGeneralVMTest: SuplaCore.ViewModelTest<SwitchGeneralFeature.ViewState> {
    private lazy var viewModel: SwitchGeneralFeature.ViewModel! = SwitchGeneralFeature.ViewModel()
    
    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = ReadChannelWithChildrenUseCaseMock()
    private lazy var getChannelBaseStateUseCase: GetChannelBaseStateUseCaseMock! = GetChannelBaseStateUseCaseMock()
    private lazy var executeSimpleActionUseCase: ExecuteSimpleActionUseCaseMock! = ExecuteSimpleActionUseCaseMock()
    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    private lazy var suplaClientProvider: SuplaClientProviderMock! = SuplaClientProviderMock()
    private lazy var getChannelBaseIconUseCase: GetChannelBaseIconUseCaseMock! = GetChannelBaseIconUseCaseMock()
    
    override func setUp() {
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: GetChannelBaseStateUseCase.self, getChannelBaseStateUseCase!)
        DiContainer.shared.register(type: ExecuteSimpleActionUseCase.self, executeSimpleActionUseCase!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, getChannelBaseIconUseCase!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        readChannelWithChildrenUseCase = nil
        getChannelBaseStateUseCase = nil
        executeSimpleActionUseCase = nil
        dateProvider = nil
        suplaClientProvider = nil
        getChannelBaseIconUseCase = nil
        
        super.tearDown()
    }
    
    func test_loadChannel() {
        // given
        var suplaValue = TSuplaChannelValue_B()
        suplaValue.value = (1, 0, 1, 1, 1, 1, 1, 1)
        
        var suplaTimer = TTimerState_ExtendedValue()
        suplaTimer.CountdownEndsAt = 122
        
        var suplaExtendedValue = TSuplaChannelExtendedValue()
        suplaExtendedValue.type = CChar(EV_TYPE_TIMER_STATE_V1)
        suplaExtendedValue.size = UInt32(MemoryLayout<TTimerState_ExtendedValue>.size)
        _ = withUnsafeMutablePointer(to: &suplaExtendedValue.value) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<TTimerState_ExtendedValue>.size) { ptr in
                memcpy(ptr, &suplaTimer, MemoryLayout<TTimerState_ExtendedValue>.size)
            }
        }
        
        let startTime = Date()
        let value = SAChannelValue(testContext: nil)
        value.setValueWith(&suplaValue)
        value.online = SUPLA_CHANNEL_ONLINE_FLAG_ONLINE
        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.timerStartTime = startTime
        extendedValue.setValueWith(&suplaExtendedValue)
        let iconResult = IconResult.suplaIcon(name: .Icons.fncGpm1)
        
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_POWERSWITCH
        channel.value = value
        channel.ev = extendedValue
        
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        getChannelBaseStateUseCase.returns = ChannelState.opened
        dateProvider.currentTimestampReturns = .single(0)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)
        getChannelBaseIconUseCase.returns = iconResult
        
        // when
        viewModel.loadChannel(remoteId: 123)
        
        // then
        XCTAssertEqual(viewModel.state.issues, [])
        XCTAssertEqual(viewModel.state.online, true)
        XCTAssertEqual(viewModel.state.on, true)
        XCTAssertEqual(viewModel.state.stateLabel, "State until 12:02:02 AM:")
        XCTAssertEqual(viewModel.state.stateValue, "on")
        XCTAssertEqual(viewModel.state.stateIcon, iconResult)
        XCTAssertEqual(viewModel.state.onButtonState?.icon, iconResult)
        XCTAssertEqual(viewModel.state.offButtonState?.icon, iconResult)
        XCTAssertEqual(viewModel.state.showElectricityState, false)
        XCTAssertEqual(viewModel.state.showImpulseCounterState, false)
        XCTAssertNil(viewModel.state.alertDialogState)
        
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [123])
        XCTAssertEqual(getChannelBaseStateUseCase.parameters, [channel])
    }
    
    func test_loadChannel_timerEndDateBeforeCurrentTimestamp() {
        // given
        var suplaTimer = TTimerState_ExtendedValue()
        suplaTimer.CountdownEndsAt = 122
        
        var suplaExtendedValue = TSuplaChannelExtendedValue()
        suplaExtendedValue.type = CChar(EV_TYPE_TIMER_STATE_V1)
        suplaExtendedValue.size = UInt32(MemoryLayout<TTimerState_ExtendedValue>.size)
        _ = withUnsafeMutablePointer(to: &suplaExtendedValue.value) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<TTimerState_ExtendedValue>.size) { ptr in
                memcpy(ptr, &suplaTimer, MemoryLayout<TTimerState_ExtendedValue>.size)
            }
        }
        
        let startTime = Date()
        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.timerStartTime = startTime
        extendedValue.setValueWith(&suplaExtendedValue)
        
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_LIGHTSWITCH
        channel.ev = extendedValue
        
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        getChannelBaseStateUseCase.returns = ChannelState.opened
        dateProvider.currentTimestampReturns = .single(124)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)
        
        // when
        viewModel.loadChannel(remoteId: 123)
        
        // then
        XCTAssertEqual(viewModel.state.issues, [])
        XCTAssertEqual(viewModel.state.online, false)
        XCTAssertEqual(viewModel.state.on, false)
        XCTAssertEqual(viewModel.state.stateLabel, Strings.SwitchDetail.stateLabel)
        XCTAssertEqual(viewModel.state.stateValue, "offline")
        XCTAssertEqual(viewModel.state.stateIcon, .suplaIcon(name: ""))
        XCTAssertEqual(viewModel.state.onButtonState?.icon, .suplaIcon(name: ""))
        XCTAssertEqual(viewModel.state.offButtonState?.icon, .suplaIcon(name: ""))
        XCTAssertEqual(viewModel.state.showElectricityState, false)
        XCTAssertEqual(viewModel.state.showImpulseCounterState, false)
        XCTAssertNil(viewModel.state.alertDialogState)
        
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [123])
        XCTAssertEqual(getChannelBaseStateUseCase.parameters, [channel])
    }
    
    func test_shouldInvokeTurnOn() {
        // given
        let remoteId: Int32 = 123
        
        // when
        viewModel.turnOn(remoteId: remoteId)
        
        // then
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOn, SUPLA.SubjectType.channel, remoteId)
        ])
    }
    
    func test_shouldInvokeTurnOff() {
        // given
        let remoteId: Int32 = 123
        
        // when
        viewModel.turnOff(remoteId: remoteId)
        
        // then
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOff, SUPLA.SubjectType.channel, remoteId)
        ])
    }
}
