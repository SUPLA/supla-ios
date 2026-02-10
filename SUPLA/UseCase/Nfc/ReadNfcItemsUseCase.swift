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
    
enum ReadNfcItems {
    protocol UseCase {
        func invoke() async -> [NfcTagItem]
    }
    
    final class Implementation: UseCase {
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<SceneRepository> private var sceneRepository
        
        func invoke() async -> [NfcTagItem] {
            var result: [NfcTagItem] = []
            
            do {
                guard let items = try await nfcTagItemRepository.findAll().awaitFirstElement() else { return result }
                let channels = try await channelRepository.getAllChannels().awaitFirstElement()
                let groups = try await groupRepository.getAllGroups().awaitFirstElement()
                let scenes = try await sceneRepository.getAllScenes().awaitFirstElement()
                
                for item in items {
                    switch (item.subjectType) {
                    case .channel:
                        if let channel = channels?.first(where: { $0.remote_id == item.subjectId?.int32Value && $0.profile.id == item.profileId?.int32Value }) {
                            result.append(item.toItem(with: channel))
                        } else {
                            result.append(item.toItem(true))
                        }
                    case .group:
                        if let group = groups?.first(where: { $0.remote_id == item.subjectId?.int32Value && $0.profile.id == item.profileId?.int32Value }) {
                            result.append(item.toItem(with: group))
                        } else {
                            result.append(item.toItem(true))
                        }
                    case .scene:
                        if let scene = scenes?.first(where: { $0.sceneId == item.subjectId?.int32Value && $0.profile?.id == item.profileId?.int32Value }) {
                            result.append(item.toItem(with: scene))
                        } else {
                            result.append(item.toItem(true))
                        }
                        break
                    case .none: result.append(item.toItem(false))
                    }
                }
                
            } catch {
                SALog.error("NFC tags list preparation failed: \(error)")
            }
            
            return result
        }
    }
}
