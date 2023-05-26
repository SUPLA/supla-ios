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

extension Reactive where Base: NSManagedObjectContext {
    
    func entities<T: NSFetchRequestResult>(fetchRequest: NSFetchRequest<T>,
                  sectionNameKeyPath: String? = nil,
                  cacheName: String? = nil) -> Observable<[T]> {
        return Observable.create { observer in
            
            let observerAdapter = FetchedResultsControllerEntityObserver(observer: observer, fetchRequest: fetchRequest, managedObjectContext: self.base, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
            
            return Disposables.create {
                observerAdapter.dispose()
            }
        }
    }
    
    func save() -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.save()
                observer.onNext(())
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    func delete<T: NSManagedObject>(entity: T) -> Observable<Void> {
        return Observable.create { observer in
            self.base.delete(entity)
            observer.onNext(())
            return Disposables.create()
        }.flatMapLatest {
            self.save()
        }
    }

    func first<T: NSFetchRequestResult>(ofType: T.Type = T.self, with predicate: NSPredicate) -> Observable<T?> {
        return Observable.deferred {
            let request = NSFetchRequest<T>(entityName: getEntityName(String(describing: T.self)))
            request.predicate = predicate
            do {
                let result = try self.base.fetch(request).first
                return Observable.just(result)
            } catch {
                return Observable.error(error)
            }
        }
    }
    
    private func getEntityName(_ entityName: String) -> String {
        if (entityName == "_SALocation") {
            return "SALocation"
        }
        
        return entityName
    }
}

extension NSManagedObjectContext {
    func create<T: NSFetchRequestResult>() -> T {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self),
                into: self) as? T else {
            fatalError()
        }
        return entity
    }
}
