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
@testable import SUPLA
import XCTest

final class GpmHistoryDetailVMTests: ViewModelTest<BaseHistoryDetailViewState, BaseHistoryDetailViewEvent> {
    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    
    private lazy var userStateHolder: UserStateHolderMock! = UserStateHolderMock()
    
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    
    private lazy var downloadEventsManager: DownloadEventsManagerMock! = DownloadEventsManagerMock()
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = ReadChannelByRemoteIdUseCaseMock()
    
    private lazy var downloadChannelMeasurementsUseCase: DownloadChannelMeasurementsUseCaseMock! = DownloadChannelMeasurementsUseCaseMock()
    
    private lazy var loadChannelMeasurementsUseCase: LoadChannelMeasurementsUseCaseMock! = LoadChannelMeasurementsUseCaseMock()
    
    private lazy var loadChannelMeasurementsDateRangeUseCase: LoadChannelMeasurementsDateRangeUseCaseMock! = LoadChannelMeasurementsDateRangeUseCaseMock()
    
    private lazy var loadChannelConfigUseCase: LoadChannelConfigUseCaseMock! = LoadChannelConfigUseCaseMock()
    
    private lazy var viewModel: GpmHistoryDetailVM! = GpmHistoryDetailVM()
    
    override func setUp() {
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: UserStateHolder.self, userStateHolder!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: DownloadEventsManager.self, downloadEventsManager!)
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: DownloadChannelMeasurementsUseCase.self, downloadChannelMeasurementsUseCase!)
        DiContainer.shared.register(type: LoadChannelMeasurementsUseCase.self, loadChannelMeasurementsUseCase!)
        DiContainer.shared.register(type: LoadChannelMeasurementsDateRangeUseCase.self, loadChannelMeasurementsDateRangeUseCase!)
        DiContainer.shared.register(type: LoadChannelConfigUseCase.self, loadChannelConfigUseCase!)
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
        loadChannelConfigUseCase = nil
        viewModel = nil
        
        super.tearDown()
    }
    
    func test_shouldStartDataDownload() {
        // given
        let remoteId: Int32 = 123
        let config = SuplaChannelGeneralPurposeMeterConfig.mock(keepHistory: true)
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        channel.config = SAChannelConfig.mock(type: .generalPurposeMeter, config: config.toJson())
        let profile = AuthProfileItem(testContext: nil)
        let chartState = DefaultChartState.empty()
        let currentDate = Date()
        
        dateProvider.currentDateReturns = currentDate
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
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
        let state3 = state2.changing(path: \.profileId, to: "")
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
        
        XCTAssertEqual(readChannelByRemoteIdUseCase.remoteIdArray, [remoteId])
        XCTAssertEqual(userStateHolder.getDefaultCharStateParameters.count, 1)
        XCTAssertEqual(downloadEventsManager.observeProgressParameters, [remoteId])
        XCTAssertTuples(downloadChannelMeasurementsUseCase.parameters, [(remoteId, SUPLA_CHANNELFNC_THERMOMETER)])
    }
    
    func test_shouldLoadGpMetersFromDbAsLineChartData() {
        doTestChartType(
            config: SuplaChannelGeneralPurposeMeterConfig.mock(),
            configType: .generalPurposeMeter,
            expectedChartDataProvider: { BarChartData($0, .lastWeek, .minutes, defaultChannelSet()) }
        )
    }
    
    func test_shouldLoadGpMetersFromDbAsBarChartData() {
        doTestChartType(
            config: SuplaChannelGeneralPurposeMeterConfig.mock(chartType: .linear),
            configType: .generalPurposeMeter,
            expectedChartDataProvider: { LineChartData($0, .lastWeek, .minutes, defaultChannelSet()) }
        )
    }
    
    func test_shouldLoadGpMeasurementsFromDbAsLineChartData() {
        doTestChartType(
            config: SuplaChannelGeneralPurposeMeasurementConfig.mock(),
            configType: .generalPurposeMeasurement,
            expectedChartDataProvider: { BarChartData($0, .lastWeek, .minutes, defaultChannelSet()) }
        )
    }
    
    func test_shouldLoadGpMeasurementsFromDbAsBarChartData() {
        doTestChartType(
            config: SuplaChannelGeneralPurposeMeasurementConfig.mock(chartType: .linear),
            configType: .generalPurposeMeasurement,
            expectedChartDataProvider: { LineChartData($0, .lastWeek, .minutes, defaultChannelSet()) }
        )
    }
    
    func test_shouldLoadGpMeasurementsFromDbAsCandleChartData() {
        doTestChartType(
            config: SuplaChannelGeneralPurposeMeasurementConfig.mock(chartType: .candle),
            configType: .generalPurposeMeasurement,
            expectedChartDataProvider: { CandleChartData($0, .lastWeek, .minutes, defaultChannelSet()) }
        )
    }
    
    private func doTestChartType(
        config: SuplaChannelGeneralPurposeBaseConfig,
        configType: ChannelConfigType,
        expectedChartDataProvider: (DaysRange) -> SUPLA.ChartData
    ) {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        channel.config = SAChannelConfig.mock(type: configType, config: config.toJson())
        let profile = AuthProfileItem(testContext: nil)
        let chartState = DefaultChartState.empty()
        let currentDate = Date()
        
        dateProvider.currentDateReturns = currentDate
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        profileRepository.activeProfileObservable = Observable.just(profile)
        userStateHolder.getDefaultChartStateReturns = chartState
        loadChannelConfigUseCase.returns = .just(config)
        loadChannelMeasurementsUseCase.returns = .just(ChannelChartSets(remoteId: remoteId, function: channel.func, name: "", aggregation: .minutes, dataSets: []))
        loadChannelMeasurementsDateRangeUseCase.returns = .just(nil)
        
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
        waitForExpectations(timeout: 2)
        let daysRange = DaysRange(start: currentDate.shift(days: -7), end: currentDate)
        let state1 = BaseHistoryDetailViewState()
        let state2 = state1.changing(path: \.remoteId, to: remoteId)
        let state3 = state2.changing(path: \.profileId, to: "")
            .changing(path: \.channelFunction, to: 40)
        let state4 = state3
            .changing(path: \.ranges, to: SelectableList(selected: .lastWeek, items: ChartRange.allCases))
            .changing(path: \.range, to: daysRange)
            .changing(path: \.aggregations, to: SelectableList(selected: .minutes, items: [.minutes, .hours, .days]))
        let state5 = state4
            .changing(path: \.showHistory, to: false)
            .changing(path: \.downloadState, to: .finished)
        let state6 = state5
            .changing(path: \.chartData, to: expectedChartDataProvider(daysRange))
            .changing(path: \.loading, to: false)
        assertStates(expected: [
            state1,
            state2,
            state3,
            state4,
            state5,
            state6
        ])
        
        XCTAssertEqual(readChannelByRemoteIdUseCase.remoteIdArray, [remoteId])
        XCTAssertEqual(userStateHolder.getDefaultCharStateParameters.count, 2)
        XCTAssertEqual(downloadEventsManager.observeProgressParameters, [])
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.count, 0)
    }
    
    private func defaultChannelSet() -> [ChannelChartSets] {
        [ChannelChartSets(remoteId: 123, function: SUPLA_CHANNELFNC_THERMOMETER, name: "", aggregation: .minutes, dataSets: [])]
    }
}
