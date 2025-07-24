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

import CoreData
import Foundation
import RxSwift

protocol ChannelRepository: RepositoryProtocol, CaptionChangeUseCaseImpl.Updater, RemoveHiddenChannelsUseCaseImpl.Deletable where T == SAChannel {
    func getAllVisibleChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]>
    func getAllVisibleChannels(forProfileId profileId: Int32) -> Observable<[SAChannel]>
    func getAllChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]>
    func getAllChannels(forProfile profile: AuthProfileItem, with ids: [Int32]) -> Observable<[SAChannel]>
    func getAllChannels() -> Observable<[SAChannel]>
    func getChannel(_ remoteId: Int32) -> Observable<SAChannel>
    func getChannel(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel>
    func getChannelNullable(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel?>
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
    func getAllVisibleChannels(forProfile profile: AuthProfileItem, inLocation locationCaption: String) -> Observable<[SAChannel]>
    func getAllIcons(for profile: AuthProfileItem) -> Observable<[UserIconData]>
    func getHiddenChannelsSync() -> [SAChannel]
}

class ChannelRepositoryImpl: Repository<SAChannel>, ChannelRepository {
    
    func getAllVisibleChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]> {
        getAllVisibleChannels(forProfileId: profile.id)
    }
    
    func getAllVisibleChannels(forProfileId profileId: Int32) -> Observable<[SAChannel]> {
        let request = SAChannel.fetchRequest()
            .filtered(by: NSPredicate(format: "func > 0 AND visible > 0 AND profile.id = %d", profileId))
        
        let localeAwareCompare = #selector(NSString.localizedStandardCompare)
        request.sortDescriptors = [
            NSSortDescriptor(key: "location.sortOrder", ascending: true),
            NSSortDescriptor(key: "location.caption", ascending: true, selector: localeAwareCompare),
            NSSortDescriptor(key: "position", ascending: true),
            NSSortDescriptor(key: "func", ascending: false),
            NSSortDescriptor(key: "caption", ascending: false, selector: localeAwareCompare)
        ]
        
        return query(request)
    }
    
    func getAllVisibleChannels(forProfile profile: AuthProfileItem, inLocation locationCaption: String) -> Observable<[SAChannel]> {
        let request = SAChannel.fetchRequest()
            .filtered(by: NSPredicate(format: "func > 0 AND visible > 0 AND profile = %@ AND location.caption = %@", profile, locationCaption))
        
        let localeAwareCompare = #selector(NSString.localizedStandardCompare)
        request.sortDescriptors = [
            NSSortDescriptor(key: "location.sortOrder", ascending: true),
            NSSortDescriptor(key: "location.caption", ascending: true, selector: localeAwareCompare),
            NSSortDescriptor(key: "position", ascending: true),
            NSSortDescriptor(key: "func", ascending: false),
            NSSortDescriptor(key: "caption", ascending: false, selector: localeAwareCompare)
        ]
        
        return query(request)
    }
    
    func getAllChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]> {
        let request = SAChannel.fetchRequest()
            .filtered(by: NSPredicate(format: "func > 0 AND visible > 0 AND profile = %@", profile))
            .ordered(by: "remote_id")
        
        return query(request)
    }
    
    func getAllChannels() -> Observable<[SAChannel]> {
        return query(SAChannel.fetchRequest().ordered(by: "remote_id"))
    }
    
    func getAllChannels(forProfile profile: AuthProfileItem, with ids: [Int32]) -> Observable<[SAChannel]> {
        let request = SAChannel.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@ && remote_id IN %@", profile, ids))
            .ordered(by: "remote_id")
        
        return query(request)
    }
    
    func getChannel(_ remoteId: Int32) -> Observable<SAChannel> {
        queryItem(NSPredicate(format: "remote_id = %d AND profile.isActive = 1", remoteId))
            .compactMap { $0 }
    }
    
    func getChannel(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel> {
        queryItem(NSPredicate(format: "remote_id = %d AND profile = %@", remoteId, profile))
            .compactMap { $0 }
    }
    
    func getChannelNullable(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel?> {
        queryItem(NSPredicate(format: "remote_id = %d AND profile = %@", remoteId, profile))
    }
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAChannel.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
    
    func getAllIcons(for profile: AuthProfileItem) -> Observable<[UserIconData]> {
        let request = SAChannel.fetchRequest()
            .filtered(by: NSPredicate(format: "usericon_id > 0 AND func > 0 AND visible > 0 AND profile = %@", profile))
            .ordered(by: "usericon_id")
        
        return query(request)
            .map { channels in
                var resultSet: Set<UserIconData> = []
                channels.forEach { resultSet.insert(.channelIconData($0.usericon_id, channelId: $0.remote_id)) }
                return Array(resultSet)
            }
    }
    
    func update(caption: String, remoteId: Int32) -> Observable<Void> {
        getChannel(remoteId)
            .map {
                $0.caption = caption
                return $0
            }
            .flatMapFirst { self.save($0) }
    }
    
    func getHiddenChannelsSync() -> [SAChannel] {
        let context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext
        var result: [SAChannel] = []
            
        context.performAndWait {
            let fetchRequest = SAChannel.fetchRequest()
                .filtered(by: NSPredicate(format: "visible = 0 AND profile.isActive = 1"))
            
            if let channels = try? context.fetch(fetchRequest) {
                result.append(contentsOf: channels)
            }
        }
        
        return result
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
        let context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext
        context.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SAChannel")
            fetch.predicate = NSPredicate(format: "remote_id = %d AND profile.id = %d", remoteId, profile.id)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            if (try? context.execute(request)) != nil {
                try? context.save()
            }
        }
    }
}
