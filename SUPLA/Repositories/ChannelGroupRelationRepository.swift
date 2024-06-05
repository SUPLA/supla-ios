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

protocol ChannelGroupRelationRepository: RepositoryProtocol where T == SAChannelGroupRelation {
    func getAllRelations(for profile: AuthProfileItem) -> Observable<[SAChannelGroupRelation]>
    func getRelation(for profile: AuthProfileItem, groupId: Int32, channelId: Int32) -> Observable<SAChannelGroupRelation>
    func getRelations(for profile: AuthProfileItem, andGroup id: Int32) -> Observable<[SAChannelGroupRelation]>
    func getRelations(forGroup id: Int32) -> Observable<[SAChannelGroupRelation]>
    func getAllVisibleRelationsForActiveProfile() -> Observable<[SAChannelGroupRelation]>
}

final class ChannelGroupRelationRepositoryImpl: Repository<SAChannelGroupRelation>, ChannelGroupRelationRepository {
    
    func getAllRelations(for profile: AuthProfileItem) -> Observable<[SAChannelGroupRelation]> {
        let request = SAChannelGroupRelation.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@", profile))
            .ordered(by: "group_id")
        
        return query(request)
    }
    
    func getRelation(for profile: AuthProfileItem, groupId: Int32, channelId: Int32) -> Observable<SAChannelGroupRelation> {
        let queryString = "group_id = %i AND channel_id = %i AND profile = %@"
        return queryItem(NSPredicate(format: queryString, groupId, channelId, profile))
            .compactMap { $0 }
    }
    
    func getRelations(for profile: AuthProfileItem, andGroup id: Int32) -> Observable<[SAChannelGroupRelation]> {
        let request = SAChannelGroupRelation.fetchRequest()
            .filtered(by: NSPredicate(format: "group_id = %i AND profile = %@ AND visible > 0", id, profile))
            .ordered(by: "group_id")
        
        return query(request)
    }
    
    func getRelations(forGroup id: Int32) -> Observable<[SAChannelGroupRelation]> {
        let request = SAChannelGroupRelation.fetchRequest()
            .filtered(by: NSPredicate(format: "group_id = %i AND profile.isActive = 1", id))
            .ordered(by: "group_id")
        
        return query(request)
    }
    
    func getAllVisibleRelationsForActiveProfile() -> Observable<[SAChannelGroupRelation]> {
        let request = SAChannelGroupRelation.fetchRequest()
            .filtered(by: NSPredicate(format: "visible > 0 AND group != nil AND value != nil AND group.visible > 0 AND profile.isActive = 1"))
            .ordered(by: "group_id")
        
        return query(request)
    }
}
