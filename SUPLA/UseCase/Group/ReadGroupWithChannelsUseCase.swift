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
                    let channels: [ChannelInGroup] = relations
                        .map { relation in
                            guard let channel = channels.first(where: { $0.remote_id == relation.channel_id }) else {
                                return ChannelInGroup.invisible(remoteId: relation.channel_id)
                            }
                            let childrenRelations = parentsMap[relation.channel_id] ?? []
                            let channelWithChildren = self.createChannelWithChildrenUseCase.invoke(channel, allChannels: channels, relations: childrenRelations)
                            return ChannelInGroup.visible(channel: channelWithChildren)
                        }
                    
                    return GroupWithChannels(group: group, channels: channels)
                }
        }
    }
    
    struct GroupWithChannels {
        let group: SAChannelGroup
        let channels: [ChannelInGroup]
        
        var relatedChannelData: [RelatedChannelData] {
            @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
            @Singleton<GetCaptionUseCase> var getCaptionUseCase
            
            return channels
                .map {
                    switch $0 {
                    case let .invisible(remoteId): RelatedChannelData.invisible(id: remoteId)
                    case let .visible(channelWithChildren): RelatedChannelData.visible(
                            id: channelWithChildren.remoteId,
                            onlineState: channelWithChildren.onlineState,
                            icon: getChannelBaseIconUseCase.invoke(channel: channelWithChildren.channel),
                            caption: getCaptionUseCase.invoke(data: channelWithChildren.channel.shareable).string,
                            userCaption: channelWithChildren.channel.caption ?? "",
                            batteryIcon: nil,
                            showChannelStateIcon: channelWithChildren.channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) != 0 &&
                                channelWithChildren.channel.state != nil
                        )
                    }
                }
        }
        
        func aggregatedState(policy: Policy = .onOff) -> ChannelState.Value? {
            guard let groupTotalValue = group.total_value as? GroupTotalValue else { return nil }
            
            return groupTotalValue.values
                .map { policy.map($0) }
                .reduce(ChannelStateHolder(state: nil)) { result, value in
                    if (result.state == nil) {
                        ChannelStateHolder(state: value)
                    } else if (result.state == value) {
                        ChannelStateHolder(state: result.state)
                    } else {
                        ChannelStateHolder(state: .notUsed)
                    }
                }
                .state
        }
        
        enum Policy {
            case onOff
            case openClosed
            case dimmer
            case rgb
            
            func map(_ value: BaseGroupValue) -> ChannelState.Value {
                switch self {
                case .onOff: (value as? BoolGroupValue)?.value == true ? .on : .off
                case .openClosed: (value as? BoolGroupValue)?.value == true ? .closed : .opened
                case .dimmer:
                    if let integerGroupValue = value as? IntegerGroupValue {
                        (integerGroupValue.value > 0) ? .on : .off
                    } else if let dimmerAndRgbValue = value as? DimmerAndRgbLightingGroupValue {
                        (dimmerAndRgbValue.brightness > 0) ? .on : .off
                    } else {
                        .off
                    }
                case .rgb:
                    if let rgbValue = value as? RgbLightingGroupValue {
                        (rgbValue.brightness > 0) ? .on : .off
                    } else if let dimmerAndRgbValue = value as? DimmerAndRgbLightingGroupValue {
                        (dimmerAndRgbValue.colorBrightness > 0) ? .on : .off
                    } else {
                        .off
                    }
                }
            }
        }
    }
    
    enum ChannelInGroup {
        case invisible(remoteId: Int32)
        case visible(channel: ChannelWithChildren)
        
        var function: Int32 {
            switch self {
            case .invisible: SuplaFunction.unknown.value
            case let .visible(channelWithChildren): channelWithChildren.function
            }
        }
    }
}

private struct ChannelStateHolder {
    let state: ChannelState.Value?
}
