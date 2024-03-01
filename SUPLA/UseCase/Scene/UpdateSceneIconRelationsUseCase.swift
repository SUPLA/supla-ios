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

final class UpdateSceneIconRelationsUseCase {
    
    @Singleton<UserIconRepository> private var userIconRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<UpdateEventsManager> private var updateEventsManager
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke() {
        do {
            try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    let request = SAScene.fetchRequest()
                        .filtered(by: NSPredicate(format: "((usericon_id <> 0 AND usericon = nil) OR (usericon != nil AND usericon.remote_id != usericon_id)) AND profile = %@", profile))
                        .ordered(by: "sceneId")
                    return self.sceneRepository.query(request)
                }
                .flatMapFirst { Observable.from($0) }
                .flatMap { scene in
                    if (scene.usericon_id != 0) {
                        return self.updateRelation(scene: scene)
                    } else if(scene.usericon != nil) {
                        return self.removeRelation(scene: scene)
                    } else {
                        return Observable.just(())
                    }
                }
                .toBlocking()
                .first()
            
        } catch {
            SALog.error("Scenes icons update failed with error \(error)")
        }
    }
    
    private func updateRelation(scene: SAScene) -> Observable<Void> {
        self.userIconRepository.getIcon(for: scene.profile!, withId: scene.usericon_id)
            .flatMapFirst { icon in
                if (icon != scene.usericon) {
                    scene.usericon = icon
                    self.updateEventsManager.emitSceneUpdate(sceneId: Int(scene.sceneId))
                    return self.userIconRepository.save()
                } else {
                    return Observable.just(())
                }
            }
    }
    
    private func removeRelation(scene: SAScene) -> Observable<Void> {
        scene.usericon = nil
        self.updateEventsManager.emitSceneUpdate(sceneId: Int(scene.sceneId))
        return self.sceneRepository.save()
    }
}

