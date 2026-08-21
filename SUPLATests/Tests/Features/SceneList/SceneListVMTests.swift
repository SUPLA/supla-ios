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

final class SceneListVMTests: SuplaCore.ViewModelTest<SceneListFeature.ViewState> {
    private lazy var viewModel: SceneListFeature.ViewModel! = SceneListFeature.ViewModel()

    private lazy var createProfileScenesListUseCase: CreateProfileScenesList.Mock! = CreateProfileScenesList.Mock()
    private lazy var readSceneByRemoteIdUseCase: ReadSceneByRemoteIdUseCaseMock! = ReadSceneByRemoteIdUseCaseMock()
    private lazy var sceneToMainListItemUseCase: SceneToMainListItem.Mock! = SceneToMainListItem.Mock()
    private lazy var swapScenePositionsUseCase: SwapScenePositionsUseCaseMock! = SwapScenePositionsUseCaseMock()
    private lazy var toggleLocationUseCase: ToggleLocationUseCaseMock! = ToggleLocationUseCaseMock()
    private lazy var updateEventsManager: UpdateEventsManagerMock! = UpdateEventsManagerMock()
    private lazy var executeSimpleActionUseCase: ExecuteSimpleAction.Mock! = ExecuteSimpleAction.Mock()
    private lazy var loadActiveProfileUrlUseCase: LoadActiveProfileUrlUseCaseMock! = LoadActiveProfileUrlUseCaseMock()
    private lazy var router: AppRouterMock! = AppRouterMock()

    override func setUp() {
        updateEventsManager.observeAllChannelsMock.returns = .single(Observable.empty())
        updateEventsManager.observeAllGroupsMock.returns = .single(Observable.empty())
        updateEventsManager.observeAllScenesMock.returns = .single(Observable.empty())

        DiContainer.shared.register(type: CreateProfileScenesList.UseCase.self, createProfileScenesListUseCase!)
        DiContainer.shared.register(type: ReadSceneByRemoteIdUseCase.self, readSceneByRemoteIdUseCase!)
        DiContainer.shared.register(type: SceneToMainListItem.UseCase.self, sceneToMainListItemUseCase!)
        DiContainer.shared.register(type: SwapScenePositionsUseCase.self, swapScenePositionsUseCase!)
        DiContainer.shared.register(type: ToggleLocationUseCase.self, toggleLocationUseCase!)
        DiContainer.shared.register(type: UpdateEventsManager.self, updateEventsManager!)
        DiContainer.shared.register(type: ExecuteSimpleAction.UseCase.self, executeSimpleActionUseCase!)
        DiContainer.shared.register(type: LoadActiveProfileUrlUseCase.self, loadActiveProfileUrlUseCase!)
        DiContainer.shared.register(type: AppRouter.self, router!)
    }

    override func tearDown() {
        viewModel = nil
        createProfileScenesListUseCase = nil
        readSceneByRemoteIdUseCase = nil
        sceneToMainListItemUseCase = nil
        swapScenePositionsUseCase = nil
        toggleLocationUseCase = nil
        updateEventsManager = nil
        executeSimpleActionUseCase = nil
        loadActiveProfileUrlUseCase = nil
        router = nil

        super.tearDown()
    }

    func test_shouldReloadItems_onSceneStructureUpdate() {
        // given
        let items = [sceneItem(remoteId: 1)]
        updateEventsManager.observeSceneUpdatesObservable = Observable.just(())
        createProfileScenesListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        _ = viewModel

        // then
        createProfileScenesListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertFalse(viewModel.state.loading)
        XCTAssertTrue(viewModel.state.listLoaded)
    }

    func test_shouldUpdateListItems_onViewAppear() {
        // given
        let items = [MainListItem.location(locationItem(remoteId: 10)), sceneItem(remoteId: 1)]
        createProfileScenesListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onViewAppear()

        // then
        createProfileScenesListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertFalse(viewModel.state.loading)
        XCTAssertTrue(viewModel.state.listLoaded)
    }

    func test_shouldNotReloadList_whenSearchTextIsShorterThanTwoCharacters() {
        // when
        viewModel.onSearchTextChanged("a")

        // then
        createProfileScenesListUseCase.invokeMock.verifyCalls(0)
        XCTAssertEqual(viewModel.state.searchText, "a")
        XCTAssertFalse(viewModel.state.filterActive)
    }

    func test_shouldReloadListWithFilter_whenSearchTextHasAtLeastTwoCharacters() {
        // given
        let items = [sceneItem(remoteId: 1)]
        createProfileScenesListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onSearchTextChanged("ab")

        // then
        XCTAssertEqual(createProfileScenesListUseCase.invokeMock.parameters, ["ab"])
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertEqual(viewModel.state.searchText, "ab")
        XCTAssertTrue(viewModel.state.filterActive)
    }

    func test_shouldUpdateSingleItem_onSceneUpdate() {
        // given
        let sceneUpdates = PublishSubject<Int32>()
        let initialItem = sceneItem(remoteId: 1, title: "Old")
        let updatedItem = sceneItem(remoteId: 1, title: "New")
        let scene = scene(remoteId: 1)

        updateEventsManager.observeAllScenesMock.returns = .single(sceneUpdates.asObservable())
        createProfileScenesListUseCase.invokeMock.returns = .single(Observable.just([initialItem]))
        readSceneByRemoteIdUseCase.returns = Observable.just(scene)
        sceneToMainListItemUseCase.invokeMock.returns = .single(updatedItem)

        viewModel.onViewAppear()

        // when
        sceneUpdates.onNext(1)

        // then
        XCTAssertEqual(readSceneByRemoteIdUseCase.parameters, [1])
        sceneToMainListItemUseCase.invokeMock.verifyCalls(1)
        createProfileScenesListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, [updatedItem])
    }

    func test_shouldSwipeItemsAndReloadList() {
        // given
        let firstItem = sceneItem(remoteId: 2, locationCaption: "Caption")
        let secondItem = sceneItem(remoteId: 4, locationCaption: "Caption")
        let reloadedItems = [secondItem, firstItem]

        swapScenePositionsUseCase.observable = Observable.just(())
        createProfileScenesListUseCase.invokeMock.returns = .single(Observable.just(reloadedItems))

        // when
        viewModel.onMove(firstItem, secondItem)

        // then
        XCTAssertEqual(swapScenePositionsUseCase.firstRemoteIdArray, [2])
        XCTAssertEqual(swapScenePositionsUseCase.secondRemoteIdArray, [4])
        XCTAssertEqual(swapScenePositionsUseCase.locationCaptionArray, ["Caption"])
        createProfileScenesListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, reloadedItems)
    }

    func test_shouldReloadList_whenLocationToggled() {
        // given
        let location = locationItem(remoteId: 123)
        let items = [MainListItem.location(location)]

        toggleLocationUseCase.invokeMock.returns = .single(Observable.just(()))
        createProfileScenesListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onLocationClick(location)

        // then
        XCTAssertTuples(toggleLocationUseCase.invokeMock.parameters, [(123, .scene)])
        createProfileScenesListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
    }

    func test_leftButtonClicked() {
        // given
        executeSimpleActionUseCase.returns = Observable.just(())

        // when
        viewModel.onLeftButtonClick(sceneItem(remoteId: 231))

        // then
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (ActionId.interrupt, SUPLA.SubjectType.scene, 231)
        ])
    }

    func test_rightButtonClicked() {
        // given
        executeSimpleActionUseCase.returns = Observable.just(())

        // when
        viewModel.onRightButtonClick(sceneItem(remoteId: 231))

        // then
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (ActionId.execute, SUPLA.SubjectType.scene, 231)
        ])
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

    private func sceneItem(
        remoteId: Int32,
        profileId: Int32 = 1,
        locationCaption: String = "Location",
        title: String = "Title"
    ) -> MainListItem {
        .scene(
            SceneListItem(
                remoteId: remoteId,
                profileId: profileId,
                userCaption: title,
                locationCaption: locationCaption,
                locationId: 1,
                status: .scene,
                icon: .suplaIcon(name: ""),
                estimatedTimerEndDate: nil,
                leftButtonTitle: Strings.Scenes.ActionButtons.abort,
                rightButtonTitle: Strings.Scenes.ActionButtons.execute
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

    private func scene(remoteId: Int32, profileId: Int32 = 1) -> SAScene {
        let profile = AuthProfileItem(testContext: nil)
        profile.id = profileId

        let scene = SAScene(testContext: nil)
        scene.profile = profile
        scene.sceneId = remoteId

        return scene
    }
}
