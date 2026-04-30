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
import RxSwift

protocol ProfileRepository: RepositoryProtocol where T == AuthProfileItem {
    func getAllProfiles() -> Observable<[ProfileDto]>
    func getAllProfiles() async -> [ProfileDto]
    
    func getActiveProfile() -> Observable<AuthProfileItem>
    func getProfile(withId id: Int32) -> Observable<AuthProfileItem?>
    
    func getAuthorizationEntity(forProfileId id: Int32) async -> SingleCallAuthorizationEntity?
    func getProfileCount() async -> Int
    
    
    func getAllProfilesIntern() -> Observable<[AuthProfileItem]>
    func updateProfilePositions(_ positions: [Int32: Int32]) -> Observable<Void>
    func markProfileActive(_ id: ProfileID) -> Observable<Void>
    
}

final class ProfileRepositoryImpl: Repository<AuthProfileItem>, ProfileRepository {
    
    @Singleton<RuntimeConfig> var config
    
    private let userDefaults = UserDefaults.standard
    
    func getAllProfiles() -> Observable<[ProfileDto]> {
        let request = AuthProfileItem.fetchRequest()
            .ordered(by: "position")
            .ordered(by: "name")
        
        return query(request).map { $0.map(\.dto) }
    }
    
    func getAllProfiles() async -> [ProfileDto] {
        let context = context
        
        return await context.perform {
            let request = AuthProfileItem.fetchRequest()
                .ordered(by: "position")
                .ordered(by: "name")
            
            return try? context.fetch(request).map { $0.dto }
        } ?? []
    }
    
    func getActiveProfile() -> Observable<AuthProfileItem> {
        let request = AuthProfileItem.fetchRequest()
            .ordered(by: "position")
            .ordered(by: "name")
        
        return query(request)
            .map { items in
                for item in items {
                    if (item.isActive) {
                        return item
                    }
                }
                return nil
            }
            .compactMap { $0 }
    }
    
    func getProfile(withId id: Int32) -> Observable<AuthProfileItem?> {
        return queryItem(NSPredicate(format: "id = %d", id))
    }
    
    func getAuthorizationEntity(forProfileId id: Int32) async -> SingleCallAuthorizationEntity? {
        let context = context
        
        return await context.perform {
            let query = AuthProfileItem.fetchRequest()
                .filtered(by: NSPredicate(format: "id = %d", id))
                .ordered(by: "id")
            
            if let profile = try? context.fetch(query).first {
                return profile.authorizationEntity
            }
            
            return nil
        }
    }
    
    func getProfileCount() async -> Int {
        let context = context
        
        return await context.perform {
            let query = AuthProfileItem.fetchRequest()
            return try? context.count(for: query)
        } ?? 0
    }
    
    
    func updateProfilePositions(_ positions: [Int32: Int32]) -> Observable<Void> {
        let request = AuthProfileItem.fetchRequest()
            .ordered(by: "position")
            .ordered(by: "name")
        
        return query(request)
            .map { items in
                    for item in items {
                        item.position = positions[item.id] ?? 0
                    }
            }
            .flatMap { self.save() }
    }
    
    
    func getAllProfilesIntern() -> Observable<[AuthProfileItem]> {
        let request = AuthProfileItem.fetchRequest()
            .ordered(by: "position")
            .ordered(by: "name")
        
        return query(request)
    }
    
    func markProfileActive(_ id: ProfileID) -> Observable<Void> {
        let request = AuthProfileItem.fetchRequest()
            .ordered(by: "position")
            .ordered(by: "name")
        
        return query(request)
            .map { profiles in
                profiles.forEach { $0.isActive = $0.objectID == id }
            }
            .flatMapFirst { self.save() }
    }
}

@objc class ProfileRepositoryProxy: NSObject {
    @objc static var currentProfile: ProfileDtoProxy? {
        @Singleton<ProfileRepository> var profileRepository
        
        return try? profileRepository.getActiveProfile()
            .map { $0.dtoProxy }
            .subscribeSynchronous()
    }
}
