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
@testable import SUPLA
import XCTest

final class ThermostatTimerDetailVMTests: ViewModelTest<ThermostatTimerDetailViewState, ThermostatTimerDetailViewEvent> {
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = {
        ReadChannelByRemoteIdUseCaseMock()
    }()
    
    private lazy var channelConfigEventManager: ChannelConfigEventsManagerMock! = {
        ChannelConfigEventsManagerMock()
    }()
    
    private lazy var getChannelConfigUseCase: GetChannelConfigUseCaseMock! = {
        GetChannelConfigUseCaseMock()
    }()
    
    private lazy var executeThermostatActionUseCase: ExecuteThermostatActionUseCaseMock! = {
        ExecuteThermostatActionUseCaseMock()
    }()
    
    private lazy var dateProvider: DateProviderMock! = {
        DateProviderMock()
    }()
    
    private lazy var viewModel: ThermostatTimerDetailVM! = {
        ThermostatTimerDetailVM()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, component: readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: ChannelConfigEventsManager.self, component: channelConfigEventManager!)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, component: getChannelConfigUseCase!)
        DiContainer.shared.register(type: ExecuteThermostatActionUseCase.self, component: executeThermostatActionUseCase!)
        DiContainer.shared.register(type: DateProvider.self, component: dateProvider!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        readChannelByRemoteIdUseCase = nil
        channelConfigEventManager = nil
        getChannelConfigUseCase = nil
        executeThermostatActionUseCase = nil
        dateProvider = nil
        
        viewModel = nil
    }
    
    func test_shouldToggleDeviceMode() {
        // given
        let mode: TimerDetailDeviceMode = .manual
        
        // when
        observe(viewModel)
        viewModel.toggleDeviceMode(deviceMode: mode)
        
        // then
        let state = ThermostatTimerDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.selectedMode, to: mode)
        ])
    }
    
    func test_shouldToggleSelectorMode() {
        // when
        observe(viewModel)
        viewModel.toggleSelectorMode()
        
        // then
        let state = ThermostatTimerDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.showCalendar, to: !state.showCalendar)
        ])
    }
    
    func test_shouldChangeCalendarDate() {
        // given
        let date: Date = Date.create(year: 2023, month: 10, day: 12)!
        
        // when
        observe(viewModel)
        viewModel.onDateChanged(date: date)
        
        // then
        let state = ThermostatTimerDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.calendarValue, to: date)
        ])
    }
    
    func test_shouldChangeTimerValues() {
        // given
        let values = TrippleNumberSelectorView.Value(firstValue: 10, secondValue: 10, thirdValue: 10)
        
        // when
        observe(viewModel)
        viewModel.onTimerValueChanged(value: values)
        
        // then
        let state = ThermostatTimerDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.pickerValue, to: values)
        ])
    }
    
    func test_shouldChangeTemperatureByValue() {
        // given
        let temperature: Float = 14.3
        
        // when
        observe(viewModel)
        viewModel.onTemperatureChange(temperature: temperature)
        
        // then
        let state = ThermostatTimerDetailViewState()
        assertStates(expected: [
            state,
            state.changing(path: \.currentTemperature, to: temperature)
        ])
    }
    
    func test_shouldChangeTemperatureByStep() {
        // given
        let state = ThermostatTimerDetailViewState(currentTemperature: 14.2)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        viewModel.onTemperatureChange(step: .smallUp)
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.currentTemperature, to: 14.3)
        ])
    }
    
    func test_shouldNotStartTimerWhenRemoteIdMissing() {
        // when
        observe(viewModel)
        viewModel.onStartTimer()
        
        // then
        let state = ThermostatTimerDetailViewState()
        assertStates(expected: [ state ])
        XCTAssertEqual(executeThermostatActionUseCase.parameters.count, 0)
    }
    
    func test_shouldNotStartTimerWhenDurationMissing() {
        // given
        let state = ThermostatTimerDetailViewState(remoteId: 123, showCalendar: true)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        viewModel.onStartTimer()
        
        // then
        assertStates(expected: [ state ])
        XCTAssertEqual(executeThermostatActionUseCase.parameters.count, 0)
    }
    
    func test_shouldStartTimer_usingTimePicker() {
        // given
        let remoteId: Int32 = 123
        let state = ThermostatTimerDetailViewState(remoteId: remoteId, selectedMode: .off)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        viewModel.onStartTimer()
        
        // then
        assertStates(expected: [ 
            state,
            state.changing(path: \.loadingState, to: state.loadingState.copy(loading: true))
        ])
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, remoteId, SuplaHvacMode.off, nil, nil, 10800)
        ])
    }
    
    func test_shouldStartTimer_usingTimeCalendar() {
        // given
        let remoteId: Int32 = 123
        let currentDate = Date.create(year: 2023, month: 11, day: 3, hour: 12)!
        let endDate = Date.create(year: 2023, month: 11, day: 6, hour: 12)!
        
        let state = ThermostatTimerDetailViewState(
            remoteId: remoteId,
            currentTemperature: 14.5,
            usingHeatSetpoint: true,
            selectedMode: .manual,
            showCalendar: true,
            calendarValue: endDate
        )
        viewModel.updateView(state: state)
        dateProvider.currentDateReturns = currentDate
        
        // when
        observe(viewModel)
        viewModel.onStartTimer()
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.loadingState, to: state.loadingState.copy(loading: true))
        ])
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, remoteId, SuplaHvacMode.heat, 14.5, nil, Int32(currentDate.differenceInSeconds(endDate)))
        ])
    }
    
    func test_shouldStartManualMode() {
        // given
        let remoteId: Int32 = 123
        let state = ThermostatTimerDetailViewState(remoteId: remoteId)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        viewModel.cancelTimerStartManual()
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.loadingState, to: state.loadingState.copy(loading: true))
        ])
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, remoteId, SuplaHvacMode.cmdSwitchToManual, nil, nil, nil)
        ])
    }
    
    func test_shouldStartProgramMode() {
        // given
        let remoteId: Int32 = 123
        let state = ThermostatTimerDetailViewState(remoteId: remoteId)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        viewModel.cancelTimerStartProgram()
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.loadingState, to: state.loadingState.copy(loading: true))
        ])
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, remoteId, SuplaHvacMode.cmdWeeklySchedule, nil, nil, nil)
        ])
    }
    
    func test_shouldStartTimerEdit() {
        // given
        let remoteId: Int32 = 123
        let currentDate = Date.create(year: 2023, month: 11, day: 3, hour: 12)!
        let endDate = Date.create(year: 2023, month: 11, day: 6, hour: 12)!
        let state = ThermostatTimerDetailViewState(
            remoteId: remoteId,
            currentMode: .heat,
            currentDate: currentDate,
            timerEndDate: endDate
        )
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        viewModel.editTimer()
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.editTime, to: true)
                .changing(path: \.pickerValue, to: .init(valueForDays: currentDate.differenceInSeconds(endDate)))
                .changing(path: \.calendarValue, to: endDate)
                .changing(path: \.selectedMode, to: .manual)
        ])
        XCTAssertEqual(executeThermostatActionUseCase.parameters.count, 0)
    }
    
    func test_shouldCancelTimerEdit() {
        // given
        let remoteId: Int32 = 123
        let state = ThermostatTimerDetailViewState(remoteId: remoteId, editTime: true)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        viewModel.editTimerCancel()
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.editTime, to: false)
        ])
    }
}
