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
import Security

private let SERVICE = "SecureSettings"

struct SecureSettings {
    protocol Interface: AnyObject {
        var wizardWifiName: String? { get set }
        var wizardWifiPassword: String? { get set }
    }
    
    class Implementation: Interface {
        var wizardWifiName: String? {
            get { readString(.wifiName) }
            set {
                if let value = newValue {
                    delete(.wifiName)
                    save(.wifiName, string: value)
                } else {
                    delete(.wifiName)
                }
            }
        }
        
        var wizardWifiPassword: String? {
            get { readString(.wifiPassword) }
            set {
                if let value = newValue {
                    delete(.wifiPassword)
                    save(.wifiPassword, string: value)
                } else {
                    delete(.wifiPassword)
                }
            }
        }
        
        private func save(_ key: Entry, string value: String) {
            let keychainItem = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.text,
                kSecAttrService: SERVICE,
                kSecValueData: value.data(using: .utf8)!
            ] as [String: Any]
            
            let status = SecItemAdd(keychainItem as CFDictionary, nil)
            if (status != errSecSuccess) {
                SALog.warning("Keychain storage of \(key.text) failed")
            }
        }
        
        private func readString(_ key: Entry) -> String? {
            let keychainItem = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.text,
                kSecAttrService: SERVICE,
                kSecReturnData: true
            ] as [String: Any]
            
            var value: CFTypeRef?
            let status = SecItemCopyMatching(keychainItem as CFDictionary, &value)
            
            if status == errSecSuccess,
               let data = value as? Data
            {
                return String(data: data, encoding: .utf8)
            } else {
                return nil
            }
        }
        
        private func delete(_ key: Entry) {
            let keychainItem = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.text,
                kSecAttrService: SERVICE
            ] as [String: Any]
            
            let status = SecItemDelete(keychainItem as CFDictionary)
            if (status != errSecSuccess) {
                SALog.warning("Keychain deletion of \(key.text) failed")
            }
        }
    }
    
    private enum Entry {
        case wifiName
        case wifiPassword
        
        var text: String {
            switch (self) {
            case .wifiName: "wifiName"
            case .wifiPassword: "wifiPassword"
            }
        }
    }
}
