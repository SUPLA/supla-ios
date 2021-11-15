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
    var emailAuth: Bool = true
    var serverAutoDetect: Bool = true
    var emailAddress: String = ""
    var serverForEmail: String = ""
    var serverForAccessID: String = ""
    var accessID: Int = 0
    var accessIDpwd: String = ""

    
    private let kEmailAuth = "emailAuth"
    private let kServerAutoDetect = "serverAutoDetect"
    private let kEmailAddress = "emailAddress"
    private let kServerForEmail = "serverForEmail"
    private let kServerForAccessID = "serverForAccessID"
    private let kAccessID = "accessID"
    private let kAccessIDpwd = "accessIDpwd"
    
    init(emailAuth: Bool, serverAutoDetect: Bool,
         emailAddress: String, serverForEmail: String,
         serverForAccessID: String, accessID: Int,
         accessIDpwd: String) {
        self.emailAuth = emailAuth; self.serverAutoDetect = serverAutoDetect
        self.emailAddress = emailAddress; self.serverForEmail = serverForEmail
        self.serverForAccessID = serverForAccessID; self.accessID = accessID
        self.accessIDpwd = accessIDpwd

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
    }
    func encode(with coder: NSCoder) {
        coder.encode(emailAuth, forKey: kEmailAuth)
        coder.encode(serverAutoDetect, forKey: kServerAutoDetect)
        coder.encode(emailAddress, forKey: kEmailAddress)
        coder.encode(serverForEmail, forKey: kServerForEmail)
        coder.encode(serverForAccessID, forKey: kServerForAccessID)
        coder.encode(accessID, forKey: kAccessID)
        coder.encode(accessIDpwd, forKey: kAccessIDpwd)
    }
    
    func clone() -> AuthInfo {
        return copy() as! AuthInfo
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AuthInfo else { return false }
        return   emailAuth == o.emailAuth && accessID  == o.accessID &&
                 serverAutoDetect == o.serverAutoDetect &&
                 serverForEmail == o.serverForEmail &&
                 serverForAccessID == o.serverForAccessID &&
                 accessIDpwd == o.accessIDpwd &&
                 emailAddress == o.emailAddress

    }
}

extension AuthInfo: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        return AuthInfo(emailAuth: emailAuth,
                        serverAutoDetect: serverAutoDetect,
                        emailAddress: emailAddress,
                        serverForEmail: serverForEmail,
                        serverForAccessID: serverForAccessID,
                        accessID: accessID, accessIDpwd: accessIDpwd)
    }
    
    
}

