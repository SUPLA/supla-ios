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

import RxSwift

protocol SaveOrCreateProfileUseCase {
    func invoke(profileId: ProfileID?, name: String, advancedMode: Bool, authInfo: AuthInfo) -> Observable<SaveOrCreateProfileResult>
}

final class SaveOrCreateProfileUseCaseImpl: SaveOrCreateProfileUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<GlobalSettings> private var globalSettings
    
    func invoke(profileId: ProfileID?, name: String, advancedMode: Bool, authInfo: AuthInfo) -> Observable<SaveOrCreateProfileResult> {
        self.profileRepository.getAllProfiles()
            .flatMap { profiles in
                if (self.isNameDuplicated(name: name, profileId: profileId, profiles: profiles)) {
                    return Observable<Void>.error(SaveOrCreateProfileError.duplicatedName)
                }
                if (!authInfo.isAuthDataComplete) {
                    return Observable<Void>.error(SaveOrCreateProfileError.dataIncomplete)
                }
                
                return .just(())
            }.flatMap {
                self.readOrCreateProfile(profileId: profileId)
            }.flatMap { profile in
                let authDataChanged = self.authDataChanged(authInfo: authInfo, profile: profile)
                
                profile.name = name
                profile.advancedSetup = advancedMode
                profile.authInfo = authInfo
                if (authDataChanged) {
                    profile.authInfo = authInfo.copy(preferredProtocolVersion: Int(SUPLA_PROTO_VERSION))
                }
                
                return self.profileRepository
                    .save(profile)
                    .map {
                        var settings = self.globalSettings
                        settings.anyAccountRegistered = true
                        
                        let needsReauth = profile.isActive && authDataChanged
                        if (needsReauth) {
                            self.suplaClientProvider.provide().reconnect()
                        }
                        
                        return SaveOrCreateProfileResult(
                            saved: true,
                            needsReauth: needsReauth
                        )
                    }
            }
    }
    
    private func readOrCreateProfile(profileId: ProfileID?) -> Observable<AuthProfileItem> {
        if let profileId = profileId {
            return profileRepository.queryItem(profileId)
                .flatMap {
                    if let profile = $0 {
                        return Observable.just(profile)
                    } else {
                        return self.createNewProfile()
                    }
                }
        } else {
            return createNewProfile()
        }
    }
    
    private func createNewProfile() -> Observable<AuthProfileItem> {
        profileRepository.create().map {
            $0.isActive = !self.globalSettings.anyAccountRegistered
            return $0
        }
    }
    
    private func isNameDuplicated(
        name: String,
        profileId: ProfileID?,
        profiles: [AuthProfileItem]
    ) -> Bool {
        return profiles.first(where: { $0.displayName == name && $0.objectID != profileId}) != nil
    }
    
    private func authDataChanged(authInfo: AuthInfo, profile: AuthProfileItem) -> Bool {
        guard let currentAuthInfo = profile.authInfo else { return true }
        
        return currentAuthInfo.emailAddress != authInfo.emailAddress
        || currentAuthInfo.serverAutoDetect != authInfo.serverAutoDetect
        || currentAuthInfo.emailAddress != authInfo.emailAddress
        || currentAuthInfo.serverForEmail != authInfo.serverForEmail
        || currentAuthInfo.serverForAccessID != authInfo.serverForAccessID
        || currentAuthInfo.accessID != authInfo.accessID
        || currentAuthInfo.accessIDpwd != authInfo.accessIDpwd
    }
}

struct SaveOrCreateProfileResult: Equatable {
    let saved: Bool
    let needsReauth: Bool
}

enum SaveOrCreateProfileError: Error {
    case duplicatedName
    case dataIncomplete
}
