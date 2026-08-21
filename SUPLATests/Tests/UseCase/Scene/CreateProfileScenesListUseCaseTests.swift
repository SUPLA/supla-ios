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

final class CreateProfileScenesListTests: UseCaseTest<[MainListItem]> {
    private lazy var useCase: CreateProfileScenesList.UseCase! = CreateProfileScenesList.Implementation()

    private lazy var sceneRepository: SceneRepositoryMock! = SceneRepositoryMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var sceneToMainListItemUseCase: SceneToMainListItem.Mock! = SceneToMainListItem.Mock()

    override func setUp() {
        DiContainer.shared.register(type: (any SceneRepository).self, sceneRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: SceneToMainListItem.UseCase.self, sceneToMainListItemUseCase!)
    }

    override func tearDown() {
        useCase = nil
        sceneRepository = nil
        profileRepository = nil
        sceneToMainListItemUseCase = nil

        super.tearDown()
    }

    func test_shouldProvideItems_whenLocationIsExpanded() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(profile: profile, caption: "Location 1", remoteId: 1)
        let scene1 = scene(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Location 2", remoteId: 2)
        let scene2 = scene(remoteId: 2, profile: profile, location: location2)

        let scene1Item = sceneItem(remoteId: 1, title: "Scene 1")
        let scene2Item = sceneItem(remoteId: 2, title: "Scene 2")

        sceneRepository.allVisibleScenesObservable = Observable.just([scene1, scene2])
        sceneToMainListItemUseCase.invokeWithLocationMock.returns = .many([scene1Item, scene2Item])

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                scene1Item,
                locationItem(location2),
                scene2Item
            ]),
            .completed
        ])
        assertMappedItems([
            (scene1, location1),
            (scene2, location2)
        ])
    }

    func test_shouldNotProvideItems_whenLocationIsCollapsed() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(
            profile: profile,
            caption: "Location 1",
            remoteId: 1,
            collapsed: CollapsedFlag.scene.rawValue
        )
        let scene1 = scene(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Location 2", remoteId: 2)
        let scene2 = scene(remoteId: 2, profile: profile, location: location2)
        let scene2Item = sceneItem(remoteId: 2, title: "Scene 2")

        sceneRepository.allVisibleScenesObservable = Observable.just([scene1, scene2])
        sceneToMainListItemUseCase.invokeWithLocationMock.returns = .single(scene2Item)

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                locationItem(location2),
                scene2Item
            ]),
            .completed
        ])
        sceneToMainListItemUseCase.invokeWithLocationMock.verifyCalls(1)
        assertMappedItems([
            (scene2, location2)
        ])
    }

    func test_shouldMergeLocationWithTheSameNameIntoOne() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(profile: profile, caption: "Location", remoteId: 1)
        let scene1 = scene(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Location", remoteId: 2)
        let scene2 = scene(remoteId: 2, profile: profile, location: location2)

        let scene1Item = sceneItem(remoteId: 1, title: "Scene 1")
        let scene2Item = sceneItem(remoteId: 2, title: "Scene 2")

        sceneRepository.allVisibleScenesObservable = Observable.just([scene1, scene2])
        sceneToMainListItemUseCase.invokeWithLocationMock.returns = .many([scene1Item, scene2Item])

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                scene1Item,
                scene2Item
            ]),
            .completed
        ])
        assertMappedItems([
            (scene1, location1),
            (scene2, location1)
        ])
    }

    private func assertMappedItems(_ expected: [(SAScene, _SALocation)]) {
        let parameters = sceneToMainListItemUseCase.invokeWithLocationMock.parameters
        XCTAssertEqual(parameters.count, expected.count)

        for index in expected.indices {
            XCTAssertEqual(parameters[index].0, expected[index].0)
            XCTAssertEqual(parameters[index].1, expected[index].1)
        }
    }

    private func locationItem(_ location: _SALocation) -> MainListItem {
        .location(
            LocationListItem(
                remoteId: location.location_id?.int32Value ?? 0,
                profileId: location.profile.id,
                userCaption: location.caption ?? "",
                collapsed: location.isCollapsed(flag: .scene)
            )
        )
    }

    private func sceneItem(remoteId: Int32, profileId: Int32 = 1, title: String = "Title") -> MainListItem {
        .scene(
            SceneListItem(
                remoteId: remoteId,
                profileId: profileId,
                userCaption: title,
                locationCaption: "Location",
                locationId: 1,
                status: .scene,
                icon: .suplaIcon(name: ""),
                estimatedTimerEndDate: nil,
                leftButtonTitle: Strings.Scenes.ActionButtons.abort,
                rightButtonTitle: Strings.Scenes.ActionButtons.execute
            )
        )
    }

    private func profile(profileId: Int32 = 1) -> AuthProfileItem {
        let profile = AuthProfileItem(testContext: nil)
        profile.id = profileId
        return profile
    }

    private func location(
        profile: AuthProfileItem,
        caption: String,
        remoteId: Int32,
        collapsed: Int16 = 0
    ) -> _SALocation {
        let location = _SALocation(testContext: nil)
        location.profile = profile
        location.caption = caption
        location.location_id = NSNumber(value: remoteId)
        location.collapsed = collapsed
        return location
    }

    private func scene(remoteId: Int32, profile: AuthProfileItem, location: _SALocation) -> SAScene {
        let scene = SAScene(testContext: nil)
        scene.profile = profile
        scene.location = location
        scene.sceneId = remoteId
        return scene
    }
}
