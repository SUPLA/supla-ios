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

protocol ChannelRepository: RepositoryProtocol where T == SAChannel {
    func getAllVisibleChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]>
    func getAllChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]>
    func getAllChannels(forProfile profile: AuthProfileItem, with ids: [Int32]) -> Observable<[SAChannel]>
    func getChannel(_ remoteId: Int32) -> Observable<SAChannel> 
    func getChannel(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel>
    func getChannelNullable(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel?>
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
    func getAllVisibleChannels(forProfile profile: AuthProfileItem, inLocation locationCaption: String) -> Observable<[SAChannel]>
    func getAllIconIds(for profile: AuthProfileItem) -> Observable<[Int32]>
}

class ChannelRepositoryImpl: Repository<SAChannel>, ChannelRepository {
    
    func getAllVisibleChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]> {
        let request = SAChannel.fetchRequest()
            .filtered(by: NSPredicate(format: "func > 0 AND visible > 0 AND profile = %@", profile))
        
        let localeAwareCompare = #selector(NSString.localizedCaseInsensitiveCompare)
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
        
        let localeAwareCompare = #selector(NSString.localizedCaseInsensitiveCompare)
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
            .filtered(by: NSPredicate(format: "profile = %@", profile))
            .ordered(by: "remote_id")
        
        return query(request)
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
    
    func getAllIconIds(for profile: AuthProfileItem) -> Observable<[Int32]> {
        let request = SAChannel.fetchRequest()
            .filtered(by: NSPredicate(format: "usericon_id > 0 AND func > 0 AND visible > 0 AND profile = %@", profile))
            .ordered(by: "usericon_id")
        
        return query(request)
            .map { channels in
                var resultSet: Set<Int32> = []
                channels.forEach { resultSet.insert($0.usericon_id) }
                return Array(resultSet)
            }
    }
}
