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
    
    private let _ctx: NSManagedObjectContext
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<DeleteAllProfileDataUseCase> private var deleteAllProfileDataUseCase
    
    @objc
    init(context: NSManagedObjectContext) {
        _ctx = context
        super.init()
    }
}

extension MultiAccountProfileManager: ProfileManager {

    func create() -> AuthProfileItem {
        return try! profileRepository.create()
            .flatMapFirst { profile in
                profile.advancedSetup = false
                profile.isActive = true
                profile.authInfo = AuthInfo.empty()
                
                return self.profileRepository.save(profile)
                    .map {
                        return profile
                    }
            }
            .subscribeSynchronous()!
    }
    
    func read(id: ProfileID) -> AuthProfileItem? {
        return try? profileRepository.queryItem(id).subscribeSynchronous()!
    }
    
    func update(_ profile: AuthProfileItem) -> Bool {
        do {
            try profileRepository.save(profile).toBlocking().first()
            return true
        } catch {
            return false
        }
    }
    
    func delete(id: ProfileID) -> Bool {
        do {
            try profileRepository.queryItem(id)
                .compactMap { $0 }
                .flatMapFirst { profile in self.profileRepository.delete(profile).map { profile } }
                .flatMapFirst { self.deleteAllProfileDataUseCase.invoke(profile: $0) }
                .subscribeSynchronous()
            
            return true
        } catch {
            return false
        }
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
                    self.profileRepository.save(profiles[0])
                }
                .subscribeSynchronous()
        } catch {
            NSLog("Error occured by saving \(error)")
            return false;
        }
        initiateReconnect()
        
        return true
    }
    
    private func initiateReconnect() {
        let app = SAApp.instance()
        let client = SAApp.suplaClient()
        app.cancelAllRestApiClientTasks()
        client.reconnect()
    }
}
