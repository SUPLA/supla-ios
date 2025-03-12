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

final class LoadChannelConfigUseCaseTests: UseCaseTest<SuplaChannelConfig?> {
    private lazy var channelConfigRepository: ChannelConfigRepositoryMock! = ChannelConfigRepositoryMock()
    
    private lazy var useCase: LoadChannelConfigUseCase! = LoadChannelConfigUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ChannelConfigRepository).self, channelConfigRepository!)
    }
    
    override func tearDown() {
        channelConfigRepository = nil
        
        super.tearDown()
    }
    
    func test_loadGeneralPurposeMeasurementConfig() {
        // given
        let remoteId: Int32 = 123
        let config = SuplaChannelGeneralPurposeMeasurementConfig.mock()
        let channelConfig = SAChannelConfig.mock(type: .generalPurposeMeasurement, config: config.toJson())
        
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(config), .completed])
    }
    
    func test_loadGeneralPurposeMeterConfig() {
        // given
        let remoteId: Int32 = 123
        let config = SuplaChannelGeneralPurposeMeterConfig.mock()
        let channelConfig = SAChannelConfig.mock(type: .generalPurposeMeter, config: config.toJson())
        
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(config), .completed])
    }
    
    func test_shouldLoadContainerConfig() {
        // given
        let remoteId: Int32 = 123
        let config = SuplaChannelContainerConfig.mock()
        let channelConfig = SAChannelConfig.mock(type: .container, config: config.toJson())
        
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(config), .completed])
    }
    
    func test_loadNilWhenCouldNotParseConfig() {
        // given
        let remoteId: Int32 = 123
        let config = SuplaChannelGeneralPurposeMeterConfig.mock()
        let channelConfig = SAChannelConfig.mock(type: .generalPurposeMeasurement, config: config.toJson())
        
        channelConfigRepository.getConfigReturns = .just(channelConfig)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(nil), .completed])
    }
}
