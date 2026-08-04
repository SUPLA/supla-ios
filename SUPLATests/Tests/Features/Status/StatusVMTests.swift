//
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
    

@testable import SUPLA
import XCTest

final class StatusVMTests: XCTestCase {
    private lazy var stateHolder: SuplaAppStateHolderMock! = SuplaAppStateHolderMock()
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var appRouter: AppRouter! = AppRouter()
    private lazy var authorizationCoordinator: AuthorizationCoordinator! = AuthorizationCoordinator()
    private lazy var disconnectUseCase: DisconnectUseCaseMock! = DisconnectUseCaseMock()
    private lazy var schedulers: SuplaSchedulersMock! = SuplaSchedulersMock()
    
    private lazy var viewModel: StatusFeature.ViewModel! = StatusFeature.ViewModel()
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaAppStateHolder.self, stateHolder!)
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: AppRouter.self, appRouter!)
        DiContainer.shared.register(type: AuthorizationCoordinator.self, authorizationCoordinator!)
        DiContainer.shared.register(type: DisconnectUseCase.self, disconnectUseCase!)
        DiContainer.shared.register(type: SuplaSchedulers.self, schedulers!)
    }
    
    override func tearDown() {
        stateHolder = nil
        settings = nil
        appRouter = nil
        authorizationCoordinator = nil
        disconnectUseCase = nil
        schedulers = nil
        
        viewModel = nil
    }
    
    func test_shouldNavigateToMain_whenConnected() {
        // given
        stateHolder.stateReturns = .just(.connected)
        
        // when
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(appRouter.root, .main)
    }
    
    func test_shouldNavigateToProfile_whenFirstProfileCreation() {
        // given
        stateHolder.stateReturns = .just(.firstProfileCreation)
        
        // when
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(appRouter.path, [.profile(profileId: ProfileDto.INVALID_ID, withLockCheck: true)])
    }

    func test_shouldNavigateToLockScreen_whenFirstProfileCreationAndAccountsLocked() {
        // given
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .accounts, pinSum: "1234", biometricAllowed: false)
        stateHolder.stateReturns = .just(.firstProfileCreation)

        // when
        viewModel.onViewAppear()

        // then
        XCTAssertEqual(appRouter.path, [.lockScreen(action: .authorizeAccountsCreate)])
    }
    
    func test_shouldShowInitialization() {
        // given
        stateHolder.stateReturns = .just(.initialization)
        
        // when
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .initializing)
    }
    
    func test_shouldShowConnecting() {
        // given
        stateHolder.stateReturns = .just(.connecting(reason: nil))
        
        // when
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .connecting)
    }
    
    func test_shouldShowDisconnecting() {
        // given
        stateHolder.stateReturns = .just(.disconnecting())
        
        // when
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .disconnecting)
    }
    
    func test_shouldShowLocking() {
        // given
        stateHolder.stateReturns = .just(.locking)
        
        // when
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .disconnecting)
    }
    
    func test_shouldDisconnectAndGoToProfile() {
        // given
        disconnectUseCase.invokeReturns = .complete()
        
        // when
        viewModel.goToProfiles()
        schedulers.testScheduler.start()
        
        // then
        XCTAssertEqual(disconnectUseCase.invokeCounter, 1)
        XCTAssertEqual(appRouter.path, [.profiles])
        
    }
    
    func test_handleError_authorizationNeeded() async {
        // given
        stateHolder.stateReturns = .just(.finished(reason: .registerError(code: SUPLA_RESULTCODE_REGISTRATION_DISABLED)))
        
        // when
        await MainActor.run {
            viewModel.onViewAppear()
        }
        let authorizationRequest = await waitForAuthorizationRequest()
        
        // then
        XCTAssertNotNil(authorizationRequest)
        if case .authorize = authorizationRequest?.requestType {
        } else {
            XCTFail("Expected authorization request")
        }
        XCTAssertEqual(viewModel.state.viewType, .error)
        XCTAssertEqual(viewModel.state.errorDescription, Strings.Status.errorRegistrationDisabled)
    }
    
    func test_shouldShowInitializing_whenFinishedBecauseAppInBackground() {
        // given
        stateHolder.stateReturns = .just(.finished(reason: .appInBackground))
        
        // when
        viewModel.onViewAppear()
        
        // then
        XCTAssertNil(authorizationCoordinator.request)
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .initializing)
    }

    private func waitForAuthorizationRequest() async -> AuthorizationCoordinator.Request? {
        let stepNanoseconds: UInt64 = 10_000_000
        let timeoutNanoseconds: UInt64 = 1_000_000_000
        var elapsedNanoseconds: UInt64 = 0

        while elapsedNanoseconds < timeoutNanoseconds {
            if let request = await MainActor.run(body: { authorizationCoordinator.request }) {
                return request
            }

            try? await Task.sleep(nanoseconds: stepNanoseconds)
            elapsedNanoseconds += stepNanoseconds
        }

        return await MainActor.run(body: { authorizationCoordinator.request })
    }
}
