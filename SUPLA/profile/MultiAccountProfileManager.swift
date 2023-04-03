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
            MultiAccountProfileManager._currentProfileId = _findCurrentProfile().objectID
        }
    }
    
    private func _findCurrentProfile() -> AuthProfileItem {
        if let profile = getAllProfiles().first(where: {$0.isActive}) {
            return profile
        } else {
            return makeNewProfile()
        }
    }
}

extension MultiAccountProfileManager: ProfileManager {

    func makeNewProfile() -> AuthProfileItem {
        let profile = NSEntityDescription.insertNewObject(forEntityName: "AuthProfileItem",
                                                          into: _ctx) as! AuthProfileItem
        profile.name = ""
        profile.isActive = true
        profile.advancedSetup = false
        profile.authInfo = AuthInfo(emailAuth: true,
                                    serverAutoDetect: true,
                                    emailAddress: "",
                                    serverForEmail: "",
                                    serverForAccessID: "",
                                    accessID: 0,
                                    accessIDpwd: "")
        try! _ctx.save()
        return profile
    }

    func getCurrentProfile() -> AuthProfileItem {
        if (MultiAccountProfileManager._currentProfileId == nil) {
            fatalError("Current profile ID not set, but expected to be set!")
        }
        let profile = getProfile(id: MultiAccountProfileManager._currentProfileId!)
        if (profile == nil) {
            fatalError("Profile for ID \(MultiAccountProfileManager._currentProfileId!) was not found!")
        }
        return profile!
    }
    
    func updateCurrentProfile(_ profile: AuthProfileItem) {
        // TODO: Delete user icons probably here
        if profile.managedObjectContext == _ctx {
            if profile.hasChanges {
                try! _ctx.save()
            }
        } else {
            _ctx.insert(profile)
            try! _ctx.save()
        }
    }
    
    func getCurrentAuthInfo() -> AuthInfo {
        return getCurrentProfile().authInfo!
    }
    
    func updateCurrentAuthInfo(_ info: AuthInfo) {
        let profile = getCurrentProfile()
        profile.authInfo = info
        updateCurrentProfile(profile)
    }
    
    func getAllProfiles() -> [AuthProfileItem] {
        let req = AuthProfileItem.fetchRequest()
        return try! _ctx.fetch(req)
    }

    func getProfile(id: ProfileID) -> AuthProfileItem? {
        return try? _ctx.existingObject(with: id) as? AuthProfileItem
    }
    
    
    func activateProfile(id: ProfileID, force: Bool) -> Bool {
        guard let profile = getProfile(id: id) else { return false }
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
    
    func removeProfile(id: ProfileID) {
        if let p = getProfile(id: id) {
            _ctx.delete(p)
            try! _ctx.save()
        }
    }
    
    private func initiateReconnect() {
        let app = SAApp.instance()
        let client = SAApp.suplaClient()
        app.cancelAllRestApiClientTasks()
        client.reconnect()
    }

}
