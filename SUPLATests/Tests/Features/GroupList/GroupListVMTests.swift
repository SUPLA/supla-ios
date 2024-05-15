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
import XCTest

@testable import SUPLA

final class GroupListVMTests: ViewModelTest<GroupListViewState, GroupListViewEvent> {
    private lazy var viewModel: GroupListViewModel! = GroupListViewModel()
    
    private lazy var createProfileGroupsListUseCase: CreateProfileGroupsListUseCaseMock! = CreateProfileGroupsListUseCaseMock()

    private lazy var swapGroupPositionsUseCase: SwapGroupPositionsUseCaseMock! = SwapGroupPositionsUseCaseMock()

    private lazy var toggleLocationUseCase: ToggleLocationUseCaseMock! = ToggleLocationUseCaseMock()

    private lazy var provideDetailTypeUseCase: ProvideDetailTypeUseCaseMock! = ProvideDetailTypeUseCaseMock()

    private lazy var updateEventsManager: UpdateEventsManagerMock! = UpdateEventsManagerMock()

    private lazy var loadActiveProfileUrlUseCase: LoadActiveProfileUrlUseCaseMock! = LoadActiveProfileUrlUseCaseMock()
    
    override func setUp() {
        DiContainer.shared.register(type: CreateProfileGroupsListUseCase.self, createProfileGroupsListUseCase!)
        DiContainer.shared.register(type: SwapGroupPositionsUseCase.self, swapGroupPositionsUseCase!)
        DiContainer.shared.register(type: ProvideDetailTypeUseCase.self, provideDetailTypeUseCase!)
        DiContainer.shared.register(type: ToggleLocationUseCase.self, toggleLocationUseCase!)
        DiContainer.shared.register(type: UpdateEventsManager.self, updateEventsManager!)
        DiContainer.shared.register(type: LoadActiveProfileUrlUseCase.self, loadActiveProfileUrlUseCase!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        createProfileGroupsListUseCase = nil
        swapGroupPositionsUseCase = nil
        provideDetailTypeUseCase = nil
        toggleLocationUseCase = nil
        updateEventsManager = nil
        loadActiveProfileUrlUseCase = nil
        
        super.tearDown()
    }
    
    func test_shouldReloadTable_onGroupUpdate() {
        // given
        updateEventsManager.observeGroupUpdatesObservable = Observable.just(())
        
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
        
        provideDetailTypeUseCase.detailType = .legacy(type: .rgbw)
        
        // when
        observe(viewModel)
        viewModel.onClicked(onItem: group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        XCTAssertEqual(eventObserver.events, [
            .next(0, .navigateToDetail(legacy: .rgbw, channelBase: group))
        ])
    }
    
    func test_shouldNotOpenLegacyDetail_whenGroupIsOffline() {
        // given
        let group = SAChannelGroup(testContext: nil)
        
        provideDetailTypeUseCase.detailType = .legacy(type: .rgbw)
        
        // when
        observe(viewModel)
        viewModel.onClicked(onItem: group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
    }
    
    func test_shouldOpenWindowDetail_whenGroupIsOnline() {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
        let group = SAChannelGroup(testContext: nil)
        group.remote_id = remoteId
        group.func = function
        group.online = 1
        
        let pages: [DetailPage] = [.facadeBlind]
        
        provideDetailTypeUseCase.detailType = .windowDetail(pages: pages)
        
        // when
        observe(viewModel)
        viewModel.onClicked(onItem: group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let itemBundle = ItemBundle(remoteId: remoteId, deviceId: 0, subjectType: .group, function: function)
        XCTAssertEqual(eventObserver.events, [
            .next(0, .naviagetToRollerShutterDetail(item: itemBundle, pages: pages))
        ])
    }
    
    func test_shouldOpenWindowDetail_whenGroupIsOffline() {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
        let group = SAChannelGroup(testContext: nil)
        group.remote_id = remoteId
        group.func = function
        group.online = 0
        
        let pages: [DetailPage] = [.facadeBlind]
        
        provideDetailTypeUseCase.detailType = .windowDetail(pages: pages)
        
        // when
        observe(viewModel)
        viewModel.onClicked(onItem: group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let itemBundle = ItemBundle(remoteId: remoteId, deviceId: 0, subjectType: .group, function: function)
        XCTAssertEqual(eventObserver.events, [
            .next(0, .naviagetToRollerShutterDetail(item: itemBundle, pages: pages))
        ])
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
    
    func test_shouldLoadSuplaCloudUrl() {
        // given
        let url: CloudUrl = .suplaCloud
        loadActiveProfileUrlUseCase.returns = .just(url)
        
        // when
        observe(viewModel)
        viewModel.onNoContentButtonClicked()
        
        // then
        assertEvents(expected: [
            .openCloud
        ])
        assertStates(expected: [
            GroupListViewState()
        ])
    }
    
    func test_shouldLoadPrivateCloudUrl() {
        // given
        let url = URL(string: "https://test.url")!
        let cloudUrl: CloudUrl = .privateCloud(url: url)
        loadActiveProfileUrlUseCase.returns = .just(cloudUrl)
        
        // when
        observe(viewModel)
        viewModel.onNoContentButtonClicked()
        
        // then
        assertEvents(expected: [
            .openPrivateCloud(url: url)
        ])
        assertStates(expected: [
            GroupListViewState()
        ])
    }
}
