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

@objc
class CoreDataManager: NSObject {
    
    private let storeType: String
    
    @objc
    lazy var persistntContainer: NSPersistentContainer! = {
        let container = NSPersistentContainer(name: "SUPLA")
        let description = container.persistentStoreDescriptions.first
        description?.url = SAApp.applicationDocumentsDirectory().appendingPathComponent("SUPLA_DB14.sqlite")
        description?.shouldInferMappingModelAutomatically = false
        description?.shouldMigrateStoreAutomatically = false
        description?.type = storeType
        
        return container
    }()
    
    @objc
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistntContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    @objc
    lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistntContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        return context
    }()
    
    @objc
    static let shared = CoreDataManager()
    
    init(storeType: String = NSSQLiteStoreType) {
        self.storeType = storeType
    }
    
    @objc func setup(completion: @escaping () -> Void) {
        loadPersistentStore {
            completion()
        }
    }
    
    private func loadPersistentStore(completion: @escaping () -> Void) {
        self.persistntContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("Not able to load store \(error)")
            }
            
            completion()
        }
    }
}
