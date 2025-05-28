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
    
protocol CarPlayItemRepository: RepositoryProtocol where T == SACarPlayItem {
    func findAll() -> Observable<[SACarPlayItem]>
    func findMaxOrder() -> Observable<Int32>
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

final class CarPlayItemRepositoryImpl: Repository<SACarPlayItem>, CarPlayItemRepository {
    
    func findAll() -> Observable<[SACarPlayItem]> {
        return query(SACarPlayItem.fetchRequest().ordered(by: "order"))
    }
    
    func findMaxOrder() -> Observable<Int32> {
        let request = SACarPlayItem.fetchRequest()
            .ordered(by: "order", ascending: false)
        request.fetchLimit = 1
        
        return query(request).map { $0.first?.order ?? 0 }
    }
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SACarPlayItem.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
