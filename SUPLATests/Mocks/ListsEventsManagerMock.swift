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

@testable import SUPLA

final class ListsEventsManagerMock: ListsEventsManager {
    
    var observeSceneObservable: Observable<SAScene> = Observable.empty()
    var observeSceneSceneIdArray: [Int] = []
    func observeScene(sceneId: Int) -> Observable<SAScene> {
        observeSceneSceneIdArray.append(sceneId)
        return observeSceneObservable
    }
    
    var observeChannelObservable: Observable<SAChannel> = Observable.empty()
    var observeChannelRemoteIdArray: [Int] = []
    func observeChannel(remoteId: Int) -> Observable<SAChannel> {
        observeChannelRemoteIdArray.append(remoteId)
        return observeChannelObservable
    }
    
    var observeGroupObservable: Observable<SAChannelGroup> = Observable.empty()
    var observeGroupRemoteIdArray: [Int] = []
    func observeGroup(remoteId: Int) -> Observable<SAChannelGroup> {
        observeGroupRemoteIdArray.append(remoteId)
        return observeGroupObservable
    }
    
    var observeChannelWithChildrenParameters: [Int] = []
    var observeChannelWithChildrenReturns: Observable<ChannelWithChildren> = Observable.empty()
    func observeChannelWithChildren(remoteId: Int) -> Observable<ChannelWithChildren> {
        observeChannelWithChildrenParameters.append(remoteId)
        return observeChannelWithChildrenReturns
    }
    
    var observeChannelUpdatesObservable: Observable<Void> = Observable.empty()
    func observeChannelUpdates() -> Observable<Void> {
        return observeChannelUpdatesObservable
    }
    
    var observeGroupUpdatesObservable: Observable<Void> = Observable.empty()
    func observeGroupUpdates() -> Observable<Void> {
        return observeGroupUpdatesObservable
    }
    
    var observeSceneUpdatesObservable: Observable<Void> = Observable.empty()
    func observeSceneUpdates() -> Observable<Void> {
        return observeSceneUpdatesObservable
    }
    
    var emitSceneChangeSceneIdArray: [Int] = []
    func emitSceneChange(sceneId: Int) {
        emitSceneChangeSceneIdArray.append(sceneId)
    }
    
    var emitChannelChangeRemoteIdArray: [Int] = []
    func emitChannelChange(remoteId: Int) {
        emitChannelChangeRemoteIdArray.append(remoteId)
    }
    
    var emitGroupChangeRemoteIdArray: [Int] = []
    func emitGroupChange(remoteId: Int) {
        emitGroupChangeRemoteIdArray.append(remoteId)
    }
    
    var emitChannelUpdateCounter = 0
    func emitChannelUpdate() {
        emitChannelUpdateCounter += 1
    }
    
    var emitGroupUpdateCounter = 0
    func emitGroupUpdate() {
        emitGroupUpdateCounter += 1
    }
    
    var emitSceneUpdateCounter = 0
    func emitSceneUpdate() {
        emitSceneUpdateCounter += 1
    }
}
