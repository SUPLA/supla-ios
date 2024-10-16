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

protocol DeleteProfileUseCase {
    func invoke(profileId: ProfileID) -> Observable<DeleteProfileResult>
}

final class DeleteProfileUseCaseImpl: DeleteProfileUseCase {
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SingleCall> private var singleCall
    @Singleton<DeleteAllProfileDataUseCase> private var deleteAllProfileDataUseCase
    @Singleton<ActivateProfileUseCase> private var activateProfileUseCase
    @Singleton<RuntimeConfig> private var runtimeConfig
    @Singleton<GlobalSettings> var settings
    @Singleton<DisconnectUseCase> private var disconnectUseCase
    @Singleton<SuplaAppStateHolder> private var suplaAppStateHolder
    
    func invoke(profileId: ProfileID) -> Observable<DeleteProfileResult> {
        profileRepository.queryItem(profileId)
            .flatMap { profile in
                guard let profile = profile else {
                    return Observable<DeleteProfileResult>.error(DeleteProfileError.profileNotExist)
                }
                
                if (profile.isActive) {
                    return self.disconnectUseCase.invoke()
                        .andThen(self.activateAndRemove(profile: profile))
                } else {
                    let serverAddress = self.getServerAddress(profile)
                    return self.removeLocally(profile: profile)
                        .map {
                            DeleteProfileResult(
                                restartNeeded: false,
                                reauthNeeded: false,
                                servertAddress: serverAddress
                            )
                        }
                }
            }
    }
    
    private func removeLocally(profile: AuthProfileItem) -> Observable<Void> {
        removeToken(profile: profile)
            .andThen(deleteAllProfileDataUseCase.invoke(profile: profile))
            .flatMap { self.profileRepository.delete(profile) }
            .flatMap { self.profileRepository.save() }
    }
    
    private func removeToken(profile: AuthProfileItem) -> Completable {
        Completable.create { completable in
            
            if let authInfo = profile.authInfo,
               authInfo.isAuthDataComplete
            {
                var authDetails = SingleCallWrapper.prepareAuthorizationDetails(for: profile)
                var tokenDetails = SingleCallWrapper.prepareClientToken(for: nil, andProfile: profile.name)
                
                do {
                    try self.singleCall.registerPushToken(authDetails, Int32(authInfo.preferredProtocolVersion), tokenDetails)
                } catch {
                    SALog.error("Push token removal failed with error: \(error)")
                }
            } else {
                SALog.info("Push token removal skipped because of incomplete data")
            }
            
            completable(.completed)
            return Disposables.create()
        }
    }
    
    private func activateAndRemove(profile: AuthProfileItem) -> Observable<DeleteProfileResult> {
        let serverAddress = getServerAddress(profile)
        
        return profileRepository.getAllProfiles()
            .flatMap { profiles in
                if let inactiveProfile = profiles.first(where: { !$0.isActive }) {
                    return self.activateProfileUseCase.invoke(
                        profileId: inactiveProfile.objectID,
                        force: true
                    )
                    .andThen(
                        self.removeLocally(profile: profile)
                            .map {
                                DeleteProfileResult(
                                    restartNeeded: false,
                                    reauthNeeded: true,
                                    servertAddress: serverAddress
                                )
                            }
                    )
                } else {
                    // Removing last account
                    return self.removeLocally(profile: profile)
                        .map {
                            var config = self.runtimeConfig
                            var settings = self.settings
                            
                            config.activeProfileId = nil
                            settings.anyAccountRegistered = false
                            self.suplaAppStateHolder.handle(event: .noAccount)
                            
                            return DeleteProfileResult(
                                restartNeeded: true,
                                reauthNeeded: true,
                                servertAddress: serverAddress
                            )
                        }
                }
            }
    }
    
    private func getServerAddress(_ profile: AuthProfileItem) -> String? {
        guard let authInfo = profile.authInfo else { return nil }
        
        if (authInfo.emailAuth && authInfo.serverAutoDetect) {
            return nil
        } else if (authInfo.emailAuth) {
            return authInfo.serverForEmail
        } else {
            return authInfo.serverForAccessID
        }
    }
}

enum DeleteProfileError: Error {
    case profileNotExist
    case otherProfileNotActivated
}

struct DeleteProfileResult: Equatable {
    var restartNeeded: Bool
    var reauthNeeded: Bool
    var servertAddress: String?
}
