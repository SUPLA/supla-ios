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

@available(iOS 17.0, *)
final class ScheduleDetailVMTests: SuplaCore.ViewModelTest<ThermostatScheduleDetailFeature.ViewState> {
    private lazy var item: ItemBundle! = .init(remoteId: 1, deviceId: 1, subjectType: .channel, function: SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
    private lazy var viewModel: ThermostatScheduleDetailFeature.ViewModel! = .init(item: item)

    private lazy var channelConfigEventsManager: ChannelConfigEventsManagerMock! = ChannelConfigEventsManagerMock()

    private lazy var deviceConfigEventsManager: DeviceConfigEventsManagerMock! = DeviceConfigEventsManagerMock()

    private lazy var getChannelConfigUseCase: GetChannelConfigUseCaseMock! = GetChannelConfigUseCaseMock()

    private lazy var dealyedWeeklyScheduleConfigSubject: DelayedWeeklyScheduleConfigSubjectMock! = DelayedWeeklyScheduleConfigSubjectMock()

    private lazy var dateProvider: DateProviderMock! = DateProviderMock()

    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()

    private lazy var readChannelByRemoteIdUseCAse: ReadChannelByRemoteIdUseCaseMock! = ReadChannelByRemoteIdUseCaseMock()

    override func setUp() {
        DiContainer.shared.register(type: ChannelConfigEventsManager.self, channelConfigEventsManager!)
        DiContainer.shared.register(type: DeviceConfigEventsManager.self, deviceConfigEventsManager!)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, getChannelConfigUseCase!)
        DiContainer.shared.register(type: DelayedWeeklyScheduleConfigSubject.self, dealyedWeeklyScheduleConfigSubject!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: ValuesFormatter.self, ValuesFormatterMock())
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCAse!)
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
    }

    override func tearDown() {
        viewModel = nil

        channelConfigEventsManager = nil
        deviceConfigEventsManager = nil
        getChannelConfigUseCase = nil
        dealyedWeeklyScheduleConfigSubject = nil
        dateProvider = nil
        readChannelByRemoteIdUseCAse = nil
        settings = nil

        super.tearDown()
    }

    func test_shouldChangeProgramWhenTapped() {
        // given
        let newProgram = ScheduleDetailProgram(scheduleProgram: .OFF)

        // when
        let observer = observe(viewModel.state.$activeProgram, count: 2)
        viewModel.onProgramTap(newProgram) // activate
        viewModel.onProgramTap(newProgram) // deactivate

        // then
        wait(for: [observer.exp], timeout: 1)
        XCTAssertEqual(observer.receivedValues, [.off, nil])
    }

    func test_shouldOpenProgramEditDialog_forHeat() {
        // given
        let program = ScheduleDetailProgram(
            scheduleProgram: SuplaWeeklyScheduleProgram(
                program: .program2,
                mode: .heat,
                setpointTemperatureHeat: 2200,
                setpointTemperatureCool: nil
            )
        )
        viewModel.state.channelFunction = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        viewModel.state.thermostatSubfunction = .heat
        viewModel.state.programs = [program]
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40

        settings.temperatureUnitMock.returns = .single(.celsius)
        settings.temperaturePrecisionMock.returns = .single(1)

        // when
        viewModel.onShowProgramDialog(program)

        // then
        XCTAssertEqual(viewModel.state.editProgramState, ThermostatScheduleDetailFeature.EditProgramState(
            program: .program2,
            modes: SelectableList(selected: .heat, items: [.heat]),
            temperatureUnit: .celsius,
            heatSetpoint: ThermostatScheduleDetailFeature.SetpointData(plusDisabled: false, minusDisabled: false, valueCorrect: true, value: "22.0"),
            coolSetpoint: ThermostatScheduleDetailFeature.SetpointData(plusDisabled: false, minusDisabled: false, valueCorrect: true, value: "21.0")
        ))
    }

    func test_shouldOpenProgramEditDialog_forCool() {
        // given
        let program = ScheduleDetailProgram(
            scheduleProgram: SuplaWeeklyScheduleProgram(
                program: .program3,
                mode: .cool,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: 2100
            )
        )
        viewModel.state.channelFunction = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        viewModel.state.thermostatSubfunction = .cool
        viewModel.state.programs = [program]
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40

        settings.temperatureUnitMock.returns = .single(.celsius)
        settings.temperaturePrecisionMock.returns = .single(1)

        // when
        viewModel.onShowProgramDialog(program)

        // then
        XCTAssertEqual(viewModel.state.editProgramState, ThermostatScheduleDetailFeature.EditProgramState(
            program: .program3,
            modes: SelectableList(selected: .cool, items: [.cool]),
            temperatureUnit: .celsius,
            heatSetpoint: ThermostatScheduleDetailFeature.SetpointData(plusDisabled: false, minusDisabled: false, valueCorrect: true, value: "21.0"),
            coolSetpoint: ThermostatScheduleDetailFeature.SetpointData(plusDisabled: false, minusDisabled: false, valueCorrect: true, value: "21.0"),
        ))
    }

    func test_shouldChangeBoxOnTap() {
        // given
        let firstKey = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 0)
        let schedule: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [
            firstKey: ThermostatScheduleDetailBoxValue(oneProgram: .program2),
            ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1): ThermostatScheduleDetailBoxValue(oneProgram: .program1)
        ]
        viewModel.state.schedule = schedule
        viewModel.state.activeProgram = .program3

        // when
        viewModel.onBoxTap(firstKey)

        // then
        XCTAssertEqual(viewModel.state.schedule[firstKey], ThermostatScheduleDetailBoxValue(oneProgram: .program3))
        XCTAssertEqual(viewModel.state.changing, true)
        XCTAssertEqual(viewModel.state.lastInteractionTime, nil)
    }

    func test_shouldNotChangeBoxWhenNoProgramActive() {
        // given
        let firstKey = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 0)
        let schedule: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [
            firstKey: ThermostatScheduleDetailBoxValue(oneProgram: .program2),
            ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1): ThermostatScheduleDetailBoxValue(oneProgram: .program1)
        ]
        viewModel.state.schedule = schedule

        // when
        viewModel.onBoxTap(firstKey)

        // then
        XCTAssertEqual(viewModel.state.schedule[firstKey], ThermostatScheduleDetailBoxValue(oneProgram: .program2))
        XCTAssertEqual(viewModel.state.changing, false)
        XCTAssertEqual(viewModel.state.lastInteractionTime, nil)
    }

    func test_shouldOpenQuartersEditDialog() {
        // given
        let activeProgram = SuplaScheduleProgram.program4
        let firstKey = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 0)
        let firstValue = ThermostatScheduleDetailBoxValue(oneProgram: .program2)
        let schedule: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [
            firstKey: firstValue,
            ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1): ThermostatScheduleDetailBoxValue(oneProgram: .program1)
        ]
        let programs = [
            ScheduleDetailProgram(
                scheduleProgram: SuplaWeeklyScheduleProgram(
                    program: .program2,
                    mode: .heat,
                    setpointTemperatureHeat: 2200,
                    setpointTemperatureCool: nil
                )
            )
        ]
        viewModel.state.activeProgram = activeProgram
        viewModel.state.schedule = schedule
        viewModel.state.programs = programs

        // when
        viewModel.onShowQuartersDialog(firstKey)

        // then
        XCTAssertEqual(viewModel.state.editQuartersState, ThermostatScheduleDetailFeature.EditQuartersState(
            key: firstKey,
            programs: programs,
            activeProgram: activeProgram,
            hourPrograms: firstValue
        ))
    }

    func test_shouldLoadConfigs() {
        // given
        let channelFunction: Int32 = 213
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig.mock(
            remoteId: item.remoteId,
            channelFunc: channelFunction
        )
        let hvacConfig = SuplaChannelHvacConfig.mock(
            remoteId: item.remoteId,
            channelFunction: channelFunction,
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )

        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]

        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock(
                availableFields: [.automaticTimeSync],
                fields: [SuplaAutomaticTimeSyncField(enabled: false)]
            )
        ))

        // when
        viewModel.observeConfig()

        // then
        XCTAssertEqual(viewModel.state.channelFunction, channelFunction)
        XCTAssertEqual(viewModel.state.thermostatSubfunction, .heat)
        XCTAssertEqual(viewModel.state.programs, [
            ScheduleDetailProgram(
                scheduleProgram: .OFF,
                icon: .Icons.powerButton
            )
        ])
        XCTAssertEqual(viewModel.state.configMin, 10)
        XCTAssertEqual(viewModel.state.configMax, 40)
        XCTAssertEqual(viewModel.state.currentDay, nil)
        XCTAssertEqual(viewModel.state.currentHour, nil)
    }

    func test_shouldSkipLoadingScheduleWhenChannelConfigNotLoadedCorrectly() {
        // given
        let channelFunction: Int32 = 213
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig.mock(
            remoteId: item.remoteId,
            channelFunc: channelFunction
        )
        let hvacConfig = SuplaChannelHvacConfig.mock(
            remoteId: item.remoteId,
            channelFunction: channelFunction,
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )

        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultFalse, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .dataError, config: hvacConfig))
        ]

        // when
        viewModel.observeConfig()

        // then
        XCTAssertEqual(viewModel.state.channelFunction, nil)
        XCTAssertEqual(viewModel.state.thermostatSubfunction, nil)
        XCTAssertEqual(viewModel.state.programs, [])
        XCTAssertEqual(viewModel.state.configMin, nil)
        XCTAssertEqual(viewModel.state.configMax, nil)
        XCTAssertEqual(viewModel.state.currentDay, nil)
        XCTAssertEqual(viewModel.state.currentHour, nil)
    }

    func test_shouldSkipLoadingWhenMinMaxNotSet() {
        // given
        let channelFunction: Int32 = 213
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig.mock(
            remoteId: item.remoteId,
            channelFunc: channelFunction
        )
        let hvacConfig = SuplaChannelHvacConfig.mock(
            remoteId: item.remoteId,
            channelFunction: channelFunction,
            subfunction: .heat,
            configMin: 1000,
            configMax: nil
        )

        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]

        // when
        viewModel.observeConfig()

        // then
        XCTAssertEqual(viewModel.state.channelFunction, nil)
        XCTAssertEqual(viewModel.state.thermostatSubfunction, nil)
        XCTAssertEqual(viewModel.state.programs, [])
        XCTAssertEqual(viewModel.state.configMin, nil)
        XCTAssertEqual(viewModel.state.configMax, nil)
        XCTAssertEqual(viewModel.state.currentDay, nil)
        XCTAssertEqual(viewModel.state.currentHour, nil)
    }
    
    func test_shouldSkipProcessingDataWhenChanging() {
        // given
        let channelFunction: Int32 = 213
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig.mock(
            remoteId: item.remoteId,
            channelFunc: channelFunction
        )
        let hvacConfig = SuplaChannelHvacConfig.mock(
            remoteId: item.remoteId,
            channelFunction: channelFunction,
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )

        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]

        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock()
        ))

        viewModel.state.changing = true

        // when
        viewModel.observeConfig()

        // then
        XCTAssertEqual(viewModel.state.channelFunction, nil)
        XCTAssertEqual(viewModel.state.thermostatSubfunction, nil)
        XCTAssertEqual(viewModel.state.programs, [])
        XCTAssertEqual(viewModel.state.configMin, nil)
        XCTAssertEqual(viewModel.state.configMax, nil)
        XCTAssertEqual(viewModel.state.currentDay, nil)
        XCTAssertEqual(viewModel.state.currentHour, nil)
    }
    
    func test_shouldSkipLoadingWhenDelayAfterManualChangesNotElapsed() {
        // given
        let channelFunction: Int32 = 213
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig.mock(
            remoteId: item.remoteId,
            channelFunc: channelFunction
        )
        let hvacConfig = SuplaChannelHvacConfig.mock(
            remoteId: item.remoteId,
            channelFunction: channelFunction,
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )

        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]

        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock()
        ))

        dateProvider.currentTimestampReturns = .single(1003)
        viewModel.state.lastInteractionTime = 1000

        // when
        viewModel.observeConfig()

        // then
        XCTAssertEqual(viewModel.state.channelFunction, nil)
        XCTAssertEqual(viewModel.state.thermostatSubfunction, nil)
        XCTAssertEqual(viewModel.state.programs, [])
        XCTAssertEqual(viewModel.state.configMin, nil)
        XCTAssertEqual(viewModel.state.configMax, nil)
        XCTAssertEqual(viewModel.state.currentDay, nil)
        XCTAssertEqual(viewModel.state.currentHour, nil)
        
        XCTAssertTuples(getChannelConfigUseCase.parameters, [
            (item.remoteId, .defaultConfig),
            (item.remoteId, .weeklyScheduleConfig)
        ])
    }
    
    func test_shouldLoadConfigsAndLoadSubfunctionFromValue() {
        // given
        let remoteId: Int32 = 123
        let channelFunction: Int32 = 213
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig.mock(
            remoteId: remoteId,
            channelFunc: channelFunction
        )
        let hvacConfig = SuplaChannelHvacConfig.mock(
            remoteId: remoteId,
            channelFunction: channelFunction,
            subfunction: .notSet,
            configMin: 1000,
            configMax: 4000
        )

        channelConfigEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]

        deviceConfigEventsManager.observeConfigReturns = .just(DeviceConfigEvent(
            result: .resultTrue,
            config: SuplaDeviceConfig.mock(
                availableFields: [.automaticTimeSync],
                fields: [SuplaAutomaticTimeSyncField(enabled: true)]
            )
        ))

        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        channel.value = .mockThermostat()
        readChannelByRemoteIdUseCAse.returns = Observable.just(channel)
        
        dateProvider.currentDateReturns = Date(timeIntervalSince1970: 1775634456)

        // when
        viewModel.observeConfig()

        // then
        XCTAssertEqual(viewModel.state.channelFunction, channelFunction)
        XCTAssertEqual(viewModel.state.thermostatSubfunction, .heat)
        XCTAssertEqual(viewModel.state.programs, [
            ScheduleDetailProgram(
                scheduleProgram: .OFF,
                icon: .Icons.powerButton
            )
        ])
        XCTAssertEqual(viewModel.state.configMin, 10)
        XCTAssertEqual(viewModel.state.configMax, 40)
        XCTAssertNotNil(viewModel.state.currentDay)
        XCTAssertNotNil(viewModel.state.currentHour)
    }
}
