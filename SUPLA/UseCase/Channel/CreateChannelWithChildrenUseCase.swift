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
    func invoke(_ channel: SAChannel, allChannels: [SAChannel], parentsMap: [Int32: [SAChannelRelation]]) -> ChannelWithChildren
}

final class CreateChannelWithChildrenUseCaseImpl: CreateChannelWithChildrenUseCase {

    func invoke(_ channel: SAChannel, allChannels: [SAChannel], parentsMap: [Int32: [SAChannelRelation]]) -> ChannelWithChildren {
        let channelsById = allChannels.reduce(into: [Int32: SAChannel]()) { result, channel in
            result[channel.remote_id] = channel
        }
        return ChannelWithChildren(
            channel: channel,
            children: makeChildren(for: channel.remote_id, parentsMap: parentsMap, channelsById: channelsById, ancestors: [])
        )
    }

    private func makeChildren(
        for parentId: Int32,
        parentsMap: [Int32: [SAChannelRelation]],
        channelsById: [Int32: SAChannel],
        ancestors: Set<Int32>
    ) -> [ChannelChild] {
        (parentsMap[parentId] ?? []).compactMap { relation in
            let childId = relation.channel_id
            guard !ancestors.contains(childId), let child = channelsById[childId] else { return nil }
            return ChannelChild(
                channel: child,
                relation: relation,
                children: makeChildren(
                    for: childId,
                    parentsMap: parentsMap,
                    channelsById: channelsById,
                    ancestors: ancestors.union([parentId])
                )
            )
        }
    }
}
