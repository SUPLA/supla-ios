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

final class CreateProfileGroupsListTests: UseCaseTest<[MainListItem]> {
    private lazy var useCase: CreateProfileGroupsList.UseCase! = CreateProfileGroupsList.Implementation()

    private lazy var groupRepository: GroupRepositoryMock! = GroupRepositoryMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var groupToMainListItemUseCase: GroupToMainListItem.Mock! = GroupToMainListItem.Mock()

    override func setUp() {
        DiContainer.shared.register(type: (any GroupRepository).self, groupRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: GroupToMainListItem.UseCase.self, groupToMainListItemUseCase!)
    }

    override func tearDown() {
        useCase = nil
        groupRepository = nil
        profileRepository = nil
        groupToMainListItemUseCase = nil

        super.tearDown()
    }

    func test_shouldProvideItems_whenLocationIsExpanded() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(profile: profile, caption: "Location 1", remoteId: 1)
        let group1 = group(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Location 2", remoteId: 2)
        let group2 = group(remoteId: 2, profile: profile, location: location2)

        let group1Item = groupItem(remoteId: 1, title: "Group 1")
        let group2Item = groupItem(remoteId: 2, title: "Group 2")

        groupRepository.allVisibleGroupsObservable = Observable.just([group1, group2])
        groupToMainListItemUseCase.invokeWithLocationMock.returns = .many([group1Item, group2Item])

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                group1Item,
                locationItem(location2),
                group2Item
            ]),
            .completed
        ])
        XCTAssertEqual(groupRepository.allVisibleGroupsProfilesArray, [profile])
        assertMappedItems([
            (group1, location1),
            (group2, location2)
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
            collapsed: CollapsedFlag.group.rawValue
        )
        let group1 = group(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Location 2", remoteId: 2)
        let group2 = group(remoteId: 2, profile: profile, location: location2)
        let group2Item = groupItem(remoteId: 2, title: "Group 2")

        groupRepository.allVisibleGroupsObservable = Observable.just([group1, group2])
        groupToMainListItemUseCase.invokeWithLocationMock.returns = .single(group2Item)

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                locationItem(location2),
                group2Item
            ]),
            .completed
        ])
        groupToMainListItemUseCase.invokeWithLocationMock.verifyCalls(1)
        assertMappedItems([
            (group2, location2)
        ])
    }

    func test_shouldProvideAllLocationItems_whenFilterMatchesCollapsedLocation() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(
            profile: profile,
            caption: "Kitchen",
            remoteId: 1,
            collapsed: CollapsedFlag.group.rawValue
        )
        let group1 = group(remoteId: 1, profile: profile, location: location1)
        let group1Item = groupItem(remoteId: 1, title: "Lights")

        groupRepository.allVisibleGroupsObservable = Observable.just([group1])
        groupToMainListItemUseCase.invokeWithLocationMock.returns = .single(group1Item)

        // when
        useCase.invoke(filter: "Kitchen").subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1, inSearch: true),
                group1Item
            ]),
            .completed
        ])
        assertMappedItems([
            (group1, location1)
        ])
    }

    func test_shouldMergeLocationWithTheSameNameIntoOne() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(profile: profile, caption: "Location", remoteId: 1)
        let group1 = group(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Location", remoteId: 2)
        let group2 = group(remoteId: 2, profile: profile, location: location2)

        let group1Item = groupItem(remoteId: 1, title: "Group 1")
        let group2Item = groupItem(remoteId: 2, title: "Group 2")

        groupRepository.allVisibleGroupsObservable = Observable.just([group1, group2])
        groupToMainListItemUseCase.invokeWithLocationMock.returns = .many([group1Item, group2Item])

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                group1Item,
                group2Item
            ]),
            .completed
        ])
        assertMappedItems([
            (group1, location1),
            (group2, location1)
        ])
    }

    private func assertMappedItems(_ expected: [(SAChannelGroup, _SALocation)]) {
        let parameters = groupToMainListItemUseCase.invokeWithLocationMock.parameters
        XCTAssertEqual(parameters.count, expected.count)

        for index in expected.indices {
            XCTAssertEqual(parameters[index].0, expected[index].0)
            XCTAssertEqual(parameters[index].1, expected[index].1)
        }
    }

    private func locationItem(_ location: _SALocation, inSearch: Bool = false) -> MainListItem {
        .location(
            LocationListItem(
                remoteId: location.location_id?.int32Value ?? 0,
                profileId: location.profile.id,
                userCaption: location.caption ?? "",
                collapsed: inSearch ? false : location.isCollapsed(flag: .group)
            )
        )
    }

    private func groupItem(remoteId: Int32, profileId: Int32 = 1, title: String = "Title") -> MainListItem {
        .group(
            DefaultListItem(
                remoteId: remoteId,
                profileId: profileId,
                userCaption: title,
                function: SuplaFunction.companion.from(value: SUPLA_CHANNELFNC_LIGHTSWITCH),
                locationCaption: "Location",
                locationId: 1,
                status: .group(onlinePercentage: 1, activePercentage: 0),
                title: title,
                icon: .suplaIcon(name: ""),
                value: nil
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

    private func group(remoteId: Int32, profile: AuthProfileItem, location: _SALocation) -> SAChannelGroup {
        let group = SAChannelGroup(testContext: nil)
        group.profile = profile
        group.location = location
        group.remote_id = remoteId
        return group
    }
}
