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
import SharedCore
import XCTest

@testable import SUPLA

final class CreateProfileChannelsListUseCaseTests: UseCaseTest<[MainListItem]> {
    private lazy var useCase: CreateProfileChannelsList.UseCase! = CreateProfileChannelsList.Implementation()

    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var snapshotUseCase: ObserveChannelsTreeSnapshotMock! = ObserveChannelsTreeSnapshotMock()
    private lazy var channelToMainListItemUseCase: ChannelToMainListItem.Mock! = ChannelToMainListItem.Mock()

    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: ObserveChannelsTreeSnapshot.UseCase.self, snapshotUseCase!)
        DiContainer.shared.register(type: ChannelToMainListItem.UseCase.self, channelToMainListItemUseCase!)
    }

    override func tearDown() {
        useCase = nil
        settings = nil
        snapshotUseCase = nil
        channelToMainListItemUseCase = nil

        super.tearDown()
    }

    func test_shouldProvideItems_whenLocationIsExpanded() {
        // given
        let profile = profile()
        let location1 = location(profile: profile, caption: "Caption 1", remoteId: 1)
        let channel1 = channel(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Caption 2", remoteId: 2)
        let channel2 = channel(remoteId: 2, profile: profile, location: location2)
        let channel3 = channel(remoteId: 3, profile: profile, location: location2)

        let channel1Item = channelItem(remoteId: 1, title: "Channel 1")
        let channel2Item = channelItem(remoteId: 2, title: "Channel 2")
        let relation = SAChannelRelation.mock(channelId: 3, type: .default)
        let channel1WithChildren = ChannelWithChildren(
            channel: channel1,
            children: [ChannelChild(channel: channel3, relation: relation)]
        )

        settings.hideUnavailableChannelsMock.returns = .single(false)
        setSnapshot(
            channels: [channel1, channel2, channel3],
            trees: [
                1: channel1WithChildren,
                2: ChannelWithChildren(channel: channel2),
                3: ChannelWithChildren(channel: channel3)
            ],
            childIds: [3]
        )
        channelToMainListItemUseCase.invokeMock.returns = .many([channel1Item, channel2Item])

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                channel1Item,
                locationItem(location2),
                channel2Item
            ]),
            .completed
        ])
        assertMappedItems([channel1WithChildren, ChannelWithChildren(channel: channel2)])
    }

    func test_shouldNotProvideItems_whenLocationIsCollapsed() {
        // given
        let profile = profile()
        let location1 = location(
            profile: profile,
            caption: "Location 1",
            remoteId: 1,
            collapsed: CollapsedFlag.channel.rawValue
        )
        let channel1 = channel(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Location 2", remoteId: 2)
        let channel2 = channel(remoteId: 2, profile: profile, location: location2)
        let channel2Item = channelItem(remoteId: 2, title: "Channel 2")

        settings.hideUnavailableChannelsMock.returns = .single(true)
        setSnapshot(
            channels: [channel1, channel2],
            trees: [1: ChannelWithChildren(channel: channel1), 2: ChannelWithChildren(channel: channel2)]
        )
        channelToMainListItemUseCase.invokeMock.returns = .single(channel2Item)

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                locationItem(location2),
                channel2Item
            ]),
            .completed
        ])
        assertMappedItems([
            ChannelWithChildren(channel: channel1),
            ChannelWithChildren(channel: channel2)
        ])
    }

    func test_shouldProvideAllLocationItems_whenFilterMatchesCollapsedLocation() {
        // given
        let profile = profile()
        let location1 = location(
            profile: profile,
            caption: "Kitchen",
            remoteId: 1,
            collapsed: CollapsedFlag.channel.rawValue
        )
        let channel1 = channel(remoteId: 1, profile: profile, location: location1)
        let channel1Item = channelItem(remoteId: 1, title: "Light")

        settings.hideUnavailableChannelsMock.returns = .single(false)
        setSnapshot(channels: [channel1], trees: [1: ChannelWithChildren(channel: channel1)])
        channelToMainListItemUseCase.invokeMock.returns = .single(channel1Item)

        // when
        useCase.invoke(filter: "Kitchen").subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1, inSearch: true),
                channel1Item
            ]),
            .completed
        ])
        assertMappedItems([ChannelWithChildren(channel: channel1)])
    }

    func test_shouldMergeLocationWithTheSameNameIntoOne() {
        // given
        let profile = profile()
        let location1 = location(profile: profile, caption: "Location 1", remoteId: 1)
        let channel1 = channel(remoteId: 1, profile: profile, location: location1, position: 1)
        let channel2 = channel(remoteId: 2, profile: profile, location: location1, position: 3)

        let location2 = location(profile: profile, caption: "Location 1", remoteId: 2)
        let channel3 = channel(remoteId: 3, profile: profile, location: location2, position: 2)

        let channel1Item = channelItem(remoteId: 1, title: "Channel 1", locationId: 1)
        let channel2Item = channelItem(remoteId: 2, title: "Channel 2", locationId: 1)
        let channel3Item = channelItem(remoteId: 3, title: "Channel 3", locationId: 2)

        settings.hideUnavailableChannelsMock.returns = .single(false)
        setSnapshot(
            channels: [channel1, channel2, channel3],
            trees: [
                1: ChannelWithChildren(channel: channel1),
                2: ChannelWithChildren(channel: channel2),
                3: ChannelWithChildren(channel: channel3)
            ]
        )
        channelToMainListItemUseCase.invokeMock.returns = .many([channel1Item, channel3Item, channel2Item])

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                channel1Item,
                channel3Item,
                channel2Item
            ]),
            .completed
        ])
        assertMappedItems([
            ChannelWithChildren(channel: channel1),
            ChannelWithChildren(channel: channel3),
            ChannelWithChildren(channel: channel2)
        ])
    }

    func test_shouldLoadChannelWithChildren() {
        // given
        let profile = profile()
        let location1 = location(profile: profile, caption: "Caption 1", remoteId: 1)
        let channel1 = channel(remoteId: 1, profile: profile, location: location1)

        let location2 = location(profile: profile, caption: "Caption 2", remoteId: 2)
        let channel2 = channel(remoteId: 2, profile: profile, location: location2)
        channel2.flags = Int64(SUPLA_CHANNEL_FLAG_HAS_PARENT)
        let channel3 = channel(remoteId: 3, profile: profile, location: location2)
        channel3.flags = Int64(SUPLA_CHANNEL_FLAG_HAS_PARENT)

        let relation1 = SAChannelRelation.mock(1, channelId: 2, type: .mainThermometer)
        let relation2 = SAChannelRelation.mock(1, channelId: 3, type: .auxThermometerFloor)
        let channel1Item = channelItem(remoteId: 1, title: "Channel 1")
        let channel1WithChildren = ChannelWithChildren(
            channel: channel1,
            children: [
                ChannelChild(channel: channel2, relation: relation1),
                ChannelChild(channel: channel3, relation: relation2)
            ]
        )

        settings.hideUnavailableChannelsMock.returns = .single(false)
        setSnapshot(
            channels: [channel1, channel2, channel3],
            trees: [
                1: channel1WithChildren,
                2: ChannelWithChildren(channel: channel2),
                3: ChannelWithChildren(channel: channel3)
            ],
            childIds: [2, 3]
        )
        channelToMainListItemUseCase.invokeMock.returns = .single(channel1Item)

        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)

        // then
        assertEvents([
            .next([
                locationItem(location1),
                channel1Item
            ]),
            .completed
        ])
        assertMappedItems([channel1WithChildren])
    }

    func test_shouldHideActionTriggerChildOnly_whenAtLeastOneParentSupportsIt() {
        let profile = profile()
        let location = location(profile: profile, caption: "Location", remoteId: 1)
        let supportedParent = channel(
            remoteId: 1,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_POWERSWITCH
        )
        let unsupportedParent = channel(
            remoteId: 2,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_THERMOMETER
        )
        let actionTriggerWithSupportedParent = channel(
            remoteId: 3,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_ACTIONTRIGGER
        )
        let actionTriggerWithUnsupportedParent = channel(
            remoteId: 4,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_ACTIONTRIGGER
        )
        let regularChild = channel(
            remoteId: 5,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_THERMOMETER
        )

        let supportedRelation = SAChannelRelation.mock(channelId: 3, type: .default)
        let unsupportedRelation = SAChannelRelation.mock(channelId: 4, type: .default)
        let regularChildRelation = SAChannelRelation.mock(channelId: 5, type: .default)

        let childIds = ChannelChildVisibilityPolicy.childIds(
            channels: [
                supportedParent,
                unsupportedParent,
                actionTriggerWithSupportedParent,
                actionTriggerWithUnsupportedParent,
                regularChild
            ],
            parentsMap: [
                supportedParent.remote_id: [supportedRelation],
                unsupportedParent.remote_id: [supportedRelation, unsupportedRelation, regularChildRelation],
                99: [unsupportedRelation]
            ]
        )

        XCTAssertEqual(childIds, Set([actionTriggerWithSupportedParent.remote_id, regularChild.remote_id]))
    }

    func test_shouldHideActionTriggerChild_whenItHasAnySupportedParent() {
        let profile = profile()
        let location = location(profile: profile, caption: "Location", remoteId: 1)
        let supportedParent = channel(
            remoteId: 1,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_LIGHTSWITCH
        )
        let unsupportedParent = channel(
            remoteId: 2,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_THERMOMETER
        )
        let child = channel(
            remoteId: 3,
            profile: profile,
            location: location,
            function: SUPLA_CHANNELFNC_ACTIONTRIGGER
        )

        let childIds = ChannelChildVisibilityPolicy.childIds(
            channels: [supportedParent, unsupportedParent, child],
            parentsMap: [
                supportedParent.remote_id: [SAChannelRelation.mock(channelId: child.remote_id, type: .default)],
                unsupportedParent.remote_id: [SAChannelRelation.mock(channelId: child.remote_id, type: .default)]
            ]
        )

        XCTAssertEqual(childIds, Set([child.remote_id]))
    }

    private func setSnapshot(
        channels: [SAChannel],
        trees: [Int32: SUPLA.ChannelWithChildren],
        childIds: Set<Int32> = []
    ) {
        snapshotUseCase.returns = .just(
            ObserveChannelsTreeSnapshot.Snapshot(
                channels: channels,
                channelsWithChildren: trees,
                childIds: childIds
            )
        )
    }

    private func profile(id: Int32 = 1) -> AuthProfileItem {
        let profile = AuthProfileItem(testContext: nil)
        profile.id = id
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

    private func channel(
        remoteId: Int32,
        profile: AuthProfileItem,
        location: _SALocation,
        position: Int32 = 0,
        function: Int32 = SUPLA_CHANNELFNC_LIGHTSWITCH
    ) -> SAChannel {
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.profile = profile
        channel.location = location
        channel.location_id = location.location_id?.int32Value ?? 0
        channel.position = position
        channel.func = function
        return channel
    }

    private func locationItem(_ location: _SALocation, inSearch: Bool = false) -> MainListItem {
        .location(
            LocationListItem(
                remoteId: location.location_id?.int32Value ?? 0,
                profileId: location.profile.id,
                userCaption: location.caption ?? "",
                collapsed: inSearch ? false : location.isCollapsed(flag: .channel)
            )
        )
    }

    private func channelItem(remoteId: Int32, title: String, locationId: Int32 = 1) -> MainListItem {
        .default(
            DefaultListItem(
                remoteId: remoteId,
                profileId: 1,
                userCaption: title,
                function: SuplaFunction.companion.from(value: SUPLA_CHANNELFNC_LIGHTSWITCH),
                locationCaption: "Location",
                locationId: locationId,
                status: .channel(.online),
                title: title,
                icon: .suplaIcon(name: ""),
                value: nil
            )
        )
    }

    private func assertMappedItems(_ expected: [SUPLA.ChannelWithChildren]) {
        let parameters = channelToMainListItemUseCase.invokeMock.parameters
        XCTAssertEqual(parameters.count, expected.count)

        for (parameter, expectedItem) in zip(parameters, expected) {
            XCTAssertEqual(parameter.channel, expectedItem.channel)
            XCTAssertEqual(parameter.children, expectedItem.children)
        }
        channelToMainListItemUseCase.invokeWithLocationMock.verifyCalls(0)
    }
}

private final class ObserveChannelsTreeSnapshotMock: ObserveChannelsTreeSnapshot.UseCase {
    var returns: Observable<ObserveChannelsTreeSnapshot.Snapshot> = .empty()

    func invoke() -> Observable<ObserveChannelsTreeSnapshot.Snapshot> {
        returns
    }
}
