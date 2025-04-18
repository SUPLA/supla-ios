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

final class SwitchGeneralVMTest: ViewModelTest<SwitchGeneralViewState, SwitchGeneralViewEvent> {
    private lazy var viewModel: SwitchGeneralVM! = SwitchGeneralVM()
    
    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = ReadChannelWithChildrenUseCaseMock()

    private lazy var getChannelBaseStateUseCase: GetChannelBaseStateUseCaseMock! = GetChannelBaseStateUseCaseMock()

    private lazy var executeSimpleActionUseCase: ExecuteSimpleActionUseCaseMock! = ExecuteSimpleActionUseCaseMock()

    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = SuplaClientProviderMock()
    
    override func setUp() {
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: GetChannelBaseStateUseCase.self, getChannelBaseStateUseCase!)
        DiContainer.shared.register(type: ExecuteSimpleActionUseCase.self, executeSimpleActionUseCase!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        readChannelWithChildrenUseCase = nil
        getChannelBaseStateUseCase = nil
        executeSimpleActionUseCase = nil
        dateProvider = nil
        suplaClientProvider = nil
        
        super.tearDown()
    }
    
    func test_loadChannel() {
        // given
        var suplaValue = TSuplaChannelValue_B()
        suplaValue.value = (1, 1, 1, 1, 1, 1, 1, 1)
        
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
        
        let function: Int32 = 123
        let altIcon: Int32 = 2
        let startTime = Date()
        let userIcon = SAUserIcon(testContext: nil)
        let value = SAChannelValue(testContext: nil)
        value.setValueWith(&suplaValue)
        value.online = SUPLA_CHANNEL_ONLINE_FLAG_ONLINE
        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.timerStartTime = startTime
        extendedValue.setValueWith(&suplaExtendedValue)
        
        let channel = SAChannel(testContext: nil)
        channel.func = function
        channel.alticon = altIcon
        channel.value = value
        channel.usericon = userIcon
        channel.ev = extendedValue
        
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        getChannelBaseStateUseCase.returns = ChannelState.opened
        dateProvider.currentTimestampReturns = .single(0)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.loadChannel(remoteId: 123)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.isOnline, true)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.isOn, true)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.timerStartDate, startTime)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.timerEndDate?.timeIntervalSince1970, 122)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.altIcon, altIcon)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.function, function)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.userIcon, userIcon)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.state, .opened)
        
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
        
        let function: Int32 = 123
        let altIcon: Int32 = 2
        let startTime = Date()
        let userIcon = SAUserIcon(testContext: nil)
        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.timerStartTime = startTime
        extendedValue.setValueWith(&suplaExtendedValue)
        
        let channel = SAChannel(testContext: nil)
        channel.func = function
        channel.alticon = altIcon
        channel.usericon = userIcon
        channel.ev = extendedValue
        
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        getChannelBaseStateUseCase.returns = ChannelState.opened
        dateProvider.currentTimestampReturns = .single(124)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.loadChannel(remoteId: 123)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.isOnline, false)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.isOn, false)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.timerStartDate, startTime)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.timerEndDate, nil)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.altIcon, altIcon)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.function, function)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.userIcon, userIcon)
        XCTAssertEqual(stateObserver.events[1].value.element?.deviceState?.iconData.state, .opened)
        
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [123])
        XCTAssertEqual(getChannelBaseStateUseCase.parameters, [channel])
    }
    
    func test_shouldInvokeTurnOn() {
        // given
        let remoteId: Int32 = 123
        
        // when
        viewModel.turnOn(remoteId: remoteId)
        
        // then
        observe(viewModel)
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOn, SUPLA.SubjectType.channel, remoteId)
        ])
    }
    
    func test_shouldInvokeTurnOff() {
        // given
        let remoteId: Int32 = 123
        
        // when
        observe(viewModel)
        viewModel.turnOff(remoteId: remoteId)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOff, SUPLA.SubjectType.channel, remoteId)
        ])
    }
}
