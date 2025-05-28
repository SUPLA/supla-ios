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
class SAKeychain: NSObject {
    @objc
    static func deleteObject(withKey key: String) -> Bool {
        return SecItemDelete(attributesWithKey(key) as CFDictionary) == noErr
    }
    
    @objc
    static func add(_ object: Data, withKey key: String) -> Bool {
        var attrs = attributesWithKey(key)
        attrs[kSecValueData as String] = try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
        return SecItemAdd(attrs as CFDictionary, nil) == noErr
    }
    
    @objc
    static func getObjectWithKey(_ key: String) -> Data? {
        var attrs = attributesWithKey(key)
        
        attrs[kSecReturnData as String] = true
        attrs[kSecMatchLimit as String] = kSecMatchLimitOne
        
        return getObject(key, attrs as CFDictionary)
    }
    
    static func migrate(_ key: String) {
        var attrs = attributesWithKey(key)
        
        attrs.removeValue(forKey: kSecAttrAccessGroup as String)
        attrs[kSecReturnData as String] = true
        attrs[kSecMatchLimit as String] = kSecMatchLimitOne
        
        if let value = getObject(key, attrs as CFDictionary) {
            _ = deleteObject(withKey: key)
            _ = add(value, withKey: key)
        }
        
    }
    
    private static func attributesWithKey(_ key: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "SAKeychain",
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrAccessGroup as String: "group.org.supla.ios"
        ]
    }
    
    private static func getObject(_ key: String, _ attrs: CFDictionary) -> Data? {
        var item: CFTypeRef?
        if (SecItemCopyMatching(attrs as CFDictionary, &item) == noErr) {
            guard let item = item as? Data,
                  let data = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: item)
            else { return nil }
            
            return data as Data
        }
        
        return nil
    }
}
