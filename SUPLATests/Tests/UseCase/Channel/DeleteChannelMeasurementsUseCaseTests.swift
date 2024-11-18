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

final class DeleteChannelMeasurementsUseCaseTests: UseCaseTest<Void> {
    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = ReadChannelWithChildrenUseCaseMock()
    private lazy var temperatureMeasurementItemRepository: TemperatureMeasurementItemRepositoryMock! = TemperatureMeasurementItemRepositoryMock()
    private lazy var tempHumidityMeasurementItemRepository: TempHumidityMeasurementItemRepositoryMock! = TempHumidityMeasurementItemRepositoryMock()
    private lazy var generalPurposeMeasurementItemRepository: GeneralPurposeMeasurementItemRepositoryMock! = GeneralPurposeMeasurementItemRepositoryMock()
    private lazy var generalPurposeMeterItemRepository: GeneralPurposeMeterItemRepositoryMock! = GeneralPurposeMeterItemRepositoryMock()
    
    private lazy var useCase: DeleteChannelMeasurementsUseCase! = DeleteChannelMeasurementsUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.register(ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase!)
        DiContainer.register((any TemperatureMeasurementItemRepository).self, temperatureMeasurementItemRepository!)
        DiContainer.register((any TempHumidityMeasurementItemRepository).self, tempHumidityMeasurementItemRepository!)
        DiContainer.register((any GeneralPurposeMeasurementItemRepository).self, generalPurposeMeasurementItemRepository!)
        DiContainer.register((any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        readChannelWithChildrenUseCase = nil
        temperatureMeasurementItemRepository = nil
        tempHumidityMeasurementItemRepository = nil
        generalPurposeMeasurementItemRepository = nil
        generalPurposeMeterItemRepository = nil
        
        useCase = nil
    }
    
    func test_shouldDeleteThermometerHistory() {
        // given
        let remoteId: Int32 = 111
        let profile = AuthProfileItem(testContext: nil)
        let channel = ChannelWithChildren(channel: SAChannel(testContext: nil), children: [])
        channel.channel.remote_id = remoteId
        channel.channel.func = SUPLA_CHANNELFNC_THERMOMETER
        channel.channel.profile = profile
        
        readChannelWithChildrenUseCase.returns = .just(channel)
        temperatureMeasurementItemRepository.deleteAllForRemoteIdAndProfileReturns = .just(())
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(()),
            .completed
        ])
        XCTAssertTuples(temperatureMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [
            (remoteId, profile)
        ])
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
    }
    
    func test_shouldDeleteHumidityAndThermometerHistory() {
        // given
        let remoteId: Int32 = 111
        let profile = AuthProfileItem(testContext: nil)
        let channel = ChannelWithChildren(channel: SAChannel(testContext: nil), children: [])
        channel.channel.remote_id = remoteId
        channel.channel.func = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        channel.channel.profile = profile
        
        readChannelWithChildrenUseCase.returns = .just(channel)
        tempHumidityMeasurementItemRepository.deleteAllForRemoteIdAndProfileReturns = .just(())
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(()),
            .completed
        ])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [
            (remoteId, profile)
        ])
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
    }
    
    func test_shouldDeleteGeneralPurposeMeasurementHistory() {
        // given
        let remoteId: Int32 = 111
        let profile = AuthProfileItem(testContext: nil)
        let channel = ChannelWithChildren(channel: SAChannel(testContext: nil), children: [])
        channel.channel.remote_id = remoteId
        channel.channel.func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
        channel.channel.profile = profile
        
        readChannelWithChildrenUseCase.returns = .just(channel)
        generalPurposeMeasurementItemRepository.deleteAllForRemoteIdAndProfileReturns = .just(())
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(()),
            .completed
        ])
        XCTAssertTuples(generalPurposeMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [
            (remoteId, profile)
        ])
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
    }
    
    func test_shouldDeleteGeneralPurposeMeterHistory() {
        // given
        let remoteId: Int32 = 111
        let profile = AuthProfileItem(testContext: nil)
        let channel = ChannelWithChildren(channel: SAChannel(testContext: nil), children: [])
        channel.channel.remote_id = remoteId
        channel.channel.func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
        channel.channel.profile = profile
        
        readChannelWithChildrenUseCase.returns = .just(channel)
        generalPurposeMeterItemRepository.deleteAllForRemoteIdAndProfileReturns = .just(())
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(()),
            .completed
        ])
        XCTAssertTuples(generalPurposeMeterItemRepository.deleteAllForRemoteIdAndProfileParameters, [
            (remoteId, profile)
        ])
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
    }
    
    func test_shouldDeleteHistory_channelWithChildren() {
        // given
        let remoteId: Int32 = 111
        let profile = AuthProfileItem(testContext: nil)
        
        let thermometerChild = SAChannel(testContext: nil)
        thermometerChild.func = SUPLA_CHANNELFNC_THERMOMETER
        thermometerChild.remote_id = 222
        thermometerChild.profile = profile
        
        let humidityAndThermomereterChild = SAChannel(testContext: nil)
        humidityAndThermomereterChild.func = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        humidityAndThermomereterChild.remote_id = 333
        humidityAndThermomereterChild.profile = profile
        
        let channel = ChannelWithChildren(channel: SAChannel(testContext: nil), children: [
            ChannelChild(channel: humidityAndThermomereterChild, relation: SAChannelRelation.mock(type: .mainThermometer)),
            ChannelChild(channel: thermometerChild, relation: SAChannelRelation.mock(type: .auxThermometerFloor))
        ])
        channel.channel.remote_id = remoteId
        channel.channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        channel.channel.profile = profile
        
        readChannelWithChildrenUseCase.returns = .just(channel)
        temperatureMeasurementItemRepository.deleteAllForRemoteIdAndProfileReturns = .just(())
        tempHumidityMeasurementItemRepository.deleteAllForRemoteIdAndProfileReturns = .just(())
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(()),
            .next(()),
            .completed
        ])
        XCTAssertTuples(temperatureMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [
            (Int32(222), profile)
        ])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [
            (Int32(333), profile)
        ])
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [remoteId])
    }
}
