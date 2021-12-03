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
import RxSwift
import RxCocoa
import CoreData

@testable import SUPLA

class AuthVMTests: XCTestCase {
    
    private var sut: AuthVM!
    private let _basicEmail = BehaviorRelay<String?>(value: "")
    private let _advancedEmail = BehaviorRelay<String?>(value: "")
    private let _accessID = BehaviorRelay<Int?>(value: nil)
    private let _accessIDpwd = BehaviorRelay<String?>(value: "")
    private let _serverAddrEmail = BehaviorRelay<String?>(value: nil)
    private let _serverAddrAccessID = BehaviorRelay<String?>(value: nil)
    private let _advancedMode = BehaviorRelay(value: true)
    private let _advancedModeAuthType = BehaviorRelay(value: AuthVM.AuthType.email)
    private let _createAccountRequest = BehaviorRelay<Void>(value: ())
    private let _autoServerSelected = BehaviorRelay(value: false)
    private let _formSubmitRequest = BehaviorRelay<Void>(value: ())

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

        let bindings = AuthVM.Inputs(basicEmail: _basicEmail.asObservable(),
                                     advancedEmail: _advancedEmail.asObservable(),
                                     accessID: _accessID.asObservable(),
                                     accessIDpwd: _accessIDpwd.asObservable(),
                                     serverAddressForEmail: _serverAddrEmail.asObservable(),
                                     serverAddressForAccessID: _serverAddrAccessID.asObservable(),
                                     toggleAdvancedState: _advancedMode.asObservable(),
                                     advancedModeAuthType: _advancedModeAuthType.asObservable(),
                                     createAccountRequest: _createAccountRequest.asObservable(),
                                     autoServerSelected: _autoServerSelected.asObservable(),
                                     formSubmitRequest: _formSubmitRequest.asObservable())
        sut = AuthVM(bindings: bindings, profileManager: profileManager)
    }

    func testAutoServerEnabled() throws {
        let bag = DisposeBag()
        XCTAssertNotNil(sut.serverAddressForEmail.single())
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(.email)
        let expectServerAddressNotEmpty = expectation(description: "Server address is set to non-empty value")
        sut.serverAddressForEmail.subscribe(onNext: { addr in
            if addr == "test.server.net" { expectServerAddressNotEmpty.fulfill() }
        }).disposed(by: bag)
        _serverAddrEmail.accept("test.server.net")
        wait(for: [expectServerAddressNotEmpty],timeout: 0.1)
        
        _autoServerSelected.accept(true)
        let expectServerAddressEmpty = expectation(description: "server address is empty after auto server detection is enabled")
        sut.serverAddressForEmail.subscribe(onNext: { addr in
            if addr == nil || addr!.isEmpty { expectServerAddressEmpty.fulfill() }
        }).disposed(by: bag)
        wait(for: [expectServerAddressEmpty], timeout: 0.1)
    }

    func testDisablingAutoServerPrefillsServerAddress() throws {
        var email: String?
        var isAuto: Bool?
        var serverAddr: String?
        
        let bag = DisposeBag()

        sut.emailAddress.subscribe { email = $0 }.disposed(by: bag)
        sut.isServerAutoDetect.subscribe { isAuto = $0 }.disposed(by: bag)
        sut.serverAddressForEmail.subscribe { serverAddr = $0 }.disposed(by: bag)

        _basicEmail.accept("testing@tst.net")

        
        XCTAssertTrue(isAuto!)
        XCTAssertEqual("testing@tst.net", email)
        XCTAssertTrue(serverAddr!.isEmpty)

        _autoServerSelected.accept(false)

        XCTAssertFalse(isAuto!)
        XCTAssertEqual("testing@tst.net", email)
        XCTAssertEqual("tst.net", serverAddr)
    }

    func testDisablingAutoServerDoesNotPrefillServerIfEmailEmpty() throws {
        var email: String?
        var isAuto: Bool?
        var serverAddr: String?
        
        let bag = DisposeBag()

        sut.emailAddress.subscribe { email = $0 }.disposed(by: bag)
        sut.isServerAutoDetect.subscribe { isAuto = $0 }.disposed(by: bag)
        sut.serverAddressForEmail.subscribe { serverAddr = $0 }.disposed(by: bag)

        _basicEmail.accept("testing@tst.net")

        
        XCTAssertTrue(isAuto!)
        XCTAssertTrue(email!.isEmpty)
        XCTAssertTrue(serverAddr!.isEmpty)

        _autoServerSelected.accept(false)

        XCTAssertFalse(isAuto!)
        XCTAssertTrue(email!.isEmpty)
        XCTAssertTrue(serverAddr!.isEmpty)
        
    }

    func testSeparateServerAddressForAccessID() {
        var serverForEmail: String = ""
        var serverForAccessID: String = ""

        let bag = DisposeBag()

        sut.serverAddressForEmail.subscribe {
            serverForEmail = $0!
        }.disposed(by: bag)
        sut.serverAddressForAccessID.subscribe {
            serverForAccessID = $0!
        }.disposed(by: bag)

        _serverAddrEmail.accept("email.server.com")
        _serverAddrAccessID.accept("aid.server.com")

        XCTAssertEqual(serverForEmail, "email.server.com")
        XCTAssertEqual(serverForAccessID, "aid.server.com")
    }

    func testConfirmUpdatesSettingsWithNewValues() {
        let oldProfile = profileManager.getCurrentProfile()
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(AuthVM.AuthType.accessId)
        _accessID.accept(345)
        _accessIDpwd.accept("topsecret")
        _serverAddrAccessID.accept("s1.testing.net")

      _formSubmitRequest.accept({}())

        let newProfile = profileManager.getCurrentProfile()
        XCTAssertNotEqual(oldProfile, newProfile)

        XCTAssertTrue(newProfile.advancedSetup)
        XCTAssertFalse(newProfile.authInfo!.emailAuth)
        XCTAssertEqual(345, newProfile.authInfo!.accessID)
        XCTAssertEqual("topsecret", newProfile.authInfo!.accessIDpwd)
        XCTAssertEqual("s1.testing.net",
                       newProfile.authInfo!.serverForAccessID)
    }
}
