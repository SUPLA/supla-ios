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
    
    var authorizationType: AuthorizationType {
        get { AuthorizationType.from(rawAuthorizationType) }
        set { rawAuthorizationType = newValue.rawValue }
    }
    
    @objc
    var serverUrlString: String {
        get { "https://\(server?.address ?? "")" }
    }
    
    @objc
    var clientGUID: Data {
        get {
            return AuthProfileItemKeychainHelper.getSecureRandom(
                size: Int(SUPLA_GUID_SIZE),
                key: AuthProfileItemKeychainHelper.guidKey,
                id: id
            )
        }
        
        set {
            AuthProfileItemKeychainHelper.setSecureRandom(
                newValue,
                key: AuthProfileItemKeychainHelper.guidKey,
                id: id
            )
        }
    }
    
    @objc
    var authKey: Data {
        get {
            return AuthProfileItemKeychainHelper.getSecureRandom(
                size: Int(SUPLA_AUTHKEY_SIZE),
                key: AuthProfileItemKeychainHelper.authKey,
                id: id
            )
        }
        
        set {
            AuthProfileItemKeychainHelper.setSecureRandom(
                newValue,
                key: AuthProfileItemKeychainHelper.authKey,
                id: id
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
    
    var isAuthDataComplete: Bool {
        if(authorizationType == .email) {
            return email?.isEmpty == false && (serverAutoDetect || server != nil)
        } else {
            return server != nil && accessId > 0 && accessIdPassword?.isEmpty == false
        }
    }
    
    var idString: String {
        get {
            if (objectID == nil) {
                return "" // Used for testing
            }
            return objectID.uriRepresentation().dataRepresentation.base64EncodedString()
        }
    }
    
}
