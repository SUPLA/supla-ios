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

final class LoadChannelMeasurementsUseCaseTests: UseCaseTest<[HistoryDataSet]> {
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = {
        ReadChannelByRemoteIdUseCaseMock()
    }()
    
    private lazy var temperatureMeasurementItemRepository: TemperatureMeasurementItemRepositoryMock! = {
        TemperatureMeasurementItemRepositoryMock()
    }()
    
    private lazy var tempHumidityMeasurementItemRepository: TempHumidityMeasurementItemRepositoryMock! = {
        TempHumidityMeasurementItemRepositoryMock()
    }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var useCase: LoadChannelMeasurementsUseCase! = {
        LoadChannelMeasurementsUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, component: readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, component: temperatureMeasurementItemRepository!)
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, component: tempHumidityMeasurementItemRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
        
        DiContainer.shared.register(type: GlobalSettings.self, component: GlobalSettingsMock())
        DiContainer.shared.register(type: ValuesFormatter.self, component: ValuesFormatterImpl())
    }
    
    override func tearDown() {
        useCase = nil
        readChannelByRemoteIdUseCase = nil
        temperatureMeasurementItemRepository = nil
        tempHumidityMeasurementItemRepository = nil
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
        
        // when
        useCase.invoke(remoteId: remotId, startDate: startDate, endDate: endDate, aggregation: .minutes).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let historyDataSets = observer.events[0].value.element!
        
        XCTAssertEqual(historyDataSets.count, 1)
        XCTAssertEqual(historyDataSets[0].setId, HistoryDataSet.Id(remoteId: remotId, type: .temperature))
        XCTAssertEqual(historyDataSets[0].color, .red)
        XCTAssertEqual(historyDataSets[0].active, true)
        XCTAssertEqual(historyDataSets[0].value, "0.0°")
        XCTAssertEqual(
            historyDataSets[0].entries[0].map { $0.x },
            [startDate.timeIntervalSince1970, endDate.timeIntervalSince1970]
        )
        XCTAssertEqual(
            historyDataSets[0].entries[0].map { $0.data as! EntryDetails },
            [
                EntryDetails(aggregation: .minutes, type: .temperature, min: nil, max: nil),
                EntryDetails(aggregation: .minutes, type: .temperature, min: nil, max: nil)
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
        
        // when
        useCase.invoke(remoteId: remotId, startDate: startDate, endDate: endDate, aggregation: .hours).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let historyDataSets = observer.events[0].value.element!
        
        XCTAssertEqual(historyDataSets.count, 1)
        XCTAssertEqual(historyDataSets[0].setId, HistoryDataSet.Id(remoteId: remotId, type: .temperature))
        XCTAssertEqual(historyDataSets[0].color, .red)
        XCTAssertEqual(historyDataSets[0].active, true)
        XCTAssertEqual(
            historyDataSets[0].entries[0].map { $0.x },
            [Date.create(2017, 8, 10, 19, 00, 00)?.timeIntervalSince1970]
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
        
        // when
        useCase.invoke(remoteId: remotId, startDate: startDate, endDate: endDate, aggregation: .minutes).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let historyDataSets = observer.events[0].value.element!
        
        XCTAssertEqual(historyDataSets.count, 1)
        XCTAssertEqual(historyDataSets[0].setId, HistoryDataSet.Id(remoteId: remotId, type: .temperature))
        XCTAssertEqual(historyDataSets[0].color, .red)
        XCTAssertEqual(historyDataSets[0].active, true)
        XCTAssertEqual(historyDataSets[0].entries[0].map { $0.x }, [startDate.timeIntervalSince1970])
        XCTAssertEqual(historyDataSets[0].entries[1].map { $0.x }, [endDate.timeIntervalSince1970])
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
        
        // when
        useCase.invoke(remoteId: remotId, startDate: startDate, endDate: endDate, aggregation: .minutes).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let historyDataSets = observer.events[0].value.element!
        
        XCTAssertEqual(historyDataSets.count, 2)
        
        // - temperature sets
        XCTAssertEqual(historyDataSets[0].setId, HistoryDataSet.Id(remoteId: remotId, type: .temperature))
        XCTAssertEqual(historyDataSets[0].color, .red)
        XCTAssertEqual(historyDataSets[0].active, true)
        XCTAssertEqual(historyDataSets[0].value, "-273.0°")
        XCTAssertEqual(
            historyDataSets[0].entries[0].map { $0.x },
            [startDate.timeIntervalSince1970, endDate.timeIntervalSince1970]
        )
        XCTAssertEqual(
            historyDataSets[0].entries[0].map { $0.data as! EntryDetails },
            [
                EntryDetails(aggregation: .minutes, type: .temperature, min: nil, max: nil),
                EntryDetails(aggregation: .minutes, type: .temperature, min: nil, max: nil)
            ]
        )
        
        // - humidity sets
        XCTAssertEqual(historyDataSets[1].setId, HistoryDataSet.Id(remoteId: remotId, type: .humidity))
        XCTAssertEqual(historyDataSets[1].color, UIColor(red: 0, green: 122/255.0, blue: 1, alpha: 1))
        XCTAssertEqual(historyDataSets[1].active, true)
        XCTAssertEqual(historyDataSets[1].value, "---")
        XCTAssertEqual(
            historyDataSets[1].entries[0].map { $0.x },
            [startDate.timeIntervalSince1970, endDate.timeIntervalSince1970]
        )
        XCTAssertEqual(
            historyDataSets[1].entries[0].map { $0.data as! EntryDetails },
            [
                EntryDetails(aggregation: .minutes, type: .humidity, min: nil, max: nil),
                EntryDetails(aggregation: .minutes, type: .humidity, min: nil, max: nil)
            ]
        )
    }
}
