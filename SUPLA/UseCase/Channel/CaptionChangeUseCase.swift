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

protocol CaptionChangeUseCase {
    func invoke(caption: String, type: CaptionChangeUseCaseImpl.CaptionType, remoteId: Int32) -> Completable
}

final class CaptionChangeUseCaseImpl: CaptionChangeUseCase {
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<LocationRepository> private var locationRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<SceneRepository> private var sceneRepository
    
    func invoke(caption: String, type: CaptionType, remoteId: Int32) -> Completable {
        getUpdater(type: type).update(caption: caption, remoteId: remoteId)
            .flatMapCompletable {
                Completable.create { subscriber in
                    if let suplaClient = self.suplaClientProvider.provide() {
                        switch (type) {
                        case .location: suplaClient.setLocationCaption(remoteId, caption: caption)
                        case .channel:
                            suplaClient.setChannelCaption(remoteId, caption: caption)
                            self.updateEventsManager.emitChannelUpdate(remoteId: Int(remoteId))
                        case .group:
                            suplaClient.setChannelGroupCaption(remoteId, caption: caption)
                            self.updateEventsManager.emitGroupUpdate(remoteId: Int(remoteId))
                        case .scene:
                            suplaClient.setSceneCaption(remoteId, caption: caption)
                            self.updateEventsManager.emitSceneUpdate(sceneId: Int(remoteId))
                        }
                    }
                    
                    subscriber(.completed)
                    
                    return Disposables.create()
                }
            }
    }
    
    private func getUpdater(type: CaptionType) -> Updater {
        switch (type) {
        case .location: locationRepository
        case .channel: channelRepository
        case .group: groupRepository
        case .scene: sceneRepository
        }
    }
    
    enum CaptionType {
        case location
        case channel
        case group
        case scene
    }
    
    protocol Updater {
        func update(caption: String, remoteId: Int32) -> Observable<Void>
    }
}
