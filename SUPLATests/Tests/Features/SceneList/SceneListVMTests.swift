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

final class SceneListVMTests: ViewModelTest<SceneListViewState, SceneListViewEvent> {
    
    private lazy var viewModel: SceneListVM! = { SceneListVM() }()
    
    private lazy var createProfileScenesListUseCase: CreateProfileScenesListUseCaseMock! = {
        CreateProfileScenesListUseCaseMock()
    }()
    private lazy var swapScenePositionsUseCase: SwapScenePositionsUseCaseMock! = {
        SwapScenePositionsUseCaseMock()
    }()
    private lazy var toggleLocationUseCase: ToggleLocationUseCaseMock! = {
        ToggleLocationUseCaseMock()
    }()
    private lazy var updateEventsManager: UpdateEventsManagerMock! = {
        UpdateEventsManagerMock()
    }()
    private lazy var executeSimpleActionUseCase: ExecuteSimpleActionUseCaseMock! = {
        ExecuteSimpleActionUseCaseMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: CreateProfileScenesListUseCase.self, createProfileScenesListUseCase!)
        DiContainer.shared.register(type: SwapScenePositionsUseCase.self, swapScenePositionsUseCase!)
        DiContainer.shared.register(type: ToggleLocationUseCase.self, toggleLocationUseCase!)
        DiContainer.shared.register(type: UpdateEventsManager.self, updateEventsManager!)
        DiContainer.shared.register(type: ExecuteSimpleActionUseCase.self, executeSimpleActionUseCase!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        createProfileScenesListUseCase = nil
        swapScenePositionsUseCase = nil
        toggleLocationUseCase = nil
        updateEventsManager = nil
        executeSimpleActionUseCase = nil
        
        super.tearDown()
    }
    
    func test_shouldReloadTable_onSceneUpdate() {
        // given
        updateEventsManager.observeSceneUpdatesObservable = Observable.just(())
        
        // when
        observe(viewModel)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(createProfileScenesListUseCase.invokeCounter, 1)
    }
    
    func test_shouldUpdateListItems_onTableReload() {
        // given
        let list: [List] = [.list(items: [])]
        createProfileScenesListUseCase.observable = Observable.just(list)
        
        let listObserver = scheduler.createObserver([List].self)
        
        // when
        observe(viewModel)
        viewModel.listItems.subscribe(listObserver).disposed(by: disposeBag)
        viewModel.reloadTable()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(createProfileScenesListUseCase.invokeCounter, 1)
        XCTAssertEqual(listObserver.events.count, 2)
    }
    
    func test_shouldSwipeItemsAndReloadTable() {
        // given
        swapScenePositionsUseCase.observable = Observable.just(())
        let firstItemId: Int32 = 2
        let secondItemId: Int32 = 4
        let locationCaption = "Caption"
        
        // when
        observe(viewModel)
        viewModel.swapItems(firstItem: firstItemId, secondItem: secondItemId, locationCaption: locationCaption)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(swapScenePositionsUseCase.firstRemoteIdArray[0], firstItemId)
        XCTAssertEqual(swapScenePositionsUseCase.secondRemoteIdArray[0], secondItemId)
        XCTAssertEqual(swapScenePositionsUseCase.locationCaptionArray[0], locationCaption)
        
        XCTAssertEqual(createProfileScenesListUseCase.invokeCounter, 1)
    }
    
    func test_shouldReloadTable_whenLocationToggled() {
        // given
        let remoteId: Int32 = 123
        toggleLocationUseCase.observable = Observable.just(())
        
        // when
        viewModel.toggleLocation(remoteId: remoteId)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 0)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(toggleLocationUseCase.remoteIdArray[0], remoteId)
        XCTAssertEqual(toggleLocationUseCase.collapsedFlagArray[0], .scene)
        
        XCTAssertEqual(createProfileScenesListUseCase.invokeCounter, 1)
    }
    
    func test_leftButtonClicked() {
        // given
        let buttonType: CellButtonType = .leftButton
        let sceneId: Int32 = 231
        
        // when
        viewModel.onButtonClicked(buttonType: buttonType, sceneId: sceneId)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 0)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.interrupt, SUPLA.SubjectType.scene, sceneId)
        ])
    }
    
    func test_rightButtonClicked() {
        // given
        let buttonType: CellButtonType = .rightButton
        let sceneId: Int32 = 231
        
        // when
        viewModel.onButtonClicked(buttonType: buttonType, sceneId: sceneId)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 0)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (Action.execute, SUPLA.SubjectType.scene, sceneId)
        ])
    }
}
