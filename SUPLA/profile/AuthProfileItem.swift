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
import CoreData

typealias ProfileID = NSManagedObjectID

extension AuthProfileItem {

    @objc
    var clientGUID: Data {
        get {
          return getSecureRandom(size: Int(SUPLA_GUID_SIZE),
                                   key: "guid",
                                   id: objectID)
        }

        set {
            setSecureRandom(newValue, key: "guid", id: objectID)
        }
    }

    @objc
    var authKey: Data {
        get {
          return getSecureRandom(size: Int(SUPLA_AUTHKEY_SIZE),
                                   key: "key",
                                   id: objectID)
        }

        set {
            setSecureRandom(newValue, key: "key", id: objectID)
        }
    }
    
    var displayName: String {
        let rawName = name ?? ""
        if rawName.count == 0 {
            return Strings.Profiles.defaultProfileName
        } else {
            return rawName
        }
    }

    private func getSecureRandom(size: Int, key: String,
                                 id: NSManagedObjectID) -> Data {
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


    private func setSecureRandom(_ bytes: Data,
                                 key: String,
                                 id: NSManagedObjectID) {
        let keychainKey = keychainKey(key: key, id: id)
        setBytes(bytes, for: keychainKey)
    }

    private func bytes(for key: String, size: Int) -> Data? {
        if let data = SAKeychain.getObjectWithKey(key) as? Data,
           data.count == size {
            return data
        } else {
            return nil
        }
    }

    private func setBytes(_ bytes: Data, for key: String) {
        SAKeychain.deleteObject(withKey: key)
        SAKeychain.add(bytes, withKey: key)
    }


    private func keychainKey(key: String, id: NSManagedObjectID) -> String {
        let idhash = id.uriRepresentation().dataRepresentation
          .base64EncodedString()
         return "\(key)_\(idhash)"
    }
}
