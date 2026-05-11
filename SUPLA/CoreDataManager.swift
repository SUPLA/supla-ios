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

import CoreData
import Foundation
import RxSwift

@objc
class CoreDataManager: NSObject {
    @Singleton<GlobalSettings> private var settings
    @Singleton<RestoreProfileFromDefaults.UseCase> private var restoreProfileFromDefaultsUseCase
    
    let migrator: CoreDataMigrator
    private let storeType: String
    
    private var tryRecreateAccount = false
    
    private let readinessQueue = DispatchQueue(label: "CoreDataManager.readiness")
    private var isStoreLoaded = false
    private var readinessCallbacks: [(Result<Void, Error>) -> Void] = []
    
    @objc
    lazy var persistentContainer: NSPersistentContainer! = {
        let dbUrl = SAApp.applicationDocumentsDirectory().appendingPathComponent("SUPLA_DB14.sqlite")
        let container = NSPersistentContainer(name: "SUPLA")
        let description = container.persistentStoreDescriptions.first
        description?.url = dbUrl
        description?.shouldInferMappingModelAutomatically = false
        description?.shouldMigrateStoreAutomatically = false
        description?.shouldAddStoreAsynchronously = false
        description?.type = storeType
        
#if DEBUG
        SALog.info("Database path: \(dbUrl.absoluteString)")
#endif
        
        return container
    }()
    
    @objc
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    @objc
    lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        return context
    }()
    
    @objc
    static let shared = CoreDataManager()
    
    init(storeType: String = NSSQLiteStoreType, migrator: CoreDataMigrator = CoreDataMigratorImpl()) {
        self.storeType = storeType
        self.migrator = migrator
    }
    
    @objc func setup(completion: @escaping () -> Void) {
        removeOldDatabases()
        
        ValueTransformer.setValueTransformer(
            GroupTotalValueTransformer(),
            forName: NSValueTransformerName("GroupTotalValueTransformer")
        )
        
        loadPersistentStore {
            completion()
        }
    }
    
    func whenStoreLoaded(_ callback: @escaping (Result<Void, Error>) -> Void) {
        let result = readinessQueue.sync { () -> Result<Void, Error>? in
            if isStoreLoaded {
                return .success(())
            }

            readinessCallbacks.append(callback)
            return nil
        }

        if let result {
            callback(result)
        }
    }

    private func loadPersistentStore(completion: @escaping () -> Void) {
        migrateStoreIfNeeded {
            self.persistentContainer.loadPersistentStores { _, error in
                guard error == nil else {
                    fatalError("Not able to load store \(error!)")
                }
                
                if (self.tryRecreateAccount) {
                    DispatchQueue.global(qos: .userInitiated).async {
                        if (self.restoreProfileFromDefaultsUseCase.invoke()) {
                            self.settings.anyAccountRegistered = true
                        }
                        DispatchQueue.main.async {
                            self.markStoreLoaded()
                            completion()
                        }
                    }
                } else {
                    self.markStoreLoaded()
                    completion()
                }
            }
        }
    }
    
    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard let storeUrl = persistentContainer.persistentStoreDescriptions.first?.url else {
            fatalError("persistentContainer was not set up properly")
        }
        
        if migrator.requiresMigration(at: storeUrl, toVersion: CoreDataMigrationVersion.current) {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self.migrator.migrateStore(at: storeUrl, toVersion: CoreDataMigrationVersion.current)
                } catch {
#if DEBUG
                    fatalError("Migration failed with error \(error)")
#else
                    // If migration fails in production we want to delete the database so the
                    // user is able to create account again
                    self.removeCurrentDatabase()
#endif
                }

                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }
    
    private func markStoreLoaded() {
        let callbacks = readinessQueue.sync {
            isStoreLoaded = true
            let callbacks = readinessCallbacks
            readinessCallbacks.removeAll()
            return callbacks
        }

        callbacks.forEach { $0(.success(())) }
    }

    private func removeCurrentDatabase() {
        do {
            _ = try removeDatabase(with: "SUPLA_DB14.sqlite")
            settings.anyAccountRegistered = false
        } catch {
            fatalError("Could not delete database after migration failure")
        }
    }
    
    private func removeOldDatabases() {
        if let removed = try? removeDatabase(with: "SUPLA_DB.sqlite"), removed {
            tryRecreateAccount = true
        }
        for i in 0 ..< 14 {
            if let removed = try? removeDatabase(with: String(format: "SUPLA_DB%i.sqlite", i)), removed {
                tryRecreateAccount = true
            }
        }
    }
    
    private func removeDatabase(with name: String) throws -> Bool {
        let url = SAApp.applicationDocumentsDirectory().appendingPathComponent(name)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: url.path)) {
            try fileManager.removeItem(atPath: url.path)
            return true
        }
        
        return false
    }
    
    enum StoreError: Error {
        case notLoaded(Error)
    }
}

extension CoreDataManager {
    func rxStoreLoaded() -> Observable<Void> {
        Observable.create { observer in
            self.whenStoreLoaded { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }
}

extension CoreDataManager {
    func waitForStoreLoaded() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.whenStoreLoaded { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
