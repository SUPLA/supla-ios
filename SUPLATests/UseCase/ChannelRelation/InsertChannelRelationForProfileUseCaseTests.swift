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

final class InsertChannelRelationForProfileUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: InsertChannelRelationForProfileUseCase! = {
        InsertChannelRelationForProfileUseCase()
    }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = { ProfileRepositoryMock() }()
    private lazy var channelRelationRepository: ChannelRelationRepositoryMock! = {
        ChannelRelationRepositoryMock()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
        DiContainer.shared.register(type: (any ChannelRelationRepository).self, component: channelRelationRepository!)
    }
    
    override func tearDown() {
        profileRepository = nil
        channelRelationRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldUpdateExistingRelation() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        let relation = SAChannelRelation(testContext: nil)
        relation.delete_flag = true
        let suplaRelation = TSC_SuplaChannelRelation(EOL: 0, Id: 123, ParentId: 234, Type: 4)
        
        profileRepository.activeProfileObservable = Observable.just(profile)
        channelRelationRepository.getRelationReturns = Observable.just(relation)
        channelRelationRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(suplaRelation: suplaRelation).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        
        XCTAssertTuples(channelRelationRepository.getRelationParameters, [(profile, 123, 234, .mainThermometer)])
        XCTAssertNil(relation.profile) // Veryfies that create was not called
        XCTAssertEqual(relation.parent_id, 234)
        XCTAssertEqual(relation.delete_flag, false)
    }
    
    func test_shouldCreateNewRelation() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        let relation = SAChannelRelation(testContext: nil)
        relation.delete_flag = true
        let suplaRelation = TSC_SuplaChannelRelation(EOL: 0, Id: 123, ParentId: 234, Type: 4)
        
        profileRepository.activeProfileObservable = Observable.just(profile)
        channelRelationRepository.getRelationReturns = Observable.empty()
        channelRelationRepository.saveObservable = Observable.just(())
        channelRelationRepository.createObservable = Observable.just(relation)
        
        // when
        useCase.invoke(suplaRelation: suplaRelation).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        
        XCTAssertEqual(channelRelationRepository.createCounter, 1)
        XCTAssertTuples(channelRelationRepository.getRelationParameters, [(profile, 123, 234, .mainThermometer)])
        XCTAssertEqual(relation.profile, profile)
        XCTAssertEqual(relation.parent_id, 234)
        XCTAssertEqual(relation.channel_id, 123)
        XCTAssertEqual(relation.relationType, .mainThermometer)
        XCTAssertEqual(relation.delete_flag, false)
    }
}
