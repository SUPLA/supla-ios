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
    
    @Singleton<RuntimeConfig> var config
    
    @objc
    init(context: NSManagedObjectContext) {
        _ctx = context
        super.init()
        
        if (config.activeProfileId == nil) {
            var config = config
            config.activeProfileId = _findCurrentProfile()?.objectID
        }
    }
    
    private func _findCurrentProfile() -> AuthProfileItem? {
        return getAllProfiles().first(where: {$0.isActive})
    }
}

extension MultiAccountProfileManager: ProfileManager {

    func create() -> AuthProfileItem {
        let profile = NSEntityDescription.insertNewObject(forEntityName: "AuthProfileItem", into: _ctx) as! AuthProfileItem
        
        profile.advancedSetup = false
        profile.isActive = true
        profile.authInfo = AuthInfo.empty()
        
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
            deleteAllRelatedData(profileId: id)
            _ctx.delete(p)
            return saveContext("deleting")
        }
        
        return false
    }

    func getCurrentProfile() -> AuthProfileItem? {
        if (config.activeProfileId == nil) {
            return nil
        }
        let profile = read(id: config.activeProfileId!)
        if (profile == nil) {
            fatalError("Profile for ID \(config.activeProfileId!) was not found!")
        }
        return profile!
    }
    
    func getAllProfiles() -> [AuthProfileItem] {
        let req = AuthProfileItem.fetchRequest()
        return try! _ctx.fetch(req)
    }

    func activateProfile(id: ProfileID, force: Bool) -> Bool {
        var config = config
        guard let profile = read(id: id) else { return false }
        if profile.isActive && !force { return false }
        
        let profiles = getAllProfiles()
        profiles.forEach { $0.isActive = $0.objectID == id }
        do {
            try _ctx.save()
        } catch {
            NSLog("Error occured by saving \(error)")
            return false;
        }
        config.activeProfileId = id
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
    
    private func deleteAllRelatedData(profileId: ProfileID) {
        if let profile = read(id: profileId) {
            deleteRelatedData(entity: "SAChannel", profile: profile)
            deleteRelatedData(entity: "SAChannelExtendedValue", profile: profile)
            deleteRelatedData(entity: "SAChannelGroup", profile: profile)
            deleteRelatedData(entity: "SAChannelValue", profile: profile)
            deleteRelatedData(entity: "SAElectricityMeasurementItem", profile: profile)
            deleteRelatedData(entity: "SAImpulseCounterMeasurementItem", profile: profile)
            deleteRelatedData(entity: "SALocation", profile: profile)
            deleteRelatedData(entity: "SAScene", profile: profile)
            deleteRelatedData(entity: "SATemperatureMeasurementItem", profile: profile)
            deleteRelatedData(entity: "SATempHumidityMeasurementItem", profile: profile)
            deleteRelatedData(entity: "SAUserIcon", profile: profile)
            deleteRelatedData(entity: "SAThermostatMeasurementItem", profile: profile)
        }
    }
    
    private func deleteRelatedData(entity: String, profile: AuthProfileItem) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.predicate = NSPredicate(format: "profile = %@", profile)
        
        do {
            let results = try _ctx.fetch(request)
            if (results.count == 0) {
                return
            }
            for item in results as! [NSManagedObject] {
                _ctx.delete(item)
            }
        } catch {
            NSLog("Could not remove items from \(entity) for profile \(profile) because: \(error)")
            // do nothing
        }
    }
}
