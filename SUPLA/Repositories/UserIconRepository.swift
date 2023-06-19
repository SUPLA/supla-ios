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

protocol UserIconRepository: RepositoryProtocol where T == SAUserIcon {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
    func getIcon(for profile: AuthProfileItem, withId remoteId: Int32) -> Observable<SAUserIcon>
    func getDownloadedIconIds(for profile: AuthProfileItem) -> Observable<[Int32]>
}

final class UserIconRepositoryImpl: Repository<SAUserIcon>, UserIconRepository {
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAUserIcon.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
    
    func getIcon(for profile: AuthProfileItem, withId remoteId: Int32) -> Observable<SAUserIcon> {
        queryItem(NSPredicate(format: "remote_id = %i AND profile = %@", remoteId, profile))
            .compactMap{ $0 }
    }
    
    func getDownloadedIconIds(for profile: AuthProfileItem) -> Observable<[Int32]> {
        let request = SAUserIcon.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@", profile))
            .ordered(by: "remote_id")
        
        return query(request)
            .map { icons in
                return icons.map { $0.remote_id }
            }
    }
}
