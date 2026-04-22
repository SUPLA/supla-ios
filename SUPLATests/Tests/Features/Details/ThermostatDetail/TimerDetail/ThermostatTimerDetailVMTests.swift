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
import SharedCore
@testable import SUPLA
import XCTest

final class ThermostatTimerDetailVMTests: SuplaCore.ViewModelTest<ThermostatTimerDetailFeature.ViewState> {
    private lazy var item: ItemBundle! = .init(remoteId: 1, deviceId: 1, subjectType: .channel, function: SUPLA_CHANNELFNC_HVAC_THERMOSTAT)
    private lazy var viewModel: ThermostatTimerDetailFeature.ViewModel! = .init(item: item)
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = ReadChannelByRemoteIdUseCaseMock()
    
    private lazy var channelConfigEventManager: ChannelConfigEventsManagerMock! = ChannelConfigEventsManagerMock()
    
    private lazy var getChannelConfigUseCase: GetChannelConfigUseCaseMock! = GetChannelConfigUseCaseMock()
    
    private lazy var executeThermostatActionUseCase: ExecuteThermostatActionUseCaseMock! = ExecuteThermostatActionUseCaseMock()
    
    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: ChannelConfigEventsManager.self, channelConfigEventManager!)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, getChannelConfigUseCase!)
        DiContainer.shared.register(type: ExecuteThermostatActionUseCase.self, executeThermostatActionUseCase!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
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
        let mode: ThermostatTimerDetailFeature.DeviceMode = .heating
        
        // when
        viewModel.onDeviceModeChange(mode)
        
        // then
        XCTAssertEqual(viewModel.state.setpointInChange, .heat)
    }
    
    func test_shouldToggleSelectorMode() {
        // when
        viewModel.onTimeSelectionModeChange(.calendar)
        
        // then
        XCTAssertEqual(viewModel.state.timeSelectionMode, .calendar)
    }
    
    func test_shouldChangeCoolTemperatureByValue() {
        // given
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40
        
        // when
        viewModel.onCoolValueChange(0.5)
        
        // then
        XCTAssertEqual(viewModel.state.coolSetpoint, 25.0)
        XCTAssertEqual(viewModel.state.setpointInChange, .cool)
    }
    
    func test_shouldChangeHeatTemperatureByValue() {
        // given
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40
        
        // when
        viewModel.onHeatValueChange(0.5)
        
        // then
        XCTAssertEqual(viewModel.state.heatSetpoint, 25.0)
        XCTAssertEqual(viewModel.state.setpointInChange, .heat)
    }
    
    func test_shouldChangeCoolTemperatureByStep() {
        // given
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40
        viewModel.state.setpointInChange = .cool
        viewModel.state.coolSetpoint = 25.0
        
        // when
        viewModel.onSetpointChange(.smallUp)
        
        // then
        XCTAssertEqual(viewModel.state.coolSetpoint, 25.1)
    }
    
    func test_shouldChangeHeatTemperatureByStep() {
        // given
        viewModel.state.configMin = 10
        viewModel.state.configMax = 40
        viewModel.state.setpointInChange = .heat
        viewModel.state.heatSetpoint = 25.0
        
        // when
        viewModel.onSetpointChange(.smallDown)
        
        // then
        XCTAssertEqual(viewModel.state.heatSetpoint, 24.9)
    }
    
    func test_shouldNotStartTimerWhenDurationMissing() {
        // given
        viewModel.state.timerMinutes = 0.asMinutePickerItem
        viewModel.state.timerHours = 0.asHourPickerItem
        viewModel.state.timerDays = 0.asDayPickerItem
        
        // when
        viewModel.onStart()
        
        // then
        XCTAssertEqual(executeThermostatActionUseCase.parameters.count, 0)
    }
    
    func test_shouldStartTimer_usingTimePicker() {
        // given
        viewModel.state.timerMinutes = 1.asMinutePickerItem
        viewModel.state.timerHours = 0.asHourPickerItem
        viewModel.state.timerDays = 0.asDayPickerItem
        viewModel.state.timeSelectionMode = .timer
        viewModel.state.selectedMode = .off
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        viewModel.onStart()
        
        // then
        XCTAssertTrue(viewModel.state.loadingState.loading)
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, item.remoteId, SuplaHvacMode.off, nil, nil, 60)
        ])
    }
    
    func test_shouldStartTimer_usingTimeCalendar() {
        // given
        let currentDate = Date.create(year: 2023, month: 11, day: 3, hour: 12)!
        let endDate = Date.create(year: 2023, month: 11, day: 6, hour: 12)!
        
        viewModel.state.timeSelectionMode = .calendar
        viewModel.state.calendarDate = endDate
        viewModel.state.selectedMode = .heating
        viewModel.state.heatSetpoint = 14.5
        dateProvider.currentTimestampReturns = .single(0)
        dateProvider.currentDateReturns = currentDate
        
        // when
        viewModel.onStart()
        
        // then
        XCTAssertTrue(viewModel.state.loadingState.loading)
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, item.remoteId, SuplaHvacMode.heat, 14.5, nil, Int32(currentDate.differenceInSeconds(endDate)))
        ])
    }
    
    func test_shouldStartManualMode() {
        // given
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        viewModel.onCancelTimerIntoManualMode()
        
        // then
        XCTAssertTrue(viewModel.state.loadingState.loading)
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, item.remoteId, SuplaHvacMode.cmdSwitchToManual, nil, nil, nil)
        ])
    }
    
    func test_shouldStartProgramMode() {
        // given
        dateProvider.currentTimestampReturns = .single(0)
        
        // when
        viewModel.onCancelTimerIntoProgramMode()
        
        // then
        XCTAssertTrue(viewModel.state.loadingState.loading)
        XCTAssertTuples(executeThermostatActionUseCase.parameters, [
            (SubjectType.channel, item.remoteId, SuplaHvacMode.cmdWeeklySchedule, nil, nil, nil)
        ])
    }
    
    func test_shouldStartTimerEdit() {
        // given
        viewModel.state.timerEndTime = Date(timeIntervalSince1970: 4722)
        dateProvider.currentDateReturns = Date(timeIntervalSince1970: 1000)
        
        // when
        viewModel.onEditTimer()
        
        // then
        XCTAssertEqual(viewModel.state.isTimerEditing, true)
        XCTAssertEqual(viewModel.state.timerDays, 0.asDayPickerItem)
        XCTAssertEqual(viewModel.state.timerHours, 1.asHourPickerItem)
        XCTAssertEqual(viewModel.state.timerMinutes, 2.asMinutePickerItem)
        XCTAssertEqual(viewModel.state.timeSelectionMode, .timer)
        XCTAssertEqual(executeThermostatActionUseCase.parameters.count, 0)
    }
    
    func test_shouldCancelTimerEdit() {
        // given
        viewModel.state.isTimerEditing = true
        
        // when
        viewModel.onCancelEditMode()
        
        // then
        XCTAssertEqual(viewModel.state.isTimerEditing, false)
    }
}
