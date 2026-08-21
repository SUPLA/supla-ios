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

struct SceneToMainListItem {
    protocol UseCase {
        func invoke(_ scene: SAScene) -> MainListItem?
        func invoke(_ scene: SAScene, location: _SALocation) -> MainListItem
    }

    final class Implementation: UseCase {
        @Singleton<GetSceneIconUseCase> private var getSceneIconUseCase

        func invoke(_ scene: SAScene) -> MainListItem? {
            guard let location = scene.location else { return nil }
            return invoke(scene, location: location)
        }

        func invoke(_ scene: SAScene, location: _SALocation) -> MainListItem {
            .scene(
                SceneListItem(
                    remoteId: scene.sceneId,
                    profileId: scene.profile?.id ?? 0,
                    userCaption: scene.caption ?? "",
                    locationCaption: location.caption ?? "",
                    locationId: Int(location.location_id?.int32Value ?? 0),
                    status: .scene,
                    icon: getSceneIconUseCase.invoke(scene),
                    estimatedTimerEndDate: scene.estimatedEndDate,
                    leftButtonTitle: Strings.Scenes.ActionButtons.abort,
                    rightButtonTitle: Strings.Scenes.ActionButtons.execute
                )
            )
        }
    }
}
