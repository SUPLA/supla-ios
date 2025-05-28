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

struct GetAllIconsToDownload {
    protocol UseCase {
        func invoke() -> Observable<[UserIconData]>
    }
    
    final class Implementation: UseCase {
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<SceneRepository> private var sceneRepository
        @Singleton<UserIcons.UseCase> private var userIconsUseCase
        
        func invoke() -> Observable<[UserIconData]> {
            profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    Observable.zip(
                        self.channelRepository.getAllIcons(for: profile),
                        self.groupRepository.getAllIcons(for: profile),
                        self.sceneRepository.getAllIcons(for: profile)
                    ) { channelIcons, groupIcons, sceneIcons in
                        channelIcons + groupIcons + sceneIcons
                    }
                    .map { allIconIds in
                        let downloadedIcons = self.userIconsUseCase.existingIconIds(profileId: profile.id)
                        
                        var result: Set<UserIconData> = []
                        allIconIds.forEach {
                            if (!downloadedIcons.contains($0.id)) {
                                result.insert($0)
                            }
                        }
                        return Array(result)
                    }
                }
        }
    }
}
