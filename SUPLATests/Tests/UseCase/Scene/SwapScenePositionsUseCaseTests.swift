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

final class SwapScenePositionsUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: SwapScenePositionsUseCase! = { SwapScenePositionsUseCaseImpl() }()
    
    private lazy var sceneRepository: SceneRepositoryMock! = {
        SceneRepositoryMock()
    }()
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any SceneRepository).self, sceneRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        sceneRepository = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldSwapPositions() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let scene1 = SAScene(testContext: nil)
        scene1.sceneId = 1
        
        let scene2 = SAScene(testContext: nil)
        scene2.sceneId = 2
        
        sceneRepository.allVisibleScenesInLocationObservable = Observable.just([ scene1, scene2 ])
        sceneRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: scene1.sceneId, secondRemoteId: scene2.sceneId, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(scene1.sortOrder, 1)
        XCTAssertEqual(scene2.sortOrder, 0)
        
        XCTAssertEqual(sceneRepository.allVisibleScenesInLocationProfiles, [profile])
        XCTAssertEqual(sceneRepository.allVisibleScenesInLocationCaptions, [locationCaption])
        XCTAssertEqual(sceneRepository.saveCounter, 1)
    }
    
    func test_shouldNotSwap_whenGroupWasNotFound() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let scene1 = SAScene(testContext: nil)
        scene1.sceneId = 1
        
        let scene2 = SAScene(testContext: nil)
        scene2.sceneId = 2
        
        sceneRepository.allVisibleScenesInLocationObservable = Observable.just([ scene1, scene2 ])
        sceneRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: scene1.sceneId, secondRemoteId: 3, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(scene1.sortOrder, 0)
        XCTAssertEqual(scene2.sortOrder, 0)
        
        XCTAssertEqual(sceneRepository.allVisibleScenesInLocationProfiles, [profile])
        XCTAssertEqual(sceneRepository.allVisibleScenesInLocationCaptions, [locationCaption])
        XCTAssertEqual(sceneRepository.saveCounter, 0)
    }
    
    func test_shouldNotSwap_whenThereIsOnlyOneGroup() {
        // given
        let locationCaption = "Caption"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = Observable.just(profile)
        
        let scene1 = SAScene(testContext: nil)
        scene1.sceneId = 1
        
        sceneRepository.allVisibleScenesInLocationObservable = Observable.just([ scene1 ])
        sceneRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(firstRemoteId: scene1.sceneId, secondRemoteId: 3, locationCaption: locationCaption).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        
        XCTAssertEqual(sceneRepository.allVisibleScenesInLocationProfiles, [profile])
        XCTAssertEqual(sceneRepository.allVisibleScenesInLocationCaptions, [locationCaption])
        XCTAssertEqual(sceneRepository.saveCounter, 0)
    }
}
