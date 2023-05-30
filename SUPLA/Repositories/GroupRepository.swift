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

protocol GroupRepository: RepositoryProtocol where T == SAChannelGroup {
    func getAllProfileVisibleGroups(profile: AuthProfileItem) -> Observable<[SAChannelGroup]>
    func getAllProfileGroups(profile: AuthProfileItem) -> Observable<[SAChannelGroup]>
    func getGroup(remoteId: Int) -> Observable<SAChannelGroup>
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

class GroupRepositoryImpl: Repository<SAChannelGroup>, GroupRepository {
    
    func getAllProfileVisibleGroups(profile: AuthProfileItem) -> Observable<[SAChannelGroup]> {
        let request = SAChannelGroup.fetchRequest()
            .filtered(by: NSPredicate(format: "func > 0 AND visible > 0 AND profile == %@", profile))
        
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
    
    func getAllProfileGroups(profile: AuthProfileItem) -> Observable<[SAChannelGroup]> {
        let request = SAChannelGroup.fetchRequest()
            .filtered(by: NSPredicate(format: "profile == %@", profile))
            .ordered(by: "remote_id")
        
        return query(request)
    }
    
    func getGroup(remoteId: Int) -> Observable<SAChannelGroup> {
        queryItem(NSPredicate(format: "remote_id = %d", remoteId))
            .compactMap { $0 }
    }
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAChannelGroup.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
