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
    
struct UpdateCarPlayOrder {
    protocol UseCase {
        func invoke(items: [Item]) -> Observable<Void>
    }
    
    final class Implementation: UseCase {
        @Singleton<CarPlayItemRepository> private var carPlayItemRepository
        
        func invoke(items: [Item]) -> Observable<Void> {
            let map = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0.order) })
            
            return carPlayItemRepository.findAll()
                .map { items in
                    for item in items {
                        item.order = map[item.objectID] ?? 0
                    }
                }
                .flatMap { _ in self.carPlayItemRepository.save() }
        }
    }
    
    struct Item {
        var id: NSManagedObjectID
        var order: Int32
    }
}
