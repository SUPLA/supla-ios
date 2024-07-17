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

class LockScreenVMTests: XCTestCase {
    private lazy var checkPinUseCase: CheckPinUseCaseMock! = CheckPinUseCaseMock()
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var coordinator: SuplaAppCoordinatorMock! = SuplaAppCoordinatorMock()
    private lazy var schedulers: SuplaSchedulersMock! = SuplaSchedulersMock()
    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    
    private lazy var viewModel: LockScreenFeature.ViewModel! = LockScreenFeature.ViewModel()
    
    override func setUp() {
        DiContainer.shared.register(type: CheckPinUseCase.self, checkPinUseCase!)
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: SuplaAppCoordinator.self, coordinator!)
        DiContainer.shared.register(type: SuplaSchedulers.self, schedulers!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
    }
    
    override func tearDown() {
        checkPinUseCase = nil
        settings = nil
        coordinator = nil
        schedulers = nil
        dateProvider = nil
        
        viewModel = nil
    }
    
    func test_shouldVerifyPin_andCloseScreen() {
        // given
        let pin = "1234"
        checkPinUseCase.returns = .just(.unlocked)
        
        // when
        viewModel.setUnlockAction(.authorizeApplication)
        viewModel.onPinChange(pin)
        schedulers.testScheduler.start()
        
        // then
        XCTAssertTuples(checkPinUseCase.parameters, [(LockScreenFeature.UnlockAction.authorizeApplication, CheckPinAction.checkPin(pin: pin))])
        coordinator.verifyPopViewController([true])
    }
    
    func test_shouldVerifyPin_andNavigateToCreateProfile() {
        // given
        let pin = "1234"
        let action: LockScreenFeature.UnlockAction = .authorizeAccountsCreate
        checkPinUseCase.returns = .just(.unlocked)
        
        // when
        viewModel.setUnlockAction(action)
        viewModel.onPinChange(pin)
        schedulers.testScheduler.start()
        
        // then
        XCTAssertTuples(checkPinUseCase.parameters, [(action, CheckPinAction.checkPin(pin: pin))])
        XCTAssertTuples(coordinator.navigateToProfileWithLockCheckMock.parameters, [(nil, false)])
        coordinator.verifyPopViewController([])
    }
    
    func test_shouldVerifyPin_andNavigateToEditProfile() {
        // given
        let pin = "1234"
        let profileId: ProfileID = NSManagedObjectID()
        let action: LockScreenFeature.UnlockAction = .authorizeAccountsEdit(profileId: profileId)
        
        checkPinUseCase.returns = .just(.unlocked)
        
        // when
        viewModel.setUnlockAction(action)
        viewModel.onPinChange(pin)
        schedulers.testScheduler.start()
        
        // then
        XCTAssertTuples(checkPinUseCase.parameters, [(action, CheckPinAction.checkPin(pin: pin))])
        XCTAssertTuples(coordinator.navigateToProfileWithLockCheckMock.parameters, [(profileId, false)])
        coordinator.verifyPopViewController([])
    }
    
    func test_shouldVerifyPin_andDoNothingWhenNoAccount() {
        // given
        let pin = "1234"
        let action: LockScreenFeature.UnlockAction = .authorizeApplication
        
        checkPinUseCase.returns = .just(.unlockedNoAccount)
        
        // when
        viewModel.setUnlockAction(action)
        viewModel.onPinChange(pin)
        schedulers.testScheduler.start()
        
        // then
        XCTAssertTuples(checkPinUseCase.parameters, [(action, CheckPinAction.checkPin(pin: pin))])
        XCTAssertTuples(coordinator.navigateToProfileWithLockCheckMock.parameters, [])
        coordinator.verifyPopViewController([true])
    }
    
    func test_shouldRejectPin() {
        // given
        let pin = "1234"
        let action: LockScreenFeature.UnlockAction = .authorizeApplication
        let lockTime: TimeInterval = 123
        
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .application, pinSum: "", biometricAllowed: false, failsCount: 0, lockTime: lockTime)
        checkPinUseCase.returns = .just(.failure)
        
        viewModel.state.pin = pin
        
        // when
        viewModel.setUnlockAction(action)
        viewModel.onPinChange(pin)
        schedulers.testScheduler.start()
        
        // then
        XCTAssertTrue(viewModel.state.wrongPin)
        XCTAssertEqual(viewModel.state.lockedTime, lockTime)
        XCTAssertEqual(viewModel.state.pin, "")
        XCTAssertTuples(checkPinUseCase.parameters, [(action, CheckPinAction.checkPin(pin: pin))])
        XCTAssertTuples(coordinator.navigateToProfileWithLockCheckMock.parameters, [])
        coordinator.verifyPopViewController([])
    }
}
