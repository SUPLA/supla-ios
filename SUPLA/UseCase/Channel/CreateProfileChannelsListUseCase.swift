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

import Foundation
import RxSwift

protocol CreateProfileChannelsListUseCase {
    func invoke() -> Observable<[List]>
}

final class CreateProfileChannelsListUseCaseImpl: CreateProfileChannelsListUseCase {
    
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository
    @Singleton<CreateChannelWithChildrenUseCase> private var createChannelWithChildrenUseCase
    
    func invoke() -> Observable<[List]> {
        return profileRepository
            .getActiveProfile()
            .flatMapFirst { profile in
                Observable.zip(
                    self.channelRepository.getAllVisibleChannels(forProfile: profile),
                    self.channelRelationRepository.getParentsMap(for: profile),
                    resultSelector: { channels, listOfParents in self.toList(channels, listOfParents) }
                )
            }
    }
    
    private func toList(_ channels: [SAChannel], _ parentsMap: [Int32: [SAChannelRelation]]) -> [List] {
        if (channels.isEmpty) {
            return [.list(items: [])]
        }
        
        let allChildrenIds = parentsMap.reduce([Int32]()) { list, item in
            var result = list
            result.append(contentsOf: item.value.map{ $0.channel_id })
            return result
        }
        
        var lastLocation: _SALocation = channels[0].location!
        var items = [ListItem]()
        items.append(.location(location: lastLocation))
        
        for channel in channels {
            if (allChildrenIds.contains(channel.remote_id)) {
                // skip channels which have parent ID.
                continue
            }
            
            if (lastLocation.caption != channel.location!.caption) {
                items.append(.location(location: channel.location!))
                lastLocation = channel.location!
            }
            
            if (!lastLocation.isCollapsed(flag: .channel)) {
                if let childrenRelations = parentsMap[channel.remote_id] {
                    let channelWithChildren = createChannelWithChildrenUseCase.invoke(
                        channel,
                        allChannels: channels,
                        relations: childrenRelations
                    )
                    items.append(.channelBase(channelBase: channel, children: channelWithChildren.children))
                } else {
                    items.append(.channelBase(channelBase: channel, children: []))
                }
            }
        }
        
        return [.list(items: items)]
    }
}
