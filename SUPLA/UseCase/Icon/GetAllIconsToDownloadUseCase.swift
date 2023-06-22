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

final class GetAllIconsToDownloadUseCase {
    
    @Singleton<UserIconRepository> private var userIconRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<SceneRepository> private var sceneRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke() -> [Int32] {
        do {
            let downloadedIcons = try profileRepository.getActiveProfile()
                .flatMapFirst { self.userIconRepository.getDownloadedIconIds(for: $0 )}
                .toBlocking()
                .first()
            guard let downloadedIcons = downloadedIcons
            else { return [] }
            
            let channelIcons = try profileRepository.getActiveProfile()
                .flatMapFirst { self.channelRepository.getAllIconIds(for: $0 )}
                .toBlocking()
                .first()
            let groupIcons = try profileRepository.getActiveProfile()
                .flatMapFirst { self.groupRepository.getAllIconIds(for: $0 )}
                .toBlocking()
                .first()
            let sceneIcons = try profileRepository.getActiveProfile()
                .flatMapFirst { self.sceneRepository.getAllIconIds(for: $0 )}
                .toBlocking()
                .first()
            
            var result: Set<Int32> = []
            channelIcons?.forEach { icon in
                if (!downloadedIcons.contains(icon)) {
                    result.insert(icon)
                }
            }
            groupIcons?.forEach { icon in
                if (!downloadedIcons.contains(icon)) {
                    result.insert(icon)
                }
            }
            sceneIcons?.forEach { icon in
                if (!downloadedIcons.contains(icon)) {
                    result.insert(icon)
                }
            }
            
            return Array(result)
        } catch {
            return []
        }
    }
}
