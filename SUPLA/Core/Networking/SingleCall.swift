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

protocol SingleCall {
    func registerPushToken(_ profile: AuthProfileItem, _ protocolVersion: Int32, _ tokenDetails: TCS_PnClientToken) throws
    func executeAction(_ action: Action, subjectType: SubjectType, subjectId: Int32, profile: AuthProfileItem) throws
}

class SingleCallImpl: SingleCall {
    
    func registerPushToken(_ profile: AuthProfileItem, _ protocolVersion: Int32, _ tokenDetails: TCS_PnClientToken) throws {
        var authDetails = profile.authDetails
        var tokenDetails = tokenDetails
        
        let result = supla_single_call_register_pn_client_token(&authDetails, protocolVersion, 5000, &tokenDetails)
        
        if (result != SUPLA_RESULTCODE_TRUE) {
            throw SingleCallError.resultException(errorCode: result)
        }
    }
    
    func executeAction(_ action: Action, subjectType: SubjectType, subjectId: Int32, profile: AuthProfileItem) throws {
        var authDetails = profile.authDetails
        var clientAction = TCS_Action()
        clientAction.SubjectType = UInt8(subjectType.rawValue)
        clientAction.SubjectId = subjectId
        clientAction.ActionId = action.rawValue
        
        let result = supla_single_call_execute_action(&authDetails, profile.preferredProtocolVersion, 5000, &clientAction)
        
        if (result != SUPLA_RESULTCODE_TRUE) {
            throw SingleCallError.resultException(errorCode: result)
        }
    }
}

enum SingleCallError: Error {
    case resultException(errorCode: Int32)
}

fileprivate extension AuthProfileItem {
    var authDetails: TCS_ClientAuthorizationDetails {
        var authDetails: TCS_ClientAuthorizationDetails = TCS_ClientAuthorizationDetails()
        withUnsafeMutablePointer(to: &authDetails.GUID.0) { pointer in
            clientGUID.copyBytes(to: UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: UInt8.self), count: Int(SUPLA_GUID_SIZE))
        }
        withUnsafeMutablePointer(to: &authDetails.AuthKey.0) { pointer in
            authKey.copyBytes(to: UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: UInt8.self), count: Int(SUPLA_GUID_SIZE))
        }
        
        switch (authorizationType) {
        case .email:
            email?.copyToCharArray(array: &authDetails.Email, capacity: Int(SUPLA_EMAIL_MAXSIZE))
            server?.address?.copyToCharArray(array: &authDetails.ServerName, capacity: Int(SUPLA_SERVER_NAME_MAXSIZE))
        case .accessId:
            authDetails.AccessID = accessId
            accessIdPassword?.copyToCharArray(array: &authDetails.AccessIDpwd, capacity: Int(SUPLA_ACCESSID_PWD_MAXSIZE))
        }
        
        return authDetails
    }
}
