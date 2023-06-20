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

final class UpdateSceneUseCase {
    
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<LocationRepository> private var locationRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ListsEventsManager> private var listsEventsManager
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(suplaScene: TSC_SuplaScene) -> Bool {
        var changed = false
        
        do {
            changed = try locationRepository
                .getLocation(remoteId: Int(suplaScene.LocationId))
                .flatMapFirst { location in
                    self.sceneRepository
                        .getScene(remoteId: Int(suplaScene.Id))
                        .ifEmpty(switchTo: self.createScene(remoteId: suplaScene.Id))
                        .map { scene in (location, scene) }
                }
                .map { tuple in self.updateScene(scene: tuple.1, suplaScene: suplaScene, location: tuple.0)}
                .flatMapFirst { tuple in
                    if (tuple.0) {
                        return self.sceneRepository.save(tuple.1).map { true }
                    }
                    
                    return Observable.just(tuple.0)
                }
                .toBlocking()
                .first() ?? false
            
            if (changed) {
                listsEventsManager.emitSceneChange(sceneId: Int(suplaScene.Id))
            }
            
        } catch {
            changed = false
        }
        
        return changed
    }
    
    private func createScene(remoteId: Int32) -> Observable<SAScene> {
        return sceneRepository.create()
            .flatMapFirst { scene in
                self.profileRepository.getActiveProfile()
                    .map { profile in
                        scene.sceneId = remoteId
                        scene.profile = profile
                        return scene
                    }
            }
    }
    
    private func updateScene(scene: SAScene, suplaScene: TSC_SuplaScene, location: _SALocation) -> (Bool, SAScene) {
        var changed = false
        
        let caption = String.fromC(suplaScene.Caption)
        if (scene.caption != caption) {
            scene.caption = caption
            changed = true
        }
        
        if (scene.location != location) {
            scene.location = location
            changed = true
        }
        
        if (scene.usericon_id != suplaScene.UserIcon) {
            scene.usericon_id = suplaScene.UserIcon
            changed = true
        }
        
        if (scene.alticon != suplaScene.AltIcon) {
            scene.alticon = suplaScene.AltIcon
            changed = true
        }
        
        if (scene.visible != 1) {
            scene.visible = 1
            changed = true
        }
        
        return (changed, scene)
    }
}
