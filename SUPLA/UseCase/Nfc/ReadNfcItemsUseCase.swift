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

enum ReadNfcItems {
    protocol UseCase {
        func invoke() -> Observable<[NfcTagDataDto]>
    }
    
    final class Implementation: UseCase {
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<SceneRepository> private var sceneRepository
        
        func invoke() -> Observable<[NfcTagDataDto]> {
            Observable.combineLatest(
                nfcTagItemRepository.findAllObservable(),
                channelRepository.getAllChannels(),
                groupRepository.getAllGroups(),
                sceneRepository.getAllScenes()
            ) { tags, channels, groups, scenes in (tags, channels, groups, scenes) }
                .map { tags, channels, groups, scenes in
                    var result: [NfcTagDataDto] = []
                    
                    for item in tags {
                        switch (item.subjectType) {
                        case .channel:
                            if let channel = channels.first(where: { $0.remote_id == item.subjectId && $0.profile.id == item.profileId }) {
                                result.append(item.toItem(with: channel))
                            } else {
                                result.append(item.toItem(true))
                            }
                        case .group:
                            if let group = groups.first(where: { $0.remote_id == item.subjectId && $0.profile.id == item.profileId }) {
                                result.append(item.toItem(with: group))
                            } else {
                                result.append(item.toItem(true))
                            }
                        case .scene:
                            if let scene = scenes.first(where: { $0.sceneId == item.subjectId && $0.profile?.id == item.profileId }) {
                                result.append(item.toItem(with: scene))
                            } else {
                                result.append(item.toItem(true))
                            }
                        case .none: result.append(item.toItem(false))
                        }
                    }
                    
                    return result
                }
        }
    }
}

private extension NfcTagItemRepository {
    func findAllObservable() -> Observable<[NfcTagItemDto]> {
        Observable.fromAsync { handler in
            Task { handler(await self.findAll()) }
        }
    }
}
