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

import XCTest
@testable import SUPLA

final class MultiAccountProfileManagerTests: XCTestCase {
    
    private lazy var currentProfile: AuthProfileItem! = {
        AuthProfileItem()
    }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var deleteAllProfileDataUseCase: DeleteAllProfileDataUseCaseMock! = {
        DeleteAllProfileDataUseCaseMock()
    }()
    
    private lazy var runtimeConfig: RuntimeConfigMock! = {
        RuntimeConfigMock()
    }()
    
    private lazy var singleCall: SingleCallMock! = {
        SingleCallMock()
    }()
    
    private lazy var suplaCloudConfigHolder: SuplaCloudConfigHolderMock! = {
        SuplaCloudConfigHolderMock()
    }()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = {
        SuplaClientProviderMock()
    }()
    
    private lazy var manager: MultiAccountProfileManager! = {
        MultiAccountProfileManager()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
        DiContainer.shared.register(type: DeleteAllProfileDataUseCase.self, component: deleteAllProfileDataUseCase!)
        DiContainer.shared.register(type: RuntimeConfig.self, component: runtimeConfig!)
        DiContainer.shared.register(type: SingleCall.self, component: singleCall!)
        DiContainer.shared.register(type: SuplaCloudConfigHolder.self, component: suplaCloudConfigHolder!)
        DiContainer.shared.register(type: SuplaClientProvider.self, component: suplaClientProvider!)
        
        profileRepository.activeProfileObservable = .just(currentProfile)
    }
    
    override func tearDown() {
        manager = nil
        
        profileRepository = nil
        deleteAllProfileDataUseCase = nil
        runtimeConfig = nil
        singleCall = nil
        suplaCloudConfigHolder = nil
        suplaClientProvider = nil
        
        currentProfile = nil
    }
    
    func test_shouldSkipActivateProfileWhenActive() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = true
        
        profileRepository.queryItemByIdObservable = .just(profile)
        
        // when
        let result = manager.activateProfile(id: profile.objectID, force: false)
        
        // then
        XCTAssertFalse(result)
    }
    
    func test_shouldActivateProfileWhenNotActive() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = false
        
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.allProfilesObservable = .just([profile, AuthProfileItem(testContext: nil)])
        
        // when
        let result = manager.activateProfile(id: profile.objectID, force: false)
        
        // then
        XCTAssertTrue(result)
        
        XCTAssertEqual(profileRepository.allProfilesCalls, 1)
        XCTAssertEqual(profileRepository.saveCounter, 1)
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [nil, profile.objectID])
        XCTAssertEqual(suplaCloudConfigHolder.cleanCalls, 1)
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 1)
    }
    
    func test_shouldNotActivateProfileCouldNotLoadAllProfiles() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = false
        
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.allProfilesObservable = .error(GeneralError.illegalState(message: "??"))
        
        // when
        let result = manager.activateProfile(id: profile.objectID, force: false)
        
        // then
        XCTAssertFalse(result)
        
        XCTAssertEqual(profileRepository.allProfilesCalls, 1)
        XCTAssertEqual(profileRepository.saveCounter, 0)
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [nil])
        XCTAssertEqual(suplaCloudConfigHolder.cleanCalls, 0)
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 0)
    }
}
