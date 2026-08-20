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
import RxTest
import SharedCore
import XCTest

@testable import SUPLA

final class ReadChannelWithChildrenUseCaseTests: UseCaseTest<SUPLA.ChannelWithChildren> {
    private lazy var useCase: ReadChannelWithChildrenUseCase! = ReadChannelWithChildrenUseCaseImpl()
    
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var channelRepository: ChannelRepositoryMock! = ChannelRepositoryMock()
    private lazy var channelRelationRepository: ChannelRelationRepositoryMock! = ChannelRelationRepositoryMock()
    private lazy var createChannelWithChildrenUseCase: CreateChannelWithChildrenUseCaseMock! = CreateChannelWithChildrenUseCaseMock()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: (any ChannelRelationRepository).self, channelRelationRepository!)
        DiContainer.shared.register(type: (any CreateChannelWithChildrenUseCase).self, createChannelWithChildrenUseCase!)
        
        super.setUp()
    }
    
    override func tearDown() {
        useCase = nil
        profileRepository = nil
        channelRepository = nil
        channelRelationRepository = nil
        createChannelWithChildrenUseCase = nil
        super.tearDown()
    }
    
    func test_shouldLoadChannelWithChildren() {
        // given
        let channelId: Int32 = 123
        let profile = AuthProfileItem(testContext: nil)
        let channels = mockChannels(channelId)
        
        profileRepository.activeProfileObservable = Observable.just(profile)
        channelRepository.getAllChannelsReturns = Observable.just(channels)
        
        let relation1 = SAChannelRelation.mock(channelId, channelId: 1, type: .mainThermometer)
        let relation2 = SAChannelRelation.mock(channelId, channelId: 2, type: .auxThermometerFloor)
        channelRelationRepository.getAllRelationsWithParentReturns = Observable.just([relation1, relation2])
        
        let channelWithChildren = ChannelWithChildren(channel: channels[0])
        createChannelWithChildrenUseCase.invokeMock.returns = .single(channelWithChildren)
        
        // when
        useCase.invoke(remoteId: channelId)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEventsCount(2)
        assertEvents([
            .next(channelWithChildren),
            .completed
        ])
    }
    
    private func mockChannels(_ parentId: Int32) -> [SAChannel] {
        return [
            SAChannel.mock(parentId),
            SAChannel.mock(1),
            SAChannel.mock(2),
            SAChannel.mock(3)
        ]
    }
}
