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

protocol ActivateProfileUseCase {
    func invoke(profileId: ProfileID, force: Bool) -> Completable
}

final class ActivateProfileUseCaseImpl: ActivateProfileUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<RuntimeConfig> private var runtimeConfig
    @Singleton<SuplaCloudConfigHolder> private var cloudConfigHolder
    @Singleton<ReconnectUseCase> private var reconnectUseCase
    
    func invoke(profileId: ProfileID, force: Bool) ->  Completable {
        profileRepository.queryItem(profileId)
            .flatMapCompletable {
                guard let profile = $0 else {
                    return Completable.complete()
                }
           
                if (profile.isActive && !force) {
                    return Completable.complete()
                }
                
                return self.activateProfile(profile)
            }
    }
    
    private func activateProfile(_ profile: AuthProfileItem) -> Completable {
        profileRepository.getAllProfiles()
            .map { profiles in
                profiles.forEach { $0.isActive = $0.objectID == profile.objectID }
                return profiles
            }
            .flatMapFirst { _ in
                self.profileRepository.save()
            }
            .flatMapCompletable { _ in
                var config = self.runtimeConfig
                config.activeProfileId = profile.objectID
                self.cloudConfigHolder.clean()
                
                return self.reconnectUseCase.invoke()
            }
    }
}
