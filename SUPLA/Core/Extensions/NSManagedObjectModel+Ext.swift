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

extension NSManagedObjectModel {
    
    static func managedObjectModel(forResource resource: String) -> NSManagedObjectModel {
        let mainBundle = Bundle.main
        let subdirectory = "SUPLA.momd"
        
        var omoURL: URL?
        if #available(iOS 11, *) {
            omoURL = mainBundle.url(forResource: resource, withExtension: "omo", subdirectory: subdirectory) // optimized model file
        }
        let momURL = mainBundle.url(forResource: resource, withExtension: "mom", subdirectory: subdirectory)
        
        guard let url = omoURL ?? momURL else {
            fatalError("Unable to find model in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Unable to load model in bundle")
        }
        
        return model
    }
    
    static func compatibleModelForStoreMetadata(_ metadata: [String : Any]) -> NSManagedObjectModel? {
        let mainBundle = Bundle.main
        return NSManagedObjectModel.mergedModel(from: [mainBundle], forStoreMetadata: metadata)
    }
}
