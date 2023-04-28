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
import CoreData
@testable import SUPLA

class ProfileManagerTests: XCTestCase {

    private lazy var ctx: NSManagedObjectContext! = { setUpInMemoryManagedObjectContext() }()
    private lazy var profileManager: ProfileManager! = { MultiAccountProfileManager(context: ctx) }()
    private lazy var runtimeConfig: RuntimeConfigMock! = { RuntimeConfigMock() }()
    

    override func setUp() {
        DiContainer.shared.register(type: RuntimeConfig.self, component: runtimeConfig!)
    }

    override func tearDown() {
        profileManager = nil
        runtimeConfig = nil
    }

    func testAuthInfoPassesEqualityTest() throws {
        let a1 = AuthInfo(emailAuth: true, serverAutoDetect: true,
                          emailAddress: "test1@test.net",
                          serverForEmail: "hacker1", serverForAccessID: "",
                          accessID: 0, accessIDpwd: "")
        let a2 = AuthInfo(emailAuth: true, serverAutoDetect: true,
                          emailAddress: "test1@test.net",
                          serverForEmail: "hacker1", serverForAccessID: "",
                          accessID: 0, accessIDpwd: "")
        XCTAssertEqual(a1, a2)
    }
    
    func testAuthInfoPassesInequalityTest() throws {
        let a1 = AuthInfo(emailAuth: true, serverAutoDetect: true,
                          emailAddress: "test1@test.net",
                          serverForEmail: "hacker1", serverForAccessID: "",
                          accessID: 0, accessIDpwd: "")
        let a2 = AuthInfo(emailAuth: true, serverAutoDetect: false,
                          emailAddress: "test1@test.net",
                          serverForEmail: "hacker1", serverForAccessID: "",
                          accessID: 0, accessIDpwd: "")
        XCTAssertNotEqual(a1, a2)
    }
    
    func test_getNoProfile_whenNoCurrentProfile() {
        // given
        runtimeConfig.activeProfileId = nil
        
        // when
        let activeProfile = profileManager.getCurrentProfile()
        
        // then
        XCTAssertNil(activeProfile)
    }
    
    func test_getActiveProfile_whenExists() {
        // given
        let profile = profileManager.create()
        runtimeConfig.activeProfileIdReturns = profile.objectID
        
        // when
        let activeProfile = profileManager.getCurrentProfile()
        
        // then
        XCTAssertIdentical(profile, activeProfile)
    }
    
    func test_shouldDeleteSucceed_whenItemDeleted() {
        // given
        let profile = profileManager.create()
        
        // when
        let result = profileManager.delete(id: profile.objectID)
        
        // then
        XCTAssertTrue(result)
    }
    
    func test_shouldDeleteFail_whenItemNotDeleted() {
        // given
        let profile = profileManager.create()
        
        // when
        _ = profileManager.delete(id: profile.objectID)
        let result = profileManager.delete(id: profile.objectID)
        
        // then
        XCTAssertFalse(result)
    }
    
    func test_shouldNotActivateProfile_whenProfileAlreadyActive() {
        // given
        let profile = profileManager.create()
        
        // when
        let result = profileManager.activateProfile(id: profile.objectID, force: false)
        
        // then
        XCTAssertFalse(result)
    }
    
    func test_shouldActivateProfile_whenProfileNotActive() {
        // given
        let profile = profileManager.create()
        profile.isActive = false
        _ = profileManager.update(profile)
        
        // when
        let result = profileManager.activateProfile(id: profile.objectID, force: false)
        
        // then
        XCTAssertTrue(result)
        XCTAssertTrue(profile.isActive)
        XCTAssertEqual(runtimeConfig.activeProfileIdValues.count, 2)
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [nil, profile.objectID])
    }
    
    func test_shouldDeactivateOtherProfile_whenActivating() {
        // given
        let first = profileManager.create()
        first.isActive = false
        _ = profileManager.update(first)
        let second = profileManager.create()
        
        // when
        let result = profileManager.activateProfile(id: first.objectID, force: false)
        
        // then
        XCTAssertTrue(result)
        XCTAssertTrue(first.isActive)
        XCTAssertFalse(second.isActive)
        XCTAssertEqual(runtimeConfig.activeProfileIdValues.count, 2)
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [nil, first.objectID])
    }
}
