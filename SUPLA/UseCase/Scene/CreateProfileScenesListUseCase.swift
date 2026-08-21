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

struct CreateProfileScenesList {
    protocol UseCase {
        func invoke(filter: String?) -> Observable<[MainListItem]>
    }

    final class Implementation: UseCase {
        @Singleton<SceneRepository> private var sceneRepository
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SceneToMainListItem.UseCase> private var sceneToMainListItemUseCase

        func invoke(filter: String?) -> Observable<[MainListItem]> {
            return profileRepository
                .getActiveProfile()
                .flatMapFirst { self.sceneRepository.getAllVisibleScenes(forProfile: $0) }
                .map { self.toList($0, filter: filter) }
        }

        private func toList(_ scenes: [SAScene], filter: String?) -> [MainListItem] {
            guard !scenes.isEmpty else {
                return []
            }

            var items = [MainListItem]()
            var displayedLocation: _SALocation?
            let inSearch = MainListFilter.isSearchable(filter)

            for scene in scenes {
                guard let location = scene.location else { continue }

                let mappingLocation = displayedLocation?.caption == location.caption ? displayedLocation! : location
                let item = sceneToMainListItemUseCase.invoke(scene, location: mappingLocation)
                if (inSearch && !itemMatches(item, location: location, filter: filter)) {
                    continue
                }

                if (displayedLocation?.location_id != location.location_id) {
                    if (displayedLocation == nil || displayedLocation?.caption != location.caption) {
                        displayedLocation = location
                        items.append(location.sceneListItem(inSearch: inSearch))
                    }
                }

                if let displayedLocation, inSearch || !displayedLocation.isCollapsed(flag: .scene) {
                    items.append(item)
                }
            }

            return items
        }

        private func itemMatches(_ item: MainListItem, location: _SALocation, filter: String?) -> Bool {
            guard let filter else { return true }

            return MainListFilter.matches(item, filter: filter)
                || MainListFilter.matches(location.caption, filter: filter)
        }
    }
}

extension CreateProfileScenesList.UseCase {
    func invoke() -> Observable<[MainListItem]> {
        invoke(filter: nil)
    }
}

private extension _SALocation {
    func sceneListItem(inSearch: Bool) -> MainListItem {
        .location(
            LocationListItem(
                remoteId: location_id?.int32Value ?? 0,
                profileId: profile.id,
                userCaption: caption ?? "",
                collapsed: inSearch ? false : isCollapsed(flag: .scene)
            )
        )
    }
}
