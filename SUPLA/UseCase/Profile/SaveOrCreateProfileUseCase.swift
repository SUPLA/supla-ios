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
    func invoke(profileDto: ProfileDto) -> Observable<SaveOrCreateProfileResult>
}

final class SaveOrCreateProfileUseCaseImpl: SaveOrCreateProfileUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<GlobalSettings> private var globalSettings
    @Singleton<SuplaAppStateHolder> private var stateHolder
    @Singleton<ReadOrCreateProfileServerUseCase> private var readOrCreateProfileServerUseCase
    
    func invoke(profileDto: ProfileDto) -> Observable<SaveOrCreateProfileResult> {
        self.profileRepository.getAllProfiles()
            .map { try self.validateAndFindProfile(profiles: $0, profile: profileDto) }
            .flatMap { self.notNullOrCreate($0) }
            .flatMap { self.setServerRelation($0, profileDto.serverAddress) }
            .flatMap { profile in
                let authDataChanged = self.authDataChanged(profileDto: profileDto, profileDb: profile)
                
                profile.name = profileDto.name
                profile.authorizationType = profileDto.authorizationType
                profile.advancedSetup = profileDto.advancedSetup
                if (!profile.serverAutoDetect && profileDto.serverAutoDetect) {
                    // User changed back to server auto detect. Server must be cleaned up to get it again during connecting
                    profile.server = nil
                }
                profile.serverAutoDetect = profileDto.serverAutoDetect
                profile.email = profileDto.email
                profile.accessId = profileDto.accessId ?? 0
                profile.accessIdPassword = profileDto.accessIdPassword
                // isActive is intentionally not changed - it shouldn't change during edition.
                // There is another use case for profile activation
                
                if (authDataChanged) {
                    profile.preferredProtocolVersion = SUPLA_PROTO_VERSION
                }
                
                return self.profileRepository
                    .save(profile)
                    .map {
                        self.globalSettings.anyAccountRegistered = true
                        
                        let needsReauth = profile.isActive && authDataChanged
                        if (needsReauth) {
                            self.stateHolder.handle(event: .connecting)
                        }
                        
                        return SaveOrCreateProfileResult(
                            saved: true,
                            needsReauth: needsReauth
                        )
                    }
            }
    }
    
    private func validateAndFindProfile(profiles: [AuthProfileItem], profile: ProfileDto) throws -> AuthProfileItem? {
        if (isNameDuplicated(name: profile.name, profileId: profile.id, profiles: profiles)) {
            throw SaveOrCreateProfileError.duplicatedName
        }
        if (!profile.isAuthDataComplete) {
            throw SaveOrCreateProfileError.dataIncomplete
        }
        
        return profiles.first { $0.id == profile.id }
    }
    
    private func notNullOrCreate(_ profile: AuthProfileItem?) -> Observable<AuthProfileItem> {
        if let profile {
            return Observable.just(profile)
        } else {
            return profileRepository
                .create()
                .map {
                    $0.isActive = !self.globalSettings.anyAccountRegistered
                    $0.id = self.globalSettings.nextProfileId
                    return $0
                }
        }
        
    }
    
    private func setServerRelation(_ profile: AuthProfileItem, _ address: String?) -> Observable<AuthProfileItem> {
        if let address, !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.readOrCreateProfileServerUseCase.invoke(address)
                .map {
                    profile.server = $0
                    return profile
                }
        } else {
            Observable.just(profile)
        }
    }
    
    private func isNameDuplicated(
        name: String,
        profileId: Int32?,
        profiles: [AuthProfileItem]
    ) -> Bool {
        return profiles.first(where: { $0.displayName == name && $0.id != profileId}) != nil
    }
    
    private func authDataChanged(profileDto: ProfileDto, profileDb: AuthProfileItem) -> Bool {
        return profileDb.email != profileDto.email
        || profileDb.serverAutoDetect != profileDto.serverAutoDetect
        || profileDb.server?.address != profileDto.serverAddress
        || profileDb.accessId != profileDto.accessId
        || profileDb.accessIdPassword != profileDto.accessIdPassword
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
