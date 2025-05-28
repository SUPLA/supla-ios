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

let SINGLE_CALL_APP_ID: Int32 = 1

protocol SingleCall {
    func registerPushToken(_ authorizationEntity: SingleCallAuthorizationEntity, _ protocolVersion: Int32, _ tokenDetails: TCS_PnClientToken) throws
    func executeAction(_ action: Action, subjectType: SubjectType, subjectId: Int32, authorizationEntity: SingleCallAuthorizationEntity) throws
    func getValue(channelId: Int32, authorizationEntity: SingleCallAuthorizationEntity) -> SingleCallResult
}

class SingleCallImpl: SingleCall {
    func registerPushToken(_ authorizationEntity: SingleCallAuthorizationEntity, _ protocolVersion: Int32, _ tokenDetails: TCS_PnClientToken) throws {
        var authDetails = authorizationEntity.authDetails
        var tokenDetails = tokenDetails
        
        let result = supla_single_call_register_pn_client_token(&authDetails, protocolVersion, 5000, &tokenDetails)
        
        if (result != SUPLA_RESULTCODE_TRUE) {
            throw SingleCallError.resultException(errorCode: result)
        }
    }
    
    func executeAction(_ action: Action, subjectType: SubjectType, subjectId: Int32, authorizationEntity: SingleCallAuthorizationEntity) throws {
        var authDetails = authorizationEntity.authDetails
        var clientAction = TCS_Action()
        clientAction.SubjectType = UInt8(subjectType.rawValue)
        clientAction.SubjectId = subjectId
        clientAction.ActionId = action.rawValue
        
        let result = supla_single_call_execute_action(&authDetails, authorizationEntity.preferredProtocolVersion, 5000, &clientAction)
        
        if (result != SUPLA_RESULTCODE_TRUE) {
            throw SingleCallError.resultException(errorCode: result)
        }
    }
    
    func getValue(channelId: Int32, authorizationEntity: SingleCallAuthorizationEntity) -> SingleCallResult {
        var authDetails = authorizationEntity.authDetails
        var value = TSC_GetChannelValueResult()
        
        supla_single_call_get_channel_value(&authDetails, authorizationEntity.preferredProtocolVersion, 500, channelId, &value)
        
        return SingleCallResult.from(valueResult: value)
    }
}

enum SingleCallError: Error {
    case resultException(errorCode: Int32)
    
    var errorCode: Int32 {
        switch (self) {
        case .resultException(let errorCode): return errorCode
        }
    }
}

extension Error {
    func getErrorMessage(subjectType: SubjectType) -> String {
        guard let singleCallError = self as? SingleCallError else {
            return Strings.CarPlay.executionError.arguments(-11)
        }

        return switch (singleCallError.errorCode) {
        case SUPLA_RESULTCODE_CHANNEL_IS_OFFLINE: Strings.General.channelOffline
        case SUPLA_RESULTCODE_CHANNELNOTFOUND: Strings.General.channelNotFound
        case SUPLA_RESULTCODE_INACTIVE:
            if (subjectType == .scene) {
                Strings.General.sceneInactive
            } else {
                Strings.CarPlay.executionError.arguments(singleCallError.errorCode)
            }
        default: Strings.CarPlay.executionError.arguments(singleCallError.errorCode)
        }
    }
}

struct SingleCallAuthorizationEntity: Codable {
    let profileId: Int32
    let data: SingleCallAuthorizationData
    let serverAddress: String
    let preferredProtocolVersion: Int32
    
    var authKey: Data {
        return AuthProfileItemKeychainHelper.getSecureRandom(
            size: Int(SUPLA_AUTHKEY_SIZE),
            key: AuthProfileItemKeychainHelper.authKey,
            id: profileId
        )
    }
    
    var clientGUID: Data {
        return AuthProfileItemKeychainHelper.getSecureRandom(
            size: Int(SUPLA_GUID_SIZE),
            key: AuthProfileItemKeychainHelper.guidKey,
            id: profileId
        )
    }
    
    init(
        profileId: Int32,
        data: SingleCallAuthorizationData,
        serverAddress: String,
        preferredProtocolVersion: Int32
    ) {
        self.profileId = profileId
        self.data = data
        self.serverAddress = serverAddress
        self.preferredProtocolVersion = preferredProtocolVersion
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profileId = try container.decode(Int32.self, forKey: .profileId)
        self.data = try container.decode(SingleCallAuthorizationData.self, forKey: .data)
        self.serverAddress = try container.decode(String.self, forKey: .serverAddress)
        self.preferredProtocolVersion = try container.decode(Int32.self, forKey: .preferredProtocolVersion)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(profileId, forKey: .profileId)
        try container.encode(data, forKey: .data)
        try container.encode(serverAddress, forKey: .serverAddress)
        try container.encode(preferredProtocolVersion, forKey: .preferredProtocolVersion)
    }
    
    var authDetails: TCS_ClientAuthorizationDetails {
        var authDetails = TCS_ClientAuthorizationDetails()
        withUnsafeMutablePointer(to: &authDetails.GUID.0) { pointer in
            clientGUID.copyBytes(to: UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: UInt8.self), count: Int(SUPLA_GUID_SIZE))
        }
        withUnsafeMutablePointer(to: &authDetails.AuthKey.0) { pointer in
            authKey.copyBytes(to: UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: UInt8.self), count: Int(SUPLA_GUID_SIZE))
        }
        
        switch (data) {
        case .email(let email):
            email.copyToCharArray(array: &authDetails.Email, capacity: Int(SUPLA_EMAIL_MAXSIZE))
        case .accessId(let id, let password):
            authDetails.AccessID = id
            password.copyToCharArray(array: &authDetails.AccessIDpwd, capacity: Int(SUPLA_ACCESSID_PWD_MAXSIZE))
        }
        serverAddress.copyToCharArray(array: &authDetails.ServerName, capacity: Int(SUPLA_SERVER_NAME_MAXSIZE))
        
        return authDetails
    }
    
    private enum CodingKeys: String, CodingKey {
        case profileId
        case data
        case serverAddress
        case preferredProtocolVersion
    }
}

enum SingleCallAuthorizationData: Codable {
    case email(email: String)
    case accessId(id: Int32, password: String)
}
