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

final class RequestChannelConfigUseCaseTests: UseCaseTest<Void> {
    private lazy var channelConfigRepository: ChannelConfigRepositoryMock! = ChannelConfigRepositoryMock()
    private lazy var getChannelConfigUseCase: GetChannelConfigUseCaseMock! = GetChannelConfigUseCaseMock()
    
    private lazy var useCase: RequestChannelConfigUseCase! = RequestChannelConfigUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ChannelConfigRepository).self, channelConfigRepository!)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, getChannelConfigUseCase!)
    }
    
    override func tearDown() {
        channelConfigRepository = nil
        getChannelConfigUseCase = nil
        
        useCase = nil
        
        super.tearDown()
    }
    
    func test_shouldJustQuitWhenConfigShouldNotBeRequested() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        
        var suplaChannel = TSC_SuplaChannel_E()
        suplaChannel.Func = SUPLA_CHANNELFNC_NONE
        
        // when
        useCase.invoke(suplaChannel: suplaChannel, profile: profile).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
    }
    
    func test_shouldAskForConfigWhenCrcDiffers() {
        // given
        let remoteId: Int32 = 123
        let profile = AuthProfileItem(testContext: nil)
        let config = SAChannelConfig(testContext: nil)
        config.config_crc32 = 10
        var suplaConfig = TSC_SuplaChannel_E()
        suplaConfig.Id = remoteId
        suplaConfig.Func = SUPLA_CHANNELFNC_VERTICAL_BLIND
        suplaConfig.DefaultConfigCRC32 = 5
        
        channelConfigRepository.getConfigReturns = .just(config)
        getChannelConfigUseCase.returns = .just(.success)
        
        // when
        useCase.invoke(suplaChannel: suplaConfig, profile: profile).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertTuples(getChannelConfigUseCase.parameters, [(remoteId, ChannelConfigType.defaultConfig)])
    }
    
    func test_shouldNotAskForConfigWhenCrcSame() {
        // given
        let remoteId: Int32 = 123
        let profile = AuthProfileItem(testContext: nil)
        let config = SAChannelConfig(testContext: nil)
        config.config_crc32 = 10
        var suplaConfig = TSC_SuplaChannel_E()
        suplaConfig.Id = remoteId
        suplaConfig.Func = SUPLA_CHANNELFNC_VERTICAL_BLIND
        suplaConfig.DefaultConfigCRC32 = 10
        
        channelConfigRepository.getConfigReturns = .just(config)
        
        // when
        useCase.invoke(suplaChannel: suplaConfig, profile: profile).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertEqual(getChannelConfigUseCase.parameters.count, 0)
    }
    
    
    
    func test_shouldAskForConfigWhenNotStored() {
        // given
        let remoteId: Int32 = 123
        let profile = AuthProfileItem(testContext: nil)
        var suplaConfig = TSC_SuplaChannel_E()
        suplaConfig.Id = remoteId
        suplaConfig.Func = SUPLA_CHANNELFNC_VERTICAL_BLIND
        suplaConfig.DefaultConfigCRC32 = 10
        
        channelConfigRepository.getConfigReturns = .just(nil)
        getChannelConfigUseCase.returns = .just(.success)
        
        // when
        useCase.invoke(suplaChannel: suplaConfig, profile: profile).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [remoteId])
        XCTAssertTuples(getChannelConfigUseCase.parameters, [(remoteId, ChannelConfigType.defaultConfig)])
    }
}
