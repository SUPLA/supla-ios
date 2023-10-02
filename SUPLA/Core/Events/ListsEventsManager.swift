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

import Foundation
import RxSwift
import RxRelay

@objc
protocol ListsEventsManagerEmitter {
    func emitSceneChange(sceneId: Int)
    func emitChannelChange(remoteId: Int)
    func emitGroupChange(remoteId: Int)
    func emitChannelUpdate()
    func emitGroupUpdate()
    func emitSceneUpdate()
}

protocol ListsEventsManager: ListsEventsManagerEmitter {
    func observeScene(sceneId: Int) -> Observable<SAScene>
    func observeChannel(remoteId: Int) -> Observable<SAChannel>
    func observeGroup(remoteId: Int) -> Observable<SAChannelGroup>
    func observeChannelUpdates() -> Observable<Void>
    func observeGroupUpdates() -> Observable<Void>
    func observeSceneUpdates() -> Observable<Void>
}

final class ListsEventsManagerImpl: ListsEventsManager {
    
    private var subjects: [Id: BehaviorRelay<Int>] = [:]
    private let syncedQueue = DispatchQueue(label: "EventsPrivateQueue", attributes: .concurrent)
    
    private let channelUpdatesSubject = BehaviorRelay(value: ())
    private let groupUpdatesSubject = BehaviorRelay(value: ())
    private let sceneUpdatesSubject = BehaviorRelay(value: ())
    
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func emitSceneChange(sceneId: Int) {
        let subject = getSubjectForScene(sceneId: sceneId)
        subject.accept(subject.value + 1)
    }
    
    func emitChannelChange(remoteId: Int) {
        let subject = getSubjectForChannel(channelId: remoteId)
        subject.accept(subject.value + 1)
    }
    
    func emitGroupChange(remoteId: Int) {
        let subject = getSubjectForGroup(groupId: remoteId)
        subject.accept(subject.value + 1)
    }
    
    func emitChannelUpdate() {
        channelUpdatesSubject.accept(())
    }
    
    func emitGroupUpdate() {
        groupUpdatesSubject.accept(())
    }
    
    func emitSceneUpdate() {
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
    
    func observeChannelUpdates() -> Observable<Void> { channelUpdatesSubject.asObservable() }
    
    func observeGroupUpdates() -> Observable<Void> { groupUpdatesSubject.asObservable() }
    
    func observeSceneUpdates() -> Observable<Void> { sceneUpdatesSubject.asObservable() }
    
    private func getSubjectForScene(sceneId: Int) -> BehaviorRelay<Int> {
        return syncedQueue.sync(execute: {
            getSubject(id: sceneId, type: .scene)
        })
    }
    
    private func getSubjectForChannel(channelId: Int) -> BehaviorRelay<Int> {
        return syncedQueue.sync(execute: {
            getSubject(id: channelId, type: .channel)
        })
    }
    
    private func getSubjectForGroup(groupId: Int) -> BehaviorRelay<Int> {
        return syncedQueue.sync(execute: {
            getSubject(id: groupId, type: .group)
        })
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
