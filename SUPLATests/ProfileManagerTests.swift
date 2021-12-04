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

    private var profileManager: ProfileManager!
    private var coordinator: NSPersistentStoreCoordinator!
    private var ctx: NSManagedObjectContext {
        let rv = NSManagedObjectContext()
        rv.persistentStoreCoordinator = coordinator
        return rv
    }
    

    override func setUpWithError() throws {
        let modelURL = Bundle.main.url(forResource: "SUPLA",
                                       withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                            configurationName: nil,
                                            at: nil,
                                            options: nil)
        profileManager = MultiAccountProfileManager(context: ctx)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreatesDefaultProfile() throws {
        let profile = profileManager.getCurrentProfile()
        XCTAssertTrue(profile.isActive)
    }
    
    func testProfileUpdatesAuthInfo() throws {
        let authInfo = profileManager.getCurrentAuthInfo()
        let newInfo = AuthInfo(emailAuth: false, serverAutoDetect: false,
                               emailAddress: "", serverForEmail: "",
                               serverForAccessID: "127.0.0.1",
                               accessID: 6666, accessIDpwd: "testing")
        XCTAssertNotEqual(newInfo, authInfo)
        profileManager.updateCurrentAuthInfo(newInfo)
        let profile = profileManager.getCurrentProfile()
        XCTAssertEqual(newInfo, profile.authInfo)
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
}
