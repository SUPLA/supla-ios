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

class AuthProfileItemKeychainHelper {
    
    static let guidKey = "guid"
    static let authKey = "key"
    
    static func getSecureRandom(size: Int, key: String, id: Int32) -> Data {
        let keychainKey = keychainKey(key: key, id: id)
        if let bytes = bytes(for: keychainKey, size: size) {
            return bytes
        } else {
            let bytes = Data((1...size).map { _ in
                UInt8.random(in: 0...255)
            })
            setBytes(bytes, for: keychainKey)
            return bytes
        }
    }


    static func setSecureRandom(_ bytes: Data, key: String, id: Int32) {
        let keychainKey = keychainKey(key: key, id: id)
        setBytes(bytes, for: keychainKey)
    }
    
    static func clear(id: Int32) {
        SAKeychain.deleteObject(withKey: keychainKey(key: authKey, id: id))
        SAKeychain.deleteObject(withKey: keychainKey(key: guidKey, id: id))
    }

    private static func bytes(for key: String, size: Int) -> Data? {
        if let data = SAKeychain.getObjectWithKey(key) as? Data,
           data.count == size {
            return data
        } else {
            return nil
        }
    }

    private static func setBytes(_ bytes: Data, for key: String) {
        SAKeychain.deleteObject(withKey: key)
        SAKeychain.add(bytes, withKey: key)
    }


    private static func keychainKey(key: String, id: Int32) -> String {
         return "\(key)_\(id)"
    }
}
