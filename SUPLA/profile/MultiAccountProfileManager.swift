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

class MultiAccountProfileManager: NSObject {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<DeleteAllProfileDataUseCase> private var deleteAllProfileDataUseCase
    @Singleton<RuntimeConfig> private var runtimeConfig
    @Singleton<SingleCall> private var singleCall
    @Singleton<SuplaCloudConfigHolder> private var cloudConfigHolder
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<ReadOrCreateProfileServerUseCase> private var readOrCreateProfileServerUseCase
    @Singleton<GlobalSettings> private var settings
    
    private let userDefaults = UserDefaults.standard
    
    @objc
    override init() {
        super.init()
        
        var config = runtimeConfig
        config.activeProfileId = getCurrentProfile()?.objectID
    }
}

extension MultiAccountProfileManager: ProfileManager {

    func read(id: ProfileID) -> AuthProfileItem? {
        return try? profileRepository.queryItem(id).subscribeSynchronous()!
    }
    
    func getCurrentProfile() -> AuthProfileItem? {
        try? profileRepository.getActiveProfile().subscribeSynchronous()
    }
    
    func getAllProfiles() -> [AuthProfileItem] {
        return try! profileRepository.getAllProfiles().subscribeSynchronous()!
    }

    func activateProfile(id: ProfileID, force: Bool) -> Bool {
        guard let profile = read(id: id) else { return false }
        if profile.isActive && !force { return false }
        
        do {
            try profileRepository.getAllProfiles()
                .map { profiles in
                    profiles.forEach { $0.isActive = $0.objectID == id }
                    return profiles
                }
                .flatMapFirst { profiles in
                    self.profileRepository.save()
                }
                .subscribeSynchronous()
            
            var config = runtimeConfig
            config.activeProfileId = profile.objectID
        } catch {
            SALog.error("Error occured by saving \(error)")
            return false;
        }
        cloudConfigHolder.clean()
        initiateReconnect()
        
        return true
    }
    
    @objc
    func getCurrentProfile(withContext context: NSManagedObjectContext) -> AuthProfileItem? {
        if (runtimeConfig.activeProfileId != nil) {
            do {
                return try context.existingObject(with: runtimeConfig.activeProfileId!) as? AuthProfileItem
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    func restoreProfileFromDefaults() -> Bool {
        let authInfo = AuthInfo.from(userDefaults: userDefaults)
        
        if (authInfo.isAuthDataComplete) {
            let isAdvanced = userDefaults.bool(forKey: "advanced_config")
            
            do {
                try readOrCreateProfileServerUseCase.invoke(authInfo.serverForCurrentAuthMethod)
                    .flatMap { server in self.profileRepository.create().map { ($0, server) } }
                    .map { (profile, server) in
                        profile.id = self.settings.nextProfileId
                        profile.advancedSetup = isAdvanced
                        profile.rawAuthorizationType = authInfo.emailAuth ? AuthorizationType.email.rawValue : AuthorizationType.accessId.rawValue
                        profile.serverAutoDetect = authInfo.serverAutoDetect
                        profile.server = server
                        profile.accessId = Int32(authInfo.accessID)
                        profile.accessIdPassword = authInfo.accessIDpwd
                        profile.preferredProtocolVersion = Int32(authInfo.preferredProtocolVersion)
                        
                        return profile
                    }
                    .flatMap { profile in self.profileRepository.save().map { profile } }
                    .map { profile in
                        var bytes = [CChar](repeating: 0, count: Int(SUPLA_GUID_SIZE))
                        if (SAApp.getClientGUID(&bytes)) {
                            AuthProfileItemKeychainHelper.setSecureRandom(
                                Data(bytes.map { UInt8(bitPattern: $0)}),
                                key: AuthProfileItemKeychainHelper.guidKey,
                                id: profile.id
                            )
                        }
                        
                        bytes = [CChar](repeating: 0, count: Int(SUPLA_AUTHKEY_SIZE))
                        if (SAApp.getAuthKey(&bytes)) {
                            AuthProfileItemKeychainHelper.setSecureRandom(
                                Data(bytes.map { UInt8(bitPattern: $0) }),
                                key: AuthProfileItemKeychainHelper.authKey,
                                id: profile.id
                            )
                        }
                    }
                    .subscribeSynchronous()
                
                return true
            } catch {
                SALog.error("Could not restore account because of \(error)")
            }
        }
        
        return false
    }
    
    private func initiateReconnect() {
        let app = SAApp.instance()
        app.cancelAllRestApiClientTasks()
        
        suplaClientProvider.provide()?.reconnect()
    }
}
