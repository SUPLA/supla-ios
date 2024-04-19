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

@testable import SUPLA

final class SAAuthorizationDialogVMTests: ViewModelTest<SAAuthorizationDialogViewState, SAAuthorizationDialogViewEvent> {
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var suplaClientProvider: SuplaClientProviderMock! = SuplaClientProviderMock()
    private lazy var authorizeUseCase: AuthorizeUseCaseMock! = AuthorizeUseCaseMock()
    private lazy var schedulers: SuplaSchedulersMock! = SuplaSchedulersMock()
    
    private lazy var viewModel: SAAuthorizationDialogVM! = SAAuthorizationDialogVM()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
        DiContainer.shared.register(type: AuthorizeUseCase.self, authorizeUseCase!)
        DiContainer.shared.register(type: SuplaSchedulers.self, schedulers!)
    }
    
    override func tearDown() {
        profileRepository = nil
        suplaClientProvider = nil
        authorizeUseCase = nil
        schedulers = nil
        viewModel = nil
        
        super.tearDown()
    }
    
    func test_shouldLoadProfile_onViewDidLoad() {
        // given
        let email = "test@supla.org"
        let profile = mockProfile(email: email)
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
        // then
        assertStates(expected: [
            SAAuthorizationDialogViewState(),
            SAAuthorizationDialogViewState(
                userName: email,
                isCloudAccount: true
            )
        ])
    }
    
    func test_shouldLoadProfile_onViewDidLoad_privateInstance() {
        // given
        let email = "test@supla.org"
        let profile = mockProfile(email: email, server: "some.url")
        profileRepository.activeProfileObservable = .just(profile)
        suplaClientProvider.suplaClientMock.isRegisteredReturns = true
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
        // then
        assertStates(expected: [
            SAAuthorizationDialogViewState(),
            SAAuthorizationDialogViewState(
                userName: email,
                isCloudAccount: false,
                userNameEnabled: true
            )
        ])
    }
    
    func test_shouldNotStartAuthorization_whenAuthorized() {
        // given
        var authorized = false
        suplaClientProvider.suplaClientMock.isRegisteredReturns = true
        suplaClientProvider.suplaClientMock.isSuperuserAuthorizedReturns = true
        
        // when
        observe(viewModel)
        viewModel.onOk(userName: "", password: "") { authorized = true }
        
        // then
        XCTAssertEqual(authorized, true)
        XCTAssertEqual(authorizeUseCase.parameters.count, 0)
    }
    
    func test_shouldAuthorize_withSuccess() {
        // given
        let user = "test"
        let password = "password"
        var authorized = false
        
        // when
        observe(viewModel)
        viewModel.onOk(userName: user, password: password) { authorized = true }
        schedulers.testScheduler.start()
        
        // then
        assertStates(expected: [
            SAAuthorizationDialogViewState(),
            SAAuthorizationDialogViewState(loading: true),
            SAAuthorizationDialogViewState()
        ])
        XCTAssertEqual(authorized, true)
        XCTAssertTuples(authorizeUseCase.parameters, [(user, password)])
    }
    
    func test_shouldAuthorize_withAuthorizationError() {
        // given
        let user = "test"
        let password = "password"
        let error = "error"
        var authorized = false
        
        authorizeUseCase.returns = .error(AuthorizationError(errorMessage: error))
        
        // when
        observe(viewModel)
        viewModel.onOk(userName: user, password: password) { authorized = true }
        schedulers.testScheduler.start()
        
        // then
        assertStates(expected: [
            SAAuthorizationDialogViewState(),
            SAAuthorizationDialogViewState(loading: true),
            SAAuthorizationDialogViewState(error: error, loading: true),
            SAAuthorizationDialogViewState(error: error)
        ])
        XCTAssertEqual(authorized, false)
        XCTAssertTuples(authorizeUseCase.parameters, [(user, password)])
    }
    
    func test_shouldAuthorize_withUnknownError() {
        // given
        let user = "test"
        let password = "password"
        var authorized = false
        
        authorizeUseCase.returns = .error(GeneralError.illegalArgument(message: ""))
        
        // when
        observe(viewModel)
        viewModel.onOk(userName: user, password: password) { authorized = true }
        schedulers.testScheduler.start()
        
        // then
        assertStates(expected: [
            SAAuthorizationDialogViewState(),
            SAAuthorizationDialogViewState(loading: true),
            SAAuthorizationDialogViewState(error: Strings.General.unknownError, loading: true),
            SAAuthorizationDialogViewState(error: Strings.General.unknownError)
        ])
        XCTAssertEqual(authorized, false)
        XCTAssertTuples(authorizeUseCase.parameters, [(user, password)])
    }
    
    private func mockProfile(email: String, server: String = "srv1.supla.org") -> AuthProfileItem {
        let profile = AuthProfileItem(testContext: nil)
        profile.authInfo = AuthInfo(
            emailAuth: true,
            serverAutoDetect: true,
            emailAddress: email,
            serverForEmail: server,
            serverForAccessID: "",
            accessID: 0,
            accessIDpwd: ""
        )
        
        return profile
    }
}
