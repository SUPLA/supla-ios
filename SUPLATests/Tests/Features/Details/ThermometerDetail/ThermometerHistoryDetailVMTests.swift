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
    
    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = {
        ReadChannelWithChildrenUseCaseMock()
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
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: UserStateHolder.self, userStateHolder!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: DownloadEventsManager.self, downloadEventsManager!)
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: DownloadChannelMeasurementsUseCase.self, downloadChannelMeasurementsUseCase!)
        DiContainer.shared.register(type: LoadChannelMeasurementsUseCase.self, loadChannelMeasurementsUseCase!)
        DiContainer.shared.register(type: LoadChannelMeasurementsDateRangeUseCase.self, loadChannelMeasurementsDateRangeUseCase!)
    }
    
    override func tearDown() {
        dateProvider = nil
        userStateHolder = nil
        profileRepository = nil
        downloadEventsManager = nil
        readChannelWithChildrenUseCase = nil
        downloadChannelMeasurementsUseCase = nil
        loadChannelMeasurementsUseCase = nil
        loadChannelMeasurementsDateRangeUseCase = nil
        viewModel = nil
        
        super.tearDown()
    }
    
    func test_shouldLoadTemperaturesAndHumidities() {
        // given
        let remoteId: Int32 = 123
        let profileId: Int32 = 1
        let profile = AuthProfileItem(testContext: nil)
        profile.id = profileId
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        channel.profile = profile
        let chartState = DefaultChartState.empty()
        let currentDate = Date()
        let channelWithChildren = ChannelWithChildren(channel: channel, children: [])
        
        dateProvider.currentDateReturns = currentDate
        readChannelWithChildrenUseCase.returns = Observable.just(channelWithChildren)
        profileRepository.activeProfileObservable = Observable.just(profile)
        userStateHolder.getDefaultChartStateReturns = chartState
        
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
        let state3 = state2.changing(path: \.profileId, to: profileId)
            .changing(path: \.channelFunction, to: 40)
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
        
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
        XCTAssertEqual(userStateHolder.getDefaultCharStateParameters.count, 1)
        XCTAssertEqual(downloadEventsManager.observeProgressParameters, [remoteId])
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters, [channelWithChildren])
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
        
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
    }
    
    func test_shouldChangeActiveSet() {
        let temperatureSet = HistoryDataSet(
            type: .temperature,
            label: .single(HistoryDataSet.LabelData(icon: nil, value: "", color: .red)),
            valueFormatter: ChannelValueFormatterMock(),
            entries: [],
            active: true
        )
        let humiditySet = HistoryDataSet(
            type: .humidity,
            label: .single(HistoryDataSet.LabelData(icon: nil, value: "", color: .red)),
            valueFormatter: ChannelValueFormatterMock(),
            entries: [],
            active: true
        )
        let channelSets = ChannelChartSets(
            remoteId: 123,
            function: SUPLA_CHANNELFNC_THERMOMETER,
            name: "",
            aggregation: .minutes,
            dataSets: [temperatureSet, humiditySet]
        )
        let state = mockState(remoteId: 123, chartData: LineChartData(nil, nil, nil, [channelSets]))
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.changeSetActive(remoteId: 123, type: .temperature)
        
        // then
        assertStates(expected: [
            state,
            state.changing(path: \.chartData, to: state.chartData.activateSets(visibleSets: [ChartStateVisibleSet(id: 123, type: .humidity)]))
                .changing(path: \.withRightAxis, to: true)
        ])
        XCTAssertEqual(userStateHolder.setChartStateParameters.count, 1)
    }
    
    func mockState(
        remoteId: Int32,
        currentDate: Date = Date(),
        chartData: SUPLA.ChartData = EmptyChartData()
    ) -> BaseHistoryDetailViewState {
        BaseHistoryDetailViewState(
            remoteId: remoteId,
            profileId: 1,
            chartData: chartData,
            range: DaysRange(start: currentDate.shift(days: -7), end: currentDate),
            ranges: SelectableList(selected: .lastWeek, items: ChartRange.allCases),
            aggregations: SelectableList(selected: .minutes, items: [.minutes, .hours, .days]),
            maxDate: currentDate
        )
    }
}
