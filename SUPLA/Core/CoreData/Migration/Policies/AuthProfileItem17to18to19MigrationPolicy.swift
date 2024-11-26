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
    
@objc(AuthProfileItem17to18to19MigrationPolicy)
final class AuthProfileItem17to18to19MigrationPolicy: NSEntityMigrationPolicy {
    @Singleton<GlobalSettings> var settings
    @Singleton<UserStateHolder> var userStateHolder
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let name = sInstance.value(forKey: "name") as? String
        let isActive = sInstance.value(forKey: "isActive") as? Bool
        let advancedSetup = sInstance.value(forKey: "advancedSetup") as? Bool
        let authInfo = sInstance.value(forKey: "authInfo") as? AuthInfo
        
        guard let name, let isActive, let advancedSetup, let authInfo else { return }
        let id = settings.nextProfileId
        
        let destinationInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
        destinationInstance.setValue(id, forKey: "id")
        destinationInstance.setValue(name, forKey: "name")
        destinationInstance.setValue(isActive, forKey: "isActive")
        destinationInstance.setValue(advancedSetup, forKey: "advancedSetup")
        destinationInstance.setValue(authInfo.accessID, forKey: "accessId")
        destinationInstance.setValue(authInfo.accessIDpwd, forKey: "accessIdPassword")
        destinationInstance.setValue(authInfo.emailAuth ? AuthorizationType.email.rawValue : AuthorizationType.accessId.rawValue, forKey: "rawAuthorizationType")
        destinationInstance.setValue(authInfo.emailAddress, forKey: "email")
        destinationInstance.setValue(authInfo.serverAutoDetect, forKey: "serverAutoDetect")
        destinationInstance.setValue(authInfo.preferredProtocolVersion, forKey: "preferredProtocolVersion")
        
        migrateSecurityKeys(Int(SUPLA_GUID_SIZE), AuthProfileItemKeychainHelper.guidKey, sInstance.objectID, id)
        migrateSecurityKeys(Int(SUPLA_AUTHKEY_SIZE), AuthProfileItemKeychainHelper.authKey, sInstance.objectID, id)
        userStateHolder.migrateFrom17To19ModelMappingVersion(sInstance.objectID, id)
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationInstance, for: mapping)
        
        // relation to server
        let serverAddress = authInfo.emailAuth ? authInfo.serverForEmail : authInfo.serverForAccessID
        var server = try findServer(address: serverAddress, manager: manager)
        if (server == nil) {
            let entity = NSEntityDescription.entity(forEntityName: "SAProfileServer", in: manager.destinationContext)!
            server = NSManagedObject(entity: entity, insertInto: manager.destinationContext)
            server?.setValue(settings.nextServerId, forKey: "id")
            server?.setValue(serverAddress, forKey: "address")
        }
    }
    
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        guard let sourceInstance = manager.sourceInstances(forEntityMappingName: mapping.name, destinationInstances: [dInstance]).first,
              let authInfo = sourceInstance.value(forKey: "authInfo") as? AuthInfo
        else { return }
        
        let serverAddress = authInfo.emailAuth ? authInfo.serverForEmail : authInfo.serverForAccessID
        if let server = try findServer(address: serverAddress, manager: manager) {
            dInstance.setValue(server, forKey: "server")
        }
    }
    
    private func findServer(address: String, manager: NSMigrationManager) throws -> NSManagedObject? {
        let serverFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SAProfileServer")
        serverFetchRequest.predicate = NSPredicate(format: "address = %@", address)
        return try manager.destinationContext.fetch(serverFetchRequest).first
    }
    
    private func migrateSecurityKeys(_ size: Int, _ key: String, _ sourceId: NSManagedObjectID, _ destinationId: Int32) {
        if let random = getSecureRandom(size: size, key: key, id: sourceId) {
            AuthProfileItemKeychainHelper.setSecureRandom(random, key: key, id: destinationId)
        }
    }
    
    func getSecureRandom(size: Int, key: String, id: NSManagedObjectID) -> Data? {
        let keychainKey = keychainKey(key: key, id: id)
        if let bytes = bytes(for: keychainKey, size: size) {
            return bytes
        } else {
            return nil
        }
    }
    
    private func bytes(for key: String, size: Int) -> Data? {
        if let data = SAKeychain.getObjectWithKey(key) as? Data,
           data.count == size
        {
            return data
        } else {
            return nil
        }
    }
    
    private func keychainKey(key: String, id: NSManagedObjectID) -> String {
        let idhash = id.uriRepresentation().dataRepresentation.base64EncodedString()
        return "\(key)_\(idhash)"
    }
}
