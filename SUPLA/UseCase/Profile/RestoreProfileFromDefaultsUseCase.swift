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
    
struct RestoreProfileFromDefaults {
    protocol UseCase {
        func invoke() -> Bool
    }
    
    final class Implementation: UseCase {
        
        @Singleton<ReadOrCreateProfileServerUseCase> private var readOrCreateProfileServerUseCase
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<GlobalSettings> private var settings
        
        private let userDefaults = UserDefaults.standard
        
        func invoke() -> Bool {
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
    }
}
