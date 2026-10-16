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
import XCTest

@testable import SUPLA

final class SwitchTimerDetailVMTests: SuplaCore.ViewModelTest<SwitchTimerDetailFeature.ViewState> {
    private var viewModel: SwitchTimerDetailVM!
    private var observeChannelWithChildrenUseCase = ObserveChannelWithChildren.Mock()
    private var getChannelBaseIconUseCase = GetChannelBaseIconUseCaseMock()
    private var observeRelayProgramStateUseCase = ObserveRelayProgramStateUseCaseMock()
    private var startTimerUseCase = StartTimerUseCaseMock()
    private var executeSimpleActionUseCase = ExecuteSimpleAction.Mock()
    private var dateProvider = DateProviderMock()
    private var runtimeConfig = RuntimeConfigImpl()

    override func setUp() {
        super.setUp()
        DiContainer.shared.register(type: ObserveChannelWithChildren.UseCase.self, observeChannelWithChildrenUseCase)
        DiContainer.shared.register(type: ObserveRelayProgramState.UseCase.self, observeRelayProgramStateUseCase)
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, getChannelBaseIconUseCase)
        DiContainer.shared.register(type: StartTimerUseCase.self, startTimerUseCase)
        DiContainer.shared.register(type: ExecuteSimpleAction.UseCase.self, executeSimpleActionUseCase)
        DiContainer.shared.register(type: DateProvider.self, dateProvider)
        DiContainer.shared.register(type: RuntimeConfig.self, runtimeConfig)
        viewModel = SwitchTimerDetailVM(remoteId: 123)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_observeChannel() {
        let startTime = Date()
        let channel = createChannelWithTimer(endsAt: 122, startTime: startTime, isOn: true, isOnline: true)
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: channel)))
        let icon = IconResult.suplaIcon(name: .Icons.fncGpm1)
        getChannelBaseIconUseCase.returns = icon
        dateProvider.currentTimestampReturns = .single(0)

        viewModel.onViewAppear()

        XCTAssertEqual(viewModel.state.isOnline, true)
        XCTAssertEqual(viewModel.state.isOn, true)
        XCTAssertEqual(viewModel.state.timerStartDate, startTime)
        XCTAssertEqual(viewModel.state.timerEndDate?.timeIntervalSince1970, 122)
        XCTAssertEqual(viewModel.state.channelCurrentStateData?.icon, icon)
        XCTAssertEqual(viewModel.state.channelCurrentStateData?.value, Strings.SwitchDetail.stateOn)
        XCTAssertEqual(viewModel.state.targetAction, .turnOn)
        XCTAssertEqual(observeChannelWithChildrenUseCase.invokeMock.parameters, [123])
        XCTAssertEqual(getChannelBaseIconUseCase.parameters.count, 1)
        XCTAssertEqual(observeRelayProgramStateUseCase.parameters, [123])
    }

    func test_observeChannel_preservesEditModeWhenTimerValuesArrive() {
        let channel = createChannelWithTimer(endsAt: 122, startTime: Date(), isOn: true, isOnline: true)
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: channel)))
        dateProvider.currentTimestampReturns = .single(0)

        viewModel.onEditTimer()
        viewModel.onViewAppear()

        XCTAssertTrue(viewModel.state.editMode)
    }

    func test_editTimer_usesRemainingDuration() {
        let channel = createChannelWithTimer(endsAt: 122, startTime: Date(), isOn: true, isOnline: true)
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: channel)))
        dateProvider.currentTimestampReturns = .single(0)
        dateProvider.currentDateReturns = Date(timeIntervalSince1970: 100)

        viewModel.onViewAppear()
        viewModel.onEditTimer()

        XCTAssertEqual(viewModel.state.timeInSeconds, 22)
        XCTAssertTrue(viewModel.state.editMode)
    }

    func test_startTimer() {
        viewModel.state.isOnline = true
        viewModel.state.setTimeInSeconds(322)
        viewModel.state.targetAction = .turnOn

        viewModel.onStartTimer()

        XCTAssertEqual(startTimerUseCase.remoteIdsArray, [123])
        XCTAssertEqual(startTimerUseCase.turnOnsArray, [true])
        XCTAssertEqual(startTimerUseCase.durationsArray, [322])
    }

    func test_startTimer_invalidTimePresentsAlert() {
        viewModel.state.isOnline = true
        startTimerUseCase.returns = .error(StartTimerUseCaseImpl.InvalidTimeError())
        viewModel.state.setTimeInSeconds(322)
        let observation = observe(viewModel.state.$invalidTimeAlertPresented, count: 1)

        viewModel.onStartTimer()
        wait(for: [observation.exp], timeout: 1)

        XCTAssertEqual(observation.receivedValues, [true])
    }

    func test_stopTimer_usesCurrentRelayState() {
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: createChannelWithHiValue(1))))
        dateProvider.currentTimestampReturns = .single(0)
        viewModel.onViewAppear()

        viewModel.onStopTimer()

        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (ActionId.turnOn, SUPLA.SubjectType.channel, 123)
        ])
    }

    func test_cancelTimer_usesOppositeRelayState() {
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: createChannelWithHiValue(0))))
        dateProvider.currentTimestampReturns = .single(0)
        viewModel.onViewAppear()

        viewModel.onCancelTimer()

        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (ActionId.turnOn, SUPLA.SubjectType.channel, 123)
        ])
    }

    func test_shouldCalculateProgressData() {
        dateProvider.currentDateReturns = Date(timeIntervalSince1970: 35)

        let progressData = viewModel.calculateProgressViewData(
            startTime: Date(timeIntervalSince1970: 20),
            endTime: Date(timeIntervalSince1970: 50)
        )

        XCTAssertEqual(progressData?.progres, 0.5)
        XCTAssertEqual(progressData?.leftTimeValues.seconds, 16)
        XCTAssertEqual(progressData?.leftTimeValues.minutes, 0)
        XCTAssertEqual(progressData?.leftTimeValues.hours, 0)
    }

    private func createChannelWithTimer(endsAt: UInt32, startTime: Date, isOn: Bool, isOnline: Bool) -> SAChannel {
        var suplaTimer = TTimerState_ExtendedValue()
        suplaTimer.CountdownEndsAt = endsAt

        var suplaExtendedValue = TSuplaChannelExtendedValue()
        suplaExtendedValue.type = CChar(EV_TYPE_TIMER_STATE_V1)
        suplaExtendedValue.size = UInt32(MemoryLayout<TTimerState_ExtendedValue>.size)
        _ = withUnsafeMutablePointer(to: &suplaExtendedValue.value) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<TTimerState_ExtendedValue>.size) { pointer in
                memcpy(pointer, &suplaTimer, MemoryLayout<TTimerState_ExtendedValue>.size)
            }
        }

        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.timerStartTime = startTime
        extendedValue.setValueWith(&suplaExtendedValue)

        let channel = createChannelWithHiValue(isOn ? 1 : 0, isOnline: isOnline)
        channel.func = SUPLA_CHANNELFNC_POWERSWITCH
        channel.alticon = 2
        channel.ev = extendedValue
        return channel
    }

    private func createChannelWithHiValue(_ value: Int8, isOnline: Bool = false) -> SAChannel {
        var suplaValue = TSuplaChannelValue_B()
        suplaValue.value = (value, value, value, value, value, value, value, value)

        let channelValue = SAChannelValue(testContext: nil)
        channelValue.setValueWith(&suplaValue)
        channelValue.online = isOnline ? SUPLA_CHANNEL_ONLINE_FLAG_ONLINE : SUPLA_CHANNEL_ONLINE_FLAG_OFFLINE

        let channel = SAChannel(testContext: nil)
        channel.value = channelValue
        return channel
    }
}

private final class ObserveRelayProgramStateUseCaseMock: ObserveRelayProgramState.UseCase {
    var parameters: [Int32] = []
    var returns: Observable<[ChannelProgramState.Data]> = .just([])

    func invoke(remoteId: Int32) -> Observable<[ChannelProgramState.Data]> {
        parameters.append(remoteId)
        return returns
    }
}
