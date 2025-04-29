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

struct ReadCarPlayItems {
    protocol UseCase {
        func invoke() -> Observable<[Item]>
    }
    
    final class Implementation: UseCase {
        @Singleton<CarPlayItemRepository> private var carPlayItemRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<SceneRepository> private var sceneRepository
        
        func invoke() -> Observable<[Item]> {
            Observable.zip(
                carPlayItemRepository.findAll(),
                channelRepository.getAllChannels(),
                groupRepository.getAllGroups(),
                sceneRepository.getAllScenes()
            ) { items, channels, groups, scenes in
                var result: [Item] = []
                
                for item in items {
                    switch (item.subjectType) {
                    case .channel:
                        if let channel = channels.first(where: { $0.remote_id == item.subjectId && $0.profile == item.profile }) {
                            result.append(item.toItem(with: channel))
                        }
                    case .group:
                        if let group = groups.first(where: { $0.remote_id == item.subjectId && $0.profile == item.profile }) {
                            result.append(item.toItem(with: group))
                        }
                    case .scene:
                        if let scene = scenes.first(where: { $0.sceneId == item.subjectId && $0.profile == item.profile }) {
                            result.append(item.toItem(with: scene))
                        }
                    }
                }
                return result
            }
        }
    }
}
    
extension ReadCarPlayItems {
    struct Item: Identifiable {
        let id: NSManagedObjectID
        let subjectId: Int32
        let subjectType: SubjectType
        let action: CarPlayAction?
        let icon: IconResult
        let caption: String
        let profileName: String
        
        let profile: AuthProfileItem?
        
        init(
            id: NSManagedObjectID,
            subjectId: Int32,
            subjectType: SubjectType,
            action: CarPlayAction?,
            icon: IconResult,
            caption: String,
            profileName: String,
            profile: AuthProfileItem? = nil
        ) {
            self.id = id
            self.subjectId = subjectId
            self.subjectType = subjectType
            self.action = action
            self.icon = icon
            self.caption = caption
            self.profileName = profileName
            self.profile = profile
        }
    }
}

private extension SACarPlayItem {
    func toItem(with channel: SAChannel) -> ReadCarPlayItems.Item {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return ReadCarPlayItems.Item(
            id: objectID,
            subjectId: subjectId,
            subjectType: .channel,
            action: action,
            icon: getChannelBaseIconUseCase.stateIcon(channel: channel, state: action.action.state),
            caption: getCaptionUseCase.invoke(data: channel.shareable).string,
            profileName: channel.profile.displayName,
            profile: channel.profile
        )
    }
    
    func toItem(with group: SAChannelGroup) -> ReadCarPlayItems.Item {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return ReadCarPlayItems.Item(
            id: objectID,
            subjectId: subjectId,
            subjectType: .channel,
            action: action,
            icon: getChannelBaseIconUseCase.stateIcon(channel: group, state: action.action.state),
            caption: getCaptionUseCase.invoke(data: group.shareable).string,
            profileName: group.profile.displayName,
            profile: group.profile
        )
    }
    
    func toItem(with scene: SAScene) -> ReadCarPlayItems.Item {
        @Singleton<GetSceneIconUseCase> var getSceneIconUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return ReadCarPlayItems.Item(
            id: objectID,
            subjectId: subjectId,
            subjectType: .channel,
            action: action,
            icon: getSceneIconUseCase.invoke(scene),
            caption: getCaptionUseCase.invoke(data: scene.shareable).string,
            profileName: scene.profile?.displayName ?? "",
            profile: scene.profile
        )
    }
}

private extension SUPLA.Action {
    var state: ChannelState {
        switch (self) {
        case .open: .opened
        case .close: .closed
        case .shut: .closed
        case .reveal: .opened
        case .revealPartially: .opened
        case .shutPartially: .closed
        case .turnOn: .on
        case .turnOff: .off
        case .setRgbwParameters: .complex([.on, .on])
        case .openClose: .opened
        case .stop: .notUsed
        case .toggle: .on
        case .upOrStop: .opened
        case .downOrStop: .closed
        case .stepByStep: .opened
        case .up: .opened
        case .down: .closed
        case .setHvacParameters: .on
        case .execute: .notUsed
        case .interrupt: .notUsed
        case .interruptAndExecute: .notUsed
        }
    }
}
