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

protocol ReadChannelWithChildrenUseCase {
    func invoke(remoteId: Int32) -> Observable<ChannelWithChildren>
}

final class ReadChannelWithChildrenUseCaseImpl: ReadChannelWithChildrenUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository
    
    func invoke(remoteId: Int32) -> Observable<ChannelWithChildren> {
        profileRepository.getActiveProfile()
            .flatMap { profile in
                self.channelRelationRepository
                    .getAllRelations(for: profile, with: remoteId)
                    .map { (profile, $0) }
            }
            .flatMap { profile, relations in
                var ids = relations.map { $0.channel_id }
                ids.append(remoteId)
                
                return self.channelRepository
                    .getAllChannels(forProfile: profile, with: ids)
                    .map { (relations, $0) }
            }
            .map { relations, channels in
                self.createChannelWithChildren(remoteId, relations, channels)
            }
            .compactMap { $0 }
    }
    
    private func createChannelWithChildren(_ parentId: Int32, _ relations: [SAChannelRelation], _ channels: [SAChannel]) -> ChannelWithChildren? {
        guard let parent = channels.first(where: { $0.remote_id == parentId })
        else { return nil }
        return ChannelWithChildren(channel: parent, children: self.createChildren(relations, channels))
    }
    
    private func createChildren(_ relations: [SAChannelRelation], _ channels: [SAChannel]) -> [ChannelChild] {
        var children: [ChannelChild] = []
        for relation in relations {
            if let channel = channels.first(where: { $0.remote_id == relation.channel_id }) {
                children.append(ChannelChild(channel: channel, relationType: relation.relationType))
            }
        }
        return children
    }
}
