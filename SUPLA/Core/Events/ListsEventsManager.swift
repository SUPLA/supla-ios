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
}

protocol ListsEventsManager: ListsEventsManagerEmitter {
    func observeScene(sceneId: Int) -> Observable<SAScene>
    func observeChannel(remoteId: Int) -> Observable<SAChannel>
    func observeGroup(remoteId: Int) -> Observable<SAChannelGroup>
    
}

final class ListsEventsManagerImpl: ListsEventsManager {
    
    private var subjects: [Id: BehaviorRelay<Int>] = [:]
    private let syncedQueue = DispatchQueue(label: "EventsPrivateQueue", attributes: .concurrent)
    
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GroupRepository> private var groupRepository
    
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
    
    func observeScene(sceneId: Int) -> Observable<SAScene> {
        let subject = getSubjectForScene(sceneId: sceneId)
        return subject.flatMap { _ in
            self.sceneRepository.getScene(remoteId: sceneId)
        }
    }
    
    func observeChannel(remoteId: Int) -> Observable<SAChannel> {
        return getSubjectForScene(sceneId: remoteId)
            .flatMap { _ in self.channelRepository.getChannel(remoteId: remoteId) }
    }
    
    func observeGroup(remoteId: Int) -> Observable<SAChannelGroup> {
        return getSubjectForScene(sceneId: remoteId)
            .flatMap { _ in self.groupRepository.getGroup(remoteId: remoteId) }
    }
    
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
