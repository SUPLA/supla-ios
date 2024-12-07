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
    func invoke(profileId: Int32) -> Observable<DeleteProfileResult>
}

final class DeleteProfileUseCaseImpl: DeleteProfileUseCase {
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SingleCall> private var singleCall
    @Singleton<DeleteAllProfileDataUseCase> private var deleteAllProfileDataUseCase
    @Singleton<ActivateProfileUseCase> private var activateProfileUseCase
    @Singleton<RuntimeConfig> private var runtimeConfig
    @Singleton<GlobalSettings> private var settings
    @Singleton<DisconnectUseCase> private var disconnectUseCase
    @Singleton<SuplaAppStateHolder> private var suplaAppStateHolder
    
    func invoke(profileId: Int32) -> Observable<DeleteProfileResult> {
        profileRepository.getProfile(withId: profileId)
            .flatMapFirst { profile in
                guard let profile else {
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
                                serverAddress: serverAddress
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
            if profile.isAuthDataComplete {
                let authDetails = SingleCallWrapper.prepareAuthorizationDetails(for: profile)
                let tokenDetails = SingleCallWrapper.prepareClientToken(for: nil, andProfile: profile.name)
                
                do {
                    try self.singleCall.registerPushToken(authDetails, profile.preferredProtocolVersion, tokenDetails)
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
                        profileId: inactiveProfile.id,
                        force: true
                    )
                    .andThen(
                        self.removeLocally(profile: profile)
                            .map {
                                DeleteProfileResult(
                                    restartNeeded: false,
                                    reauthNeeded: true,
                                    serverAddress: serverAddress
                                )
                            }
                    )
                } else {
                    // Removing last account
                    return self.removeLocally(profile: profile)
                        .map {
                            var config = self.runtimeConfig
                            
                            config.activeProfileId = nil
                            self.settings.anyAccountRegistered = false
                            self.suplaAppStateHolder.handle(event: .noAccount)
                            
                            return DeleteProfileResult(
                                restartNeeded: true,
                                reauthNeeded: true,
                                serverAddress: serverAddress
                            )
                        }
                }
            }
    }
    
    private func getServerAddress(_ profile: AuthProfileItem) -> String? {
        if (profile.authorizationType == .email && profile.serverAutoDetect) {
            return nil
        } else {
            return profile.server?.address
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
    var serverAddress: String?
}
