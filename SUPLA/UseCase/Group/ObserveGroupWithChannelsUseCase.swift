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

struct ObserveGroupWithChannels {
    protocol UseCase {
        func invoke(remoteId: Int32) -> Observable<ReadGroupWithChannels.GroupWithChannels>
    }

    final class Implementation: UseCase {
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<ChannelGroupRelationRepository> private var channelGroupRelationRepository
        @Singleton<ObserveChannelsTreeSnapshot.UseCase> private var observeChannelsTreeSnapshotUseCase

        func invoke(remoteId: Int32) -> Observable<ReadGroupWithChannels.GroupWithChannels> {
            profileRepository.getActiveProfile()
                .flatMapLatest { profile in
                    Observable.combineLatest(
                        self.groupRepository.observeGroup(for: profile, with: remoteId),
                        self.channelGroupRelationRepository.observeRelations(for: profile, andGroup: remoteId),
                        self.observeChannelsTreeSnapshotUseCase.invoke()
                    ) { group, relations, treeSnapshot in
                        let channels = relations.map { relation in
                            guard let channel = treeSnapshot.channelsWithChildren[relation.channel_id] else {
                                return ReadGroupWithChannels.ChannelInGroup.invisible(remoteId: relation.channel_id)
                            }
                            return ReadGroupWithChannels.ChannelInGroup.visible(channel: channel)
                        }
                        return ReadGroupWithChannels.GroupWithChannels(group: group, channels: channels)
                    }
                }
        }
    }
}
