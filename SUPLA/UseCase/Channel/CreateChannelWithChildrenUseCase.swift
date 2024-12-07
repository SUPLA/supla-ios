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

protocol CreateChannelWithChildrenUseCase {
    func invoke(_ channel: SAChannel, allChannels: [SAChannel], relations: [SAChannelRelation]) -> ChannelWithChildren
}

final class CreateChannelWithChildrenUseCaseImpl: CreateChannelWithChildrenUseCase {
    
    func invoke(_ channel: SAChannel, allChannels: [SAChannel], relations: [SAChannelRelation]) -> ChannelWithChildren {
        let childrenIds = relations.map { $0.channel_id }
        let childrenChannels = allChannels.filter { childrenIds.contains($0.remote_id) }
        
        var children: [ChannelChild] = []
        for child in childrenChannels {
            let relation = relations
                .first { $0.channel_id == child.remote_id }
            
            if let relation {
                children.append(ChannelChild(channel: child, relation: relation))
            }
        }
        
        return ChannelWithChildren(channel: channel, children: children)
    }
    
}
