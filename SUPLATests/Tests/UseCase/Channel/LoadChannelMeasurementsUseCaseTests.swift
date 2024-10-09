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

final class LoadChannelMeasurementsUseCaseTests: UseCaseTest<ChannelChartSets> {
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = ReadChannelByRemoteIdUseCaseMock()
    
    private lazy var temperatureMeasurementItemRepository: TemperatureMeasurementItemRepositoryMock! = TemperatureMeasurementItemRepositoryMock()
    
    private lazy var tempHumidityMeasurementItemRepository: TempHumidityMeasurementItemRepositoryMock! = TempHumidityMeasurementItemRepositoryMock()
    
    private lazy var generalPurposeMeasurementItemRepository: GeneralPurposeMeasurementItemRepositoryMock! = GeneralPurposeMeasurementItemRepositoryMock()
    
    private lazy var generalPurposeMeterItemRepository: GeneralPurposeMeterItemRepositoryMock! = GeneralPurposeMeterItemRepositoryMock()
    
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    
    private lazy var getChannelValueStringUseCase: GetChannelValueStringUseCaseMock! = GetChannelValueStringUseCaseMock()
    
    private lazy var useCase: LoadChannelMeasurementsUseCase! = LoadChannelMeasurementsUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: GetChannelValueStringUseCase.self, getChannelValueStringUseCase!)
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, temperatureMeasurementItemRepository!)
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, tempHumidityMeasurementItemRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeasurementItemRepository).self, generalPurposeMeasurementItemRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        
        DiContainer.shared.register(type: GlobalSettings.self, GlobalSettingsMock())
        DiContainer.shared.register(type: ValuesFormatter.self, ValuesFormatterImpl())
    }
    
    override func tearDown() {
        useCase = nil
        readChannelByRemoteIdUseCase = nil
        temperatureMeasurementItemRepository = nil
        tempHumidityMeasurementItemRepository = nil
        generalPurposeMeasurementItemRepository = nil
        generalPurposeMeterItemRepository = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldLoadTemperatureMeasurementsWithoutAggregating() {
        // given
        let remotId: Int32 = 12
        let value = SAChannelValue(testContext: nil)
        value.online = true
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remotId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        channel.value = value
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelByRemoteIdUseCase.returns = .just(channel)
        profileRepository.activeProfileObservable = .just(profile)
        
        let startDate: Date = .create(2017, 8, 10, 19, 33, 00)!
        let endDate: Date = .create(2017, 8, 10, 19, 43, 00)!
        
        let measurements = [
            SATemperatureMeasurementItem.mock(startDate, 10.7),
            SATemperatureMeasurementItem.mock(endDate, 10.9)
        ]
        temperatureMeasurementItemRepository.findMeasurementsReturns = .just(measurements)
        getChannelValueStringUseCase.returns = "0.0°"
        let spec = ChartDataSpec(startDate: startDate, endDate: endDate, aggregation: .minutes)
        
        // when
        useCase.invoke(remoteId: remotId, spec: spec).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let channelChartSets = observer.events[0].value.element!
        
        XCTAssertEqual(channelChartSets.dataSets.count, 1)
        XCTAssertEqual(channelChartSets.remoteId, remotId)
        XCTAssertEqual(channelChartSets.dataSets[0].type, .temperature)
        XCTAssertEqual(channelChartSets.dataSets[0].label.color, .chartTemperature1)
        XCTAssertEqual(channelChartSets.dataSets[0].active, true)
        XCTAssertEqual(channelChartSets.dataSets[0].label.value, "0.0°")
        XCTAssertTuples(
            channelChartSets.dataSets[0].entries[0].map { ($0.date, Int(($0.value.value * 10).rounded())) },
            [
                (startDate.timeIntervalSince1970, 107),
                (endDate.timeIntervalSince1970, 109)
            ]
        )
    }
    
    func test_shouldLoadTemperatureMeasurementsWithAggregating() {
        // given
        let remotId: Int32 = 12
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remotId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelByRemoteIdUseCase.returns = .just(channel)
        profileRepository.activeProfileObservable = .just(profile)
        
        let startDate: Date = .create(2017, 8, 10, 19, 33, 00)!
        let endDate: Date = .create(2017, 8, 10, 19, 43, 00)!
        
        let measurements = [
            SATemperatureMeasurementItem.mock(startDate, 10.7),
            SATemperatureMeasurementItem.mock(endDate, 10.9)
        ]
        temperatureMeasurementItemRepository.findMeasurementsReturns = .just(measurements)
        getChannelValueStringUseCase.returns = "0.0°"
        let spec = ChartDataSpec(startDate: startDate, endDate: endDate, aggregation: .hours)
        
        // when
        useCase.invoke(remoteId: remotId, spec: spec).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let channelChartSets = observer.events[0].value.element!
        
        XCTAssertEqual(channelChartSets.dataSets.count, 1)
        XCTAssertEqual(channelChartSets.remoteId, remotId)
        XCTAssertEqual(channelChartSets.dataSets[0].type, .temperature)
        XCTAssertEqual(channelChartSets.dataSets[0].label.color, .chartTemperature1)
        XCTAssertEqual(channelChartSets.dataSets[0].active, true)
        XCTAssertEqual(channelChartSets.dataSets[0].label.value, "0.0°")
        
        XCTAssertTuples(
            channelChartSets.dataSets[0].entries[0].map { ($0.date, Int(($0.value.value * 10).rounded())) },
            [(Date.create(2017, 8, 10, 19, 00, 00)?.timeIntervalSince1970, 108)]
        )
    }
    
    func test_shouldLoadTemperatureMeasurementsWDividingToSubsets() {
        // given
        let remotId: Int32 = 12
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remotId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelByRemoteIdUseCase.returns = .just(channel)
        profileRepository.activeProfileObservable = .just(profile)
        
        let startDate: Date = .create(2017, 8, 10, 19, 23, 00)!
        let endDate: Date = .create(2017, 8, 10, 19, 43, 00)!
        
        let measurements = [
            SATemperatureMeasurementItem.mock(startDate, 10.7),
            SATemperatureMeasurementItem.mock(endDate, 10.9)
        ]
        temperatureMeasurementItemRepository.findMeasurementsReturns = .just(measurements)
        getChannelValueStringUseCase.returns = "0.0°"
        let spec = ChartDataSpec(startDate: startDate, endDate: endDate, aggregation: .minutes)
        
        // when
        useCase.invoke(remoteId: remotId, spec: spec).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let channelChartSets = observer.events[0].value.element!
        
        XCTAssertEqual(channelChartSets.dataSets.count, 1)
        XCTAssertEqual(channelChartSets.remoteId, remotId)
        XCTAssertEqual(channelChartSets.dataSets[0].type, .temperature)
        XCTAssertEqual(channelChartSets.dataSets[0].label.color, .chartTemperature1)
        XCTAssertEqual(channelChartSets.dataSets[0].active, true)
        XCTAssertEqual(channelChartSets.dataSets[0].label.value, "0.0°")
        
        XCTAssertEqual(channelChartSets.dataSets[0].entries[0].map { $0.date }, [startDate.timeIntervalSince1970])
        XCTAssertEqual(channelChartSets.dataSets[0].entries[1].map { $0.date }, [endDate.timeIntervalSince1970])
    }
    
    func test_shouldLoadTemperatureAndHumidityMeasurementsWithoutAggregating() {
        // given
        let remotId: Int32 = 12
        let value = SAChannelValue(testContext: nil)
        value.online = true
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remotId
        channel.func = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        channel.value = value
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelByRemoteIdUseCase.returns = .just(channel)
        profileRepository.activeProfileObservable = .just(profile)
        
        let startDate: Date = .create(2017, 8, 10, 19, 33, 00)!
        let endDate: Date = .create(2017, 8, 10, 19, 43, 00)!
        
        let measurements = [
            SATempHumidityMeasurementItem.mock(startDate, 10.7, 55.4),
            SATempHumidityMeasurementItem.mock(endDate, 10.9, 55.8)
        ]
        tempHumidityMeasurementItemRepository.findMeasurementsReturns = .just(measurements)
        getChannelValueStringUseCase.returns = "0"
        let spec = ChartDataSpec(startDate: startDate, endDate: endDate, aggregation: .minutes)
        
        // when
        useCase.invoke(remoteId: remotId, spec: spec).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let channelChartSets = observer.events[0].value.element!
        
        XCTAssertEqual(channelChartSets.dataSets.count, 2)

        // - temperature sets
        XCTAssertEqual(channelChartSets.remoteId, remotId)
        XCTAssertEqual(channelChartSets.dataSets[0].type, .temperature)
        XCTAssertEqual(channelChartSets.dataSets[0].label.color, .chartTemperature1)
        XCTAssertEqual(channelChartSets.dataSets[0].active, true)
        XCTAssertEqual(channelChartSets.dataSets[0].label.value, "0")
        XCTAssertTuples(
            channelChartSets.dataSets[0].entries[0].map { ($0.date, Int(($0.value.value * 10).rounded())) },
            [
                (startDate.timeIntervalSince1970, 107),
                (endDate.timeIntervalSince1970, 109)
            ]
        )
        
        // - humidity sets
        XCTAssertEqual(channelChartSets.remoteId, remotId)
        XCTAssertEqual(channelChartSets.dataSets[1].type, .humidity)
        XCTAssertEqual(channelChartSets.dataSets[1].label.color, .chartHumidity1)
        XCTAssertEqual(channelChartSets.dataSets[1].active, true)
        XCTAssertEqual(channelChartSets.dataSets[1].label.value, "0")
        
        XCTAssertTuples(
            channelChartSets.dataSets[1].entries[0].map { ($0.date, Int(($0.value.value * 10).rounded())) },
            [
                (startDate.timeIntervalSince1970, 554),
                (endDate.timeIntervalSince1970, 558)
            ]
        )
    }
    
    func test_shouldLoadGeneralPurposeMeasurementsWithoutAggregating() {
        // given
        let remotId: Int32 = 12
        let function = SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
        let value = SAChannelValue.mock(online: true)
        let channel = SAChannel.mock(remotId, function: function, value: value)
        let profile = AuthProfileItem.mock()
        
        readChannelByRemoteIdUseCase.returns = .just(channel)
        profileRepository.activeProfileObservable = .just(profile)
        
        let startDate: Date = .create(2017, 8, 10, 19, 33, 00)!
        let endDate: Date = .create(2017, 8, 10, 19, 43, 00)!
        
        let measurements = [
            SAGeneralPurposeMeasurementItem.mock(date: startDate, valueAverage: 10.7, valueMin: 5, valueMax: 12, valueOpen: 10, valueClose: 11),
            SAGeneralPurposeMeasurementItem.mock(date: endDate, valueAverage: 10.9)
        ]
        generalPurposeMeasurementItemRepository.findMeasurementsReturns = .just(measurements)
        getChannelValueStringUseCase.returns = "0.0°"
        let spec = ChartDataSpec(startDate: startDate, endDate: endDate, aggregation: .minutes)
        
        // when
        useCase.invoke(remoteId: remotId, spec: spec).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let channelChartSets = observer.events[0].value.element!
        
        XCTAssertEqual(channelChartSets.dataSets.count, 1)
        XCTAssertEqual(channelChartSets.remoteId, remotId)
        XCTAssertEqual(channelChartSets.dataSets[0].type, .generalPurposeMeasurement)
        XCTAssertEqual(channelChartSets.dataSets[0].label.color, .chartTemperature1)
        XCTAssertEqual(channelChartSets.dataSets[0].active, true)
        XCTAssertEqual(channelChartSets.dataSets[0].label.value, "0.0°")
        
        XCTAssertTuples(
            channelChartSets.dataSets[0].entries[0].map {
                ($0.date, Int(($0.value.value * 10).rounded()), $0.value.min, $0.value.max, $0.value.open, $0.value.close)
            }, [
                (startDate.timeIntervalSince1970, 107, 5, 12, 10, 11),
                (endDate.timeIntervalSince1970, 109, 0, 0, 0, 0)
            ]
        )
    }
    
    func test_shouldLoadGeneralPurposeMeterWithoutAggregating() {
        // given
        let remotId: Int32 = 12
        let function = SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
        let value = SAChannelValue.mock(online: true)
        let channel = SAChannel.mock(remotId, function: function, value: value)
        let profile = AuthProfileItem.mock()
        
        readChannelByRemoteIdUseCase.returns = .just(channel)
        profileRepository.activeProfileObservable = .just(profile)
        
        let startDate: Date = .create(2017, 8, 10, 19, 33, 00)!
        let endDate: Date = .create(2017, 8, 10, 19, 43, 00)!
        
        let measurements = [
            SAGeneralPurposeMeterItem.mock(date: startDate, valueIncrement: 10.7),
            SAGeneralPurposeMeterItem.mock(date: endDate, valueIncrement: 10.9)
        ]
        generalPurposeMeterItemRepository.findMeasurementsReturns = .just(measurements)
        getChannelValueStringUseCase.returns = "0.0°"
        let spec = ChartDataSpec(startDate: startDate, endDate: endDate, aggregation: .minutes)
        
        // when
        useCase.invoke(remoteId: remotId, spec: spec).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let channelChartSets = observer.events[0].value.element!
        
        XCTAssertEqual(channelChartSets.dataSets.count, 1)
        XCTAssertEqual(channelChartSets.remoteId, remotId)
        XCTAssertEqual(channelChartSets.dataSets[0].type, .generalPurposeMeter)
        XCTAssertEqual(channelChartSets.dataSets[0].label.color, .chartGpm)
        XCTAssertEqual(channelChartSets.dataSets[0].active, true)
        XCTAssertEqual(channelChartSets.dataSets[0].label.value, "0.0°")
        XCTAssertTuples(
            channelChartSets.dataSets[0].entries[0].map {
                ($0.date, Int(($0.value.value * 10).rounded()))
            }, [
                (startDate.timeIntervalSince1970, 107),
                (endDate.timeIntervalSince1970, 109)
            ]
        )
    }
}
