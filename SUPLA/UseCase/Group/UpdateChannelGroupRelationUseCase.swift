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

final class UpdateChannelGroupRelationUseCase {
    
    @Singleton<ChannelGroupRelationRepository> private var channelGroupRelationRepository
    @Singleton<ChannelValueRepository> private var channelValueRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(suplaGroupRelation: TSC_SuplaChannelGroupRelation) -> Bool {
        var changed = false
        
        do {
            changed = try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    self.channelGroupRelationRepository
                        .getRelation(for: profile, groupId: suplaGroupRelation.ChannelGroupID, channelId: suplaGroupRelation.ChannelID)
                        .ifEmpty(switchTo: self.createRelation(groupId: suplaGroupRelation.ChannelGroupID, channelId: suplaGroupRelation.ChannelID))
                        .map { relation in
                            if (relation.setItemVisible(1)) {
                                changed = true
                            }
                            
                            if (relation.value != nil && relation.value?.channel_id != relation.channel_id) {
                                relation.value = nil
                                changed = true
                            }
                            if (relation.group != nil && relation.group?.remote_id != relation.group_id) {
                                relation.group = nil
                                changed = true
                            }
                            
                            return relation
                        }
                        .flatMapFirst { (relation: SAChannelGroupRelation) in
                            if (relation.value == nil) {
                                return self.channelValueRepository.getChannelValue(for: profile, with: relation.channel_id)
                                    .map { channel in
                                        relation.value = channel
                                        if (relation.value != nil) {
                                            changed = true
                                        }
                                        
                                        return relation
                                    }
                            }
                            
                            return Observable.just(relation)
                        }
                        .flatMapFirst { (relation: SAChannelGroupRelation) in
                            if (relation.group == nil) {
                                return self.groupRepository.getGroup(for: profile, with: relation.group_id)
                                    .map { group in
                                        relation.group = group
                                        if (relation.group != nil) {
                                            changed = true
                                        }
                                        
                                        return relation
                                    }
                            }
                            
                            return Observable.just(relation)
                        }
                }
                .flatMapFirst { relation in
                    if (changed) {
                        return self.channelGroupRelationRepository.save(relation).map { true }
                    }
                    
                    return Observable.just(false)
                }
                .toBlocking()
                .first() ?? false
        } catch {
            changed = false
        }
        
        return changed
    }
    
    private func createRelation(groupId: Int32, channelId: Int32) -> Observable<SAChannelGroupRelation> {
        return channelGroupRelationRepository.create()
            .flatMapFirst { relation in
                self.profileRepository.getActiveProfile()
                    .map { profile in
                        relation.group_id = groupId
                        relation.channel_id = channelId
                        relation.profile = profile
                        
                        return relation
                    }
            }
    }
}
