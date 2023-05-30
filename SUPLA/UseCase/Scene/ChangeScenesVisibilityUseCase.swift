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

final class ChangeScenesVisibilityUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SceneRepository> private var sceneRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(from: Int16, to: Int16) -> Bool {
        var changed = false
        do {
            try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    self.sceneRepository.getAllProfileScenes(profile: profile)
                }
                .map { scenes in scenes.filter { $0.visible == from } }
                .flatMapFirst { scenes in
                    var updates: [Observable<Void>] = []
                    scenes.forEach {
                        $0.visible = to
                        changed = true
                        updates.append(self.sceneRepository.save($0))
                    }
                    return Observable.merge(updates)
                }
                .toBlocking()
                .first()
        } catch {
            changed = false
        }
        
        return changed
    }
}
