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

enum ReadNfcItem {
    protocol UseCase {
        func invoke(_ uuid: String) async -> NfcTagItem?
    }

    final class Implementation: UseCase {
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<SceneRepository> private var sceneRepository

        func invoke(_ uuid: String) async -> NfcTagItem? {
            var result: NfcTagItem? = nil

            guard let item = await nfcTagItemRepository.find(byUuid: uuid) else { return result }

            switch (item.subjectType) {
            case .channel:
                if let subjectId = item.subjectId?.int32Value, let channel = try? await channelRepository.getChannel(subjectId).awaitFirstElement() {
                    result = item.toItem(with: channel)
                } else {
                    result = item.toItem(true)
                }
            case .group:
                if let subjectId = item.subjectId?.int32Value, let group = try? await groupRepository.getGroup(subjectId).awaitFirstElement() {
                    result = item.toItem(with: group)
                } else {
                    result = item.toItem(true)
                }
            case .scene:
                if let subjectId = item.subjectId?.int32Value, let scene = try? await sceneRepository.getScene(subjectId).awaitFirstElement() {
                    result = item.toItem(with: scene)
                } else {
                    result = item.toItem(true)
                }
            case .none: result = item.toItem(false)
            }

            return result
        }
    }
}
