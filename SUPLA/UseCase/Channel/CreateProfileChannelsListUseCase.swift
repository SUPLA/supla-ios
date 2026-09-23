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

struct CreateProfileChannelsList {
    protocol UseCase {
        func invoke(filter: String?) -> Observable<[MainListItem]>
    }

    final class Implementation: UseCase {
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRelationRepository> private var channelRelationRepository
        @Singleton<CreateChannelWithChildrenUseCase> private var createChannelWithChildrenUseCase
        @Singleton<ChannelToMainListItem.UseCase> private var channelToMainListItemUseCase

        func invoke(filter: String?) -> Observable<[MainListItem]> {
            return profileRepository
                .getActiveProfile()
                .flatMapFirst { profile in
                    @Singleton<GlobalSettings> var settings

                    return Observable.zip(
                        self.channelRepository.getAllVisibleChannels(forProfile: profile, withUnavailable: !settings.hideUnavailableChannels),
                        self.channelRelationRepository.getParentsMap(for: profile),
                        resultSelector: { channels, listOfParents in self.toList(channels, listOfParents, filter: filter) }
                    )
                }
        }

        private func toList(
            _ channels: [SAChannel],
            _ parentsMap: [Int32: [SAChannelRelation]],
            filter: String?
        ) -> [MainListItem] {
            if (channels.isEmpty) {
                return []
            }

            let allChildrenIds = parentsMap.reduce([Int32]()) { list, item in
                var result = list
                result.append(contentsOf: item.value.map { $0.channel_id })
                return result
            }

            var items = [MainListItem]()
            let inSearch = MainListFilter.isSearchable(filter)

            for section in channels.toLocationSections(
                locationOf: { $0.location },
                positionOf: { $0.position }
            ) {
                let visibleChannels = section.items.compactMap { channel -> MainListItem? in
                    if allChildrenIds.contains(channel.remote_id) {
                        return nil
                    }

                    guard let item = channelItem(channel, channels, parentsMap) else { return nil }
                    if inSearch && !itemMatches(item, location: channel.location!, filter: filter) {
                        return nil
                    }

                    return item
                }

                guard
                    !visibleChannels.isEmpty,
                    let location = section.items
                        .compactMap(\.location)
                        .min(by: { ($0.sortOrder?.int32Value ?? 0) < ($1.sortOrder?.int32Value ?? 0) })
                else {
                    continue
                }

                items.append(location.listItem(inSearch: inSearch))
                if inSearch || !location.isCollapsed(flag: .channel) {
                    items.append(contentsOf: visibleChannels)
                }
            }

            return items
        }

        private func channelItem(
            _ channel: SAChannel,
            _ channels: [SAChannel],
            _ parentsMap: [Int32: [SAChannelRelation]]
        ) -> MainListItem? {
            if let childrenRelations = parentsMap[channel.remote_id] {
                let channelWithChildren = createChannelWithChildrenUseCase.invoke(
                    channel,
                    allChannels: channels,
                    relations: childrenRelations
                )
                return channelToMainListItemUseCase.invoke(channelWithChildren)
            } else {
                return channelToMainListItemUseCase.invoke(ChannelWithChildren(channel: channel))
            }
        }

        private func itemMatches(_ item: MainListItem, location: _SALocation, filter: String?) -> Bool {
            guard let filter else { return true }

            return MainListFilter.matches(item, filter: filter)
                || MainListFilter.matches(location.caption, filter: filter)
        }
    }
}

extension CreateProfileChannelsList.UseCase {
    func invoke() -> Observable<[MainListItem]> {
        invoke(filter: nil)
    }
}

private extension _SALocation {
    func listItem(inSearch: Bool) -> MainListItem {
        .location(
            LocationListItem(
                remoteId: location_id?.int32Value ?? 0,
                profileId: profile.id,
                userCaption: caption ?? "",
                collapsed: inSearch ? false : isCollapsed(flag: .channel)
            )
        )
    }
}
