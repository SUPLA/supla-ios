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
import RxTest
import RxSwift

@testable import SUPLA

final class ReadChannelByRemoteIdUseCaseTests: UseCaseTest<SAChannel> {
    
    private lazy var useCase: ReadChannelByRemoteIdUseCase! = { ReadChannelByRemoteIdUseCaseImpl() }()
    
    private lazy var channelRepository: ChannelRepositoryMock! = {
        ChannelRepositoryMock()
    }()
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        channelRepository = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldLoadChannelByRemoteIdForActiveProfile() {
        // given
        let remoteId: Int32 = 123
        let profile = AuthProfileItem(testContext: nil)
        let channel = SAChannel(testContext: nil)
        
        profileRepository.activeProfileObservable = Observable.just(profile)
        channelRepository.channelObservable = Observable.just(channel)
        
        // when
        useCase.invoke(remoteId: remoteId)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events, [.next(0, channel), .completed(0)])
        
        XCTAssertEqual(channelRepository.channelProfiles, [profile])
        XCTAssertEqual(channelRepository.channelRemoteIds, [remoteId])
    }
}
