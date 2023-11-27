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
import QueryKit

protocol RepositoryProtocol {
    associatedtype T: NSManagedObject
    
    func query(_ request: NSFetchRequest<T>) -> Observable<[T]>
    func queryItem(_ predicate: NSPredicate) -> Observable<T?>
    func queryItem(_ id: NSManagedObjectID) -> Observable<T?>
    func save(_ entity: T) -> Observable<Void>
    func save() -> Observable<Void>
    func delete(_ entity: T) -> Observable<Void>
    func create() -> Observable<T>
}

class Repository<T: NSManagedObject>: RepositoryProtocol {

    lazy var context = { CoreDataManager.shared.backgroundContext }()
    private lazy var scheduler = { ContextScheduler(context: context) }()
    
    func query(_ request: NSFetchRequest<T>) -> Observable<[T]> {
        return context.rx.entities(fetchRequest: request)
            .subscribe(on: scheduler)
    }
    
    func queryItem(_ predicate: NSPredicate) -> Observable<T?> {
        return context.rx.first(ofType: T.self, with: predicate)
            .subscribe(on: scheduler)
    }
    
    func queryItem(_ id: NSManagedObjectID) -> Observable<T?> {
        return context.rx.first(ofType: T.self, with: id)
            .subscribe(on: scheduler)
    }
    
    func count(_ predicate: NSPredicate) -> Observable<Int> {
        return context.rx.count(ofType: T.self, with: predicate)
            .subscribe(on: scheduler)
    }
    
    func save(_ entity: T) -> Observable<Void> {
        return context.rx.save()
            .subscribe(on: scheduler)
    }
    
    func save() -> Observable<Void> {
        return context.rx.save()
            .subscribe(on: scheduler)
    }
    
    func delete(_ entity: T) -> Observable<Void> {
        return context.rx.delete(entity: entity)
            .subscribe(on: scheduler)
    }
    
    func deleteAll(_ request: NSFetchRequest<T>) -> Observable<Void> {
        return context.rx.deleteAll(request: request)
            .subscribe(on: scheduler)
    }
    
    func create() -> Observable<T> {
        return context.rx.create()
            .subscribe(on: scheduler)
    }
    
}
