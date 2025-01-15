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
@testable import SUPLA

final class LoadChannelMeasurementsDateRangeUseCaseTests: UseCaseTest<DaysRange?> {
    
    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = {
        ReadChannelWithChildrenUseCaseMock()
    }()
    
    private lazy var temperatureMeasurementItemRepository: TemperatureMeasurementItemRepositoryMock! = {
        TemperatureMeasurementItemRepositoryMock()
    }()
    
    private lazy var tempHumidityMeasurementItemRepository: TempHumidityMeasurementItemRepositoryMock! = {
        TempHumidityMeasurementItemRepositoryMock()
    }()
    
    private lazy var generalPurposeMeasurementItemRepository: GeneralPurposeMeasurementItemRepositoryMock! = {
        GeneralPurposeMeasurementItemRepositoryMock()
    }()
    
    private lazy var generalPurposeMeterItemRepository: GeneralPurposeMeterItemRepositoryMock! = {
        GeneralPurposeMeterItemRepositoryMock()
    }()
    
    private lazy var useCase: LoadChannelMeasurementsDateRangeUseCase! = {
        LoadChannelMeasurementsDateRangeUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, temperatureMeasurementItemRepository!)
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, tempHumidityMeasurementItemRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeasurementItemRepository).self, generalPurposeMeasurementItemRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        readChannelWithChildrenUseCase = nil
        temperatureMeasurementItemRepository = nil
        tempHumidityMeasurementItemRepository = nil
        generalPurposeMeasurementItemRepository = nil
        generalPurposeMeterItemRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldFindRangeForTemperature() {
        // given
        let remoteId: Int32 = 123
        let serverId: Int32 = 3
        
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        
        let channel = SAChannel(testContext: nil)
        channel.profile = profile
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_THERMOMETER
        
        let channelWithChildren = ChannelWithChildren(channel: channel)
        
        let minDate = Date.create(year: 2018)!
        let maxDate = Date.create(year: 2020)!
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        temperatureMeasurementItemRepository.findMinTimestampReturns = .just(minDate.timeIntervalSince1970)
        temperatureMeasurementItemRepository.findMaxTimestampReturns = .just(maxDate.timeIntervalSince1970)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEventsCount(2)
        XCTAssertEqual(observer.events[0].value.element??.start, minDate)
        XCTAssertEqual(observer.events[0].value.element??.end, maxDate)
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
        XCTAssertTuples(temperatureMeasurementItemRepository.findMinTimestampParameters, [(remoteId, serverId)])
        XCTAssertTuples(temperatureMeasurementItemRepository.findMaxTimestampParameters, [(remoteId, serverId)])
    }
    
    func test_shouldFindRangeForTemperatureAndHumidity() {
        // given
        let remoteId: Int32 = 123
        let serverId: Int32 = 1
        
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        
        let channel = SAChannel(testContext: nil)
        channel.profile = profile
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        
        let channelWithChildren = ChannelWithChildren(channel: channel)
        
        let minDate = Date.create(year: 2018)!
        let maxDate = Date.create(year: 2020)!
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        tempHumidityMeasurementItemRepository.findMinTimestampReturns = .just(minDate.timeIntervalSince1970)
        tempHumidityMeasurementItemRepository.findMaxTimestampReturns = .just(maxDate.timeIntervalSince1970)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEventsCount(2)
        XCTAssertEqual(observer.events[0].value.element??.start, minDate)
        XCTAssertEqual(observer.events[0].value.element??.end, maxDate)
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMinTimestampParameters, [(remoteId, serverId)])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMaxTimestampParameters, [(remoteId, serverId)])
    }
    
    func test_shouldFindRangeForGeneralPurposeMeasurement() {
        // given
        let remoteId: Int32 = 123
        let serverId: Int32 = 1
        
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        
        let channel = SAChannel(testContext: nil)
        channel.profile = profile
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
        
        let channelWithChildren = ChannelWithChildren(channel: channel)
        
        let minDate = Date.create(year: 2018)!
        let maxDate = Date.create(year: 2020)!
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        generalPurposeMeasurementItemRepository.findMinTimestampReturns = .just(minDate.timeIntervalSince1970)
        generalPurposeMeasurementItemRepository.findMaxTimestampReturns = .just(maxDate.timeIntervalSince1970)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEventsCount(2)
        XCTAssertEqual(observer.events[0].value.element??.start, minDate)
        XCTAssertEqual(observer.events[0].value.element??.end, maxDate)
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
        XCTAssertTuples(generalPurposeMeasurementItemRepository.findMinTimestampParameters, [(remoteId, serverId)])
        XCTAssertTuples(generalPurposeMeasurementItemRepository.findMaxTimestampParameters, [(remoteId, serverId)])
    }
    
    func test_shouldFindRangeForGeneralPurposeMeter() {
        // given
        let remoteId: Int32 = 123
        let serverId: Int32 = 1
        
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        
        let channel = SAChannel(testContext: nil)
        channel.profile = profile
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
        
        let channelWithChildren = ChannelWithChildren(channel: channel)
        
        let minDate = Date.create(year: 2018)!
        let maxDate = Date.create(year: 2020)!
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        generalPurposeMeterItemRepository.findMinTimestampReturns = .just(minDate.timeIntervalSince1970)
        generalPurposeMeterItemRepository.findMaxTimestampReturns = .just(maxDate.timeIntervalSince1970)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEventsCount(2)
        XCTAssertEqual(observer.events[0].value.element??.start, minDate)
        XCTAssertEqual(observer.events[0].value.element??.end, maxDate)
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
        XCTAssertTuples(generalPurposeMeterItemRepository.findMinTimestampParameters, [(remoteId, serverId)])
        XCTAssertTuples(generalPurposeMeterItemRepository.findMaxTimestampParameters, [(remoteId, serverId)])
    }
    
    func test_shouldGetNilWhenTemperatureNotFound() {
        // given
        let remoteId: Int32 = 123
        let serverId: Int32 = 1
        
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        
        let channel = SAChannel(testContext: nil)
        channel.profile = profile
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        
        let channelWithChildren = ChannelWithChildren(channel: channel)
        
        readChannelWithChildrenUseCase.returns = .just(channelWithChildren)
        tempHumidityMeasurementItemRepository.findMinTimestampReturns = .just(nil)
        tempHumidityMeasurementItemRepository.findMaxTimestampReturns = .just(nil)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(nil),
            .completed
        ])
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMinTimestampParameters, [(remoteId, serverId)])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.findMaxTimestampParameters, [(remoteId, serverId)])
    }
}
