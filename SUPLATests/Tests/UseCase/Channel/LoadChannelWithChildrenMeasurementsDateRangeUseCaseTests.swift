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
import RxSwift

final class LoadChannelWithChildrenMeasurementsDateRangeUseCaseTests: UseCaseTest<DaysRange?> {
    
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
    
    private lazy var useCase: LoadChannelWithChildrenMeasurementsDateRangeUseCase! = {
        LoadChannelWithChildrenMeasurementsDateRangeUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, temperatureMeasurementItemRepository!)
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, tempHumidityMeasurementItemRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        
        readChannelWithChildrenUseCase = nil
        temperatureMeasurementItemRepository = nil
        tempHumidityMeasurementItemRepository = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldFindMinAndMaxTemperature() {
        // given
        let channelId: Int32 = 123
        let child1Id: Int32 = 234
        let child2Id: Int32 = 345
        let channelWithChildren = mockChannelWithChildren(channelId, child1Id, child2Id)
        
        let child1Min = Date.create(2023, 11, 1, 0, 0, 0)!
        let child1Max = Date.create(2023, 11, 5, 0, 0, 0)!
        let child2Min = Date.create(2023, 10, 17, 0, 0, 0)!
        let child2Max = Date.create(2023, 11, 4, 0, 0, 0)!
        
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        temperatureMeasurementItemRepository.findMinTimestampReturns = .just(child2Min.timeIntervalSince1970)
        temperatureMeasurementItemRepository.findMaxTimestampReturns = .just(child2Max.timeIntervalSince1970)
        tempHumidityMeasurementItemRepository.findMinTimestampReturns = .just(child1Min.timeIntervalSince1970)
        tempHumidityMeasurementItemRepository.findMaxTimestampReturns = .just(child1Max.timeIntervalSince1970)
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        useCase.invoke(remoteId: channelId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(DaysRange(start: child2Min, end: child1Max)),
            .completed
        ])
        
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [channelId])
        XCTAssertTuples(temperatureMeasurementItemRepository.findMinTimestampParameters, [(child2Id, profile)])
        XCTAssertTuples(temperatureMeasurementItemRepository.findMaxTimestampParameters, [(child2Id, profile)])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMinTimestampParameters, [(child1Id, profile)])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMaxTimestampParameters, [(child1Id, profile)])
    }
    
    func test_shouldFindMinAndMaxTemperature_whenOneChannelHasNoMeasurements() {
        // given
        let channelId: Int32 = 123
        let child1Id: Int32 = 234
        let child2Id: Int32 = 345
        let channelWithChildren = mockChannelWithChildren(channelId, child1Id, child2Id)
        
        let child1Min = Date.create(2023, 11, 1, 0, 0, 0)!
        let child1Max = Date.create(2023, 11, 5, 0, 0, 0)!
        
        let profile = AuthProfileItem(testContext: nil)
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        temperatureMeasurementItemRepository.findMinTimestampReturns = .just(nil)
        temperatureMeasurementItemRepository.findMaxTimestampReturns = .just(nil)
        tempHumidityMeasurementItemRepository.findMinTimestampReturns = .just(child1Min.timeIntervalSince1970)
        tempHumidityMeasurementItemRepository.findMaxTimestampReturns = .just(child1Max.timeIntervalSince1970)
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        useCase.invoke(remoteId: channelId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(DaysRange(start: child1Min, end: child1Max)),
            .completed
        ])
        
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [channelId])
        XCTAssertTuples(temperatureMeasurementItemRepository.findMinTimestampParameters, [(child2Id, profile)])
        XCTAssertTuples(temperatureMeasurementItemRepository.findMaxTimestampParameters, [(child2Id, profile)])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMinTimestampParameters, [(child1Id, profile)])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMaxTimestampParameters, [(child1Id, profile)])
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
                ChannelChild(channel: child1, relation: SAChannelRelation.mock(type: .mainThermometer)),
                ChannelChild(channel: child2, relation: SAChannelRelation.mock(type: .auxThermometerFloor))
            ]
        )
    }
}
