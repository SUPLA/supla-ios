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

final class SwapGroupPositionsUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: SwapGroupPositionsUseCase! = { SwapGroupPositionsUseCaseImpl() }()
    
    private lazy var groupRepository: GroupRepositoryMock! = {
        GroupRepositoryMock()
    }()
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any GroupRepository).self, component: groupRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        groupRepository = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldSwapGroupPositions() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let group1 = SAChannelGroup(testContext: nil)
        group1.remote_id = 1
        
        let group2 = SAChannelGroup(testContext: nil)
        group2.remote_id = 2
        
        groupRepository.allVisibleGroupsInLocationObservable = Observable.just([ group1, group2 ])
        groupRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: group1.remote_id, secondRemoteId: group2.remote_id, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(group1.position, 1)
        XCTAssertEqual(group2.position, 0)
        
        XCTAssertEqual(groupRepository.allVisibleGroupsInLocationProfiles, [profile])
        XCTAssertEqual(groupRepository.allVisibleGroupsInLocationCaptions, [locationCaption])
        XCTAssertEqual(groupRepository.saveCounter, 1)
    }
    
    func test_shouldNotSwap_whenGroupWasNotFound() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let group1 = SAChannelGroup(testContext: nil)
        group1.remote_id = 1
        
        let group2 = SAChannelGroup(testContext: nil)
        group2.remote_id = 2
        
        groupRepository.allVisibleGroupsInLocationObservable = Observable.just([ group1, group2 ])
        groupRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: group1.remote_id, secondRemoteId: 3, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(group1.position, 0)
        XCTAssertEqual(group2.position, 0)
        
        XCTAssertEqual(groupRepository.allVisibleGroupsInLocationProfiles, [profile])
        XCTAssertEqual(groupRepository.allVisibleGroupsInLocationCaptions, [locationCaption])
        XCTAssertEqual(groupRepository.saveCounter, 0)
    }
    
    func test_shouldNotSwap_whenThereIsOnlyOneGroup() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let group1 = SAChannelGroup(testContext: nil)
        group1.remote_id = 1
        
        groupRepository.allVisibleGroupsInLocationObservable = Observable.just([ group1 ])
        groupRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: group1.remote_id, secondRemoteId: 3, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        
        XCTAssertEqual(groupRepository.allVisibleGroupsInLocationProfiles, [profile])
        XCTAssertEqual(groupRepository.allVisibleGroupsInLocationCaptions, [locationCaption])
        XCTAssertEqual(groupRepository.saveCounter, 0)
    }
}
