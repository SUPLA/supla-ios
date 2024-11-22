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

protocol ChannelToRootRelationHolderUseCase {
    func reloadRelations()
    func getParent(for channelId: Int32) -> Int32?
}

class ChannelToRootRelationHolderUseCaseImpl: ChannelToRootRelationHolderUseCase {
    
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository
    
    private var channelToRootMap: [Int32: Int32] = [:]
    
    func getParent(for channelId: Int32) -> Int32? {
        return channelToRootMap[channelId]
    }
    
    func reloadRelations() {
        let data = try? profileRepository
            .getActiveProfile()
            .flatMapFirst { profile in
                Observable.zip(
                    self.channelRepository.getAllVisibleChannels(forProfile: profile),
                    self.channelRelationRepository.getParentsMap(for: profile),
                    resultSelector: { ($0, $1) }
                )
            }
            .subscribeSynchronous()
        
        if let data {
            buildMap(data.0, data.1)
        }
    }
    
    private func buildMap(_ channels: [SAChannel], _ parentsMap: [Int32: [SAChannelRelation]]) {
        channelToRootMap.removeAll()
        
        var channelsMap: [Int32: SAChannel] = [:]
        channels.forEach { channelsMap[$0.remote_id] = $0 }
        channels.forEach { channel in
            let childrenIds = getChildrenIds(for: channel.remote_id, parentsMap, channelsMap, [])
            childrenIds.forEach { childId in
                channelToRootMap[childId] = channel.remote_id
            }
        }
    }
    
    private func getChildrenIds(
        for channelId: Int32,
        _ parentsMap: [Int32: [SAChannelRelation]],
        _ channelsMap: [Int32: SAChannel],
        _ childrenIds: [Int32]
    ) -> [Int32] {
        var result: [Int32] = []
        
        parentsMap[channelId]?.forEach {
            if let child = channelsMap[$0.channel_id] {
                if (!childrenIds.contains(child.remote_id)) {
                    result.append(child.remote_id)
                    result.append(contentsOf: getChildrenIds(for: child.remote_id, parentsMap, channelsMap, result))
                    
                }
            }
        }
        
        return result
    }
}
