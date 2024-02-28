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

final class DeleteRemovableChannelRelationUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: DeleteRemovableChannelRelationsUseCase! = {
        DeleteRemovableChannelRelationsUseCase()
    }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = { ProfileRepositoryMock() }()
    private lazy var channelRelationRepository: ChannelRelationRepositoryMock! = {
        ChannelRelationRepositoryMock()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelRelationRepository).self, channelRelationRepository!)
    }
    
    override func tearDown() {
        profileRepository = nil
        channelRelationRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldDeleteAllForProfile() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        channelRelationRepository.deleteRemovableRelationsReturns = Observable.just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEventsCount(2)
        assertEvents([.next(()), .completed])
        
        XCTAssertEqual(channelRelationRepository.deleteRemovableRelationsParameters, [profile])
    }
}
