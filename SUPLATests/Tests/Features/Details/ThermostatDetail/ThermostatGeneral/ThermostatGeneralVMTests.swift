/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import RxSwift
import SharedCore
import XCTest

@testable import SUPLA

@available(iOS 17.0, *)
final class ThermostatGeneralVMTests: SuplaCore.ViewModelTest<ThermostatGeneralFeature.ViewState> {
    private let item = ItemBundle(
        remoteId: 231,
        profileId: 1,
        deviceId: 321,
        subjectType: .channel,
        function: SUPLA_CHANNELFNC_HVAC_THERMOSTAT
    )

    private lazy var viewModel = ThermostatGeneralFeature.ViewModel(itemBundle: item)
    private lazy var readChannelWithChildrenUseCase = ReadChannelWithChildrenUseCaseMock()
    private lazy var createTemperaturesListUseCase = CreateTemperaturesListUseCaseMock()
    private lazy var channelConfigEventsManager = ChannelConfigEventsManagerMock()
    private lazy var deviceConfigEventsManager = DeviceConfigEventsManagerMock()
    private lazy var getChannelConfigUseCase = GetChannelConfigUseCaseMock()
    private lazy var delayedThermostatActionSubject = DelayedThermostatActionSubjectMock()
    private lazy var dateProvider = DateProviderMock()
    private lazy var loadingTimeoutManager = LoadingTimeoutManagerMock()
    private lazy var updateEventsManager = UpdateEventsManagerMock()
    private lazy var checkIsSlaveThermostatUseCase = CheckIsSlaveThermostatUseCaseMock()
    private lazy var groupSharedSettings = GroupShared.SettingsMock()

    override func setUp() {
        super.setUp()
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase)
        DiContainer.shared.register(type: CreateTemperaturesListUseCase.self, createTemperaturesListUseCase)
        DiContainer.shared.register(type: ChannelConfigEventsManager.self, channelConfigEventsManager)
        DiContainer.shared.register(type: DeviceConfigEventsManager.self, deviceConfigEventsManager)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, getChannelConfigUseCase)
        DiContainer.shared.register(type: DelayedThermostatActionSubject.self, delayedThermostatActionSubject)
        DiContainer.shared.register(type: DateProvider.self, dateProvider)
        DiContainer.shared.register(type: ValuesFormatter.self, ValuesFormatterMock())
        DiContainer.shared.register(type: LoadingTimeoutManager.self, producer: { self.loadingTimeoutManager })
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, GetChannelBaseIconUseCaseMock())
        DiContainer.shared.register(type: CheckIsSlaveThermostat.UseCase.self, checkIsSlaveThermostatUseCase)
        DiContainer.shared.register(type: GroupShared.Settings.self, groupSharedSettings)
        DiContainer.shared.register(type: UpdateEventsManager.self, updateEventsManager)
        DiContainer.shared.register(type: GetDeviceConfigUseCase.self, GetDeviceConfigUseCaseMock())
        DiContainer.shared.register(type: SUPLA.ThermostatIssuesProvider.self, ThermostatIssuesProviderMock())

        groupSharedSettings.temperatureUnitMock.returns = .single(.celsius)
        groupSharedSettings.temperaturePrecisionMock.returns = .single(1)
        dateProvider.currentTimestampReturns = .single(100)
        checkIsSlaveThermostatUseCase.mock.returns = .single(.just(false))
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_loadsChannelValuesIntoPublishedViewState() {
        let measurements = [MeasurementValue(id: 1, icon: .suplaIcon(name: .Icons.fncUnknown), value: "21.2°")]
        var hvacValue = THVACValue(
            IsOn: 1,
            Mode: UInt8(SuplaHvacMode.heat.value),
            SetpointTemperatureHeat: 2120,
            SetpointTemperatureCool: 0,
            Flags: UInt16(1 | (1 << 9))
        )
        let channel = makeChannel(remoteId: item.remoteId, value: &hvacValue)
        readChannelWithChildrenUseCase.returns = .just(ChannelWithChildren(channel: channel, children: []))
        createTemperaturesListUseCase.returns = measurements
        channelConfigEventsManager.observeConfigReturns = [
            .just(hvacConfigEvent(item.remoteId)),
            .just(weeklyConfigEvent(item.remoteId))
        ]
        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(result: .resultTrue, config: .mock()))
        checkIsSlaveThermostatUseCase.mock.returns = .single(.just(false))

        let stateChange = observe(viewModel.state.$mode, count: 1)
        viewModel.onViewCreated()

        wait(for: [stateChange.exp], timeout: 2)
        XCTAssertEqual(stateChange.receivedValues.last!, .heat)
        XCTAssertEqual(viewModel.state.remoteId, item.remoteId)
        XCTAssertEqual(viewModel.state.channelFunc, SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
        XCTAssertEqual(viewModel.state.setpointHeat, 21.2)
        XCTAssertEqual(viewModel.state.activeSetpointType, .heat)
        XCTAssertEqual(viewModel.state.configMin, 10)
        XCTAssertEqual(viewModel.state.configMax, 40)
        XCTAssertTrue(viewModel.state.controlButtonsEnabled)
        XCTAssertEqual(viewModel.state.thermometerValues.measurements, measurements)
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [item.remoteId])
        XCTAssertEqual(getChannelConfigUseCase.parameters.count, 2)
    }

    func test_setpointDragUpdatesPublishedFieldsAndEmitsAction() {
        viewModel.state.remoteId = item.remoteId
        viewModel.state.controlButtonsEnabled = true
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40
        viewModel.state.mode = .off
        viewModel.state.offline = false
        viewModel.state.weeklyScheduleActive = true
        dateProvider.currentTimestampReturns = .single(100)

        viewModel.onPositionEvent(.mooving(setpointType: .heat, position: 0.5))

        XCTAssertEqual(viewModel.state.activeSetpointType, .heat)
        XCTAssertEqual(viewModel.state.setpointHeat, 25)
        XCTAssertEqual(viewModel.state.mode, .heat)
        XCTAssertTrue(viewModel.state.changing)
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters, [
            ThermostatActionData(remoteId: item.remoteId, mode: .notSet, setpointHeat: 25)
        ])

        viewModel.onPositionEvent(.finished)
        XCTAssertFalse(viewModel.state.changing)
    }

    func test_temperatureStepClampsToConfiguredMaximum() {
        viewModel.state.remoteId = item.remoteId
        viewModel.state.controlButtonsEnabled = true
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40
        viewModel.state.activeSetpointType = .heat
        viewModel.state.setpointHeat = 40
        dateProvider.currentTimestampReturns = .single(100)

        viewModel.onTemperatureChange(.smallUp)

        XCTAssertEqual(viewModel.state.setpointHeat, 40)
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters.last?.setpointHeat, 40)
    }

    func test_powerButtonRequestsTurnOnAndUpdatesViewState() {
        viewModel.state.remoteId = item.remoteId
        viewModel.state.offline = false
        viewModel.state.mode = .off
        viewModel.state.setpointHeat = 20

        viewModel.onPowerButtonTap()

        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters.last?.mode, .cmdTurnOn)
        XCTAssertEqual(viewModel.state.mode, .heat)
        XCTAssertTrue(viewModel.state.loadingState.loading)
    }

    func test_manualAndWeeklyButtonsUpdateViewState() {
        viewModel.state.remoteId = item.remoteId

        viewModel.onManualButtonTap()
        XCTAssertTrue(viewModel.state.manualActive)
        XCTAssertFalse(viewModel.state.weeklyScheduleActive)
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters.last?.mode, .cmdSwitchToManual)

        viewModel.onWeeklyScheduleButtonTap()
        XCTAssertFalse(viewModel.state.manualActive)
        XCTAssertTrue(viewModel.state.weeklyScheduleActive)
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters.last?.mode, .cmdWeeklySchedule)
    }

    private func makeChannel(remoteId: Int32, value: inout THVACValue) -> SAChannel {
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(bytes: &value, length: MemoryLayout<THVACValue>.size)
        channelValue.online = SUPLA_CHANNEL_ONLINE_FLAG_ONLINE

        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        channel.value = channelValue
        return channel
    }

    private func hvacConfigEvent(_ remoteId: Int32) -> ChannelConfigEvent {
        ChannelConfigEvent(
            result: .resultTrue,
            config: SuplaChannelHvacConfig.mock(
                remoteId: remoteId,
                channelFunction: SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
                subfunction: .heat,
                configMin: 1000,
                configMax: 4000
            )
        )
    }

    private func weeklyConfigEvent(_ remoteId: Int32) -> ChannelConfigEvent {
        ChannelConfigEvent(result: .resultTrue, config: SuplaChannelWeeklyScheduleConfig.mock(remoteId: remoteId))
    }
}

private final class ThermostatIssuesProviderMock: SUPLA.ThermostatIssuesProvider {
    func provide(channelWithChildren: SharedCore.ChannelWithChildren) -> [SharedCore.ChannelIssueItem] { [] }
}

private final class GetDeviceConfigUseCaseMock: SUPLA.GetDeviceConfigUseCase {
    func invoke(deviceId: Int32) -> Observable<RequestResult> { .empty() }
}
