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

final class TimerDetailVMTests: SuplaCore.ViewModelTest<SwitchTimerDetailFeature.ViewState> {
    private var viewModel: SwitchTimerDetailVM!
    private var observeChannelWithChildrenUseCase = ObserveChannelWithChildren.Mock()
    private var getChannelBaseStateUseCase = GetChannelBaseStateUseCaseMock()
    private var getChannelBaseIconUseCase = GetChannelBaseIconUseCaseMock()
    private var startTimerUseCase = StartTimerUseCaseMock()
    private var executeSimpleActionUseCase = ExecuteSimpleAction.Mock()
    private var dateProvider = DateProviderMock()
    private var runtimeConfig = RuntimeConfigImpl()
    private var suplaClientProvider = SuplaClientProviderMock()

    override func setUp() {
        super.setUp()
        DiContainer.shared.register(type: ObserveChannelWithChildren.UseCase.self, observeChannelWithChildrenUseCase)
        DiContainer.shared.register(type: GetChannelBaseStateUseCase.self, getChannelBaseStateUseCase)
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, getChannelBaseIconUseCase)
        DiContainer.shared.register(type: StartTimerUseCase.self, startTimerUseCase)
        DiContainer.shared.register(type: ExecuteSimpleAction.UseCase.self, executeSimpleActionUseCase)
        DiContainer.shared.register(type: DateProvider.self, dateProvider)
        DiContainer.shared.register(type: RuntimeConfig.self, runtimeConfig)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider)

        viewModel = SwitchTimerDetailVM(remoteId: 123)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_observeChannel() throws {
        let startTime = Date()
        let channel = createChannelWithTimer(endsAt: 122, startTime: startTime, isOn: true, isOnline: true)
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: channel)))
        getChannelBaseStateUseCase.returns = .default(value: .opened)
        dateProvider.currentTimestampReturns = .single(0)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)

        let observation = observe(viewModel.state.$deviceState, count: 1)
        viewModel.onViewAppear()
        wait(for: [observation.exp], timeout: 1)

        let deviceState = try XCTUnwrap(observation.receivedValues.first ?? nil)
        XCTAssertEqual(deviceState.isOnline, true)
        XCTAssertEqual(deviceState.isOn, true)
        XCTAssertEqual(deviceState.timerStartDate, startTime)
        XCTAssertEqual(deviceState.timerEndDate?.timeIntervalSince1970, 122)
        XCTAssertEqual(deviceState.iconData.state, .default(value: .opened))
        XCTAssertEqual(viewModel.state.targetAction, .turnOn)
        XCTAssertEqual(observeChannelWithChildrenUseCase.invokeMock.parameters, [123])
        XCTAssertEqual(getChannelBaseStateUseCase.parameters, [channel])
        XCTAssertEqual(getChannelBaseIconUseCase.parameters.count, 1)
    }

    func test_observeChannel_preservesEditModeWhenTimerValuesArrive() {
        let channel = createChannelWithTimer(endsAt: 122, startTime: Date(), isOn: true, isOnline: true)
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: channel)))
        getChannelBaseStateUseCase.returns = .default(value: .opened)
        dateProvider.currentTimestampReturns = .single(0)
        suplaClientProvider.suplaClientMock.getServerTimeDiffInSecMock.returns = .single(0)

        let observation = observe(viewModel.state.$editMode, count: 1)
        viewModel.onEditTimer()
        viewModel.onViewAppear()
        wait(for: [observation.exp], timeout: 1)

        XCTAssertEqual(observation.receivedValues, [true])
    }

    func test_startTimer() {
        setOnlineDeviceState()
        viewModel.state.setTimeInSeconds(322)
        viewModel.state.targetAction = .turnOn

        viewModel.onStartTimer()

        XCTAssertEqual(startTimerUseCase.remoteIdsArray, [123])
        XCTAssertEqual(startTimerUseCase.turnOnsArray, [true])
        XCTAssertEqual(startTimerUseCase.durationsArray, [322])
    }

    func test_startTimer_invalidTimePresentsAlert() {
        setOnlineDeviceState()
        startTimerUseCase.returns = .error(StartTimerUseCaseImpl.InvalidTimeError())
        viewModel.state.setTimeInSeconds(322)
        let observation = observe(viewModel.state.$invalidTimeAlertPresented, count: 1)

        viewModel.onStartTimer()
        wait(for: [observation.exp], timeout: 1)

        XCTAssertEqual(observation.receivedValues, [true])
    }

    func test_stopTimer_usesCurrentRelayState() {
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: createChannelWithHiValue(1))))
        viewModel.onViewAppear()

        viewModel.onStopTimer()

        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (ActionId.turnOn, SUPLA.SubjectType.channel, 123)
        ])
    }

    func test_cancelTimer_usesOppositeRelayState() {
        observeChannelWithChildrenUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: createChannelWithHiValue(0))))
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

    private func setOnlineDeviceState() {
        let iconData = FetchIconData(function: SUPLA_CHANNELFNC_POWERSWITCH, altIcon: 0, profileId: 0)
        viewModel.state.deviceState = DeviceStateViewState(
            isOnline: true,
            isOn: false,
            timerEndDate: nil,
            timerStartDate: nil,
            iconData: iconData
        )
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
        channel.func = 123
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
