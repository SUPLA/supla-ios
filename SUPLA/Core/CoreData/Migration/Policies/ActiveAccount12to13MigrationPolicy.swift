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

@objc(ActiveAccount12to13MigrationPolicy)
final class ActiveAccount12to13MigrationPolicy: NSEntityMigrationPolicy {
    
    @Singleton<GlobalSettings> var settings
    
    override func end(_ mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        var settings = settings
        settings.shouldShowNewGestureInfo = true
        
        let context = manager.destinationContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
        let profiles = try context.fetch(request)
        
        profiles.forEach { profile in
            if
                let isActive = profile.value(forKey: "isActive") as? Bool,
                let authInfo = profile.value(forKey: "authInfo") as? AuthInfo {
                
                if (isActive && authInfo.isAuthDataComplete) {
                    settings.anyAccountRegistered = true
                }
            }
        }
        
        // if there is no active account with valid auth data, cleanup table.
        // In older versions there was an empty initial profile created which
        // is not needed anymore.
        if (!settings.anyAccountRegistered) {
            let allRequest = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
            try context.fetch(allRequest).forEach(context.delete)
        }
    }
}
