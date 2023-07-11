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

final class UpdateGroupUseCase {
    
    @Singleton<LocationRepository> private var locationRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ListsEventsManager> private var listsEventsManager
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(suplaGroup: TSC_SuplaChannelGroup_B) -> Bool {
        var changed = false
        
        do {
            changed = try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    self.locationRepository
                        .getLocation(for: profile, with: suplaGroup.LocationID)
                        .flatMapFirst { location in
                            self.groupRepository
                                .getGroup(for: profile, with: suplaGroup.Id)
                                .ifEmpty(switchTo: self.createGroup(remoteId: suplaGroup.Id))
                                .map { scene in (location, scene) }
                        }
                }
                .map { tuple in self.updateGroup(group: tuple.1, suplaGroup: suplaGroup, location: tuple.0) }
                .flatMapFirst { tuple in
                    if (tuple.0) {
                        return self.groupRepository.save(tuple.1).map { true }
                    }
                    
                    return Observable.just(false)
                }
                .toBlocking()
                .first() ?? false
            
            if (changed) {
                listsEventsManager.emitGroupChange(remoteId: Int(suplaGroup.Id))
            }
        } catch {
            changed = false
        }
        
        return changed
    }
    
    private func createGroup(remoteId: Int32) -> Observable<SAChannelGroup> {
        return groupRepository.create()
            .flatMapFirst { group in
                self.profileRepository.getActiveProfile()
                    .map { profile in
                        group.caption = ""
                        group.func = 0
                        group.visible = 1
                        group.alticon = 0
                        group.flags = 0
                        group.online = 0
                        group.total_value = nil
                        group.remote_id = remoteId
                        group.profile = profile
                        
                        return group
                    }
            }
    }
    
    private func updateGroup(group: SAChannelGroup, suplaGroup: TSC_SuplaChannelGroup_B, location: _SALocation) -> (Bool, SAChannelGroup) {
        var changed = false
        
        let caption = String.fromC(suplaGroup.Caption)
        if (group.caption != caption) {
            group.caption = caption
            changed = true
        }
        if (group.setChannelLocation(location)) {
            changed = true
        }
        if (group.setChannelFunction(suplaGroup.Func)) {
            changed = true
        }
        if (group.setItemVisible(1)) {
            changed = true
        }
        if (group.setChannelAltIcon(suplaGroup.AltIcon)) {
            changed = true
        }
        if (group.setLocationId(suplaGroup.LocationID)) {
            changed = true
        }
        if (group.setRemoteId(suplaGroup.Id)) {
            changed = true
        }
        if (group.setUserIconId(suplaGroup.UserIcon)) {
            changed = true
        }
        if (group.setChannelFlags(Int32(suplaGroup.Flags))) {
            changed = true
        }
        
        return (changed, group)
    }
}
