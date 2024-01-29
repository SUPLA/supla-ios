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

final class GetClientConfigUseCaseTests: UseCaseTest<RequestResult> {
    
    private lazy var useCase: GetChannelConfigUseCase! = { GetChannelConfigUseCaseImpl() }()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = {
        SuplaClientProviderMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
    }
    
    override func tearDown() {
        useCase = nil
        suplaClientProvider = nil
        
        super.tearDown()
    }
    
    func test_getParametersSuccess() {
        // given
        suplaClientProvider.suplaClientMock.getChannelConfigReturns = true
        
        // when
        useCase.invoke(remoteId: 123, type: .defaultConfig).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.success), .completed])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.getChannelConfigParameters.count, 1)
        
        let parameters = suplaClientProvider.suplaClientMock.getChannelConfigParameters[0].pointee
        XCTAssertEqual(parameters.ChannelId, 123)
        XCTAssertEqual(parameters.ConfigType, ChannelConfigType.defaultConfig.rawValue)
        XCTAssertEqual(parameters.Flags, 0)
    }
    
    func test_getParametersFailure() {
        // when
        useCase.invoke(remoteId: 123, type: .defaultConfig).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.failure), .completed])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.getChannelConfigParameters.count, 1)
        
        let parameters = suplaClientProvider.suplaClientMock.getChannelConfigParameters[0].pointee
        XCTAssertEqual(parameters.ChannelId, 123)
        XCTAssertEqual(parameters.ConfigType, ChannelConfigType.defaultConfig.rawValue)
        XCTAssertEqual(parameters.Flags, 0)
    }
}
