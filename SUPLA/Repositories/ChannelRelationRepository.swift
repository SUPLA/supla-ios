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
import SharedCore

protocol ChannelRelationRepository: RepositoryProtocol, RemoveHiddenChannelsUseCaseImpl.Deletable where T == SAChannelRelation {
    func getRelation(for profile: AuthProfileItem, with channelId: Int32, with parentId: Int32, and relationType: ChannelRelationType) -> Observable<SAChannelRelation>
    func getAllRelations(for profile: AuthProfileItem) -> Observable<[SAChannelRelation]>
    func getAllRelations(for profile: AuthProfileItem, with parentId: Int32) -> Observable<[SAChannelRelation]>
    func deleteRemovableRelations(for profile: AuthProfileItem) -> Observable<Void>
    func getParentsMap(for profile: AuthProfileItem) -> Observable<[Int32: [SAChannelRelation]]>
}

final class ChannelRelationRepositoryImpl: Repository<SAChannelRelation>, ChannelRelationRepository {
    
    func getRelation(
        for profile: AuthProfileItem,
        with channelId: Int32,
        with parentId: Int32,
        and relationType: ChannelRelationType
    ) -> Observable<SAChannelRelation> {
        
        let predicate = NSPredicate(
            format: "profile = %@ AND channel_id = %i AND parent_id = %i AND channel_relation_type = %i",
            profile, channelId, parentId, relationType.value
        )
        
        return queryItem(predicate).compactMap { $0 }
    }
    
    func getAllRelations(for profile: AuthProfileItem) -> Observable<[SAChannelRelation]> {
        let request = SAChannelRelation.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@", profile))
            .ordered(by: "channel_id")
        
        return query(request)
    }
    
    func getAllRelations(for profile: AuthProfileItem, with parentId: Int32) -> Observable<[SAChannelRelation]> {
        let request = SAChannelRelation.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@ AND parent_id = %i", profile, parentId))
            .ordered(by: "channel_id")
        
        return query(request)
    }
    
    func deleteRemovableRelations(for profile: AuthProfileItem) -> Observable<Void> {
        let request = SAChannelRelation.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@ AND delete_flag = YES", profile))
            .ordered(by: "channel_id")
        
        return deleteAll(request)
    }
    
    func getParentsMap(for profile: AuthProfileItem) -> Observable<[Int32: [SAChannelRelation]]> {
        return getAllRelations(for: profile)
            .map { relations in
                var map: [Int32: [SAChannelRelation]] = [:]
                relations.forEach {
                    var children = map[$0.parent_id] ?? []
                    children.append($0)
                    map[$0.parent_id] = children
                }
                return map
            }
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
        let context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext
        context.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SAChannelRelation")
            fetch.predicate = NSPredicate(format: "(channel_id = %d OR parent_id = %d) AND profile.id = %d", remoteId, remoteId, profile.id)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            if (try? context.execute(request)) != nil {
                try? context.save()
            }
        }
    }
}
