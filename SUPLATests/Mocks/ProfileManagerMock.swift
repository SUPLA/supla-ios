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

@testable import SUPLA

final class ProfileManagerMock : ProfileManager {
    let item: AuthProfileItem
    
    var updateResults: [Bool]? = nil
    var updatedProfiles: [ProfileID] = []
    
    var deleteResults: [Bool]? = nil
    var deletedProfiles: [ProfileID] = []
    
    var allProfilesResult: [AuthProfileItem]? = nil
    
    var activateResults: [Bool]? = nil
    var activatedProfiles: [ActivatedProfile] = []
    
    init(item: AuthProfileItem) {
        self.item = item
    }
    
    func create() -> AuthProfileItem { item }
    func read(id: ProfileID) -> AuthProfileItem? { item }
    func update(_ profile: AuthProfileItem) -> Bool {
        updatedProfiles.append(profile.objectID)
        
        if let result = updateResults?[updatedProfiles.count - 1] {
            return result
        } else {
            return true
        }
    }
    func delete(id: ProfileID) -> Bool {
        deletedProfiles.append(id)
        
        if let result = deleteResults?[deletedProfiles.count - 1] {
            return result
        } else {
            return true
        }
    }
    
    func getAllProfiles() -> [AuthProfileItem] {
        if let result = allProfilesResult {
            return result
        } else {
            return []
        }
    }
    
    func getCurrentProfile() -> AuthProfileItem? { nil }
    
    func activateProfile(id: ProfileID, force: Bool) -> Bool {
        activatedProfiles.append(ActivatedProfile(id: id, force: force))
        
        if let result = activateResults?[activatedProfiles.count - 1] {
            return result
        } else {
            return true
        }
    }
    
    struct ActivatedProfile: Equatable {
        let id: ProfileID
        let force: Bool
    }
}
