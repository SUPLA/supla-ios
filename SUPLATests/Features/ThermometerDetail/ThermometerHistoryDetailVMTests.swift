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
import RxSwift
import XCTest


final class ThermometerHistoryDetailVMTests: ViewModelTest<BaseHistoryDetailViewState, BaseHistoryDetailViewEvent> {
    
    private lazy var dateProvider: DateProviderMock! = {
        DateProviderMock()
    }()
    
    private lazy var userStateHolder: UserStateHolderMock! = {
        UserStateHolderMock()
    }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var downloadEventsManager: DownloadEventsManagerMock! = {
        DownloadEventsManagerMock()
    }()
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = {
        ReadChannelByRemoteIdUseCaseMock()
    }()
    
    private lazy var downloadChannelMeasurementsUseCase: DownloadChannelMeasurementsUseCaseMock! = {
        DownloadChannelMeasurementsUseCaseMock()
    }()
    
    private lazy var loadChannelMeasurementsUseCase: LoadChannelMeasurementsUseCaseMock! = {
        LoadChannelMeasurementsUseCaseMock()
    }()
    
    private lazy var loadChannelMeasurementsDateRangeUseCase: LoadChannelMeasurementsDateRangeUseCaseMock! = {
        LoadChannelMeasurementsDateRangeUseCaseMock()
    }()
    
    private lazy var viewModel: ThermometerHistoryDetailVM! = {
        ThermometerHistoryDetailVM()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: DateProvider.self, component: dateProvider!)
        DiContainer.shared.register(type: UserStateHolder.self, component: userStateHolder!)
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
        DiContainer.shared.register(type: DownloadEventsManager.self, component: downloadEventsManager!)
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, component: readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: DownloadChannelMeasurementsUseCase.self, component: downloadChannelMeasurementsUseCase!)
        DiContainer.shared.register(type: LoadChannelMeasurementsUseCase.self, component: loadChannelMeasurementsUseCase!)
        DiContainer.shared.register(type: LoadChannelMeasurementsDateRangeUseCase.self, component: loadChannelMeasurementsDateRangeUseCase!)
    }
    
    override func tearDown() {
        dateProvider = nil
        userStateHolder = nil
        profileRepository = nil
        downloadEventsManager = nil
        readChannelByRemoteIdUseCase = nil
        downloadChannelMeasurementsUseCase = nil
        loadChannelMeasurementsUseCase = nil
        loadChannelMeasurementsDateRangeUseCase = nil
        viewModel = nil
        
        super.tearDown()
    }
    
    func test_shouldLoadTemperaturesAndHumidities() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        let profile = AuthProfileItem(testContext: nil)
        let chartState = TemperatureChartState.defaultState()
        let currentDate = Date()
        
        dateProvider.currentDateReturns = currentDate
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        profileRepository.activeProfileObservable = Observable.just(profile)
        userStateHolder.getTemperatureChartStateReturns = chartState
        
        let expectation = expectation(description: "States loaded")
        
        // when
        var statesCount = 0
        observe(viewModel) { object in
            if (object is BaseHistoryDetailViewState) {
                statesCount += 1
            }
            if (statesCount == 6) {
                expectation.fulfill()
            }
        }
        viewModel.loadData(remoteId: remoteId)
        
        // then
        waitForExpectations(timeout: 1)
        let state1 = BaseHistoryDetailViewState()
        let state2 = state1.changing(path: \.remoteId, to: remoteId)
        let state3 = state2.changing(path: \.profileId, to: "")
        let state4 = state3.changing(path: \.ranges, to: SelectableList(selected: .lastWeek, items: ChartRange.allCases))
            .changing(path: \.range, to: DaysRange(start: currentDate.shift(days: -7), end: currentDate))
            .changing(path: \.aggregations, to: SelectableList(selected: .minutes, items: [.minutes, .hours, .days]))
        let state5 = state4.changing(path: \.downloadConfigured, to: true)
        let state6 = state5.changing(path: \.initialLoadStarted, to: true)
        assertStates(expected: [
            state1,
            state2,
            state3,
            state4,
            state5,
            state6
        ])
        
        XCTAssertEqual(readChannelByRemoteIdUseCase.remoteIdArray, [remoteId])
        XCTAssertEqual(userStateHolder.getTemperatureCharStateParameters.count, 1)
        XCTAssertEqual(downloadEventsManager.observeProgressParameters, [remoteId])
        XCTAssertTuples(downloadChannelMeasurementsUseCase.parameters, [(remoteId, SUPLA_CHANNELFNC_THERMOMETER)])
    }
    
    func test_shouldRefreshData() {
        // given
        let remoteId: Int32 = 123
        let state = BaseHistoryDetailViewState(remoteId: remoteId)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.refresh()
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.loading, to: true)
                .changing(path: \.initialLoadStarted, to: false)
        ])
        
        XCTAssertEqual(readChannelByRemoteIdUseCase.remoteIdArray, [remoteId])
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
    }
    
    func test_shouldChangeActiveSet() {
        let setId = HistoryDataSet.Id(remoteId: 123, type: .temperature)
        let set = HistoryDataSet(setId: setId, icon: nil, value: "", color: .red, entries: [], active: true)
        let state = mockState(remoteId: 123, sets: [set])
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.changeSetActive(setId: setId)
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.sets, to: state.sets.map { $0.changing(path: \.active, to: false) })
        ])
        XCTAssertEqual(userStateHolder.setTemperatureChartStateParameters.count, 1)
    }
    
    func mockState(
        remoteId: Int32,
        currentDate: Date = Date(),
        sets: [HistoryDataSet] = []
    ) -> BaseHistoryDetailViewState {
        BaseHistoryDetailViewState(
            remoteId: remoteId,
            profileId: "",
            sets: sets,
            range: DaysRange(start: currentDate.shift(days: -7), end: currentDate),
            ranges: SelectableList(selected: .lastWeek, items: ChartRange.allCases),
            aggregations: SelectableList(selected: .minutes, items: [.minutes, .hours, .days]),
            maxDate: currentDate
        )
    }
}
