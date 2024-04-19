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

final class CreateProfileChannelsListUseCaseTests: UseCaseTest<[List]> {
    
    private lazy var useCase: CreateProfileChannelsListUseCase! = { CreateProfileChannelsListUseCaseImpl() }()
    
    private lazy var channelRepository: ChannelRepositoryMock! = {
        ChannelRepositoryMock()
    }()
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    private lazy var channelRelationRepository: ChannelRelationRepositoryMock! = {
        ChannelRelationRepositoryMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelRelationRepository).self, channelRelationRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        channelRepository = nil
        profileRepository = nil
        channelRelationRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldProvideItems_whenLocationIsExpanded() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let location1 = _SALocation(testContext: nil)
        location1.caption = "Caption 1"
        location1.location_id = 1
        let channel1 = SAChannel(testContext: nil)
        channel1.remote_id = 1
        channel1.location = location1
        
        let location2 = _SALocation(testContext: nil)
        location2.caption = "Caption 2"
        location2.location_id = 2
        let channel2 = SAChannel(testContext: nil)
        channel2.remote_id = 2
        channel2.location = location2
        let channel3 = SAChannel(testContext: nil)
        channel3.remote_id = 3
        channel3.location_id = 2
        
        channelRepository.allVisibleChannelsObservable = Observable.just([ channel1, channel2, channel3 ])
        
        let relation = SAChannelRelation(testContext: nil)
        relation.channel_id = 3
        channelRelationRepository.getParentsMapReturns = Observable.just([1 : [relation]])
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        guard let items = observer.events[0].value.element?.first?.items else {
            XCTFail("No items produced")
            return
        }
        
        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items, [
            .location(location: location1),
            .channelBase(channelBase: channel1, children: [ChannelChild(channel: channel3, relationType: .defaultType)]),
            .location(location: location2),
            .channelBase(channelBase: channel2, children: [])
        ])
    }
    
    func test_shouldNotProvideItems_whenLocationIsCollapsed() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let location1 = _SALocation(testContext: nil)
        location1.caption = "Location 1"
        location1.location_id = 1
        location1.collapsed = 0 | CollapsedFlag.channel.rawValue
        
        let channel1 = SAChannel(testContext: nil)
        channel1.location = location1
        
        let location2 = _SALocation(testContext: nil)
        location2.caption = "Location 2"
        location2.location_id = 2
        let channel2 = SAChannel(testContext: nil)
        channel2.location = location2
        
        channelRepository.allVisibleChannelsObservable = Observable.just([ channel1, channel2 ])
        channelRelationRepository.getParentsMapReturns = Observable.just([:])
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        guard let items = observer.events[0].value.element?.first?.items else {
            XCTFail("No items produced")
            return
        }
        
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items, [
            .location(location: location1),
            .location(location: location2),
            .channelBase(channelBase: channel2, children: [])
        ])
    }
    
    func test_shouldMergeLocationWithTheSameNameIntoOne() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let location1 = _SALocation(testContext: nil)
        location1.caption = "Location 1"
        location1.location_id = 1
        
        let channel1 = SAChannel(testContext: nil)
        channel1.location = location1
        
        let location2 = _SALocation(testContext: nil)
        location2.caption = "Location 1"
        location2.location_id = 2
        let channel2 = SAChannel(testContext: nil)
        channel2.location = location2
        
        channelRepository.allVisibleChannelsObservable = Observable.just([ channel1, channel2 ])
        channelRelationRepository.getParentsMapReturns = Observable.just([:])
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        guard let items = observer.events[0].value.element?.first?.items else {
            XCTFail("No items produced")
            return
        }
        
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items, [
            .location(location: location1),
            .channelBase(channelBase: channel1, children: []),
            .channelBase(channelBase: channel2, children: [])
        ])
    }
    
    func test_shouldLoadChannelWithChildren() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let location1 = _SALocation(testContext: nil)
        location1.caption = "Caption 1"
        location1.location_id = 1
        let channel1 = SAChannel(testContext: nil)
        channel1.remote_id = 1
        channel1.location = location1
        
        let location2 = _SALocation(testContext: nil)
        location2.caption = "Caption 2"
        location2.location_id = 2
        let channel2 = SAChannel(testContext: nil)
        channel2.remote_id = 2
        channel2.location = location2
        channel2.flags = Int64(SUPLA_CHANNEL_FLAG_HAS_PARENT)
        let channel3 = SAChannel(testContext: nil)
        channel3.remote_id = 3
        channel3.location_id = 2
        channel3.flags = Int64(SUPLA_CHANNEL_FLAG_HAS_PARENT)
        
        channelRepository.allVisibleChannelsObservable = Observable.just([ channel1, channel2, channel3 ])
        channelRelationRepository.getParentsMapReturns = Observable.just([
            1: [
                SAChannelRelation.mock(1, channelId: 2, type: .mainThermometer),
                SAChannelRelation.mock(1, channelId: 3, type: .auxThermometerFloor)
            ]
        ])
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        guard let items = observer.events[0].value.element?.first?.items else {
            XCTFail("No items produced")
            return
        }
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items, [
            .location(location: location1),
            .channelBase(channelBase: channel1, children: [
                ChannelChild(channel: channel2, relationType: .mainThermometer),
                ChannelChild(channel: channel3, relationType: .auxThermometerFloor)
            ]),
        ])
    }
}

