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

struct CreateProfileGroupsList {
    protocol UseCase {
        func invoke() -> Observable<[MainListItem]>
    }

    final class Implementation: UseCase {
        @Singleton<GroupRepository> private var groupRepository
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<GroupToMainListItem.UseCase> private var groupToMainListItemUseCase

        func invoke() -> Observable<[MainListItem]> {
            profileRepository
                .getActiveProfile()
                .flatMapFirst { self.groupRepository.getAllVisibleGroups(forProfile: $0) }
                .map { self.toList($0) }
        }

        private func toList(_ groups: [SAChannelGroup]) -> [MainListItem] {
            guard let firstGroup = groups.first, var lastLocation = firstGroup.location else {
                return []
            }

            var items = [MainListItem]()
            items.append(lastLocation.groupListItem)

            for group in groups {
                guard let location = group.location else { continue }

                if (lastLocation.caption != location.caption) {
                    lastLocation = location
                    items.append(lastLocation.groupListItem)
                }

                if (!lastLocation.isCollapsed(flag: .group)) {
                    items.append(groupToMainListItemUseCase.invoke(group, location: lastLocation))
                }
            }

            return items
        }
    }
}

private extension _SALocation {
    var groupListItem: MainListItem {
        .location(
            LocationListItem(
                remoteId: location_id?.int32Value ?? 0,
                profileId: profile.id,
                userCaption: caption ?? "",
                collapsed: isCollapsed(flag: .group)
            )
        )
    }
}
