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

@testable import SUPLA

class AuthVMTests: XCTestCase {
    
    private var sut: AuthVM!
    private let _basicEmail = BehaviorRelay<String?>(value: "")
    private let _advancedEmail = BehaviorRelay<String?>(value: "")
    private let _accessID = BehaviorRelay<Int?>(value: nil)
    private let _accessIDpwd = BehaviorRelay<String?>(value: "")
    private let _serverAddr = BehaviorRelay<String?>(value: nil)
    private let _advancedMode = BehaviorRelay(value: true)
    private let _advancedModeAuthType = BehaviorRelay(value: AuthVM.AuthType.email)
    private let _createAccountRequest = BehaviorRelay<Void>(value: ())
    private let _autoServerSelected = BehaviorRelay(value: false)
    private let _formSubmitRequest = BehaviorRelay<Void>(value: ())
    
    class MockCfgProvider: AuthCfgProvider {
        func loadCurrentAuthCfg() -> AuthCfg? { return nil }
        func storeCurrentAuthCfg(_ ac: AuthCfg) {}
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bindings = AuthVM.Bindings(basicEmail: _basicEmail.asObservable(),
                                       advancedEmail: _advancedEmail.asObservable(),
                                       accessID: _accessID.asObservable(),
                                       accessIDpwd: _accessIDpwd.asObservable(),
                                       serverAddress: _serverAddr.asObservable(),
                                       toggleAdvancedState: _advancedMode.asObservable(),
                                       advancedModeAuthType: _advancedModeAuthType.asObservable(),
                                       createAccountRequest: _createAccountRequest.asObservable(),
                                       autoServerSelected: _autoServerSelected.asObservable(),
                                       formSubmitRequest: _formSubmitRequest.asObservable())
        sut = AuthVM(bindings: bindings, authConfigProvider: MockCfgProvider())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAutoServerEnabled() throws {
        let bag = DisposeBag()
        XCTAssertNotNil(sut.serverAddress.single())
        _advancedMode.accept(true)
        _advancedModeAuthType.accept(.email)
        let expectServerAddressNotEmpty = expectation(description: "Server address is set to non-empty value")
        sut.serverAddress.subscribe(onNext: { addr in
            if addr == "test.server.net" { expectServerAddressNotEmpty.fulfill() }
        }).disposed(by: bag)
        _serverAddr.accept("test.server.net")
        wait(for: [expectServerAddressNotEmpty],timeout: 0.1)
        
        _autoServerSelected.accept(true)
        let expectServerAddressEmpty = expectation(description: "server address is empty after auto server detection is enabled")
        sut.serverAddress.subscribe(onNext: { addr in
            if addr == nil || addr!.isEmpty { expectServerAddressEmpty.fulfill() }
        }).disposed(by: bag)
        wait(for: [expectServerAddressEmpty], timeout: 0.1)
    }
}
