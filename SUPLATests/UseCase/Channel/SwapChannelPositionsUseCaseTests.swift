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

final class SwapChannelPositionsUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: SwapChannelPositionsUseCase! = { SwapChannelPositionsUseCaseImpl() }()
    
    private lazy var channelRepository: ChannelRepositoryMock! = {
        ChannelRepositoryMock()
    }()
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ChannelRepository).self, component: channelRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        channelRepository = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldSwapPositions() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let channel1 = SAChannel(testContext: nil)
        channel1.remote_id = 1
        
        let channel2 = SAChannel(testContext: nil)
        channel2.remote_id = 2
        
        channelRepository.allVisibleChannelsInLocationObservable = Observable.just([ channel1, channel2 ])
        channelRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: channel1.remote_id, secondRemoteId: channel2.remote_id, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(channel1.position, 1)
        XCTAssertEqual(channel2.position, 0)
        
        XCTAssertEqual(channelRepository.allVisibleChannelsInLocationProfiles, [profile])
        XCTAssertEqual(channelRepository.allVisibleChannelsInLocationCaptions, [locationCaption])
        XCTAssertEqual(channelRepository.saveCounter, 1)
    }
    
    func test_shouldNotSwap_whenWasNotFound() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let channel1 = SAChannel(testContext: nil)
        channel1.remote_id = 1
        
        let channel2 = SAChannel(testContext: nil)
        channel2.remote_id = 2
        
        channelRepository.allVisibleChannelsInLocationObservable = Observable.just([ channel1, channel2 ])
        channelRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: channel1.remote_id, secondRemoteId: 3, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(channel1.position, 0)
        XCTAssertEqual(channel2.position, 0)
        
        XCTAssertEqual(channelRepository.allVisibleChannelsInLocationProfiles, [profile])
        XCTAssertEqual(channelRepository.allVisibleChannelsInLocationCaptions, [locationCaption])
        XCTAssertEqual(channelRepository.saveCounter, 0)
    }
    
    func test_shouldNotSwap_whenThereIsOnlyOne() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let channel1 = SAChannel(testContext: nil)
        channel1.remote_id = 1
        
        channelRepository.allVisibleChannelsInLocationObservable = Observable.just([ channel1 ])
        channelRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: channel1.remote_id, secondRemoteId: 3, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        
        XCTAssertEqual(channelRepository.allVisibleChannelsInLocationProfiles, [profile])
        XCTAssertEqual(channelRepository.allVisibleChannelsInLocationCaptions, [locationCaption])
        XCTAssertEqual(channelRepository.saveCounter, 0)
    }
}

