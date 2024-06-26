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

@testable import SUPLA

class BaseRepositoryMock<T: NSManagedObject>: RepositoryProtocol {
    typealias T = T
    
    var queryObservable: Observable<[T]> = Observable.empty()
    func query(_ request: NSFetchRequest<T>) -> Observable<[T]> {
        return queryObservable
    }
    
    var queryItemByPredicateObservable: Observable<T?> = Observable.empty()
    func queryItem(_ predicate: NSPredicate) -> Observable<T?> {
        return queryItemByPredicateObservable
    }
    
    var queryItemByIdObservable: Observable<T?> = Observable.empty()
    func queryItem(_ id: NSManagedObjectID) -> Observable<T?> {
        return queryItemByIdObservable
    }
    
    var saveObservable: Observable<Void> = Observable.empty()
    var saveParameters: [T] = []
    func save(_ entity: T) -> Observable<Void> {
        saveParameters.append(entity)
        return saveObservable
    }
    
    var saveCounter = 0
    func save() -> Observable<Void> {
        saveCounter += 1
        return saveObservable
    }
    
    var deleteParameters: [T] = []
    var deleteObservable: Observable<Void> = Observable.empty()
    func delete(_ entity: T) -> Observable<Void> {
        deleteParameters.append(entity)
        return deleteObservable
    }
    
    var createObservable: Observable<T> = Observable.empty()
    var createCounter = 0
    func create() -> Observable<T> {
        createCounter += 1
        return createObservable
    }
}
