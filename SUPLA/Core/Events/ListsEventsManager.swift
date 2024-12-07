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
import RxRelay

@objc
protocol UpdateEventsManagerEmitter {
    func emitSceneUpdate(sceneId: Int)
    func emitChannelUpdate(remoteId: Int)
    func emitGroupUpdate(remoteId: Int)
    func emitChannelsUpdate()
    func emitGroupsUpdate()
    func emitScenesUpdate()
}

protocol UpdateEventsManager: UpdateEventsManagerEmitter {
    func observeScene(sceneId: Int) -> Observable<SAScene>
    func observeChannel(remoteId: Int) -> Observable<SAChannel>
    func observeGroup(remoteId: Int) -> Observable<SAChannelGroup>
    func observeChannelWithChildren(remoteId: Int) -> Observable<ChannelWithChildren>
    func observeChannelsUpdate() -> Observable<Void>
    func observeGroupsUpdate() -> Observable<Void>
    func observeScenesUpdate() -> Observable<Void>
    
    func cleanup()
}

final class UpdateEventsManagerImpl: UpdateEventsManager {
    
    private var subjects: [Id: BehaviorRelay<Int>] = [:]
    
    private let channelUpdatesSubject = BehaviorRelay(value: ())
    private let groupUpdatesSubject = BehaviorRelay(value: ())
    private let sceneUpdatesSubject = BehaviorRelay(value: ())
    
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository
    @Singleton<CreateChannelWithChildrenUseCase> private var createChannelWithChildrenUseCase
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
    @Singleton<ChannelToRootRelationHolderUseCase> private var channelToRootRelationHolderUseCase
    
    func emitSceneUpdate(sceneId: Int) {
        let subject = getSubjectForScene(sceneId: sceneId)
        subject.accept(subject.value + 1)
    }
    
    func emitChannelUpdate(remoteId: Int) {
        let subject = getSubjectForChannel(channelId: remoteId)
        subject.accept(subject.value + 1)
        
        if let rootParent = channelToRootRelationHolderUseCase.getParent(for: Int32(remoteId)) {
            let rootParentSubject = getSubjectForChannel(channelId: Int(rootParent))
            rootParentSubject.accept(rootParentSubject.value + 1)
        }
    }
    
    func emitGroupUpdate(remoteId: Int) {
        let subject = getSubjectForGroup(groupId: remoteId)
        subject.accept(subject.value + 1)
    }
    
    func emitChannelsUpdate() {
        channelUpdatesSubject.accept(())
    }
    
    func emitGroupsUpdate() {
        groupUpdatesSubject.accept(())
    }
    
    func emitScenesUpdate() {
        sceneUpdatesSubject.accept(())
    }
    
    func observeScene(sceneId: Int) -> Observable<SAScene> {
        return getSubjectForScene(sceneId: sceneId)
            .flatMap { _ in
                self.profileRepository.getActiveProfile()
                    .flatMapFirst { self.sceneRepository.getScene(for: $0, with: Int32(sceneId)) }
            }
    }
    
    func observeChannel(remoteId: Int) -> Observable<SAChannel> {
        return getSubjectForChannel(channelId: remoteId)
            .flatMap { _ in
                self.profileRepository.getActiveProfile()
                    .flatMapFirst { self.channelRepository.getChannel(for: $0, with: Int32(remoteId)) }
            }
    }
    
    func observeGroup(remoteId: Int) -> Observable<SAChannelGroup> {
        return getSubjectForGroup(groupId: remoteId)
            .flatMap { _ in
                self.profileRepository.getActiveProfile()
                    .flatMapFirst { self.groupRepository.getGroup(for: $0, with: Int32(remoteId)) }
            }
    }
    
    func observeChannelWithChildren(remoteId: Int) -> Observable<ChannelWithChildren> {
        getSubjectForChannel(channelId: remoteId)
            .flatMap { _ in self.readChannelWithChildrenUseCase.invoke(remoteId: Int32(remoteId)) }
    }
    
    func observeChannelsUpdate() -> Observable<Void> { channelUpdatesSubject.asObservable() }
    
    func observeGroupsUpdate() -> Observable<Void> { groupUpdatesSubject.asObservable() }
    
    func observeScenesUpdate() -> Observable<Void> { sceneUpdatesSubject.asObservable() }
    
    func cleanup() {
        subjects.removeAll()
    }
    
    private func getSubjectForScene(sceneId: Int) -> BehaviorRelay<Int> {
        return synced(self) { getSubject(id: sceneId, type: .scene) }
    }
    
    private func getSubjectForChannel(channelId: Int) -> BehaviorRelay<Int> {
        return synced(self) { getSubject(id: channelId, type: .channel) }
    }
    
    private func getSubjectForGroup(groupId: Int) -> BehaviorRelay<Int> {
        return synced(self) { getSubject(id: groupId, type: .group) }
    }
    
    private func getSubject(id: Int, type: IdType) -> BehaviorRelay<Int> {
        let subjectId = Id(type: type, id: id)
        
        if let subject = subjects[subjectId] {
            return subject
        }
        
        let subject = BehaviorRelay(value: 0)
        subjects[subjectId] = subject
        return subject
    }
    
    private func toChannelWithChildren(remoteId: Int, _ channels: [SAChannel], _ parentsMap: [Int32: [SAChannelRelation]]) -> ChannelWithChildren? {
        
        guard
            let channel = channels.first(where: { $0.remote_id == remoteId}),
            let relations = parentsMap.first(where: { $0.key == remoteId})?.value
        else { return nil }
        
        return createChannelWithChildrenUseCase.invoke(channel, allChannels: channels, relations: relations)
    }
    
    enum IdType {
        case scene
        case channel
        case group
    }
    
    struct Id: Hashable {
        let type: IdType
        let id: Int
    }
}
