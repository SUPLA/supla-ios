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

protocol ReadChannelWithChildrenTreeUseCase {
    func invoke(remoteId: Int32) -> Observable<ChannelWithChildren>
}

final class ReadChannelWithChildrenTreeUseCaseImpl: ReadChannelWithChildrenTreeUseCase {
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository

    func invoke(remoteId: Int32) -> Observable<ChannelWithChildren> {
        return profileRepository
            .getActiveProfile()
            .flatMapFirst { profile in
                Observable.zip(
                    self.channelRepository.getAllVisibleChannels(forProfile: profile),
                    self.channelRelationRepository.getParentsMap(for: profile),
                    resultSelector: { channels, listOfParents in
                        self.toTree(remoteId, channels, listOfParents)
                    }
                ).flatMap { if let result = $0 { Observable.just(result) } else { Observable<ChannelWithChildren>.empty() } }
            }
    }

    private func toTree(_ remoteId: Int32, _ channels: [SAChannel], _ parentsMap: [Int32: [SAChannelRelation]]) -> ChannelWithChildren? {
        guard let channel = channels.first(where: { $0.remote_id == remoteId }) else { return nil }
        var channelsMap: [Int32: SAChannel] = [:]
        channels.forEach { channelsMap[$0.remote_id] = $0 }

        return ChannelWithChildren(channel: channel, children: findChildren(for: remoteId, parentsMap, channelsMap, []))
    }

    private func findChildren(
        for channelId: Int32,
        _ parentsMap: [Int32: [SAChannelRelation]],
        _ channelsMap: [Int32: SAChannel],
        _ childrenIds: [Int32]
    ) -> [ChannelChild] {
        var result: [ChannelChild] = []
        
        parentsMap[channelId]?.forEach {
            if let child = channelsMap[$0.channel_id] {
                if (!childrenIds.contains(child.remote_id)) {
                    result.append(
                        ChannelChild(
                            channel: child,
                            relationType: $0.relationType,
                            children: findChildren(for: $0.channel_id, parentsMap, channelsMap, childrenIds + [channelId])
                        )
                    )
                }
            }
        }
        
        return result
    }
}
