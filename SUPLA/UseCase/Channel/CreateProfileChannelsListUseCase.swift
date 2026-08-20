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
        func invoke() -> Observable<[MainListItem]>
    }

    final class Implementation: UseCase {
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRelationRepository> private var channelRelationRepository
        @Singleton<CreateChannelWithChildrenUseCase> private var createChannelWithChildrenUseCase
        @Singleton<ChannelToMainListItem.UseCase> private var channelToMainListItemUseCase

        func invoke() -> Observable<[MainListItem]> {
            return profileRepository
                .getActiveProfile()
                .flatMapFirst { profile in
                    @Singleton<GlobalSettings> var settings

                    return Observable.zip(
                        self.channelRepository.getAllVisibleChannels(forProfile: profile, withUnavailable: !settings.hideUnavailableChannels),
                        self.channelRelationRepository.getParentsMap(for: profile),
                        resultSelector: { channels, listOfParents in self.toList(channels, listOfParents) }
                    )
                }
        }

        private func toList(_ channels: [SAChannel], _ parentsMap: [Int32: [SAChannelRelation]]) -> [MainListItem] {
            if (channels.isEmpty) {
                return []
            }

            let allChildrenIds = parentsMap.reduce([Int32]()) { list, item in
                var result = list
                result.append(contentsOf: item.value.map { $0.channel_id })
                return result
            }

            var lastLocation: _SALocation = channels[0].location!
            var items = [MainListItem]()
            items.append(lastLocation.listItem)

            for channel in channels {
                if (allChildrenIds.contains(channel.remote_id)) {
                    // skip channels which have parent ID.
                    continue
                }

                if (lastLocation.caption != channel.location!.caption) {
                    lastLocation = channel.location!
                    items.append(lastLocation.listItem)
                }

                if (!lastLocation.isCollapsed(flag: .channel)) {
                    if let childrenRelations = parentsMap[channel.remote_id] {
                        let channelWithChildren = createChannelWithChildrenUseCase.invoke(
                            channel,
                            allChannels: channels,
                            relations: childrenRelations
                        )
                        items.append(channelToMainListItemUseCase.invoke(channelWithChildren, location: lastLocation))
                    } else {
                        items.append(channelToMainListItemUseCase.invoke(ChannelWithChildren(channel: channel), location: lastLocation))
                    }
                }
            }

            return items
        }
    }
}

private extension _SALocation {
    var listItem: MainListItem {
        .location(
            LocationListItem(
                remoteId: location_id?.int32Value ?? 0,
                profileId: profile.id,
                userCaption: caption ?? "",
                collapsed: isCollapsed(flag: .channel)
            )
        )
    }
}
