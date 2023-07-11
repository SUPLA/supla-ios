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

final class GroupListVMTests: ViewModelTest<GroupListViewState, GroupListViewEvent> {
    
    private lazy var viewModel: GroupListViewModel! = { GroupListViewModel() }()
    
    private lazy var createProfileGroupsListUseCase: CreateProfileGroupsListUseCaseMock! = {
        CreateProfileGroupsListUseCaseMock()
    }()
    private lazy var swapGroupPositionsUseCase: SwapGroupPositionsUseCaseMock! = {
        SwapGroupPositionsUseCaseMock()
    }()
    private lazy var toggleLocationUseCase: ToggleLocationUseCaseMock! = {
        ToggleLocationUseCaseMock()
    }()
    private lazy var provideDetailTypeUseCase: ProvideDetailTypeUseCaseMock! = {
        ProvideDetailTypeUseCaseMock()
    }()
    private lazy var listsEventsManager: ListsEventsManagerMock! = {
        ListsEventsManagerMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: CreateProfileGroupsListUseCase.self, component: createProfileGroupsListUseCase!)
        DiContainer.shared.register(type: SwapGroupPositionsUseCase.self, component: swapGroupPositionsUseCase!)
        DiContainer.shared.register(type: ProvideDetailTypeUseCase.self, component: provideDetailTypeUseCase!)
        DiContainer.shared.register(type: ToggleLocationUseCase.self, component: toggleLocationUseCase!)
        DiContainer.shared.register(type: ListsEventsManager.self, component: listsEventsManager!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        createProfileGroupsListUseCase = nil
        swapGroupPositionsUseCase = nil
        provideDetailTypeUseCase = nil
        toggleLocationUseCase = nil
        listsEventsManager = nil
        
        super.tearDown()
    }
    
    func test_shouldReloadTable_onGroupUpdate() {
        // given
        listsEventsManager.observeGroupUpdatesObservable = Observable.just(())
        
        // when
        observe(viewModel)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(createProfileGroupsListUseCase.invokeCounter, 1)
    }
    
    func test_shouldUpdateListItems_onTableReload() {
        // given
        let list: [List] = [.list(items: [])]
        createProfileGroupsListUseCase.observable = Observable.just(list)
        
        let listObserver = scheduler.createObserver([List].self)
        
        // when
        observe(viewModel)
        viewModel.listItems.subscribe(listObserver).disposed(by: disposeBag)
        viewModel.reloadTable()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(createProfileGroupsListUseCase.invokeCounter, 1)
        XCTAssertEqual(listObserver.events.count, 2)
    }
    
    func test_shouldSwipeItemsAndReloadTable() {
        // given
        swapGroupPositionsUseCase.observable = Observable.just(())
        let firstItemId: Int32 = 2
        let secondItemId: Int32 = 4
        let locationCaption = "Caption"
        
        // when
        observe(viewModel)
        viewModel.swapItems(firstItem: firstItemId, secondItem: secondItemId, locationCaption: locationCaption)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(swapGroupPositionsUseCase.firstRemoteIdArray[0], firstItemId)
        XCTAssertEqual(swapGroupPositionsUseCase.secondRemoteIdArray[0], secondItemId)
        XCTAssertEqual(swapGroupPositionsUseCase.locationCaptionArray[0], locationCaption)
        
        XCTAssertEqual(createProfileGroupsListUseCase.invokeCounter, 1)
    }
    
    func test_shouldOpenLegacyDetail_whenGroupIsOnline() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.online = 1
        
        provideDetailTypeUseCase.detailType = .legacy(type: .temperature)
        
        // when
        observe(viewModel)
        viewModel.onClicked(onItem: group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        XCTAssertEqual(eventObserver.events, [
            .next(0, .navigateToDetail(legacy: .temperature, channelBase: group))
        ])
    }
    
    func test_shouldNotOpenLegacyDetail_whenGroupIsOffline() {
        // given
        let group = SAChannelGroup(testContext: nil)
        
        provideDetailTypeUseCase.detailType = .legacy(type: .temperature)
        
        // when
        observe(viewModel)
        viewModel.onClicked(onItem: group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
    }
    
    func test_shouldNotOpenLegacyDetail_whenNotAssinged() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.online = 1
        
        // when
        observe(viewModel)
        viewModel.onClicked(onItem: group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(provideDetailTypeUseCase.channelBaseArray.count, 1)
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
        XCTAssertEqual(toggleLocationUseCase.collapsedFlagArray[0], .group)
        
        XCTAssertEqual(createProfileGroupsListUseCase.invokeCounter, 1)
    }
}
