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

final class MagicUpdateGroupsUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelGroupRelationRepository> private var channelGroupRelationRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke() -> [NSNumber] {
        do {
            return try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    let request = SAChannelGroupRelation.fetchRequest()
                        .filtered(by: NSPredicate(format: "visible > 0 AND group != nil AND value != nil AND group.visible > 0 AND profile = %@", profile))
                        .ordered(by: "group_id")
                    
                    return self.channelGroupRelationRepository.query(request)
                }
                .map { relations in self.updateRelations(relations: relations) }
                .flatMapFirst { tuple in
                    if (tuple.0) {
                        return self.channelGroupRelationRepository.save(tuple.2!).map { tuple.1 }
                    }
                    
                    return Observable.just(tuple.1)
                }
                .toBlocking()
                .first() ?? []
        } catch {
            return []
        }
    }
    
    private func updateRelations(relations: [SAChannelGroupRelation]) -> (Bool, [NSNumber], SAChannelGroupRelation?) {
        if (relations.isEmpty) {
            return (false, [], nil)
        }
        
        var save = false
        var result: [NSNumber] = []
        var cgroup: SAChannelGroup? = nil
        for i in 0...relations.count-1 {
            var relation = relations[i]
            if (cgroup == nil) {
                cgroup = relation.group
                cgroup?.resetBuffer()
            }
            
            if (cgroup?.remote_id == relation.group_id) {
                cgroup?.addValue(toBuffer: relation.value!)
            }
            
            if (i < relations.count-1) {
                relation = relations[i+1]
            }
            
            if (i==relations.count-1 || relation.group_id != cgroup?.remote_id) {
                if (cgroup?.diffWithBuffer() == true) {
                    cgroup?.assignBuffer()
                    result.append(NSNumber(value: cgroup!.remote_id))
                    save = true
                }
                cgroup = nil
            }
        }
        
        if (save) {
            return (save, result, relations[0])
        } else {
            return (save, result, nil)
        }
    }
}
