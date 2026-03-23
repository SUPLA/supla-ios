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

struct ProfileDto: Equatable, Identifiable {
    let id: Int32
    let name: String
    let isActive: Bool
    let authorizationType: AuthorizationType
    let advancedSetup: Bool
    let serverAutoDetect: Bool

    let email: String?
    let accessId: Int32?
    let accessIdPassword: String?
    let serverAddress: String?

    let preferredProtocolVersion: Int32

    var isAuthDataComplete: Bool {
        if (authorizationType == .email) {
            return email?.isEmpty == false && (serverAutoDetect || serverAddress?.isEmpty == false)
        } else {
            return serverAddress?.isEmpty == false && (accessId ?? 0) > 0 && accessIdPassword?.isEmpty == false
        }
    }

    init(
        id: Int32 = 0,
        name: String = "",
        isActive: Bool = false,
        authorizationType: AuthorizationType = .email,
        advancedSetup: Bool = false,
        serverAutoDetect: Bool = false,
        email: String? = nil,
        accessId: Int32? = nil,
        accessIdPassword: String? = nil,
        serverAddress: String? = nil,
        preferredProtocolVersion: Int32 = 0
    ) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.authorizationType = authorizationType
        self.advancedSetup = advancedSetup
        self.serverAutoDetect = serverAutoDetect
        self.email = email
        self.accessId = accessId
        self.accessIdPassword = accessIdPassword
        self.serverAddress = serverAddress
        self.preferredProtocolVersion = preferredProtocolVersion
    }
    
    var authorizationEntity: SingleCallAuthorizationEntity {
        let authorizationData: SingleCallAuthorizationData = switch (authorizationType) {
        case .email: .email(email: email ?? "")
        case .accessId: .accessId(id: accessId ?? 0, password: accessIdPassword ?? "")
        }
        
        return SingleCallAuthorizationEntity(
            profileId: id,
            data: authorizationData,
            serverAddress: serverAddress ?? "",
            preferredProtocolVersion: preferredProtocolVersion
        )
    }
    
    func token(_ tokenData: Data?) -> TCS_PnClientToken {
        AuthProfileItem.token(tokenData, name: name)
    }
    
    static let INVALID_ID: Int32 = -1
}

extension AuthProfileItem {
    var dto: ProfileDto {
        ProfileDto(
            id: id,
            name: name.ifEmptyOrNil(Strings.Profiles.defaultProfileName),
            isActive: isActive,
            authorizationType: authorizationType,
            advancedSetup: advancedSetup,
            serverAutoDetect: serverAutoDetect,
            email: email,
            accessId: accessId,
            accessIdPassword: accessIdPassword,
            serverAddress: server?.address,
            preferredProtocolVersion: preferredProtocolVersion
        )
    }
}
