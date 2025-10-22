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

struct ReadGroupWithChannels {
    protocol UseCase {
        func invoke(remoteId: Int32) -> Observable<GroupWithChannels>
    }
    
    final class Implementation: UseCase {
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<ChannelRelationRepository> private var channelRelationRepository
        @Singleton<ChannelGroupRelationRepository> private var channelGroupRelationRepository
        @Singleton<CreateChannelWithChildrenUseCase> private var createChannelWithChildrenUseCase
        
        func invoke(remoteId: Int32) -> Observable<GroupWithChannels> {
            profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    Observable.zip(
                        self.groupRepository.getGroup(for: profile, with: remoteId),
                        self.channelRepository.getAllVisibleChannels(forProfile: profile),
                        self.channelRelationRepository.getParentsMap(for: profile),
                        self.channelGroupRelationRepository.getRelations(for: profile, andGroup: remoteId)
                    )
                }
                .map { group, channels, parentsMap, relations in
                    let channels: [ChannelWithChildren] = relations
                        .map { relation in
                            if let channel = channels.first(where: { $0.remote_id == relation.channel_id }) {
                                let childrenRelations = parentsMap[relation.channel_id] ?? []
                                return self.createChannelWithChildrenUseCase.invoke(channel, allChannels: channels, relations: childrenRelations)
                            }
                            
                            return nil
                        }
                        .compactMap { $0 }
                    
                    return GroupWithChannels(group: group, channels: channels)
                }
        }
    }
    
    struct GroupWithChannels {
        let group: SAChannelGroup
        let channels: [ChannelWithChildren]
        
        var relatedChannelData: [RelatedChannelData] {
            @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
            @Singleton<GetCaptionUseCase> var getCaptionUseCase
            
            return channels
                .map {
                    RelatedChannelData(
                        channelId: $0.remoteId,
                        onlineState: $0.onlineState,
                        icon: getChannelBaseIconUseCase.invoke(channel: $0.channel),
                        caption: getCaptionUseCase.invoke(data: $0.channel.shareable).string,
                        userCaption: $0.channel.caption ?? "",
                        batteryIcon: nil,
                        showChannelStateIcon: $0.onlineState.online && $0.channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0
                    )
                }
        }
        
        func aggregatedState(activeValue: ChannelState, inactiveValue: ChannelState) -> ChannelState? {
            guard let groupTotalValue = group.total_value as? GroupTotalValue else { return nil }
            
            return groupTotalValue.values
                .map { ($0 as? BoolGroupValue)?.value }
                .map {
                    switch $0 {
                    case .none:
                        ChannelState.notUsed
                    case .some(let active):
                        active ? activeValue : inactiveValue
                    }
                }
                .reduce(ChannelStateHolder(state: nil)) { result, value in
                    if (result.state == nil) {
                        ChannelStateHolder(state: value)
                    } else if (result.state == value) {
                        ChannelStateHolder(state: result.state)
                    } else {
                        ChannelStateHolder(state: ChannelState.notUsed)
                    }
                }
                .state
        }
    }
}

private struct ChannelStateHolder {
    let state: ChannelState?
}
