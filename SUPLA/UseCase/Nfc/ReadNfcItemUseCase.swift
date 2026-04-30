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

enum ReadNfcItem {
    protocol UseCase {
        func invoke(_ uuid: String) -> Observable<NfcTagDataDto>
    }

    final class Implementation: UseCase {
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<SceneRepository> private var sceneRepository

        func invoke(_ uuid: String) -> Observable<NfcTagDataDto> {
            nfcTagItemRepository.findObservable(byUuid: uuid)
                .flatMap { tag in
                    switch (tag.subjectType) {
                    case .channel: self.toNfcItemWithChannel(tag)
                    case .group: self.toNfcItemWithGroup(tag)
                    case .scene: self.toNfcItemWithScene(tag)
                    case .none: Observable.just(tag.toItem(false))
                    }
                }
        }
        
        private func toNfcItemWithChannel(_ tag: NfcTagItemDto) -> Observable<NfcTagDataDto> {
            if let profileId = tag.profileId, let channelId = tag.subjectId {
                channelRepository.getChannel(for: profileId, with: channelId)
                    .map {
                        if let channel = $0 {
                            tag.toItem(with: channel)
                        } else {
                            tag.toItem(true)
                        }
                    }
            } else {
                Observable.just(tag.toItem(true))
            }
        }
        
        private func toNfcItemWithGroup(_ tag: NfcTagItemDto) -> Observable<NfcTagDataDto> {
            if let profileId = tag.profileId, let groupId = tag.subjectId {
                groupRepository.getGroup(for: profileId, with: groupId)
                    .map {
                        if let group = $0 {
                            tag.toItem(with: group)
                        } else {
                            tag.toItem(true)
                        }
                    }
            } else {
                Observable.just(tag.toItem(true))
            }
        }
        
        private func toNfcItemWithScene(_ tag: NfcTagItemDto) -> Observable<NfcTagDataDto> {
            if let profileId = tag.profileId, let sceneId = tag.subjectId {
                sceneRepository.getScene(for: profileId, with: sceneId)
                    .map {
                        if let scene = $0 {
                            tag.toItem(with: scene)
                        } else {
                            tag.toItem(true)
                        }
                    }
            } else {
                Observable.just(tag.toItem(true))
            }
        }
    }
}

private extension NfcTagItemRepository {
    func findObservable(byUuid uuid: String) -> Observable<NfcTagItemDto> {
        Observable.fromAsync { handler in
            Task { handler(await self.find(byUuid: uuid)) }
        }
        .compactMap { $0 }
    }
}
