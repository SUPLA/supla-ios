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

@objc(AuthProfileItemInitialMigrationPolicy)
final class AuthProfileItemInitialMigrationPolicy: NSEntityMigrationPolicy {
    
    private let userDefaults = UserDefaults.standard
    
    override func begin(_ mapping: NSEntityMapping, with manager: NSMigrationManager) throws {
        let isAdvanced = userDefaults.bool(forKey: "advanced_config")
        let authInfo = AuthInfo.from(userDefaults: userDefaults)
        
        if (authInfo.isAuthDataComplete) {
            let profile = NSEntityDescription.insertNewObject(forEntityName: "AuthProfileItem", into: manager.destinationContext)
            profile.setValue(isAdvanced, forKey: "advancedSetup")
            profile.setValue(authInfo, forKey: "authInfo")
            profile.setValue(true, forKey: "isActive")
        }
    }
    
    override func end(_ mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let context = manager.destinationContext
        let request = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
        
        if let profile = try context.fetch(request).first {
            var bytes = [CChar](repeating: 0, count: Int(SUPLA_GUID_SIZE))
            if (SAApp.getClientGUID(&bytes)) {
                setSecureRandom(
                    Data(bytes.map { UInt8(bitPattern: $0)}),
                    key: AuthProfileItemKeychainHelper.guidKey,
                    id: profile.objectID
                )
            }
            
            bytes = [CChar](repeating: 0, count: Int(SUPLA_AUTHKEY_SIZE))
            if (SAApp.getAuthKey(&bytes)) {
                setSecureRandom(
                    Data(bytes.map { UInt8(bitPattern: $0) }),
                    key: AuthProfileItemKeychainHelper.authKey,
                    id: profile.objectID
                )
            }
        }
    }
    
    func setSecureRandom(_ bytes: Data, key: String, id: NSManagedObjectID) {
        let keychainKey = keychainKey(key: key, id: id)
        setBytes(bytes, for: keychainKey)
    }
    
    private func setBytes(_ bytes: Data, for key: String) {
        SAKeychain.deleteObject(withKey: key)
        SAKeychain.add(bytes, withKey: key)
    }
    
    private func keychainKey(key: String, id: NSManagedObjectID) -> String {
        let idhash = id.uriRepresentation().dataRepresentation.base64EncodedString()
        return "\(key)_\(idhash)"
    }
}

