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

struct CoreDataMigrationStep {
    
    let sourceModel: NSManagedObjectModel
    let destinationModel: NSManagedObjectModel
    let mappingModel: NSMappingModel
    
    // MARK: Init
    
    init(sourceVersion: CoreDataMigrationVersion, destinationVersion: CoreDataMigrationVersion) {
        let sourceModel = NSManagedObjectModel.managedObjectModel(forResource: sourceVersion.rawValue)
        let destinationModel = NSManagedObjectModel.managedObjectModel(forResource: destinationVersion.rawValue)
        
        guard let mappingModel = CoreDataMigrationStep.mappingModel(fromSourceModel: sourceModel, toDestinationModel: destinationModel) else {
            fatalError("Expected modal mapping not present")
        }
        
        self.sourceModel = sourceModel
        self.destinationModel = destinationModel
        self.mappingModel = mappingModel
    }
    
    // MARK: - Mapping
    
    private static func mappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
        guard let customMapping = customMappingModel(fromSourceModel: sourceModel, toDestinationModel: destinationModel) else {
            return inferredMappingModel(fromSourceModel:sourceModel, toDestinationModel: destinationModel)
        }
        
        return customMapping
    }
    
    private static func inferredMappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
        return try? NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
    }
    
    private static func customMappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
        return NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel)
    }
}
