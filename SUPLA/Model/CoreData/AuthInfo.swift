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

@objc
class AuthInfo: NSObject, NSCoding {
    @objc let emailAuth: Bool
    @objc let serverAutoDetect: Bool
    @objc let emailAddress: String
    @objc let serverForEmail: String
    @objc let serverForAccessID: String
    @objc let accessID: Int
    @objc let accessIDpwd: String
    @objc let preferredProtocolVersion: Int
    @objc var serverUrlString: String {
        get { "https://\(serverForCurrentAuthMethod)" }
    }

    
    private let kEmailAuth = "emailAuth"
    private let kServerAutoDetect = "serverAutoDetect"
    private let kEmailAddress = "emailAddress"
    private let kServerForEmail = "serverForEmail"
    private let kServerForAccessID = "serverForAccessID"
    private let kAccessID = "accessID"
    private let kAccessIDpwd = "accessIDpwd"
    private let kPreferredProtocolVersion = "preferredProtocolVersion"
    
    init(emailAuth: Bool, serverAutoDetect: Bool,
         emailAddress: String, serverForEmail: String,
         serverForAccessID: String, accessID: Int,
         accessIDpwd: String,
         preferredProtocolVersion: Int = 0) {
        self.emailAuth = emailAuth
        self.serverAutoDetect = serverAutoDetect
        self.emailAddress = emailAddress
        self.serverForEmail = serverForEmail
        self.serverForAccessID = serverForAccessID
        self.accessID = accessID
        self.accessIDpwd = accessIDpwd
        self.preferredProtocolVersion = preferredProtocolVersion

        super.init()
    }
    
    required init?(coder: NSCoder) {
        emailAuth = coder.decodeBool(forKey: kEmailAuth)
        serverAutoDetect = coder.decodeBool(forKey: kServerAutoDetect)
        emailAddress = coder.decodeObject(forKey: kEmailAddress) as? String ?? ""
        serverForEmail = coder.decodeObject(forKey: kServerForEmail) as? String ?? ""
        serverForAccessID = coder.decodeObject(forKey: kServerForAccessID) as? String ?? ""
        accessID = coder.decodeInteger(forKey: kAccessID)
        accessIDpwd = coder.decodeObject(forKey: kAccessIDpwd) as? String ?? ""
        preferredProtocolVersion = coder.decodeInteger(forKey: kPreferredProtocolVersion)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(emailAuth, forKey: kEmailAuth)
        coder.encode(serverAutoDetect, forKey: kServerAutoDetect)
        coder.encode(emailAddress, forKey: kEmailAddress)
        coder.encode(serverForEmail, forKey: kServerForEmail)
        coder.encode(serverForAccessID, forKey: kServerForAccessID)
        coder.encode(accessID, forKey: kAccessID)
        coder.encode(accessIDpwd, forKey: kAccessIDpwd)
        coder.encode(preferredProtocolVersion, forKey: kPreferredProtocolVersion)
    }
    
    func copy(
        emailAuth: Bool? = nil,
        serverAutoDetect: Bool? = nil,
        emailAddress: String? = nil,
        serverForEmail: String? = nil,
        serverForAccessID: String? = nil,
        accessID: Int? = nil,
        accessIDpwd: String? = nil,
        preferredProtocolVersion: Int? = nil
    ) -> AuthInfo {
        AuthInfo(
            emailAuth: emailAuth ?? self.emailAuth,
            serverAutoDetect: serverAutoDetect ?? self.serverAutoDetect,
            emailAddress: emailAddress ?? self.emailAddress,
            serverForEmail: serverForEmail ?? self.serverForEmail,
            serverForAccessID: serverForAccessID ?? self.serverForAccessID,
            accessID: accessID ?? self.accessID,
            accessIDpwd: accessIDpwd ?? self.accessIDpwd,
            preferredProtocolVersion: preferredProtocolVersion ?? self.preferredProtocolVersion
        )
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AuthInfo else { return false }
        return   emailAuth == o.emailAuth && accessID  == o.accessID &&
                 serverAutoDetect == o.serverAutoDetect &&
                 serverForEmail == o.serverForEmail &&
                 serverForAccessID == o.serverForAccessID &&
                 accessIDpwd == o.accessIDpwd &&
                 emailAddress == o.emailAddress &&
                 preferredProtocolVersion == o.preferredProtocolVersion
    }
    
    @objc var serverForCurrentAuthMethod: String {
        if(emailAuth) { return serverForEmail } else { return serverForAccessID }
    }
    
    @objc var isAuthDataComplete: Bool {
        if(emailAuth) {
            return !emailAddress.isEmpty &&
            (serverAutoDetect || !serverForCurrentAuthMethod.isEmpty)
        } else {
            return !serverForCurrentAuthMethod.isEmpty &&
            accessID > 0 && !accessIDpwd.isEmpty
        }
    }
    
    override var debugDescription: String {
        return "email: \(emailAddress) autoDetect: \(serverAutoDetect) server: \(serverForEmail)"
    }
}

@objc(AuthInfoValueTransformer)
class AuthInfoValueTransformer: ValueTransformer {
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Data else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: value)
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? AuthInfo else { return nil }
        return NSKeyedArchiver.archivedData(withRootObject: value)
    }
}

extension AuthInfo {
    static func empty() -> AuthInfo {
        AuthInfo(
            emailAuth: true,
            serverAutoDetect: true,
            emailAddress: "",
            serverForEmail: "",
            serverForAccessID: "",
            accessID: 0,
            accessIDpwd: ""
        )
    }
    
    static func from(userDefaults: UserDefaults) -> AuthInfo {
        let accessID = userDefaults.integer(forKey: "access_id")
        let accessIDpwd = userDefaults.string(forKey: "access_id_pwd") ?? ""
        let serverHostName = userDefaults.string(forKey: "server_host") ?? ""
        let emailAddress = userDefaults.string(forKey: "email_address") ?? ""
        let isAdvanced = userDefaults.bool(forKey: "advanced_config")
        let prefProtoVersion = Int(SUPLA_PROTO_VERSION)
        let serverForEmail: String
        let serverForAccessID: String
        
        if isAdvanced {
            serverForAccessID = serverHostName
            serverForEmail = ""
        } else {
            serverForAccessID = ""
            serverForEmail = serverHostName
        }
        
        return AuthInfo(
            emailAuth: !isAdvanced,
            serverAutoDetect: !isAdvanced,
            emailAddress: emailAddress,
            serverForEmail: serverForEmail,
            serverForAccessID: serverForAccessID,
            accessID: accessID,
            accessIDpwd: accessIDpwd,
            preferredProtocolVersion: prefProtoVersion
        )
    }
}
