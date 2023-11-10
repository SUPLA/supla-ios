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

final class UpdateGroupIconRelationsUseCase {
    
    @Singleton<UserIconRepository> private var userIconRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<UpdateEventsManager> private var updateEventsManager
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke() {
        do {
            try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    let request = SAChannelGroup.fetchRequest()
                        .filtered(by: NSPredicate(format: "((usericon_id <> 0 AND usericon = nil) OR (usericon != nil AND usericon.remote_id != usericon_id)) AND profile = %@", profile))
                        .ordered(by: "remote_id")
                    return self.groupRepository.query(request)
                }
                .flatMapFirst { Observable.from($0) }
                .flatMap { group in
                    if (group.usericon_id != 0) {
                        return self.updateRelation(group: group)
                    } else if(group.usericon != nil) {
                        return self.removeRelation(group: group)
                    } else {
                        return Observable.just(())
                    }
                }
                .toBlocking()
                .first()
            
        } catch {
            NSLog("Groups icons update failed with error \(error)")
        }
    }
    
    private func updateRelation(group: SAChannelGroup) -> Observable<Void> {
        self.userIconRepository.getIcon(for: group.profile, withId: group.usericon_id)
            .flatMapFirst { icon in
                if (icon != group.usericon) {
                    group.usericon = icon
                    self.updateEventsManager.emitGroupUpdate(remoteId: Int(group.remote_id))
                    return self.userIconRepository.save()
                } else {
                    return Observable.just(())
                }
            }
    }
    
    private func removeRelation(group: SAChannelGroup) -> Observable<Void> {
        group.usericon = nil
        self.updateEventsManager.emitGroupUpdate(remoteId: Int(group.remote_id))
        return self.groupRepository.save()
    }
}
