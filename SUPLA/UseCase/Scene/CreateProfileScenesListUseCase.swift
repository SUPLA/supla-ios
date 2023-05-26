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

protocol CreateProfileScenesListUseCase {
    func invoke() -> Observable<[List]>
}

final class CreateProfileScenesListUseCaseImpl: CreateProfileScenesListUseCase {
    
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke() -> Observable<[List]> {
        return profileRepository
            .getActiveProfile()
            .compactMap { $0 }
            .flatMapFirst { self.sceneRepository.getAllProfileScenes(profile: $0) }
            .map { self.toList($0) }
    }
    
    private func toList(_ scenes: [SAScene]) -> [List] {
        if (scenes.isEmpty) {
            return []
        }
        
        var lastLocation: _SALocation = scenes[0].location!
        var items = [ListItem]()
        items.append(.location(location: lastLocation))
        
        for scene in scenes {
            if (lastLocation != scene.location) {
                items.append(.location(location: scene.location!))
                lastLocation = scene.location!
            }
            
            if (!lastLocation.isCollapsed(flag: .scene)) {
                items.append(.scene(scene: scene))
            }
        }
        
        return [.list(items: items)]
    }
}
