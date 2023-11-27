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

final class LoadChannelWithChildrenMeasurementsUseCaseTests: UseCaseTest<[HistoryDataSet]> {
    
    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = {
        ReadChannelWithChildrenUseCaseMock()
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
    
    private lazy var useCase: LoadChannelWithChildrenMeasurementsUseCase! = {
        LoadChannelWithChildrenMeasurementsUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, component: readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, component: temperatureMeasurementItemRepository!)
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, component: tempHumidityMeasurementItemRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        readChannelWithChildrenUseCase = nil
        temperatureMeasurementItemRepository = nil
        tempHumidityMeasurementItemRepository = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldLoadMeasurements() {
        // given
        let channelId: Int32 = 123
        let child1Id: Int32 = 234
        let child2Id: Int32 = 345
        
        let child1Min = Date.create(2023, 11, 1, 0, 0, 0)!
        let child1Max = Date.create(2023, 11, 5, 0, 0, 0)!
        let child2Min = Date.create(2023, 10, 17, 0, 0, 0)!
        let child2Max = Date.create(2023, 11, 4, 0, 0, 0)!
        
        let channelWithChildren = mockChannelWithChildren(channelId, child1Id, child2Id)
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        profileRepository.activeProfileObservable = .just(profile)
        
        let tempMeasurements = [
            SATemperatureMeasurementItem.mock(child2Min, 10.7),
            SATemperatureMeasurementItem.mock(child2Max, 10.9)
        ]
        temperatureMeasurementItemRepository.findMeasurementsReturns = .just(tempMeasurements)
        
        let tempAndHumidityMeasurements = [
            SATempHumidityMeasurementItem.mock(child1Min, 10.7, 50.7),
            SATempHumidityMeasurementItem.mock(child1Max, 10.9, 51.2)
        ]
        tempHumidityMeasurementItemRepository.findMeasurementsReturns = .just(tempAndHumidityMeasurements)
        
        // when
        useCase.invoke(remoteId: channelId, startDate: child2Min, endDate: child1Max, aggregation: .minutes).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let historyDataSets = observer.events[0].value.element!
        
        XCTAssertEqual(historyDataSets.count, 3)
        XCTAssertEqual(historyDataSets[0].setId, HistoryDataSet.Id(remoteId: child1Id, type: .temperature))
        XCTAssertEqual(historyDataSets[0].color, .red)
        XCTAssertEqual(historyDataSets[0].active, true)
        XCTAssertEqual(historyDataSets[0].value, "---")
        XCTAssertEqual(historyDataSets[1].setId, HistoryDataSet.Id(remoteId: child1Id, type: .humidity))
        XCTAssertEqual(historyDataSets[1].color, UIColor(red: 0, green: 122/255.0, blue: 1, alpha: 1))
        XCTAssertEqual(historyDataSets[1].active, true)
        XCTAssertEqual(historyDataSets[1].value, "---")
        XCTAssertEqual(historyDataSets[2].setId, HistoryDataSet.Id(remoteId: child2Id, type: .temperature))
        XCTAssertEqual(historyDataSets[2].color, .darkRed)
        XCTAssertEqual(historyDataSets[2].active, true)
        XCTAssertEqual(historyDataSets[2].value, "---")
    }
    
    func test_shouldLoadMeasurements_whenOneChannelHasNoMeasurements() {
        // given
        let channelId: Int32 = 123
        let child1Id: Int32 = 234
        let child2Id: Int32 = 345
        
        let child2Min = Date.create(2023, 10, 17, 0, 0, 0)!
        let child2Max = Date.create(2023, 11, 4, 0, 0, 0)!
        
        let channelWithChildren = mockChannelWithChildren(channelId, child1Id, child2Id)
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        profileRepository.activeProfileObservable = .just(profile)
        
        let tempMeasurements = [
            SATemperatureMeasurementItem.mock(child2Min, 10.7),
            SATemperatureMeasurementItem.mock(child2Max, 10.9)
        ]
        temperatureMeasurementItemRepository.findMeasurementsReturns = .just(tempMeasurements)
        
        tempHumidityMeasurementItemRepository.findMeasurementsReturns = .just([])
        
        // when
        useCase.invoke(remoteId: channelId, startDate: child2Min, endDate: child2Max, aggregation: .minutes).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        let historyDataSets = observer.events[0].value.element!
        
        XCTAssertEqual(historyDataSets.count, 3)
        XCTAssertEqual(historyDataSets[0].setId, HistoryDataSet.Id(remoteId: child1Id, type: .temperature))
        XCTAssertEqual(historyDataSets[0].color, .red)
        XCTAssertEqual(historyDataSets[0].active, true)
        XCTAssertEqual(historyDataSets[0].value, "---")
    }
    
    private func mockChannelWithChildren(_ channelId: Int32, _ child1Id: Int32, _ child2Id: Int32) -> ChannelWithChildren {
        let channel = SAChannel(testContext: nil)
        channel.remote_id = channelId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        let child1 = SAChannel(testContext: nil)
        child1.remote_id = child1Id
        child1.func = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        
        let child2 = SAChannel(testContext: nil)
        child2.remote_id = child2Id
        child2.func = SUPLA_CHANNELFNC_THERMOMETER
        
        return ChannelWithChildren(
            channel: channel,
            children: [
                ChannelChild(channel: child1, relationType: .mainThermometer),
                ChannelChild(channel: child2, relationType: .auxThermometerFloor)
            ]
        )
    }
}
