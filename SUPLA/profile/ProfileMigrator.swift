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
class ProfileMigrator: NSObject {

    private let _defs = UserDefaults.standard
    
    @objc
    func migrateProfileFromUserDefaults(_ ctx: NSManagedObjectContext) throws {
        // Obtain current authentication settings
        let accessID = _defs.integer(forKey: "access_id")
        let accessIDpwd = _defs.string(forKey: "access_id_pwd") ?? ""
        let serverHostName = _defs.string(forKey: "server_host") ?? ""
        let emailAddress = _defs.string(forKey: "email_address") ?? ""
        let isAdvanced = _defs.bool(forKey: "advanced_config")
        let prefProtoVersion = _defs.integer(forKey: "pref_proto_version")
        let serverForEmail: String
        let serverForAccessID: String
        
        if isAdvanced {
            serverForAccessID = serverHostName
            serverForEmail = ""
        } else {
            serverForAccessID = ""
            serverForEmail = serverHostName
        }
        
        
        let pm = MultiAccountProfileManager(context: ctx)
        
        ctx.perform {
            let profile = pm.getCurrentProfile()
            profile.advancedSetup = isAdvanced
            profile.authInfo = AuthInfo(emailAuth: !isAdvanced,
                                        serverAutoDetect: !isAdvanced,
                                        emailAddress: emailAddress,
                                        serverForEmail: serverForEmail,
                                        serverForAccessID: serverForAccessID,
                                        accessID: accessID,
                                        accessIDpwd: accessIDpwd,
                                        preferredProtocolVersion: prefProtoVersion)
            pm.updateCurrentProfile(profile)
        }
    }
}
