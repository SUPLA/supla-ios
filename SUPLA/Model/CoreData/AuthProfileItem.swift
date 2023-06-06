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

typealias ProfileID = NSManagedObjectID

extension AuthProfileItem {
    
    @objc
    var clientGUID: Data {
        get {
            return AuthProfileItemKeychainHelper.getSecureRandom(
                size: Int(SUPLA_GUID_SIZE),
                key: AuthProfileItemKeychainHelper.guidKey,
                id: objectID
            )
        }
        
        set {
            AuthProfileItemKeychainHelper.setSecureRandom(
                newValue,
                key: AuthProfileItemKeychainHelper.guidKey,
                id: objectID
            )
        }
    }
    
    @objc
    var authKey: Data {
        get {
            return AuthProfileItemKeychainHelper.getSecureRandom(
                size: Int(SUPLA_AUTHKEY_SIZE),
                key: AuthProfileItemKeychainHelper.authKey,
                id: objectID
            )
        }
        
        set {
            AuthProfileItemKeychainHelper.setSecureRandom(
                newValue,
                key: AuthProfileItemKeychainHelper.authKey,
                id: objectID
            )
        }
    }
    
    var displayName: String {
        let rawName = name ?? ""
        if rawName.count == 0 {
            return Strings.Profiles.defaultProfileName
        } else {
            return rawName
        }
    }
    
    
}
