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
    func invoke(profileId: ProfileID, force: Bool) -> Observable<Bool>
}

final class ActivateProfileUseCaseImpl: ActivateProfileUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<RuntimeConfig> private var runtimeConfig
    @Singleton<SuplaCloudConfigHolder> private var cloudConfigHolder
    @Singleton<SuplaAppWrapper> private var suplaApp
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    
    func invoke(profileId: ProfileID, force: Bool) -> Observable<Bool> {
        profileRepository.queryItem(profileId)
            .flatMap {
                guard let profile = $0 else {
                    return Observable.just(false)
                }
                
                if (profile.isActive && !force) {
                    return Observable.just(false)
                }
                
                return self.activateProfile(profile)
            }
    }
    
    private func activateProfile(_ profile: AuthProfileItem) -> Observable<Bool> {
        profileRepository.getAllProfiles()
            .map { profiles in
                profiles.forEach { $0.isActive = $0.objectID == profile.objectID }
                return profiles
            }
            .flatMapFirst { profiles in
                self.profileRepository.save()
            }.map {
                var config = self.runtimeConfig
                config.activeProfileId = profile.objectID
                self.cloudConfigHolder.clean()
                
                // reconect
                self.suplaApp.cancelAllRestApiClientTasks()
                self.suplaClientProvider.provide().reconnect()
                
                return true
            }
    }
    
}
