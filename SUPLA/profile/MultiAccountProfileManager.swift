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
        return try! _ctx.fetch(req).first(where: {$0.isActive})!
    }
    
    func updateCurrentProfile(_ profile: AuthProfileItem) {
        fatalError("unimplemented")
    }
    
    func getCurrentAuthInfo() -> AuthInfo {
        return getCurrentProfile().authInfo as! AuthInfo
    }
    
    func updateCurrentAuthInfo(_ info: AuthInfo) {
        let profile = getCurrentProfile()
        profile.authInfo = info
        updateCurrentProfile(profile)
    }
    
    
}
