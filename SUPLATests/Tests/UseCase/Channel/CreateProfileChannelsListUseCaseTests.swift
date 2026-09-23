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
    private lazy var channelRepository: ChannelRepositoryMock! = ChannelRepositoryMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var channelRelationRepository: ChannelRelationRepositoryMock! = ChannelRelationRepositoryMock()
    private lazy var createChannelWithChildrenUseCase: CreateChannelWithChildrenUseCaseMock! = CreateChannelWithChildrenUseCaseMock()
    private lazy var channelToMainListItemUseCase: ChannelToMainListItem.Mock! = ChannelToMainListItem.Mock()

    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelRelationRepository).self, channelRelationRepository!)
        DiContainer.shared.register(type: CreateChannelWithChildrenUseCase.self, createChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: ChannelToMainListItem.UseCase.self, channelToMainListItemUseCase!)
    }

    override func tearDown() {
        useCase = nil
        settings = nil
        channelRepository = nil
        profileRepository = nil
        channelRelationRepository = nil
        createChannelWithChildrenUseCase = nil
        channelToMainListItemUseCase = nil

        super.tearDown()
    }

    func test_shouldProvideItems_whenLocationIsExpanded() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

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
        channelRepository.allVisibleChannelsMock.returns = .single(.just([channel1, channel2, channel3]))
        channelRelationRepository.getParentsMapReturns = Observable.just([1: [relation]])
        createChannelWithChildrenUseCase.invokeMock.returns = .single(channel1WithChildren)
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
        XCTAssertTuples(channelRepository.allVisibleChannelsMock.parameters, [(profile, true)])
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.count, 1)
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.first?.0, channel1)
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.first?.1, [channel1, channel2, channel3])
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.first?.2, [relation])
        assertMappedItems([channel1WithChildren, ChannelWithChildren(channel: channel2)])
    }

    func test_shouldNotProvideItems_whenLocationIsCollapsed() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

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
        channelRepository.allVisibleChannelsMock.returns = .single(.just([channel1, channel2]))
        channelRelationRepository.getParentsMapReturns = Observable.just([:])
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
        XCTAssertTuples(channelRepository.allVisibleChannelsMock.parameters, [(profile, false)])
        createChannelWithChildrenUseCase.invokeMock.verifyCalls(0)
        assertMappedItems([ChannelWithChildren(channel: channel1), ChannelWithChildren(channel: channel2)])
    }

    func test_shouldProvideAllLocationItems_whenFilterMatchesCollapsedLocation() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(
            profile: profile,
            caption: "Kitchen",
            remoteId: 1,
            collapsed: CollapsedFlag.channel.rawValue
        )
        let channel1 = channel(remoteId: 1, profile: profile, location: location1)
        let channel1Item = channelItem(remoteId: 1, title: "Light")

        settings.hideUnavailableChannelsMock.returns = .single(false)
        channelRepository.allVisibleChannelsMock.returns = .single(.just([channel1]))
        channelRelationRepository.getParentsMapReturns = Observable.just([:])
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
        profileRepository.activeProfileObservable = Observable.just(profile)

        let location1 = location(profile: profile, caption: "Location 1", remoteId: 1)
        let channel1 = channel(remoteId: 1, profile: profile, location: location1, position: 1)
        let channel2 = channel(remoteId: 2, profile: profile, location: location1, position: 3)

        let location2 = location(profile: profile, caption: "Location 1", remoteId: 2)
        let channel3 = channel(remoteId: 3, profile: profile, location: location2, position: 2)

        let channel1Item = channelItem(remoteId: 1, title: "Channel 1", locationId: 1)
        let channel2Item = channelItem(remoteId: 2, title: "Channel 2", locationId: 1)
        let channel3Item = channelItem(remoteId: 3, title: "Channel 3", locationId: 2)

        settings.hideUnavailableChannelsMock.returns = .single(false)
        channelRepository.allVisibleChannelsMock.returns = .single(.just([channel1, channel2, channel3]))
        channelRelationRepository.getParentsMapReturns = Observable.just([:])
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
        XCTAssertTuples(channelRepository.allVisibleChannelsMock.parameters, [(profile, true)])
        assertMappedItems([
            ChannelWithChildren(channel: channel1),
            ChannelWithChildren(channel: channel3),
            ChannelWithChildren(channel: channel2)
        ])
    }

    func test_shouldLoadChannelWithChildren() {
        // given
        let profile = profile()
        profileRepository.activeProfileObservable = Observable.just(profile)

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
        channelRepository.allVisibleChannelsMock.returns = .single(.just([channel1, channel2, channel3]))
        channelRelationRepository.getParentsMapReturns = Observable.just([
            1: [relation1, relation2]
        ])
        createChannelWithChildrenUseCase.invokeMock.returns = .single(channel1WithChildren)
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
        XCTAssertTuples(channelRepository.allVisibleChannelsMock.parameters, [(profile, true)])
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.count, 1)
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.first?.0, channel1)
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.first?.1, [channel1, channel2, channel3])
        XCTAssertEqual(createChannelWithChildrenUseCase.invokeMock.parameters.first?.2, [relation1, relation2])
        assertMappedItems([channel1WithChildren])
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
        position: Int32 = 0
    ) -> SAChannel {
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.profile = profile
        channel.location = location
        channel.location_id = location.location_id?.int32Value ?? 0
        channel.position = position
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
