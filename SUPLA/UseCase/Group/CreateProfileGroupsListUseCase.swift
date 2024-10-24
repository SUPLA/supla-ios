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

protocol CreateProfileGroupsListUseCase {
    func invoke() -> Observable<[List]>
}

final class CreateProfileGroupsListUseCaseImpl: CreateProfileGroupsListUseCase {
    
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke() -> Observable<[List]> {
        return profileRepository
            .getActiveProfile()
            .flatMapFirst { self.groupRepository.getAllVisibleGroups(forProfile: $0) }
            .map { self.toList($0) }
    }
    
    private func toList(_ channels: [SAChannelGroup]) -> [List] {
        if (channels.isEmpty) {
            return [.list(items: [])]
        }
        
        var lastLocation: _SALocation = channels[0].location!
        var items = [ListItem]()
        items.append(.location(location: lastLocation))
        
        for channel in channels {
            if (lastLocation.caption != channel.location!.caption) {
                items.append(.location(location: channel.location!))
                lastLocation = channel.location!
            }
            
            if (!lastLocation.isCollapsed(flag: .group)) {
                items.append(.channelBase(channelBase: channel, children: []))
            }
        }
        
        return [.list(items: items)]
    }
}
