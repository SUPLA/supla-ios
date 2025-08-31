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
    
class EspPostData {
    var fieldMap: [String: String]
    
    init(fieldMap: [String : String]) {
        self.fieldMap = fieldMap
    }
    
    var ssid: String? {
        get { fieldMap[EspPostData.FIELD_SSID] }
        set { fieldMap.putOrRemove(EspPostData.FIELD_SSID, newValue) }
    }
    
    var password: String? {
        get { fieldMap[EspPostData.FIELD_PASSWORD] }
        set { fieldMap.putOrRemove(EspPostData.FIELD_PASSWORD, newValue) }
    }
    
    var server: String? {
        get { fieldMap[EspPostData.FIELD_SERVER] }
        set { fieldMap.putOrRemove(EspPostData.FIELD_SERVER, newValue) }
    }
    
    var email: String? {
        get { fieldMap[EspPostData.FIELD_EMAIL] }
        set { fieldMap.putOrRemove(EspPostData.FIELD_EMAIL, newValue) }
    }
    
    var softwareUpdate: Bool? {
        get { fieldMap[EspPostData.FIELD_UPDATE]?.bool }
        set { fieldMap.putOrRemove(EspPostData.FIELD_UPDATE, newValue) }
    }
    
    var `protocol`: EspDeviceProtocol? {
        get { EspDeviceProtocol.from(fieldMap[EspPostData.FIELD_PROTO]) }
        set { fieldMap.putOrRemove(EspPostData.FIELD_PROTO, newValue?.id) }
    }
    
    var reboot: Bool? {
        get { fieldMap[EspPostData.FIELD_REBOOT]?.bool }
        set { fieldMap.putOrRemove(EspPostData.FIELD_REBOOT, newValue) }
    }
    
    var isCompatible: Bool {
        ssid != nil && password != nil && server != nil && email != nil
    }
    
    static let FIELD_SSID = "sid"
    static let FIELD_PASSWORD = "wpw"
    static let FIELD_SERVER = "svr"
    static let FIELD_EMAIL = "eml"
    static let FIELD_UPDATE = "upd"
    static let FIELD_PROTO = "pro"
    static let FIELD_REBOOT = "rbt"
}

private extension Dictionary where Key == String, Value == String {
    mutating func putOrRemove(_ key: String, _ value: String?) {
        if let value {
            self[key] = value
        } else {
            removeValue(forKey: key)
        }
    }
    
    mutating func putOrRemove(_ key: String, _ value: Bool?) {
        if let value {
            self[key] = value ? "1" : "0"
        } else {
            removeValue(forKey: key)
        }
    }
    
    mutating func putOrRemove(_ key: String, _ value: Int?) {
        if let value {
            self[key] = "\(value)"
        } else {
            removeValue(forKey: key)
        }
    }
}

private extension String {
    var bool: Bool {
        self == "1"
    }
}
