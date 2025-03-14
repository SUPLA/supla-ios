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

final class ReadChannelWithChildrenTreeUseCaseTests: UseCaseTest<SUPLA.ChannelWithChildren> {
    
    private lazy var useCase: ReadChannelWithChildrenTreeUseCase! = { ReadChannelWithChildrenTreeUseCaseImpl() }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = { ProfileRepositoryMock() }()
    private lazy var channelRepository: ChannelRepositoryMock! = { ChannelRepositoryMock() }()
    private lazy var channelRelationRepository: ChannelRelationRepositoryMock! = {
        ChannelRelationRepositoryMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: (any ChannelRelationRepository).self, channelRelationRepository!)
        
        super.setUp()
    }
    
    override func tearDown() {
        useCase = nil
        profileRepository = nil
        channelRepository = nil
        channelRelationRepository = nil
        super.tearDown()
    }
    
    func test_shouldLoadChannelWithChildrenTree() {
        // given
        let channelId: Int32 = 1
        let profile = AuthProfileItem(testContext: nil)
        let channels = [
            SAChannel.mock(1),
            SAChannel.mock(2),
            SAChannel.mock(3),
            SAChannel.mock(4)
        ]
        
        profileRepository.activeProfileObservable = Observable.just(profile)
        channelRepository.allVisibleChannelsObservable = Observable.just(channels)
        
        let relation1 = SAChannelRelation.mock(1, channelId: 2, type: .meter)
        let relation2 = SAChannelRelation.mock(1, channelId: 3, type: .masterThermostat)
        let relation3 = SAChannelRelation.mock(3, channelId: 4, type: .mainThermometer)
        channelRelationRepository.getParentsMapReturns = Observable.just([
            1: [relation1, relation2],
            3: [relation3]
        ])
        
        // when
        useCase.invoke(remoteId: channelId)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEventsCount(2)
        assertEvents([
            .next(
                ChannelWithChildren(channel: channels[0], children: [
                    ChannelChild(channel: channels[1], relation: relation1),
                    ChannelChild(channel: channels[2], relation: relation2, children: [
                        ChannelChild(channel: channels[3], relation: relation3)
                    ])
                ])
            ),
            .completed
        ])
        
    }
}
