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

@testable import SUPLA

final class ProfileRepositoryMock: BaseRepositoryMock<AuthProfileItem>, ProfileRepository {
    
    var activeProfileObservable: Observable<AuthProfileItem> = Observable.empty()
    var activeProfileCalls = 0
    func getActiveProfile() -> Observable<AuthProfileItem> {
        activeProfileCalls += 1
        return activeProfileObservable
    }
    
    var allProfilesObservable: Observable<[ProfileDto]> = Observable.empty()
    var allProfilesCalls = 0
    func getAllProfiles() -> Observable<[ProfileDto]> {
        allProfilesCalls += 1
        return allProfilesObservable
    }
    
    func getAllProfiles() async -> [ProfileDto] {
        []
    }
    
    var getProfileWithIdMock: FunctionMock<Int32, Observable<AuthProfileItem?>> = FunctionMock()
    func getProfile(withId id: Int32) -> Observable<AuthProfileItem?> {
        getProfileWithIdMock.handle(id)
    }
    
    var getAuthorizationEntityMock: FunctionMock<Int32, SingleCallAuthorizationEntity?> = FunctionMock()
    func getAuthorizationEntity(forProfileId id: Int32) async -> SingleCallAuthorizationEntity? {
        getAuthorizationEntityMock.handle(id)
    }
    
    var getProfileCountMock: FunctionMock<Void, Int> = FunctionMock()
    func getProfileCount() async -> Int {
        getProfileCountMock.handle(())
    }
    
    let allProfilesInternMock: FunctionMock<Void, Observable<[AuthProfileItem]>> = FunctionMock()
    func getAllProfilesIntern() -> Observable<[AuthProfileItem]> {
        allProfilesInternMock.handle(())
    }
    
    func updateProfilePositions(_ positions: [Int32 : Int32]) -> Observable<Void> {
        .empty()
    }
    
    let markProfileActiveMock: FunctionMock<ProfileID, Observable<Void>> = .init()
    func markProfileActive(_ id: ProfileID) -> Observable<Void> {
        markProfileActiveMock.handle(id)
    }
}
