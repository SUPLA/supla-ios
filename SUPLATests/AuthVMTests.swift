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

    private var profileId: NSManagedObjectID?
    
    private lazy var sut: AuthVM! = {
        let bindings = AuthVM.Inputs(basicEmail: _basicEmail.asObservable(),
                                     basicName: _basicName.asObservable(),
                                     advancedEmail: _advancedEmail.asObservable(),
                                     advancedName: _advancedName.asObservable(),
                                     accessID: _accessID.asObservable(),
                                     accessIDpwd: _accessIDpwd.asObservable(),
                                     serverAddressForEmail: _serverAddrEmail.asObservable(),
                                     serverAddressForAccessID: _serverAddrAccessID.asObservable(),
                                     toggleAdvancedState: _advancedMode.asObservable(),
                                     advancedModeAuthType: _advancedModeAuthType.asObservable(),
                                     createAccountRequest: _createAccountRequest.asObservable(),
                                     autoServerSelected: _autoServerSelected.asObservable(),
                                     formSubmitRequest: _formSubmitRequest.asObservable(),
                                     accountDeleteRequest: _accountDeleteRequest.asObservable())
        return AuthVM(bindings: bindings, profileManager: profileManager,
                      profileId: profileId)
    }()
    private let _basicEmail = BehaviorRelay<String?>(value: "")
    private let _basicName = BehaviorRelay<String?>(value: "")
    private let _advancedEmail = BehaviorRelay<String?>(value: "")
    private let _advancedName = BehaviorRelay<String?>(value: "")
    private let _accessID = BehaviorRelay<Int?>(value: nil)
    private let _accessIDpwd = BehaviorRelay<String?>(value: "")
    private let _serverAddrEmail = BehaviorRelay<String?>(value: nil)
    private let _serverAddrAccessID = BehaviorRelay<String?>(value: nil)
    private let _advancedMode = BehaviorRelay(value: false)
    private let _advancedModeAuthType = BehaviorRelay(value: AuthVM.AuthType.email)
    private let _createAccountRequest = PublishRelay<Void>()
    private let _autoServerSelected = BehaviorRelay(value: true)
    private let _formSubmitRequest = PublishRelay<Void>()
    private let _accountDeleteRequest = PublishRelay<Void>()

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
        _basicEmail.accept("my@email.com")
        _advancedEmail.accept("")
        _accessID.accept(nil)
        _accessIDpwd.accept("")
        _serverAddrEmail.accept("server.email.com")
        _serverAddrAccessID.accept(nil)
        _advancedMode.accept(false)
        _advancedModeAuthType.accept(.email)
        _autoServerSelected.accept(false)
        profileId = nil
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
        _autoServerSelected.accept(false)
        _autoServerSelected.accept(true)
        let expectServerAddressEmpty = expectation(description: "server address is empty after auto server detection is enabled")
        sut.serverAddressForEmail.subscribe(onNext: { addr in
            if addr == nil || addr!.isEmpty { expectServerAddressEmpty.fulfill() }
        }).disposed(by: bag)
        wait(for: [expectServerAddressEmpty], timeout: 0.1)
    }
    
    func testNoChangeOnAutoServerMaintainsServerAddress() throws {
        let ai = profileManager.getCurrentAuthInfo()
        ai.serverForEmail = "a.test.net"
        profileManager.updateCurrentAuthInfo(ai)
        let addr = profileManager.getCurrentAuthInfo().serverForEmail
        XCTAssertFalse(addr.isEmpty)
        _ = sut
        _formSubmitRequest.accept(())

        let addr2 = profileManager.getCurrentAuthInfo().serverForEmail
        XCTAssertEqual(addr, addr2)
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
        _advancedEmail.accept("")
        
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
        XCTAssertEqual(false, profileManager.getCurrentProfile().advancedSetup)

        let oldAuthInfo = profileManager.getCurrentProfile().authInfo!.clone()
        profileId = profileManager.getCurrentProfile().objectID
        _ = sut
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(AuthVM.AuthType.accessId)
        _accessID.accept(345)
        _accessIDpwd.accept("topsecret")
        _serverAddrAccessID.accept("s1.testing.net")
        _formSubmitRequest.accept({}())

        let newAuthInfo = profileManager.getCurrentProfile().authInfo
        XCTAssertNotEqual(oldAuthInfo, newAuthInfo)

        XCTAssertTrue(profileManager.getCurrentProfile().advancedSetup)
        XCTAssertFalse(newAuthInfo!.emailAuth)
        XCTAssertEqual(345, newAuthInfo!.accessID)
        XCTAssertEqual("topsecret", newAuthInfo!.accessIDpwd)
        XCTAssertEqual("s1.testing.net",
                       newAuthInfo!.serverForAccessID)
    }
    
    func testReturningToBasicModeRequiresEmailAuto1() {
        let disposeBag = DisposeBag()
        _ = sut

        var isAdvanced: Bool = false
        var alertTriggered: Bool = false

        // Initial conditions
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(.accessId)
        _autoServerSelected.accept(false)

        // Capture values for assertions
        sut.isAdvancedMode.subscribe { isAdvanced = $0 }.disposed(by: disposeBag)
        sut.basicModeUnavailable.subscribe(onNext: { alertTriggered = true })
            .disposed(by: disposeBag)
        
        // Attempt to switch to basic mode
        _advancedMode.accept(false)
        
        // ... should not succeed
        XCTAssertTrue(isAdvanced)
        XCTAssertTrue(alertTriggered)
    }
    
    func testReturningToBasicModeRequiresEmailAuto2() {
        let disposeBag = DisposeBag()
        _ = sut

        var isAdvanced: Bool = false
        var alertTriggered: Bool = false
        
        // Initial conditions
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(.accessId)
        _autoServerSelected.accept(false)
        
        // Capture values for assertions
        sut.isAdvancedMode.subscribe { isAdvanced = $0 }.disposed(by: disposeBag)
        sut.basicModeUnavailable.subscribe(onNext: { alertTriggered = true })
            .disposed(by: disposeBag)
        
        // Partial fulfill preconditions for entering basic mode
        _advancedModeAuthType.accept(.email)

        // Attempt to switch to basic mode
        _advancedMode.accept(false)
        
        // ... should not succeed
        XCTAssertTrue(isAdvanced)
        XCTAssertTrue(alertTriggered)
    }
    
    func testReturningToBasicModeRequiresEmailAuto3() {
        let disposeBag = DisposeBag()
        _ = sut

        var isAdvanced: Bool = false
        var alertTriggered: Bool = false
        
        // Initial conditions
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(.accessId)
        _autoServerSelected.accept(false)
        
        // Capture values for assertions
        sut.isAdvancedMode.subscribe { isAdvanced = $0 }.disposed(by: disposeBag)
        sut.basicModeUnavailable.subscribe(onNext: { alertTriggered = true })
            .disposed(by: disposeBag)
        
        // Partial fulfill preconditions for entering basic mode
        _autoServerSelected.accept(true)

        // Attempt to switch to basic mode
        _advancedMode.accept(false)
        
        // ... should not succeed
        XCTAssertTrue(isAdvanced)
        XCTAssertTrue(alertTriggered)
    }

    func testReturningToBasicModeRequiresEmailAuto4() {
        let disposeBag = DisposeBag()
        _ = sut

        var isAdvanced: Bool = false
        var alertTriggered: Bool = false
        
        // Initial conditions
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(.accessId)
        _autoServerSelected.accept(false)
        
        // Capture values for assertions
        sut.isAdvancedMode.subscribe { isAdvanced = $0 }.disposed(by: disposeBag)
        sut.basicModeUnavailable.subscribe(onNext: { alertTriggered = true })
            .disposed(by: disposeBag)
        
        // Fulfill preconditions for entering basic mode
        _advancedModeAuthType.accept(.email)
        _autoServerSelected.accept(true)
        
        // Attempt to switch to basic mode
        _advancedMode.accept(false)
        
        // ... should not succeed
        XCTAssertFalse(isAdvanced)
        XCTAssertFalse(alertTriggered)
    }
    
    func testSubmitWithNoChangesDoesNotRequireReauth() {
        let disposeBag = DisposeBag()
        sut.formSaved.subscribe {
            XCTAssertFalse($0)
        }.disposed(by: disposeBag)
        _formSubmitRequest.accept(())
    }
}
