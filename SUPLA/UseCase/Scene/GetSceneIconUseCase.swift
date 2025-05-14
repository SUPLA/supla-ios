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

protocol GetSceneIconUseCase {
    func invoke(_ scene: SAScene) -> IconResult
}

final class GetSceneIconUseCaseImpl: GetSceneIconUseCase {
    @Singleton<GlobalSettings> private var settings
    @Singleton<UserIcons.UseCase> private var userIconsUseCase

    func invoke(_ scene: SAScene) -> IconResult {
        if scene.usericon_id != 0, let profileId = scene.profile?.id {
            let darkMode = settings.darkMode == .always || (settings.darkMode == .auto && UITraitCollection.current.userInterfaceStyle == .dark)

            if (scene.usericon_id != 0),
               let profileId = scene.profile?.id
            {
                return .userIcon(profileId: profileId, iconId: scene.usericon_id, type: .icon1, defaultName: "scene_0")
            } else {
                return .suplaIcon(name: "scene_0")
            }
        } else if scene.alticon < 20 {
            return .suplaIcon(name: "scene_\(scene.alticon)")
        } else {
            return .suplaIcon(name: "scene_0")
        }
    }
}
