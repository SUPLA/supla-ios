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

final class TimerDetailVMTests: ViewModelTest<SwitchTimerDetailViewState, SwitchTimerDetailViewEvent> {
    private lazy var viewModel: SwitchTimerDetailVM! = SwitchTimerDetailVM()
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = ReadChannelByRemoteIdUseCaseMock()

    private lazy var getChannelBaseStateUseCase: GetChannelBaseStateUseCaseMock! = GetChannelBaseStateUseCaseMock()

    private lazy var startTimerUseCase: StartTimerUseCaseMock! = StartTimerUseCaseMock()

    private lazy var executeSimpleActionUseCase: ExecuteSimpleActionUseCaseMock! = ExecuteSimpleActionUseCaseMock()

    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = SuplaClientProviderMock()
    
    override func setUp() {
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: GetChannelBaseStateUseCase.self, getChannelBaseStateUseCase!)
        DiContainer.shared.register(type: StartTimerUseCase.self, startTimerUseCase!)
        DiContainer.shared.register(type: ExecuteSimpleActionUseCase.self, executeSimpleActionUseCase!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        readChannelByRemoteIdUseCase = nil
        getChannelBaseStateUseCase = nil
        startTimerUseCase = nil
        executeSimpleActionUseCase = nil
        dateProvider = nil
        suplaClientProvider = nil
        
        super.tearDown()
    }
    
    func test_loadChannel() {
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
        
        let isOnline = true
        let function: Int32 = 123
        let altIcon: Int32 = 2
        let startTime = Date()
        let userIcon = SAUserIcon(testContext: nil)
        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.timerStartTime = startTime
        extendedValue.setValueWith(&suplaExtendedValue)
        
        let channel = createChannelWithHiValue(1, isOnline: isOnline)
        channel.func = function
        channel.alticon = altIcon
        channel.usericon = userIcon
        channel.ev = extendedValue
        
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        getChannelBaseStateUseCase.returns = ChannelState.opened
        dateProvider.currentTimestampReturns = .single(0)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.loadChannel(remoteId: 123)
        
        // thena
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertState(1, withPath: \.deviceState?.isOnline, equalTo: isOnline)
        assertState(1, withPath: \.deviceState?.isOn, equalTo: true)
        assertState(1, withPath: \.deviceState?.timerStartDate, equalTo: startTime)
        assertState(1, withPath: \.deviceState?.timerEndDate?.timeIntervalSince1970, equalTo: 122)
        assertState(1, withPath: \.deviceState?.iconData.altIcon, equalTo: altIcon)
        assertState(1, withPath: \.deviceState?.iconData.function, equalTo: function)
        assertState(1, withPath: \.deviceState?.iconData.userIcon, equalTo: userIcon)
        assertState(1, withPath: \.deviceState?.iconData.state, equalTo: .opened)
        assertState(1, withPath: \.editMode, equalTo: false)
        
        XCTAssertEqual(readChannelByRemoteIdUseCase.remoteIdArray[0], 123)
        XCTAssertEqual(getChannelBaseStateUseCase.parameters, [channel])
    }
    
    func test_shouldLoadChannelAndSetEditModeToFalse() {
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
        
        let isOnline = true
        let function: Int32 = 123
        let altIcon: Int32 = 2
        let startTime = Date()
        let userIcon = SAUserIcon(testContext: nil)
        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.timerStartTime = startTime
        extendedValue.setValueWith(&suplaExtendedValue)
        
        let channel = createChannelWithHiValue(1, isOnline: isOnline)
        channel.func = function
        channel.alticon = altIcon
        channel.usericon = userIcon
        channel.ev = extendedValue
        
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        getChannelBaseStateUseCase.returns = ChannelState.opened
        dateProvider.currentTimestampReturns = .single(0)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.startEditMode()
        viewModel.loadChannel(remoteId: 123)
        
        // thena
        assertObserverItems(statesCount: 3, eventsCount: 0)
        assertState(1, withPath: \.editMode, equalTo: true)
        assertState(2, withPath: \.deviceState?.isOnline, equalTo: isOnline)
        assertState(2, withPath: \.deviceState?.isOn, equalTo: true)
        assertState(2, withPath: \.deviceState?.timerStartDate, equalTo: startTime)
        assertState(2, withPath: \.deviceState?.timerEndDate?.timeIntervalSince1970, equalTo: 122)
        assertState(2, withPath: \.deviceState?.iconData.altIcon, equalTo: altIcon)
        assertState(2, withPath: \.deviceState?.iconData.function, equalTo: function)
        assertState(2, withPath: \.deviceState?.iconData.userIcon, equalTo: userIcon)
        assertState(2, withPath: \.deviceState?.iconData.state, equalTo: .opened)
        assertState(2, withPath: \.editMode, equalTo: false)
        
        XCTAssertEqual(readChannelByRemoteIdUseCase.remoteIdArray[0], 123)
        XCTAssertEqual(getChannelBaseStateUseCase.parameters, [channel])
    }
    
    func test_shouldStopEditMode() {
        // when
        observe(viewModel)
        viewModel.startEditMode()
        viewModel.stopEditMode()
        
        // then
        assertObserverItems(statesCount: 3, eventsCount: 0)
        assertState(0, withPath: \.editMode, equalTo: false)
        assertState(1, withPath: \.editMode, equalTo: true)
        assertState(2, withPath: \.editMode, equalTo: false)
    }
    
    func test_startTimer_notInEditMode() {
        // given
        let remoteId: Int32 = 123
        let action = TimerTargetAction.turnOn
        let duration = 322
        
        // when
        observe(viewModel)
        viewModel.startTimer(remoteId: remoteId, action: action, durationInSecs: duration)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0)
        
        XCTAssertEqual(startTimerUseCase.remoteIdsArray.count, 1)
        XCTAssertEqual(startTimerUseCase.remoteIdsArray[0], remoteId)
        XCTAssertEqual(startTimerUseCase.turnOnsArray[0], true)
        XCTAssertEqual(startTimerUseCase.durationsArray[0], Int32(duration))
    }
    
    func test_startTimer_informAboutWrongTime() {
        // given
        let remoteId: Int32 = 123
        let action = TimerTargetAction.turnOn
        let duration = 322
        
        startTimerUseCase.returns = Observable.error(StartTimerUseCaseImpl.InvalidTimeError())
        
        // when
        observe(viewModel)
        viewModel.startTimer(remoteId: remoteId, action: action, durationInSecs: duration)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 1)
        
        XCTAssertEqual(startTimerUseCase.remoteIdsArray.count, 1)
        XCTAssertEqual(startTimerUseCase.remoteIdsArray[0], remoteId)
        XCTAssertEqual(startTimerUseCase.turnOnsArray[0], true)
        XCTAssertEqual(startTimerUseCase.durationsArray[0], Int32(duration))
        
        assertEvent(0, equalTo: .showInvalidTime)
    }
    
    func test_startTimer_informAboutWrongTime_editMode() {
        // given
        let remoteId: Int32 = 123
        let action = TimerTargetAction.turnOn
        let duration = 322
        
        let channel = createChannelWithHiValue(0)
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        startTimerUseCase.returns = Observable.error(StartTimerUseCaseImpl.InvalidTimeError())
        
        // when
        observe(viewModel)
        viewModel.startEditMode()
        viewModel.startTimer(remoteId: remoteId, action: action, durationInSecs: duration)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 1)
        
        XCTAssertEqual(startTimerUseCase.remoteIdsArray.count, 1)
        XCTAssertEqual(startTimerUseCase.remoteIdsArray[0], remoteId)
        XCTAssertEqual(startTimerUseCase.turnOnsArray[0], true)
        XCTAssertEqual(startTimerUseCase.durationsArray[0], Int32(duration))
        
        assertEvent(0, equalTo: .showInvalidTime)
    }
    
    func test_stopTimer_channelOn() {
        // given
        let remoteId: Int32 = 123
        
        let channel = createChannelWithHiValue(1)
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        
        // when
        observe(viewModel)
        viewModel.stopTimer(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0) // only default state
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOn, SUPLA.SubjectType.channel, remoteId)
        ])
    }
    
    func test_stopTimer_channelOff() {
        // given
        let remoteId: Int32 = 123
        
        let channel = createChannelWithHiValue(0)
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        
        // when
        observe(viewModel)
        viewModel.stopTimer(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0) // only default state
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOff, SUPLA.SubjectType.channel, remoteId)
        ])
    }
    
    func test_cancelTimer_channelOn() {
        // given
        let remoteId: Int32 = 123
        
        let channel = createChannelWithHiValue(1)
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        
        // when
        observe(viewModel)
        viewModel.cancelTimer(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0) // only default state
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOff, SUPLA.SubjectType.channel, remoteId)
        ])
    }
    
    func test_cancelTimer_channelOff() {
        // given
        let remoteId: Int32 = 123
        
        let channel = createChannelWithHiValue(0)
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        
        // when
        observe(viewModel)
        viewModel.cancelTimer(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0) // only default state
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.turnOn, SUPLA.SubjectType.channel, remoteId)
        ])
    }
    
    func test_shouldCalculateProgressData() {
        // given
        let startDate = Date(timeIntervalSince1970: 20)
        let endDate = Date(timeIntervalSince1970: 50)
        
        dateProvider.currentDateReturns = Date(timeIntervalSince1970: 35)
        
        // when
        observe(viewModel)
        let progressData = viewModel.calculateProgressViewData(startTime: startDate, endTime: endDate)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0) // only default state
        
        XCTAssertEqual(progressData!.progres, 0.5)
        XCTAssertEqual(progressData!.leftTimeValues.seconds, 16)
        XCTAssertEqual(progressData!.leftTimeValues.minutes, 0)
        XCTAssertEqual(progressData!.leftTimeValues.hours, 0)
    }
    
    private func createChannelWithHiValue(_ value: Int8, isOnline: Bool = false) -> SAChannel {
        var suplaValue = TSuplaChannelValue_B()
        suplaValue.value = (value, value, value, value, value, value, value, value)
        
        let value = SAChannelValue(testContext: nil)
        value.setValueWith(&suplaValue)
        value.online = isOnline
        
        let channel = SAChannel(testContext: nil)
        channel.value = value
        
        return channel
    }
}
