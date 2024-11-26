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
import CoreData
import RxSwift

protocol ProfileRepository: RepositoryProtocol where T == AuthProfileItem {
    func getActiveProfile() -> Observable<AuthProfileItem>
    func getAllProfiles() -> Observable<[AuthProfileItem]>
    func getProfile(withId id: Int32) -> Observable<AuthProfileItem?>
}

final class ProfileRepositoryImpl: Repository<AuthProfileItem>, ProfileRepository {
    
    @Singleton<RuntimeConfig> var config
    
    func getActiveProfile() -> Observable<AuthProfileItem> {
        return getAllProfiles()
            .map { items in
                for item in items {
                    if (item.isActive) {
                        return item
                    }
                }
                return nil
            }
            .compactMap { $0 }
    }
    
    func getAllProfiles() -> Observable<[AuthProfileItem]> {
        let request = AuthProfileItem.fetchRequest()
            .ordered(by: "name")
        
        return query(request)
    }
    
    func getProfile(withId id: Int32) -> Observable<AuthProfileItem?> {
        return queryItem(NSPredicate(format: "id = %d", id))
    }
}
