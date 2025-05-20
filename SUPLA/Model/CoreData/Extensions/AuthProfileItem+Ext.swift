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
    
    var authorizationEntity: SingleCallAuthorizationEntity {
        let authorizationData: SingleCallAuthorizationData = switch (authorizationType) {
        case .email: .email(email: email ?? "")
        case .accessId: .accessId(id: accessId, password: accessIdPassword ?? "")
        }
        
        return SingleCallAuthorizationEntity(
            profileId: id,
            data: authorizationData,
            serverAddress: server?.address ?? "",
            preferredProtocolVersion: preferredProtocolVersion
        )
    }
    
    @objc
    var authDetails: TCS_ClientAuthorizationDetails {
        authorizationEntity.authDetails
    }
    
    @objc
    func token(_ tokenData: Data?) -> TCS_PnClientToken {
        var token = TCS_PnClientToken()
        token.AppId = SINGLE_CALL_APP_ID
        token.Platform = PLATFORM_IOS
#if DEBUG
        token.DevelopmentEnv = 1;
#endif
        if let tokenData {
            let tokenString = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
            withUnsafeMutablePointer(to: &token.Token.0) { ptr in
                tokenString.utf8StringToBuffer(ptr, withSize: Int(SUPLA_PN_CLIENT_TOKEN_MAXSIZE))
            }
            withUnsafeMutablePointer(to: &token.ProfileName.0) { ptr in
                displayName.utf8StringToBuffer(ptr, withSize: Int(SUPLA_PN_PROFILE_NAME_MAXSIZE))
            }
            
            // One more because of \0 character at string end
            let realSize = tokenString.count + 1
            token.TokenSize = UInt16(min(realSize, Int(SUPLA_PN_CLIENT_TOKEN_MAXSIZE)))
            token.RealTokenSize = UInt16(realSize)
        }
        
        return token
    }
}
