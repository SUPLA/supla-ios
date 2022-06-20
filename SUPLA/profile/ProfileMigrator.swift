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
        let pm = MultiAccountProfileManager(context: ctx)
        
        let profile = pm.getCurrentProfile()
        if profile.authInfo?.isAuthDataComplete == false {
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
        
        // profile was already migrated, so we're good now
        try updateRelationships(profile: profile, in: ctx)

      var bytes = [CChar](repeating: 0, count: Int(SUPLA_GUID_SIZE))
      if SAApp.getClientGUID(&bytes) {
          profile.clientGUID = Data(bytes.map { UInt8(bitPattern: $0)})
      }

      bytes = [CChar](repeating: 0, count: Int(SUPLA_AUTHKEY_SIZE))
      if SAApp.getAuthKey(&bytes) {
          profile.authKey = Data(bytes.map { UInt8(bitPattern: $0) })
      }
    }

    private func updateRelationships(profile: AuthProfileItem,
                                     in ctx: NSManagedObjectContext) throws {
        let entities = [ "SAChannelBase", "SAChannelValueBase",
            "SAMeasurementItem", "SAUserIcon", "SALocation" ]
        
        for name in entities {
            let fr = NSFetchRequest<NSManagedObject>(entityName: name)
            for obj in try ctx.fetch(fr) {
                obj.setValue(profile, forKey: "profile")
            }
        }
        
        try ctx.save()
    }
}
