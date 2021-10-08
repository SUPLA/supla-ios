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
    private let _advancedMode = BehaviorRelay(value: true)
    private let _advancedModeAuthType = BehaviorRelay(value: AuthVM.AuthType.email)
    private let _createAccountRequest = BehaviorRelay<Void>(value: ())
    private let _autoServerSelected = BehaviorRelay(value: false)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AuthVM(basicEmail: _basicEmail.asObservable(),
                     toggleAdvancedState: _advancedMode.asObservable(),
                     advancedModeAuthType: _advancedModeAuthType.asObservable(),
                     createAccountRequest: _createAccountRequest.asObservable(),
                     autoServerSelected: _autoServerSelected.asObservable())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAutoServerEnabled() throws {
        XCTAssertNotNil(sut.serverAddress.single())
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
