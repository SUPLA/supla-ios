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

final class InsertChannelConfigUseCaseTests: UseCaseTest<Void> {
    private lazy var channelConfigRepository: ChannelConfigRepositoryMock! = ChannelConfigRepositoryMock()
    private lazy var channelRepository: ChannelRepositoryMock! = ChannelRepositoryMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var generalPurposeMeterItemRepository: GeneralPurposeMeterItemRepositoryMock! = GeneralPurposeMeterItemRepositoryMock()
    private lazy var downloadEventManager: DownloadEventsManagerMock! = DownloadEventsManagerMock()
    
    private lazy var useCase: InsertChannelConfigUseCase! = InsertChannelConfigUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ChannelConfigRepository).self, channelConfigRepository!)
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository!)
        DiContainer.shared.register(type: (any DownloadEventsManager).self, downloadEventManager!)
    }
    
    override func tearDown() {
        channelConfigRepository = nil
        channelRepository = nil
        profileRepository = nil
        generalPurposeMeterItemRepository = nil
        downloadEventManager = nil
        
        super.tearDown()
    }
    
    func test_shouldQuitWhenResultIsNotTrue() {
        // when
        useCase.invoke(config: nil, result: .resultFalse).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
    }
    
    func test_shouldInsertGeneralPurposeMeasurementConfig() {
        // given
        let remoteId: Int32 = 231
        let crc32: Int64 = 123
        let profile = AuthProfileItem.mock()
        let channel = SAChannel.mock()
        let config = SuplaChannelGeneralPurposeMeasurementConfig.mock(remoteId: remoteId, crc32: crc32)
        let channelConfig = SAChannelConfig.mock()
        
        channelConfigRepository.getConfigReturns = .just(nil)
        profileRepository.activeProfileObservable = .just(profile)
        channelRepository.channelObservable = .just(channel)
        channelConfigRepository.createObservable = .just(channelConfig)
        channelConfigRepository.saveObservable = .just(())
        
        // when
        useCase.invoke(config: config, result: .resultTrue).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.createCounter, 1)
        XCTAssertEqual(channelConfigRepository.saveParameters, [channelConfig])
        XCTAssertEqual(generalPurposeMeterItemRepository.deleteAllParameters, [])
        XCTAssertEqual(downloadEventManager.emitProgressStateParameters.count, 0)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertEqual(channelRepository.channelProfiles, [profile])
        XCTAssertEqual(channelRepository.channelRemoteIds, [remoteId])
        
        XCTAssertEqual(channelConfig.profile, profile)
        XCTAssertEqual(channelConfig.channel, channel)
        XCTAssertEqual(channelConfig.config_crc32, crc32)
        XCTAssertEqual(channelConfig.config_type, Int32(ChannelConfigType.generalPurposeMeasurement.rawValue))
    }
    
    func test_shouldInsertGeneralPurposeMeterConfig() {
        // given
        let remoteId: Int32 = 231
        let crc32: Int64 = 123
        let profile = AuthProfileItem.mock()
        let channel = SAChannel.mock()
        let config = SuplaChannelGeneralPurposeMeterConfig.mock(remoteId: remoteId, crc32: crc32)
        let channelConfig = SAChannelConfig.mock()
        
        channelConfigRepository.getConfigReturns = .just(nil)
        profileRepository.activeProfileObservable = .just(profile)
        channelRepository.channelObservable = .just(channel)
        channelConfigRepository.createObservable = .just(channelConfig)
        channelConfigRepository.saveObservable = .just(())
        
        // when
        useCase.invoke(config: config, result: .resultTrue).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.createCounter, 1)
        XCTAssertEqual(channelConfigRepository.saveParameters, [channelConfig])
        XCTAssertEqual(generalPurposeMeterItemRepository.deleteAllParameters, [])
        XCTAssertEqual(downloadEventManager.emitProgressStateParameters.count, 0)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertEqual(channelRepository.channelProfiles, [profile])
        XCTAssertEqual(channelRepository.channelRemoteIds, [remoteId])
        
        XCTAssertEqual(channelConfig.profile, profile)
        XCTAssertEqual(channelConfig.channel, channel)
        XCTAssertEqual(channelConfig.config_crc32, crc32)
        XCTAssertEqual(channelConfig.config_type, Int32(ChannelConfigType.generalPurposeMeter.rawValue))
    }
    
    func test_shouldUpdateGeneralPurposeMeasurementConfig() {
        // given
        let remoteId: Int32 = 231
        let crc32: Int64 = 123
        let config = SuplaChannelGeneralPurposeMeasurementConfig.mock(remoteId: remoteId, crc32: crc32)
        let channelConfig = SAChannelConfig.mock()
        
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        channelConfigRepository.saveObservable = .just(())
        
        // when
        useCase.invoke(config: config, result: .resultTrue).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.createCounter, 0)
        XCTAssertEqual(channelConfigRepository.saveParameters, [channelConfig])
        XCTAssertEqual(generalPurposeMeterItemRepository.deleteAllParameters, [])
        XCTAssertEqual(downloadEventManager.emitProgressStateParameters.count, 0)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertEqual(channelRepository.channelProfiles, [])
        XCTAssertEqual(channelRepository.channelRemoteIds, [])
        
        XCTAssertEqual(channelConfig.config_crc32, crc32)
        XCTAssertEqual(channelConfig.config_type, Int32(ChannelConfigType.generalPurposeMeasurement.rawValue))
    }
    
    func test_shouldUpdateGeneralPurposeMeterConfig() {
        // given
        let remoteId: Int32 = 231
        let crc32: Int64 = 123
        let config = SuplaChannelGeneralPurposeMeterConfig.mock(remoteId: remoteId, crc32: crc32)
        let channelConfig = SAChannelConfig.mock()
        
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        channelConfigRepository.saveObservable = .just(())
        
        // when
        useCase.invoke(config: config, result: .resultTrue).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.createCounter, 0)
        XCTAssertEqual(channelConfigRepository.saveParameters, [channelConfig])
        XCTAssertEqual(generalPurposeMeterItemRepository.deleteAllParameters, [])
        XCTAssertEqual(downloadEventManager.emitProgressStateParameters.count, 0)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertEqual(channelRepository.channelProfiles, [])
        XCTAssertEqual(channelRepository.channelRemoteIds, [])
        
        XCTAssertEqual(channelConfig.config_crc32, crc32)
        XCTAssertEqual(channelConfig.config_type, Int32(ChannelConfigType.generalPurposeMeter.rawValue))
    }
    
    func test_shouldRemoveConfigWhenNotHandled() {
        // given
        let remoteId: Int32 = 231
        let profile = AuthProfileItem.mock()
        let channel = SAChannel.mock()
        
        profileRepository.activeProfileObservable = .just(profile)
        channelRepository.channelObservable = .just(channel)
        channelConfigRepository.deleteAllReturns = .just(())
        
        // when
        useCase.invoke(
            config: SuplaChannelConfig(remoteId: remoteId, channelFunc: SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER),
            result: .resultTrue
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [])
        XCTAssertEqual(channelConfigRepository.createCounter, 0)
        XCTAssertEqual(channelConfigRepository.saveParameters, [])
        XCTAssertEqual(generalPurposeMeterItemRepository.deleteAllParameters, [])
        XCTAssertEqual(downloadEventManager.emitProgressStateParameters.count, 0)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertEqual(channelRepository.channelProfiles, [profile])
        XCTAssertEqual(channelRepository.channelRemoteIds, [remoteId])
        XCTAssertTuples(channelConfigRepository.deleteAllParameters, [(channel, profile)])
    }
    
    func test_shouldDoNothingWhenConfigShouldNotBeHandled() {
        // given
        let remoteId: Int32 = 231
        
        // when
        useCase.invoke(
            config: SuplaChannelConfig(remoteId: remoteId, channelFunc: SUPLA_CHANNELFNC_THERMOMETER),
            result: .resultTrue
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [])
        XCTAssertEqual(channelConfigRepository.createCounter, 0)
        XCTAssertEqual(channelConfigRepository.saveParameters, [])
        XCTAssertEqual(generalPurposeMeterItemRepository.deleteAllParameters, [])
        XCTAssertEqual(downloadEventManager.emitProgressStateParameters.count, 0)
        XCTAssertEqual(profileRepository.activeProfileCalls, 0)
        XCTAssertEqual(channelRepository.channelProfiles, [])
        XCTAssertEqual(channelRepository.channelRemoteIds, [])
        XCTAssertTuples(channelConfigRepository.deleteAllParameters, [])
    }
    
    func test_shouldDeleteHistoryAndEmitRefreshState_whenCounterTypeChanged() {
        // given
        let remoteId: Int32 = 231
        let crc32: Int64 = 123
        let profile = AuthProfileItem.mock()
        let channel = SAChannel.mock()
        let config = SuplaChannelGeneralPurposeMeterConfig.mock(
            remoteId: remoteId,
            crc32: crc32,
            counterType: .alwaysDecrement
        )
        let channelConfig = SAChannelConfig.mock(
            type: .generalPurposeMeter,
            config: SuplaChannelGeneralPurposeMeterConfig.mock(counterType: .alwaysIncrement).toJson()
        )
        
        channelConfigRepository.getConfigReturns = .just(nil)
        channelConfigRepository.saveObservable = .just(())
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        profileRepository.activeProfileObservable = .just(profile)
        channelRepository.channelObservable = .just(channel)
        generalPurposeMeterItemRepository.deleteAllForProfileAndChannelReturns = .just(())
        
        // when
        useCase.invoke(config: config, result: .resultTrue).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.createCounter, 0)
        XCTAssertEqual(channelConfigRepository.saveParameters, [channelConfig])
        XCTAssertTuples(generalPurposeMeterItemRepository.deleteAllForProfileAndChannelParameters, [
            (profile, remoteId)
        ])
        XCTAssertTuples(downloadEventManager.emitProgressStateParameters, [(remoteId, .refresh)])
        XCTAssertEqual(profileRepository.activeProfileCalls, 2)
        XCTAssertEqual(channelRepository.channelProfiles, [])
        XCTAssertEqual(channelRepository.channelRemoteIds, [])
        
        XCTAssertEqual(channelConfig.config_crc32, crc32)
        XCTAssertEqual(channelConfig.config_type, Int32(ChannelConfigType.generalPurposeMeter.rawValue))
    }
    
    func test_shouldDeleteHistoryAndEmitRefreshState_whenFillMissingDataChanged() {
        // given
        let remoteId: Int32 = 231
        let crc32: Int64 = 123
        let profile = AuthProfileItem.mock()
        let channel = SAChannel.mock()
        let config = SuplaChannelGeneralPurposeMeterConfig.mock(
            remoteId: remoteId,
            crc32: crc32,
            fillMissingData: true
        )
        let channelConfig = SAChannelConfig.mock(
            type: .generalPurposeMeter,
            config: SuplaChannelGeneralPurposeMeterConfig.mock(fillMissingData: false).toJson()
        )
        
        channelConfigRepository.getConfigReturns = .just(nil)
        channelConfigRepository.saveObservable = .just(())
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        profileRepository.activeProfileObservable = .just(profile)
        channelRepository.channelObservable = .just(channel)
        generalPurposeMeterItemRepository.deleteAllForProfileAndChannelReturns = .just(())
        
        // when
        useCase.invoke(config: config, result: .resultTrue).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.createCounter, 0)
        XCTAssertEqual(channelConfigRepository.saveParameters, [channelConfig])
        XCTAssertTuples(generalPurposeMeterItemRepository.deleteAllForProfileAndChannelParameters, [
            (profile, remoteId)
        ])
        XCTAssertTuples(downloadEventManager.emitProgressStateParameters, [(remoteId, .refresh)])
        XCTAssertEqual(profileRepository.activeProfileCalls, 2)
        XCTAssertEqual(channelRepository.channelProfiles, [])
        XCTAssertEqual(channelRepository.channelRemoteIds, [])
        
        XCTAssertEqual(channelConfig.config_crc32, crc32)
        XCTAssertEqual(channelConfig.config_type, Int32(ChannelConfigType.generalPurposeMeter.rawValue))
    }
}
