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
    @Singleton<CreateChannelWithChildrenUseCase> private var createChannelWithChildrenUseCase
    
    func invoke(remoteId: Int32) -> Observable<ChannelWithChildren> {
        profileRepository.getActiveProfile()
            .flatMap { profile in
                Observable.zip(
                    self.channelRelationRepository.getParentsMap(for: profile),
                    self.channelRepository.getAllVisibleChannels(forProfile: profile),
                    resultSelector: { ($0, $1) }
                )
            }
            .map { parentsMap, channels in
                self.createChannelWithChildren(remoteId, parentsMap, channels)
            }
            .compactMap { $0 }
    }
    
    private func createChannelWithChildren(_ parentId: Int32, _ parentsMap: [Int32: [SAChannelRelation]], _ channels: [SAChannel]) -> ChannelWithChildren? {
        guard let parent = channels.first(where: { $0.remote_id == parentId }) else { return nil }
        return createChannelWithChildrenUseCase.invoke(parent, allChannels: channels, parentsMap: parentsMap)
    }
}
