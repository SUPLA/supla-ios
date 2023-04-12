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

class MultiAccountProfileManager: NSObject {
    
    private let _ctx: NSManagedObjectContext
    
    /**
     Temporairy introduced to solve issue with concurent access to current profile.
     Will be removed with persisntency layer redesign.
     */
    private static var _currentProfileId: ProfileID?
    
    @objc
    init(context: NSManagedObjectContext) {
        _ctx = context
        super.init()
        
        if (MultiAccountProfileManager._currentProfileId == nil) {
            MultiAccountProfileManager._currentProfileId = _findCurrentProfile()?.objectID
        }
    }
    
    private func _findCurrentProfile() -> AuthProfileItem? {
        return getAllProfiles().first(where: {$0.isActive})
    }
}

extension MultiAccountProfileManager: ProfileManager {

    func create() -> AuthProfileItem {
        let profile = NSEntityDescription.insertNewObject(forEntityName: "AuthProfileItem", into: _ctx) as! AuthProfileItem
        try! _ctx.save()
        return profile
    }
    
    func read(id: ProfileID) -> AuthProfileItem? {
        return try? _ctx.existingObject(with: id) as? AuthProfileItem
    }
    
    func update(_ profile: AuthProfileItem) -> Bool {
        if profile.managedObjectContext == _ctx {
            if profile.hasChanges {
                return saveContext("updating")
            } else {
                return true
            }
        } else {
            _ctx.insert(profile)
            return saveContext("updating (by insert)")
        }
    }
    
    func delete(id: ProfileID) -> Bool {
        if let p = read(id: id) {
            _ctx.delete(p)
            return saveContext("deleting")
        }
        
        return false
    }

    func getCurrentProfile() -> AuthProfileItem? {
        if (MultiAccountProfileManager._currentProfileId == nil) {
            return nil
        }
        let profile = read(id: MultiAccountProfileManager._currentProfileId!)
        if (profile == nil) {
            fatalError("Profile for ID \(MultiAccountProfileManager._currentProfileId!) was not found!")
        }
        return profile!
    }
    
    func getAllProfiles() -> [AuthProfileItem] {
        let req = AuthProfileItem.fetchRequest()
        return try! _ctx.fetch(req)
    }

    func activateProfile(id: ProfileID, force: Bool) -> Bool {
        guard let profile = read(id: id) else { return false }
        if profile.isActive && !force { return false }
        
        let profiles = getAllProfiles()
        profiles.forEach { $0.isActive = $0.objectID == id}
        do {
            try _ctx.save()
        } catch {
            NSLog("Error occured by saving \(error)")
            return false;
        }
        MultiAccountProfileManager._currentProfileId = id
        initiateReconnect()
        
        return true
    }
    
    private func initiateReconnect() {
        let app = SAApp.instance()
        let client = SAApp.suplaClient()
        app.cancelAllRestApiClientTasks()
        client.reconnect()
    }

    private func saveContext(_ action: String) -> Bool {
        do {
            try _ctx.save()
        } catch {
            NSLog("Error occured by \(action) '\(error)'")
            return false
        }
        return true
    }
}
