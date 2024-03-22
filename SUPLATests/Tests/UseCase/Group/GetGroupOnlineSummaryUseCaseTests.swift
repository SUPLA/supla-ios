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
import RxSwift

@testable import SUPLA

final class GetGroupOnlineSummaryUseCaseTests: UseCaseTest<GroupOnlineSummary> {
    
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    
    private lazy var channelGroupRelationRepository: ChannelGroupRelationRepositoryMock! = ChannelGroupRelationRepositoryMock()
    
    private lazy var useCase: GetGroupOnlineSummaryUseCase! = GetGroupOnlineSummaryUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.register((any ProfileRepository).self, profileRepository!)
        DiContainer.register((any ChannelGroupRelationRepository).self, channelGroupRelationRepository!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        channelGroupRelationRepository = nil
        useCase = nil
    }
    
    func test_shouldGetOnlineSummary() {
        // given
        let remoteId: Int32 = 123
        
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = .just(profile)
        
        let groupRelationOnline = mockGroupRelation(online: true)
        let groupRelationOffline = mockGroupRelation(online: false)
        channelGroupRelationRepository.getRelationsReturns = .just([groupRelationOnline, groupRelationOffline])
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(GroupOnlineSummary(onlineCount: 1, count: 2)),
            .completed
        ])
        
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertTuples(channelGroupRelationRepository.getRelationsParameters, [(profile, remoteId)])
    }
    
    private func mockGroupRelation(online: Bool) -> SAChannelGroupRelation {
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.online = online
        
        let groupRelationOnline = SAChannelGroupRelation(testContext: nil)
        groupRelationOnline.value = channelValue
        
        return groupRelationOnline
    }
}
