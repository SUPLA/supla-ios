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
    
@objc class ProfileDtoProxy: NSObject {
    let id: Int32
    let name: String
    @objc let email: String
    @objc let accessId: Int32
    @objc let accessIdPassword: String?
    @objc let serverAddress: String?
    @objc let authorizationType: AuthorizationType
    @objc let preferredProtocolVersion: Int32
    
    init(
        id: Int32,
        name: String,
        email: String,
        accessId: Int32,
        accessIdPassword: String?,
        serverAddress: String?,
        authorizationType: AuthorizationType,
        preferredProtocolVersion: Int32
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.accessId = accessId
        self.accessIdPassword = accessIdPassword
        self.serverAddress = serverAddress
        self.authorizationType = authorizationType
        self.preferredProtocolVersion = preferredProtocolVersion
    }
    
    @objc
    var serverUrlString: String {
        get { "https://\(serverAddress ?? "")" }
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
    
    var authorizationEntity: SingleCallAuthorizationEntity {
        let authorizationData: SingleCallAuthorizationData = switch (authorizationType) {
        case .email: .email(email: email)
        case .accessId: .accessId(id: accessId, password: accessIdPassword ?? "")
        }
        
        return SingleCallAuthorizationEntity(
            profileId: id,
            data: authorizationData,
            serverAddress: serverAddress ?? "",
            preferredProtocolVersion: preferredProtocolVersion
        )
    }
    
    @objc
    var authDetails: TCS_ClientAuthorizationDetails {
        authorizationEntity.authDetails
    }
    
    @objc
    func token(_ tokenData: Data?) -> TCS_PnClientToken {
        AuthProfileItem.token(tokenData, name: name)
    }
}

extension AuthProfileItem {
    var dtoProxy: ProfileDtoProxy {
        ProfileDtoProxy(
            id: id,
            name: name.ifEmptyOrNil(Strings.Profiles.defaultProfileName),
            email: email ?? "",
            accessId: accessId,
            accessIdPassword: accessIdPassword,
            serverAddress: server?.address,
            authorizationType: authorizationType,
            preferredProtocolVersion: preferredProtocolVersion
        )
    }
}
