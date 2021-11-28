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
    
    init(context: NSManagedObjectContext) {
        _ctx = context
        super.init()
    }
}

extension MultiAccountProfileManager: ProfileManager {

    func getCurrentProfile() -> AuthProfileItem {
        let req = AuthProfileItem.fetchRequest()
        if let profile = try! _ctx.fetch(req).first(where: {$0.isActive}) {
            return profile
        } else {
            // Need to create initial profile
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
    }
    
    func updateCurrentProfile(_ profile: AuthProfileItem) {
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
    
    
}
