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
    private lazy var coordinator: SuplaAppCoordinatorMock! = SuplaAppCoordinatorMock()
    private lazy var disconnectUseCase: DisconnectUseCaseMock! = DisconnectUseCaseMock()
    
    private lazy var viewModel: StatusFeature.ViewModel! = StatusFeature.ViewModel()
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaAppStateHolder.self, stateHolder!)
        DiContainer.shared.register(type: SuplaAppCoordinator.self, coordinator!)
        DiContainer.shared.register(type: DisconnectUseCase.self, disconnectUseCase!)
    }
    
    override func tearDown() {
        stateHolder = nil
        coordinator = nil
        disconnectUseCase = nil
        
        viewModel = nil
    }
    
    func test_shouldNavigateToMain_whenConnected() {
        // given
        stateHolder.stateReturns = .just(.connected)
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(coordinator.navigateToMainMock.parameters.count, 1)
    }
    
    func test_shouldNavigateToProfile_whenFirstProfileCreation() {
        // given
        stateHolder.stateReturns = .just(.firstProfileCreation)
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(coordinator.navigateToProfileMock.parameters, [nil])
    }
    
    func test_shouldShowInitialization() {
        // given
        stateHolder.stateReturns = .just(.initialization)
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .initializing)
    }
    
    func test_shouldShowConnecting() {
        // given
        stateHolder.stateReturns = .just(.connecting(reason: nil))
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .connecting)
    }
    
    func test_shouldShowDisconnecting() {
        // given
        stateHolder.stateReturns = .just(.disconnecting)
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .disconnecting)
    }
    
    func test_shouldShowLocking() {
        // given
        stateHolder.stateReturns = .just(.locking)
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .disconnecting)
    }
    
    func test_shouldNavigateToLockScreen() {
        // given
        stateHolder.stateReturns = .just(.locked)
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        XCTAssertEqual(coordinator.navigateToLockScreenMock.parameters, [.authorizeApplication])
    }
    
    func test_shouldDisconnectAndGoToProfile() {
        // given
        disconnectUseCase.invokeReturns = .complete()
        
        // when
        viewModel.goToProfiles()
        
        // then
        XCTAssertEqual(disconnectUseCase.invokeCounter, 1)
        coordinator.navigateToProfilesMock.verifyCalls(1)
        
    }
    
    func test_handleError_authorizationNeeded() {
        // given
        stateHolder.stateReturns = .just(.finished(reason: .registerError(code: SUPLA_RESULTCODE_REGISTRATION_DISABLED)))
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        coordinator.showLoginMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.viewType, .error)
        XCTAssertEqual(viewModel.state.errorDescription, Strings.Status.errorRegistrationDisabled)
    }
    
    func test_shouldShowInitializing_whenFinishedBecauseAppInBackground() {
        // given
        stateHolder.stateReturns = .just(.finished(reason: .appInBackground))
        
        // when
        viewModel.onViewWillAppear()
        
        // then
        coordinator.showLoginMock.verifyCalls(0)
        XCTAssertEqual(viewModel.state.viewType, .connecting)
        XCTAssertEqual(viewModel.state.stateText, .initializing)
    }
}
