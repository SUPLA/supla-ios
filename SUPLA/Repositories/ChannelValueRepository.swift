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

protocol ChannelValueRepository: RepositoryProtocol, RemoveHiddenChannelsUseCaseImpl.Deletable where T == SAChannelValue {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
    func getChannelValue(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannelValue>
}

final class ChannelValueRepositoryImpl: Repository<SAChannelValue>, ChannelValueRepository {
    
    func getChannelValue(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannelValue> {
        queryItem(NSPredicate(format: "channel_id = %i AND profile = %@", remoteId, profile))
            .compactMap { $0 }
    }
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAChannelValue.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
        let context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext
        context.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SAChannelValue")
            fetch.predicate = NSPredicate(format: "channel_id = %d AND profile.id = %d", remoteId, profile.id)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            if (try? context.execute(request)) != nil {
                try? context.save()
            }
        }
    }
}
