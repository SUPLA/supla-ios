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
import SharedCore
import XCTest

@testable import SUPLA

final class GroupListVMTests: SuplaCore.ViewModelTest<GroupListFeature.ViewState> {
    private lazy var viewModel: GroupListFeature.ViewModel! = GroupListFeature.ViewModel()

    private lazy var createProfileGroupsListUseCase: CreateProfileGroupsList.Mock! = CreateProfileGroupsList.Mock()
    private lazy var readGroupByRemoteIdUseCase: ReadGroupByRemoteIdUseCaseMock! = ReadGroupByRemoteIdUseCaseMock()
    private lazy var provideDetailTypeUseCase: ProvideGroupDetailTypeUseCaseMock! = ProvideGroupDetailTypeUseCaseMock()
    private lazy var channelBaseActionUseCase: ChannelBaseActionUseCaseMock! = ChannelBaseActionUseCaseMock()
    private lazy var swapGroupPositionsUseCase: SwapGroupPositionsUseCaseMock! = SwapGroupPositionsUseCaseMock()
    private lazy var toggleLocationUseCase: ToggleLocationUseCaseMock! = ToggleLocationUseCaseMock()
    private lazy var updateEventsManager: UpdateEventsManagerMock! = UpdateEventsManagerMock()
    private lazy var groupToMainListItemUseCase: GroupToMainListItem.Mock! = GroupToMainListItem.Mock()
    private lazy var loadActiveProfileUrlUseCase: LoadActiveProfileUrlUseCaseMock! = LoadActiveProfileUrlUseCaseMock()
    private lazy var router: AppRouterMock! = AppRouterMock()

    override func setUp() {
        updateEventsManager.observeAllChannelsMock.returns = .single(Observable.empty())
        updateEventsManager.observeAllGroupsMock.returns = .single(Observable.empty())
        updateEventsManager.observeAllScenesMock.returns = .single(Observable.empty())

        DiContainer.shared.register(type: CreateProfileGroupsList.UseCase.self, createProfileGroupsListUseCase!)
        DiContainer.shared.register(type: ReadGroupByRemoteIdUseCase.self, readGroupByRemoteIdUseCase!)
        DiContainer.shared.register(type: ProvideGroupDetailTypeUseCase.self, provideDetailTypeUseCase!)
        DiContainer.shared.register(type: ChannelBaseActionUseCase.self, channelBaseActionUseCase!)
        DiContainer.shared.register(type: SwapGroupPositionsUseCase.self, swapGroupPositionsUseCase!)
        DiContainer.shared.register(type: ToggleLocationUseCase.self, toggleLocationUseCase!)
        DiContainer.shared.register(type: UpdateEventsManager.self, updateEventsManager!)
        DiContainer.shared.register(type: GroupToMainListItem.UseCase.self, groupToMainListItemUseCase!)
        DiContainer.shared.register(type: LoadActiveProfileUrlUseCase.self, loadActiveProfileUrlUseCase!)
        DiContainer.shared.register(type: AppRouter.self, router!)
    }

    override func tearDown() {
        viewModel = nil
        createProfileGroupsListUseCase = nil
        readGroupByRemoteIdUseCase = nil
        provideDetailTypeUseCase = nil
        channelBaseActionUseCase = nil
        swapGroupPositionsUseCase = nil
        toggleLocationUseCase = nil
        updateEventsManager = nil
        groupToMainListItemUseCase = nil
        loadActiveProfileUrlUseCase = nil
        router = nil

        super.tearDown()
    }

    func test_shouldReloadItems_onGroupStructureUpdate() {
        // given
        let items = [groupItem(remoteId: 1)]
        updateEventsManager.observeGroupUpdatesObservable = Observable.just(())
        createProfileGroupsListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        _ = viewModel

        // then
        createProfileGroupsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertFalse(viewModel.state.loading)
        XCTAssertTrue(viewModel.state.listLoaded)
    }

    func test_shouldUpdateListItems_onViewAppear() {
        // given
        let items = [MainListItem.location(locationItem(remoteId: 10)), groupItem(remoteId: 1)]
        createProfileGroupsListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onViewAppear()

        // then
        createProfileGroupsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertFalse(viewModel.state.loading)
        XCTAssertTrue(viewModel.state.listLoaded)
    }

    func test_shouldNotReloadList_whenSearchTextIsShorterThanTwoCharacters() {
        // when
        viewModel.onSearchTextChanged("a")

        // then
        createProfileGroupsListUseCase.invokeMock.verifyCalls(0)
        XCTAssertEqual(viewModel.state.searchText, "a")
        XCTAssertFalse(viewModel.state.filterActive)
    }

    func test_shouldReloadListWithFilter_whenSearchTextHasAtLeastTwoCharacters() {
        // given
        let items = [groupItem(remoteId: 1)]
        createProfileGroupsListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onSearchTextChanged("ab")

        // then
        XCTAssertEqual(createProfileGroupsListUseCase.invokeMock.parameters, ["ab"])
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertEqual(viewModel.state.searchText, "ab")
        XCTAssertTrue(viewModel.state.filterActive)
    }

    func test_shouldUpdateSingleItem_onGroupUpdate() {
        // given
        let groupUpdates = PublishSubject<Int32>()
        let initialItem = groupItem(remoteId: 1, title: "Old")
        let updatedItem = groupItem(remoteId: 1, title: "New")
        let group = group(remoteId: 1)

        updateEventsManager.observeAllGroupsMock.returns = .single(groupUpdates.asObservable())
        createProfileGroupsListUseCase.invokeMock.returns = .single(Observable.just([initialItem]))
        readGroupByRemoteIdUseCase.returns = Observable.just(group)
        groupToMainListItemUseCase.invokeMock.returns = .single(updatedItem)

        viewModel.onViewAppear()

        // when
        groupUpdates.onNext(1)

        // then
        XCTAssertEqual(readGroupByRemoteIdUseCase.remoteIdArray, [1])
        groupToMainListItemUseCase.invokeMock.verifyCalls(1)
        createProfileGroupsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, [updatedItem])
    }

    func test_shouldSwipeItemsAndReloadList() {
        // given
        let firstItem = groupItem(remoteId: 2, locationCaption: "Caption")
        let secondItem = groupItem(remoteId: 4, locationCaption: "Caption")
        let reloadedItems = [secondItem, firstItem]

        swapGroupPositionsUseCase.observable = Observable.just(())
        createProfileGroupsListUseCase.invokeMock.returns = .single(Observable.just(reloadedItems))

        // when
        viewModel.onMove(firstItem, secondItem)

        // then
        XCTAssertEqual(swapGroupPositionsUseCase.firstRemoteIdArray, [2])
        XCTAssertEqual(swapGroupPositionsUseCase.secondRemoteIdArray, [4])
        XCTAssertEqual(swapGroupPositionsUseCase.locationCaptionArray, ["Caption"])
        createProfileGroupsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, reloadedItems)
    }

    func test_shouldReloadList_whenLocationToggled() {
        // given
        let location = locationItem(remoteId: 123)
        let items = [MainListItem.location(location)]

        toggleLocationUseCase.invokeMock.returns = .single(Observable.just(()))
        createProfileGroupsListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onLocationClick(location)

        // then
        XCTAssertTuples(toggleLocationUseCase.invokeMock.parameters, [(123, .group)])
        createProfileGroupsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
    }

    func test_shouldOpenLegacyDetail_whenGroupIsOnline() {
        // given
        let group = group(remoteId: 321, function: SUPLA_CHANNELFNC_THERMOMETER, online: true)
        readGroupByRemoteIdUseCase.returns = Observable.just(group)
        provideDetailTypeUseCase.detailType = .legacy(type: .thermostat_hp)

        // when
        viewModel.onItemClick(groupItem(remoteId: 321))

        // then
        XCTAssertEqual(readGroupByRemoteIdUseCase.remoteIdArray, [321])
        XCTAssertEqual(provideDetailTypeUseCase.channelBaseArray.count, 1)
        XCTAssertEqual(router.navigateMock.parameters, [
            .legacyDetail(type: .thermostat_hp, channelRemoteId: 321)
        ])
    }

    func test_shouldNotOpenDetail_whenGroupIsOfflineAndUnavailableOffline() {
        // given
        let group = group(remoteId: 321, function: SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL, online: false)
        readGroupByRemoteIdUseCase.returns = Observable.just(group)
        provideDetailTypeUseCase.detailType = .legacy(type: .thermostat_hp)

        // when
        viewModel.onItemClick(groupItem(remoteId: 321))

        // then
        XCTAssertEqual(provideDetailTypeUseCase.channelBaseArray.count, 0)
        XCTAssertEqual(router.navigateMock.parameters, [])
    }

    func test_shouldOpenStandardDetail() {
        // given
        let remoteId: Int32 = 322
        let profileId: Int32 = 1
        let function: Int32 = SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
        let group = group(remoteId: remoteId, profileId: profileId, function: function, online: true)

        readGroupByRemoteIdUseCase.returns = Observable.just(group)
        provideDetailTypeUseCase.detailType = .standardDetail(pages: [.facadeBlind])

        // when
        viewModel.onItemClick(groupItem(remoteId: remoteId))

        // then
        XCTAssertEqual(router.navigateMock.parameters, [
            .standardDetail(
                item: ItemBundle(remoteId: remoteId, profileId: profileId, deviceId: 0, subjectType: .group, function: function),
                pages: [.facadeBlind]
            )
        ])
    }

    func test_leftButtonClicked() {
        // given
        let item = groupItem(remoteId: 321)
        let group = group(remoteId: 321)

        readGroupByRemoteIdUseCase.returns = Observable.just(group)
        channelBaseActionUseCase.returns = Observable.just(.success)

        // when
        viewModel.onLeftButtonClick(item)

        // then
        XCTAssertEqual(readGroupByRemoteIdUseCase.remoteIdArray, [321])
        XCTAssertEqual(channelBaseActionUseCase.parameters.count, 1)
        XCTAssertEqual(channelBaseActionUseCase.parameters.first?.1, .leftButton)
    }

    func test_shouldLoadSuplaCloudUrl() {
        // given
        let url: CloudUrl = .suplaCloud
        loadActiveProfileUrlUseCase.returns = .just(url)

        // when
        viewModel.onNoContentButtonClick()

        // then
        XCTAssertEqual(router.openUrlMock.parameters, [url.url])
    }

    private func groupItem(
        remoteId: Int32,
        profileId: Int32 = 1,
        function: Int32 = SUPLA_CHANNELFNC_LIGHTSWITCH,
        locationCaption: String = "Location",
        title: String = "Title"
    ) -> MainListItem {
        .group(
            DefaultListItem(
                remoteId: remoteId,
                profileId: profileId,
                userCaption: title,
                function: SuplaFunction.companion.from(value: function),
                locationCaption: locationCaption,
                locationId: 1,
                status: .group(onlinePercentage: 1, activePercentage: 0),
                title: title,
                icon: .suplaIcon(name: ""),
                value: nil
            )
        )
    }

    private func locationItem(remoteId: Int32, profileId: Int32 = 1) -> LocationListItem {
        LocationListItem(
            remoteId: remoteId,
            profileId: profileId,
            userCaption: "Location",
            collapsed: false
        )
    }

    private func group(
        remoteId: Int32,
        profileId: Int32 = 1,
        function: Int32 = SUPLA_CHANNELFNC_LIGHTSWITCH,
        online: Bool = true
    ) -> SAChannelGroup {
        let profile = AuthProfileItem(testContext: nil)
        profile.id = profileId

        let group = SAChannelGroup(testContext: nil)
        group.profile = profile
        group.remote_id = remoteId
        group.func = function
        group.online = online ? 100 : 0

        return group
    }
}
