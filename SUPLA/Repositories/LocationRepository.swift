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

protocol LocationRepository: RepositoryProtocol where T == _SALocation {
    func getLocation(remoteId: Int) -> Observable<_SALocation>
    func getAllLocations(forProfile profile: AuthProfileItem) -> Observable<[_SALocation]>
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

class LocationRepositoryImpl: Repository<_SALocation>, LocationRepository {
    
    func getLocation(remoteId: Int) -> Observable<_SALocation> {
        queryItem(NSPredicate(format: "location_id = %d", remoteId))
            .compactMap { $0 }
    }
    
    func getAllLocations(forProfile profile: AuthProfileItem) -> Observable<[_SALocation]> {
        let request = _SALocation.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@", profile))
            .ordered(by: "sortOrder")
            .ordered(by: "caption", selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        return query(request)
    }

    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(_SALocation.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
