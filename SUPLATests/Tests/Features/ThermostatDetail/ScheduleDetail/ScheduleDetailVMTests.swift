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

@testable import SUPLA

final class ScheduleDetailVMTests: ViewModelTest<ScheduleDetailViewState, ScheduleDetailViewEvent> {
    
    private lazy var viewModel: ScheduleDetailVM! = { ScheduleDetailVM() }()
    
    private lazy var configEventsManager: ConfigEventsManagerMock! = {
        ConfigEventsManagerMock()
    }()
    private lazy var getChannelConfigUseCase: GetChannelConfigUseCaseMock! = {
        GetChannelConfigUseCaseMock()
    }()
    private lazy var dealyedWeeklyScheduleConfigSubject: DelayedWeeklyScheduleConfigSubjectMock! = {
        DelayedWeeklyScheduleConfigSubjectMock()
    }()
    private lazy var dateProvider: DateProviderMock! = {
        DateProviderMock()
    }()
    private lazy var readChannelByRemoteIdUseCAse: ReadChannelByRemoteIdUseCaseMock! = {
        ReadChannelByRemoteIdUseCaseMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: ChannelConfigEventsManager.self, component: configEventsManager!)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, component: getChannelConfigUseCase!)
        DiContainer.shared.register(type: DelayedWeeklyScheduleConfigSubject.self, component: dealyedWeeklyScheduleConfigSubject!)
        DiContainer.shared.register(type: DateProvider.self, component: dateProvider!)
        DiContainer.shared.register(type: ValuesFormatter.self, component: ValuesFormatterMock())
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, component: readChannelByRemoteIdUseCAse!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        configEventsManager = nil
        getChannelConfigUseCase = nil
        dealyedWeeklyScheduleConfigSubject = nil
        dateProvider = nil
        readChannelByRemoteIdUseCAse = nil
        
        super.tearDown()
    }
    
    func test_shouldChangeProgramWhenTapped() {
        // given
        let newProgram = SuplaScheduleProgram.program2
        
        // when
        observe(viewModel)
        viewModel.onProgramTap(newProgram) // activate
        viewModel.onProgramTap(newProgram) // deactivate
        
        // then
        assertObserverItems(statesCount: 3, eventsCount: 0)
        
        let state = ScheduleDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.activeProgram, to: newProgram),
            state
        ])
    }
    
    func test_shouldOpenProgramEditDialog_forHeat() {
        // given
        let program = ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program2, mode: .heat, setpointTemperatureHeat: 2200, setpointTemperatureCool: nil))
        let state = ScheduleDetailViewState(
            channelFunction: SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
            thermostatSubfunction: .heat,
            programs: [program],
            configMin: 10,
            configMax: 40
        )
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.onProgramLongPress(.program2)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 1)
        
        XCTAssertEqual(
            eventObserver.events[0].value.element,
            .editProgram(
                state: EditProgramDialogViewState(
                    program: program,
                    heatTemperatureText: "22.0",
                    showHeatEdit: true,
                    showCoolEdit: false,
                    configMin: 10,
                    configMax: 40
                )
            )
        )
    }
    
    func test_shouldOpenProgramEditDialog_forCool() {
        // given
        let program = ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program2, mode: .cool, setpointTemperatureHeat: nil, setpointTemperatureCool: 2200))
        viewModel.updateView { _ in
            ScheduleDetailViewState(
                channelFunction: SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
                thermostatSubfunction: .cool,
                programs: [program],
                configMin: 10,
                configMax: 40
            )
        }
        
        // when
        observe(viewModel)
        viewModel.onProgramLongPress(.program2)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 1)
        
        XCTAssertEqual(
            eventObserver.events[0].value.element,
            .editProgram(
                state: EditProgramDialogViewState(
                    program: program,
                    coolTemperatureText: "22.0",
                    showHeatEdit: false,
                    showCoolEdit: true,
                    configMin: 10,
                    configMax: 40
                )
            )
        )
    }
    
    func test_shouldChangeBoxOnTap() {
        // given
        let firstKey = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 0)
        let schedule: [ScheduleDetailBoxKey: ScheduleDetailBoxValue] = [
            firstKey : ScheduleDetailBoxValue(oneProgram: .program2),
            ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1) : ScheduleDetailBoxValue(oneProgram: .program1)
        ]
        viewModel.updateView { _ in
            ScheduleDetailViewState(
                activeProgram: .off,
                schedule: schedule
            )
        }
        dateProvider.currentTimestampReturns = 123
        
        // when
        observe(viewModel)
        viewModel.onBoxEvent(.panning(boxKey: firstKey))
        viewModel.onBoxEvent(.finished)
        
        // then
        assertObserverItems(statesCount: 3, eventsCount: 0)
        let state = ScheduleDetailViewState(activeProgram: .off, schedule: schedule)
        assertStates(expected: [
            state,
            state
                .changing(path: \.schedule, to: [
                    firstKey : ScheduleDetailBoxValue(oneProgram: .off),
                    ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1) : ScheduleDetailBoxValue(oneProgram: .program1)
                ])
                .changing(path: \.changing, to: true),
            state
                .changing(path: \.schedule, to: [
                    firstKey : ScheduleDetailBoxValue(oneProgram: .off),
                    ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1) : ScheduleDetailBoxValue(oneProgram: .program1)
                ])
                .changing(path: \.lastInteractionTime, to: 123)
        ])
    }
    
    func test_shouldNotChangeBoxWhenNoProgramActive() {
        // given
        let firstKey = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 0)
        let schedule: [ScheduleDetailBoxKey: ScheduleDetailBoxValue] = [
            firstKey : ScheduleDetailBoxValue(oneProgram: .program2),
            ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1) : ScheduleDetailBoxValue(oneProgram: .program1)
        ]
        viewModel.updateView { _ in
            ScheduleDetailViewState(
                schedule: schedule
            )
        }
        
        // when
        observe(viewModel)
        viewModel.onBoxEvent(.panning(boxKey: firstKey))
        viewModel.onBoxEvent(.finished)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0)
        let state = ScheduleDetailViewState(schedule: schedule)
        assertStates(expected: [
            state,
        ])
    }
    
    func test_shouldOpenQuartersEditDialog() {
        // given
        let activeProgram = SuplaScheduleProgram.program4
        let firstKey = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 0)
        let firstValue = ScheduleDetailBoxValue(oneProgram: .program2)
        let schedule: [ScheduleDetailBoxKey: ScheduleDetailBoxValue] = [
            firstKey : firstValue,
            ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1) : ScheduleDetailBoxValue(oneProgram: .program1)
        ]
        let programs = [ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program2, mode: .heat, setpointTemperatureHeat: 2200, setpointTemperatureCool: nil))]
        viewModel.updateView { _ in
            ScheduleDetailViewState(
                activeProgram: activeProgram,
                schedule: schedule,
                programs: programs
            )
        }
        
        // when
        observe(viewModel)
        viewModel.onBoxLongPress(firstKey)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 1)
        assertEvent(0, equalTo: .editScheduleBox(
            state: EditQuartersDialogViewState(
                key: firstKey,
                activeProgram: activeProgram,
                availablePrograms: programs,
                quarterPrograms: firstValue
            )
        ))
    }
    
    func test_shouldTakeOverQuarterChanges() {
        // given
        let remoteId: Int32 = 123
        let firstKey = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 0)
        let firstValue = ScheduleDetailBoxValue(oneProgram: .program2)
        let schedule: [ScheduleDetailBoxKey: ScheduleDetailBoxValue] = [
            firstKey : firstValue,
            ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1) : ScheduleDetailBoxValue(oneProgram: .program1)
        ]
        let initialState = ScheduleDetailViewState(
            remoteId: remoteId,
            activeProgram: .program3,
            schedule: schedule
        )
        viewModel.updateView { _ in initialState }
        dateProvider.currentTimestampReturns = 4321
        
        // when
        observe(viewModel)
        viewModel.onQuartersChanged(key: firstKey, value: ScheduleDetailBoxValue(oneProgram: .program1), activeProgram: .program1)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState
                .changing(path: \.schedule, to: [
                    firstKey : ScheduleDetailBoxValue(oneProgram: .program1),
                    ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 1) : ScheduleDetailBoxValue(oneProgram: .program1)
                    
                ])
                .changing(path: \.activeProgram, to: .program1)
                .changing(path: \.lastInteractionTime, to: 4321)
        ])
        XCTAssertEqual(dealyedWeeklyScheduleConfigSubject.emitParameters.count, 1)
        XCTAssertEqual(dealyedWeeklyScheduleConfigSubject.emitParameters[0].remoteId, remoteId)
        XCTAssertEqual(dealyedWeeklyScheduleConfigSubject.emitParameters[0].programs, [])
        XCTAssertEqual(dealyedWeeklyScheduleConfigSubject.emitParameters[0].schedule.count, 8)
    }
    
    func test_shouldTakeOverProgramChanges() {
        // given
        let newProgram = ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program2, mode: .cool, setpointTemperatureHeat: nil, setpointTemperatureCool: 2100))
        let programs = [
            ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program2, mode: .heat, setpointTemperatureHeat: 2200, setpointTemperatureCool: nil)),
            ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program1, mode: .heat, setpointTemperatureHeat: 2400, setpointTemperatureCool: nil))
        ]
        let initialState = ScheduleDetailViewState(
            remoteId: 4321,
            activeProgram: .program1,
            programs: programs
        )
        viewModel.updateView { _ in initialState }
        dateProvider.currentTimestampReturns = 123
        
        // when
        observe(viewModel)
        viewModel.onProgramChanged(newProgram)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.programs, to: [newProgram, programs[1]])
                .changing(path: \.activeProgram, to: newProgram.scheduleProgram.program)
                .changing(path: \.lastInteractionTime, to: 123)
        ])
        XCTAssertEqual(dealyedWeeklyScheduleConfigSubject.emitParameters, [
            WeeklyScheduleConfigData(
                remoteId: 4321,
                programs: [
                    SuplaWeeklyScheduleProgram(program: .program2, mode: .cool, setpointTemperatureHeat: nil, setpointTemperatureCool: 2100),
                    SuplaWeeklyScheduleProgram(program: .program1, mode: .heat, setpointTemperatureHeat: 2400, setpointTemperatureCool: nil)
                ],
                schedule: []
            )
        ])
    }
    
    func test_shouldLoadConfigs() {
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
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )
        
        configEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]
        
        // when
        observe(viewModel)
        viewModel.observeConfig(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        let state = ScheduleDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.channelFunction, to: channelFunction)
                .changing(path: \.thermostatSubfunction, to: .heat)
                .changing(path: \.remoteId, to: remoteId)
                .changing(path: \.programs, to: [
                    ScheduleDetailProgram(
                        scheduleProgram: .OFF,
                        icon: .iconPowerButton
                    )
                ])
                .changing(path: \.configMin, to: 10)
                .changing(path: \.configMax, to: 40)
        ])
    }
    
    func test_shouldSkipWhenResultNotTrue() {
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
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )
        
        configEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultFalse, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .dataError, config: hvacConfig))
        ]
        
        // when
        observe(viewModel)
        viewModel.observeConfig(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0)
        let state = ScheduleDetailViewState()
        assertStates(expected: [
            state,
        ])
    }
    
    func test_shouldSkipWhenMinMaxNotSet() {
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
            subfunction: .heat,
            configMin: 1000,
            configMax: nil
        )
        
        configEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]
        
        // when
        observe(viewModel)
        viewModel.observeConfig(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 0)
        let state = ScheduleDetailViewState()
        assertStates(expected: [
            state,
        ])
    }
    
    func test_shouldSkipWhenChanging() {
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
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )
        
        configEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]
        
        let initialState = ScheduleDetailViewState(changing: true)
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.observeConfig(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState,
        ])
    }
    
    func test_shouldSkipWhenDelayAfterManualChangesNotElapsed() {
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
            subfunction: .heat,
            configMin: 1000,
            configMax: 4000
        )
        
        configEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]
        
        dateProvider.currentTimestampReturns = 1003
        let initialState = ScheduleDetailViewState(lastInteractionTime: 1000)
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.observeConfig(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState,
        ])
        XCTAssertTuples(getChannelConfigUseCase.parameters, [
            (remoteId, .defaultConfig),
            (remoteId, .weeklyScheduleConfig)
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
        
        configEventsManager.observeConfigReturns = [
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: weeklyConfig)),
            Observable.just(ChannelConfigEvent(result: .resultTrue, config: hvacConfig))
        ]
        
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        channel.value = .mockThermostat()
        readChannelByRemoteIdUseCAse.returns = Observable.just(channel)
        
        // when
        observe(viewModel)
        viewModel.observeConfig(remoteId: remoteId)
        
        // then
        assertObserverItems(statesCount: 3, eventsCount: 0)
        let state = ScheduleDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.channelFunction, to: channelFunction)
                .changing(path: \.thermostatSubfunction, to: .notSet)
                .changing(path: \.remoteId, to: remoteId)
                .changing(path: \.programs, to: [
                    ScheduleDetailProgram(
                        scheduleProgram: .OFF,
                        icon: .iconPowerButton
                    )
                ])
                .changing(path: \.configMin, to: 10)
                .changing(path: \.configMax, to: 40),
            state.changing(path: \.channelFunction, to: channelFunction)
                .changing(path: \.thermostatSubfunction, to: .heat)
                .changing(path: \.remoteId, to: remoteId)
                .changing(path: \.programs, to: [
                    ScheduleDetailProgram(
                        scheduleProgram: .OFF,
                        icon: .iconPowerButton
                    )
                ])
                .changing(path: \.configMin, to: 10)
                .changing(path: \.configMax, to: 40)
        ])
    }
}
