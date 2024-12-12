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

import XCTest
import RxTest
import RxSwift
import SharedCore

@testable import SUPLA

final class ThermostatGeneralVMTests: ViewModelTest<ThermostatGeneralViewState, ThermostatGeneralViewEvent> {
    
    private lazy var viewModel: ThermostatGeneralVM! = { ThermostatGeneralVM() }()
    
    private lazy var readChannelWithChildrenTreeUseCase: ReadChannelWithChildrenTreeUseCaseMock! = {
        ReadChannelWithChildrenTreeUseCaseMock()
    }()
    private lazy var createTemperaturesListUseCase: CreateTemperaturesListUseCaseMock! = {
        CreateTemperaturesListUseCaseMock()
    }()
    private lazy var channelConfigEventsManager: ChannelConfigEventsManagerMock! = {
        ChannelConfigEventsManagerMock()
    }()
    private lazy var deviceConfigEventsManager: DeviceConfigEventsManagerMock! = {
        DeviceConfigEventsManagerMock()
    }()
    private lazy var getChannelConfigUseCase: GetChannelConfigUseCaseMock! = {
        GetChannelConfigUseCaseMock()
    }()
    private lazy var delayedThermostatActionSubject: DelayedThermostatActionSubjectMock! = {
        DelayedThermostatActionSubjectMock()
    }()
    private lazy var dateProvider: DateProviderMock! = {
        DateProviderMock()
    }()
    private lazy var loadingTimeoutManager: LoadingTimeoutManagerMock! = {
        LoadingTimeoutManagerMock()
    }()
    
    
    override func setUp() {
        DiContainer.shared.register(type: ReadChannelWithChildrenTreeUseCase.self, readChannelWithChildrenTreeUseCase!)
        DiContainer.shared.register(type: CreateTemperaturesListUseCase.self, createTemperaturesListUseCase!)
        DiContainer.shared.register(type: ChannelConfigEventsManager.self, channelConfigEventsManager!)
        DiContainer.shared.register(type: DeviceConfigEventsManager.self, deviceConfigEventsManager!)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, getChannelConfigUseCase!)
        DiContainer.shared.register(type: DelayedThermostatActionSubject.self, delayedThermostatActionSubject!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: ValuesFormatter.self, ValuesFormatterMock())
        DiContainer.shared.register(type: LoadingTimeoutManager.self, producer: { self.loadingTimeoutManager! })
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, GetChannelBaseIconUseCaseMock())
    }
    
    override func tearDown() {
        viewModel = nil
        
        readChannelWithChildrenTreeUseCase = nil
        createTemperaturesListUseCase = nil
        channelConfigEventsManager = nil
        deviceConfigEventsManager = nil
        getChannelConfigUseCase = nil
        delayedThermostatActionSubject = nil
        dateProvider = nil
        loadingTimeoutManager = nil
        
        super.tearDown()
    }
    
    // MARK: - Data Loading
    
    func test_shouldLoadData_heatStandbyManual() {
        // given
        var hvacValue = THVACValue(IsOn: 1, Mode: UInt8(SuplaHvacMode.heat.value), SetpointTemperatureHeat: 2120, SetpointTemperatureCool: 0, Flags: (1 | (1 << 9)))
        let remoteId: Int32 = 231
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(bytes: &hvacValue, length: MemoryLayout<THVACValue>.size)
        channelValue.online = true
        channel.value = channelValue
        
        let measurements: [MeasurementValue] = [
            MeasurementValue(id: 0, icon: .suplaIcon(name: .Icons.fncUnknown), value: "12.2"),
            MeasurementValue(id: 1, icon: .suplaIcon(name: .Icons.fncUnknown), value: "21.2")
        ]
        
        readChannelWithChildrenTreeUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: [mockMainTemperatureChild(), mockSensorChild()]))
        createTemperaturesListUseCase.returns = measurements
        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(mockHvacConfigEvent(remoteId)),
            Observable.just(mockWeeklyConfigEvent(remoteId))
        ]
        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock())
        )
        let expectation = expectation(description: "States loaded")
        
        // when
        var statesCount = 0
        observe(viewModel) { object in
            if (object is ThermostatGeneralViewState) {
                statesCount += 1
            }
            if (statesCount == 2) {
                expectation.fulfill()
            }
        }
        viewModel.observeData(remoteId: remoteId, deviceId: 321)
        viewModel.triggerDataLoad(remoteId: remoteId)
        
        // then
        waitForExpectations(timeout: 1)
        assertObserverItems(statesCount: 2, eventsCount: 0)
        
        let state = ThermostatGeneralViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.remoteId, to: remoteId)
                .changing(path: \.channelFunc, to: SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
                .changing(path: \.mode, to: .heat)
                .changing(path: \.offline, to: false)
                .changing(path: \.configMin, to: 10)
                .changing(path: \.configMax, to: 40)
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: false))
                .changing(path: \.setpointHeat, to: 21.2)
                .changing(path: \.activeSetpointType, to: .heat)
                .changing(path: \.plusMinusHidden, to: false)
                .changing(path: \.manualActive, to: true)
                .changing(path: \.heatingIndicatorActive, to: false)
                .changing(path: \.coolingIndicatorActive, to: false)
                .changing(path: \.currentTemperaturePercentage, to: 0.32666665)
                .changing(path: \.childrenIds, to: [0, 0])
                .changing(path: \.sensorIssue, to: SensorIssue(sensorIcon: .suplaIcon(name: ""), message: Strings.ThermostatDetail.offByCard))
                .changing(path: \.subfunction, to: .heat)
                .changing(path: \.currentPower, to: 1)
        ])
        
        XCTAssertEqual(viewModel.thermometerValuesState.measurements, measurements)

        assertState(1) {
            XCTAssertEqual($0.off, false)
            XCTAssertEqual($0.setpointText, "21.2")
            XCTAssertEqual($0.plusButtonEnabled, true)
            XCTAssertEqual($0.minusButtonEnabled, true)
            XCTAssertEqual($0.operationalMode, .standby)
            XCTAssertEqual($0.powerIconColor, .primary)
            XCTAssertEqual($0.controlButtonsEnabled, true)
            XCTAssertEqual($0.configMinMaxHidden, false)
        }
    }
    
    func test_shouldLoadData_coolCoolingProgram() {
        // given
        let flags = (2 | (1 << 3) | (1 << 4) | (1 << 7) | (1 << 8) | (1 << 10))
        var hvacValue = THVACValue(IsOn: 1, Mode: UInt8(SuplaHvacMode.cool.value), SetpointTemperatureHeat: 0, SetpointTemperatureCool: 2300, Flags: UInt16(flags))
        let remoteId: Int32 = 231
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(bytes: &hvacValue, length: MemoryLayout<THVACValue>.size)
        channelValue.online = true
        channel.value = channelValue
        
        let measurements: [MeasurementValue] = [
            MeasurementValue(id: 0, icon: .suplaIcon(name: .Icons.fncUnknown), value: "12.2"),
            MeasurementValue(id: 1, icon: .suplaIcon(name: .Icons.fncUnknown), value: "21.2")
        ]
        
        readChannelWithChildrenTreeUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: [mockMainTemperatureChild()]))
        createTemperaturesListUseCase.returns = measurements
        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(mockHvacConfigEvent(remoteId)),
            Observable.just(mockWeeklyConfigEvent(remoteId))
        ]
        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock(
                availableFields: [.automaticTimeSync],
                fields: [SuplaAutomaticTimeSyncField(enabled: false)]
            )
        ))
        let expectation = expectation(description: "States loaded")
        
        // when
        var statesCount = 0
        observe(viewModel) { object in
            if (object is ThermostatGeneralViewState) {
                statesCount += 1
            }
            if (statesCount == 2) {
                expectation.fulfill()
            }
        }
        viewModel.observeData(remoteId: remoteId, deviceId: 321)
        viewModel.triggerDataLoad(remoteId: remoteId)
        
        // then
        waitForExpectations(timeout: 1)
        assertObserverItems(statesCount: 2, eventsCount: 0)
        let state = ThermostatGeneralViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.remoteId, to: remoteId)
                .changing(path: \.channelFunc, to: SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
                .changing(path: \.mode, to: .cool)
                .changing(path: \.offline, to: false)
                .changing(path: \.configMin, to: 10)
                .changing(path: \.configMax, to: 40)
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: false))
                .changing(path: \.setpointCool, to: 23)
                .changing(path: \.activeSetpointType, to: .cool)
                .changing(path: \.plusMinusHidden, to: false)
                .changing(path: \.weeklyScheduleActive, to: true)
                .changing(path: \.heatingIndicatorActive, to: false)
                .changing(path: \.coolingIndicatorActive, to: true)
                .changing(path: \.currentTemperaturePercentage, to: 0.32666665)
                .changing(path: \.childrenIds, to: [0])
                .changing(path: \.issues, to: [
                    ChannelIssueItem.Error(string: LocalizedStringWithId(id: LocalizedStringId.thermostatThermometerError)),
                    ChannelIssueItem.Warning(string: LocalizedStringWithId(id: LocalizedStringId.thermostatClockError))
                ])
                .changing(path: \.subfunction, to: .cool)
                .changing(path: \.currentPower, to: 1)
        ])
        
        XCTAssertEqual(viewModel.thermometerValuesState.measurements, measurements)
        
        assertState(1) {
            XCTAssertEqual($0.off, false)
            XCTAssertEqual($0.setpointText, "23.0")
            XCTAssertEqual($0.plusButtonEnabled, true)
            XCTAssertEqual($0.minusButtonEnabled, true)
            XCTAssertEqual($0.powerIconColor, .primary)
            XCTAssertEqual($0.controlButtonsEnabled, true)
            XCTAssertEqual($0.configMinMaxHidden, false)
        }
    }
    
    func test_shouldLoadData_off() {
        // given
        var hvacValue = THVACValue(IsOn: 0, Mode: UInt8(SuplaHvacMode.off.value), SetpointTemperatureHeat: 0, SetpointTemperatureCool: 0, Flags: 0)
        let remoteId: Int32 = 231
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(bytes: &hvacValue, length: MemoryLayout<THVACValue>.size)
        channelValue.online = true
        channel.value = channelValue
        
        let measurements: [MeasurementValue] = [
            MeasurementValue(id: 0, icon: .suplaIcon(name: .Icons.fncUnknown), value: "12.2"),
            MeasurementValue(id: 1, icon: .suplaIcon(name: .Icons.fncUnknown), value: "21.2")
        ]
        
        readChannelWithChildrenTreeUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: [mockMainTemperatureChild()]))
        createTemperaturesListUseCase.returns = measurements
        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(mockHvacConfigEvent(remoteId)),
            Observable.just(mockWeeklyConfigEvent(remoteId))
        ]
        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock())
        )
        let expectation = expectation(description: "States loaded")
        
        // when
        var statesCount = 0
        observe(viewModel) { object in
            if (object is ThermostatGeneralViewState) {
                statesCount += 1
            }
            if (statesCount == 2) {
                expectation.fulfill()
            }
        }
        viewModel.observeData(remoteId: remoteId, deviceId: 321)
        viewModel.triggerDataLoad(remoteId: remoteId)
        
        // then
        waitForExpectations(timeout: 1)
        assertObserverItems(statesCount: 2, eventsCount: 0)
        let state = ThermostatGeneralViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.remoteId, to: remoteId)
                .changing(path: \.channelFunc, to: SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
                .changing(path: \.mode, to: .off)
                .changing(path: \.offline, to: false)
                .changing(path: \.configMin, to: 10)
                .changing(path: \.configMax, to: 40)
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: false))
                .changing(path: \.plusMinusHidden, to: true)
                .changing(path: \.heatingIndicatorActive, to: false)
                .changing(path: \.coolingIndicatorActive, to: false)
                .changing(path: \.currentTemperaturePercentage, to: 0.32666665)
                .changing(path: \.childrenIds, to: [0])
                .changing(path: \.activeSetpointType, to: .heat)
                .changing(path: \.subfunction, to: .heat)
        ])
        
        XCTAssertEqual(viewModel.thermometerValuesState.measurements, measurements)
        
        assertState(1) {
            XCTAssertEqual($0.off, true)
            XCTAssertEqual($0.setpointText, "off")
            XCTAssertEqual($0.plusButtonEnabled, false)
            XCTAssertEqual($0.minusButtonEnabled, false)
            XCTAssertEqual($0.powerIconColor, .red)
            XCTAssertEqual($0.operationalMode, .off(heating: false, cooling: false))
            XCTAssertEqual($0.controlButtonsEnabled, true)
            XCTAssertEqual($0.configMinMaxHidden, false)
        }
    }
    
    func test_shouldLoadData_offline() {
        // given
        let remoteId: Int32 = 231
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.online = false
        channel.value = channelValue
        
        let measurements: [MeasurementValue] = [
            MeasurementValue(id: 0, icon: .suplaIcon(name: .Icons.fncUnknown), value: "12.2"),
            MeasurementValue(id: 1, icon: .suplaIcon(name: .Icons.fncUnknown), value: "21.2")
        ]
        
        readChannelWithChildrenTreeUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: [mockMainTemperatureChild()]))
        createTemperaturesListUseCase.returns = measurements
        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(mockHvacConfigEvent(remoteId)),
            Observable.just(mockWeeklyConfigEvent(remoteId))
        ]
        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock())
        )
        let expectation = expectation(description: "States loaded")
        
        // when
        var statesCount = 0
        observe(viewModel) { object in
            if (object is ThermostatGeneralViewState) {
                statesCount += 1
            }
            if (statesCount == 2) {
                expectation.fulfill()
            }
        }
        viewModel.observeData(remoteId: remoteId, deviceId: 321)
        viewModel.triggerDataLoad(remoteId: remoteId)
        
        // then
        waitForExpectations(timeout: 1)
        assertObserverItems(statesCount: 2, eventsCount: 0)
        let state = ThermostatGeneralViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.remoteId, to: remoteId)
                .changing(path: \.channelFunc, to: SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
                .changing(path: \.mode, to: .unknown)
                .changing(path: \.offline, to: true)
                .changing(path: \.configMin, to: 10)
                .changing(path: \.configMax, to: 40)
                .changing(path: \.loadingState, to: state.loadingState.copy(loading: false))
                .changing(path: \.plusMinusHidden, to: true)
                .changing(path: \.heatingIndicatorActive, to: false)
                .changing(path: \.coolingIndicatorActive, to: false)
                .changing(path: \.childrenIds, to: [0])
        ])
        
        XCTAssertEqual(viewModel.thermometerValuesState.measurements, measurements)
        
        assertState(1) {
            XCTAssertEqual($0.off, true)
            XCTAssertEqual($0.setpointText, "offline")
            XCTAssertEqual($0.plusButtonEnabled, false)
            XCTAssertEqual($0.minusButtonEnabled, false)
            XCTAssertEqual($0.powerIconColor, .red)
            XCTAssertEqual($0.operationalMode, .offline)
            XCTAssertEqual($0.controlButtonsEnabled, false)
            XCTAssertEqual($0.configMinMaxHidden, true)
        }
    }
    
    func test_shouldSkipData_whenUserChanging() {
        // given
        let remoteId: Int32 = 231
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.online = false
        channel.value = channelValue
        
        readChannelWithChildrenTreeUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: [mockMainTemperatureChild()]))
        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(mockHvacConfigEvent(remoteId)),
            Observable.just(mockWeeklyConfigEvent(remoteId))
        ]
        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock())
        )
        
        let initialState = ThermostatGeneralViewState(changing: true)
        viewModel.updateView { _ in initialState }
        let expectation = expectation(description: "States loaded")
        
        // when
        var statesCount = 0
        observe(viewModel) { object in
            if (object is ThermostatGeneralViewState) {
                statesCount += 1
            }
            if (statesCount == 2) {
                expectation.fulfill()
            }
        }
        viewModel.observeData(remoteId: remoteId, deviceId: 321)
        viewModel.triggerDataLoad(remoteId: remoteId)
        
        // then
        waitForExpectations(timeout: 1)
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState
        ])
    }
    
    func test_shouldSkipData_whenDelayAfterLastInteractionNotElapsed() {
        // given
        let remoteId: Int32 = 231
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.online = false
        channel.value = channelValue
        
        readChannelWithChildrenTreeUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: [mockMainTemperatureChild()]))
        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(mockHvacConfigEvent(remoteId)),
            Observable.just(mockWeeklyConfigEvent(remoteId))
        ]
        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock())
        )
        dateProvider.currentTimestampReturns = .single(1001)
        
        let initialState = ThermostatGeneralViewState(lastInteractionTime: 1000)
        viewModel.updateView { _ in initialState }
        let expectation = expectation(description: "States loaded")
        
        // when
        var statesCount = 0
        observe(viewModel) { object in
            if (object is ThermostatGeneralViewState) {
                statesCount += 1
            }
            if (statesCount == 2) {
                expectation.fulfill()
            }
        }
        viewModel.observeData(remoteId: remoteId, deviceId: 321)
        viewModel.triggerDataLoad(remoteId: remoteId)
        
        // then
        waitForExpectations(timeout: 1)
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState
        ])
    }
    
    
    // MARK: - Setpoint position changing
    
    func test_shouldChangeHeatSetpointPosition() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
            .changing(path: \.remoteId, to: 1233)
            .changing(path: \.manualActive, to: true)
        
        viewModel.updateView { _ in initialState }
        
        dateProvider.currentTimestampReturns = .single(1100)
        
        // when
        observe(viewModel)
        viewModel.onPositionEvent(.mooving(setpointType: .heat, position: 0.5))
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.activeSetpointType, to: .heat)
                .changing(path: \.lastInteractionTime, to: 1100)
                .changing(path: \.changing, to: true)
                .changing(path: \.setpointHeat, to: 25)
        ])
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters, [
            ThermostatActionData(remoteId: 1233, setpointHeat: 25)
        ])
    }
    
    func test_shouldChangeCoolSetpointPosition() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
            .changing(path: \.remoteId, to: 1233)
            .changing(path: \.manualActive, to: true)
        
        viewModel.updateView { _ in initialState }
        
        dateProvider.currentTimestampReturns = .single(1100)
        
        // when
        observe(viewModel)
        viewModel.onPositionEvent(.mooving(setpointType: .cool, position: 0.5))
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.activeSetpointType, to: .cool)
                .changing(path: \.lastInteractionTime, to: 1100)
                .changing(path: \.changing, to: true)
                .changing(path: \.setpointCool, to: 25)
        ])
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters, [
            ThermostatActionData(remoteId: 1233, setpointCool: 25)
        ])
    }
    
    func test_shouldStopChanging_whenDraggingFinished() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.changing, to: true)
        
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.onPositionEvent(.finished)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.changing, to: false)
        ])
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters.count, 0)
    }
    
    // MARK: - Setpoint position changing by plus/minus buttons
    
    func test_shouldStepUpHeatTemperature() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.activeSetpointType, to: .heat)
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.setpointHeat, to: 22)
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        
        viewModel.updateView { _ in initialState }
        
        dateProvider.currentTimestampReturns = .single(1100)
        
        // when
        observe(viewModel)
        viewModel.onTemperatureChange(.smallUp)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.lastInteractionTime, to: 1100)
                .changing(path: \.setpointHeat, to: 22.1)
        ])
        assertState(1) {
            XCTAssertEqual($0.plusButtonEnabled, true)
            XCTAssertEqual($0.minusButtonEnabled, true)
        }
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters, [
            ThermostatActionData(remoteId: 12312, setpointHeat: 22.1)
        ])
    }
    
    func test_shouldStepDownCoolTemperature() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.activeSetpointType, to: .cool)
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.setpointCool, to: 22)
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        
        viewModel.updateView { _ in initialState }
        
        dateProvider.currentTimestampReturns = .single(1100)
        
        // when
        observe(viewModel)
        viewModel.onTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.lastInteractionTime, to: 1100)
                .changing(path: \.setpointCool, to: 21.9)
        ])
        assertState(1) {
            XCTAssertEqual($0.plusButtonEnabled, true)
            XCTAssertEqual($0.minusButtonEnabled, true)
        }
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters, [
            ThermostatActionData(remoteId: 12312, setpointCool: 21.9)
        ])
    }
    
    // MARK: - Plus/minus button disabling
    
    func test_shouldDisableMinusButtonReachingConfigMinTemperature() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.activeSetpointType, to: .cool)
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.setpointCool, to: 39.9)
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        
        viewModel.updateView { _ in initialState }
        
        dateProvider.currentTimestampReturns = .single(1100)
        
        // when
        observe(viewModel)
        viewModel.onTemperatureChange(.smallUp)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.lastInteractionTime, to: 1100)
                .changing(path: \.setpointCool, to: 40)
        ])
        assertState(1) {
            XCTAssertEqual($0.plusButtonEnabled, false)
            XCTAssertEqual($0.minusButtonEnabled, true)
        }
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters, [
            ThermostatActionData(remoteId: 12312, setpointCool: 40)
        ])
    }
    
    func test_shouldDisablePlusButtonReachingConfigMaxTemperature() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.activeSetpointType, to: .heat)
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.setpointHeat, to: 10.1)
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        
        viewModel.updateView { _ in initialState }
        
        dateProvider.currentTimestampReturns = .single(1100)
        
        // when
        observe(viewModel)
        viewModel.onTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.lastInteractionTime, to: 1100)
                .changing(path: \.setpointHeat, to: 10)
        ])
        assertState(1) {
            XCTAssertEqual($0.plusButtonEnabled, true)
            XCTAssertEqual($0.minusButtonEnabled, false)
        }
        XCTAssertEqual(delayedThermostatActionSubject.emitParameters, [
            ThermostatActionData(remoteId: 12312, setpointHeat: 10)
        ])
    }
    
    // MARK: - Power button
    
    func test_shouldTurnOnWhenTurnedOff() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.channelFunc, to: SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER)
            .changing(path: \.remoteId, to: 1231)
            .changing(path: \.mode, to: .off)
            .changing(path: \.offline, to: false)
        
        viewModel.updateView { _ in initialState }
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.onPowerButtonTap()
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.mode, to: .heat)
                .changing(path: \.loadingState, to: initialState.loadingState.copy(loading: true))
        ])
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters, [
            ThermostatActionData(remoteId: 1231, mode: .cmdTurnOn)
        ])
    }
    
    func test_shouldTurnOffWhenTurnedOn() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.remoteId, to: 1231)
            .changing(path: \.mode, to: .heat)
            .changing(path: \.offline, to: false)
        
        viewModel.updateView { _ in initialState }
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.onPowerButtonTap()
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.mode, to: .off)
                .changing(path: \.loadingState, to: initialState.loadingState.copy(loading: true))
        ])
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters, [
            ThermostatActionData(remoteId: 1231, mode: .off)
        ])
    }
    
    func test_shouldTurnOffWhenModeOffButWeeklyScheduleActive() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.remoteId, to: 1231)
            .changing(path: \.mode, to: .off)
            .changing(path: \.weeklyScheduleActive, to: true)
            .changing(path: \.offline, to: false)
        
        viewModel.updateView { _ in initialState }
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.onPowerButtonTap()
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.mode, to: .off)
                .changing(path: \.loadingState, to: initialState.loadingState.copy(loading: true))
        ])
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters, [
            ThermostatActionData(remoteId: 1231, mode: .off)
        ])
    }
    
    // MARK: - Manual button
    
    func test_shouldChangeToManual() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.weeklyScheduleActive, to: true)
        
        viewModel.updateView { _ in initialState }
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.onManualButtonTap()
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.manualActive, to: true)
                .changing(path: \.mode, to: .cmdSwitchToManual)
                .changing(path: \.weeklyScheduleActive, to: false)
                .changing(path: \.loadingState, to: initialState.loadingState.copy(loading: true))
        ])
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters, [
            ThermostatActionData(remoteId: 12312, mode: .cmdSwitchToManual)
        ])
    }
    
    func test_shouldNoChangeToManual_whenManualAlreadyActive() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.manualActive, to: true)
        
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.onManualButtonTap()
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState
        ])
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters.count, 0)
    }
    
    // MARK: - Weekly schedule button
    
    func test_shouldChangeToWeeklySchedule() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.manualActive, to: true)
        
        viewModel.updateView { _ in initialState }
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        observe(viewModel)
        viewModel.onWeeklyScheduleButtonTap()
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.manualActive, to: false)
                .changing(path: \.mode, to: .cmdWeeklySchedule)
                .changing(path: \.weeklyScheduleActive, to: true)
                .changing(path: \.loadingState, to: initialState.loadingState.copy(loading: true))
        ])
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters, [
            ThermostatActionData(remoteId: 12312, mode: .cmdWeeklySchedule)
        ])
    }
    
    func test_shouldNoChangeToWeeklySchedule_whenAlreadyActive() {
        // given
        let initialState = ThermostatGeneralViewState()
            .changing(path: \.remoteId, to: 12312)
            .changing(path: \.weeklyScheduleActive, to: true)
        
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.onWeeklyScheduleButtonTap()
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState
        ])
        XCTAssertEqual(delayedThermostatActionSubject.sendImmediatelyParameters.count, 0)
    }
    
    // MARK: - Mock functions
    
    private func mockMainTemperatureChild() -> SUPLA.ChannelChild {
        var temperature: Double = 19.8
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(bytes: &temperature, length: MemoryLayout<Double>.size)
        channelValue.online = true
        
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        channel.value = channelValue
        
        return ChannelChild(channel: channel, relation: SAChannelRelation.mock(type: .mainThermometer))
    }
    
    private func mockSensorChild() -> SUPLA.ChannelChild {
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_HOTELCARDSENSOR
        
        return ChannelChild(channel: channel, relation: SAChannelRelation.mock(type: .default))
    }
    
    private func mockHvacConfigEvent(_ remoteId: Int32) -> ChannelConfigEvent {
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
    
    private func mockWeeklyConfigEvent(_ remoteId: Int32) -> ChannelConfigEvent {
        ChannelConfigEvent(
            result: .resultTrue,
            config: SuplaChannelWeeklyScheduleConfig.mock(remoteId: remoteId)
        )
    }
}
