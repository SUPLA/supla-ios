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
    
import RxSwift
import XCTest
@testable import SUPLA

final class CheckPinUseCaseTests: SingleTestCase<CheckPinResult> {
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var stateHolder: SuplaAppStateHolderMock! = SuplaAppStateHolderMock()
    
    private lazy var useCase: CheckPinUseCase! = CheckPinUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: SuplaAppStateHolder.self, stateHolder!)
    }
    
    override func tearDown() {
        settings = nil
        dateProvider = nil
        profileRepository = nil
        stateHolder = nil
        
        useCase = nil
        
        super.tearDown()
    }
    
    func test_shouldUnlock_checkPinAction() {
        // given
        let password = "123"
        let profile = AuthProfileItem(testContext: nil)
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .application, pinSum: password.sha1(), biometricAllowed: false, failsCount: 2, lockTime: 10)
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        useCase.invoke(unlockAction: .authorizeApplication, pinAction: .checkPin(pin: password)).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.unlocked)
        
        XCTAssertEqual(stateHolder.handleParameters, [.unlock])
        XCTAssertEqual(settings.lockScreenSettingsValues, [LockScreenSettings(scope: .application, pinSum: password.sha1(), biometricAllowed: false)]) // Cleanups wrong pins count
        XCTAssertEqual(dateProvider.currentTimestampCalls, 0)
    }
    
    func test_shouldUnlock_biometricGranted_noProfile() {
        // given
        let password = "123"
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .application, pinSum: password.sha1(), biometricAllowed: false, failsCount: 2, lockTime: 10)
        profileRepository.activeProfileObservable = .empty()
        
        // when
        useCase.invoke(unlockAction: .authorizeApplication, pinAction: .biometricGranted).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.unlockedNoAccount)
        
        XCTAssertEqual(stateHolder.handleParameters, [.noAccount])
        XCTAssertEqual(settings.lockScreenSettingsValues, [LockScreenSettings(scope: .application, pinSum: password.sha1(), biometricAllowed: false)]) // Cleanups wrong pins count
        XCTAssertEqual(dateProvider.currentTimestampCalls, 0)
    }
    
    func test_shouldUnlock_turnOffPin() {
        // given
        let password = "123"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = .just(profile)
        
        let lockScreenSettings = LockScreenSettings(scope: .application, pinSum: password.sha1(), biometricAllowed: false, failsCount: 2, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        
        // when
        useCase.invoke(unlockAction: .turnOffPin, pinAction: .checkPin(pin: password)).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.unlocked)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [LockScreenSettings(scope: .application, pinSum: password.sha1(), biometricAllowed: false), LockScreenSettings.DEFAULT])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 0)
    }
    
    func test_shouldUnlock_changeScope_Accounts() {
        // given
        let password = "123"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = .just(profile)
        
        let lockScreenSettings = LockScreenSettings(scope: .application, pinSum: password.sha1(), biometricAllowed: false, failsCount: 2, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        
        // when
        useCase.invoke(unlockAction: .confirmAuthorizeAccounts, pinAction: .checkPin(pin: password)).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.unlocked)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [lockScreenSettings.copy(failsCount: .value(0), lockTime: .value(nil)), lockScreenSettings.copy(scope: .value(.accounts))])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 0)
    }
    
    func test_shouldUnlock_changeScope_Application() {
        // given
        let password = "123"
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.activeProfileObservable = .just(profile)
        
        let lockScreenSettings = LockScreenSettings(scope: .accounts, pinSum: password.sha1(), biometricAllowed: false, failsCount: 2, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        
        // when
        useCase.invoke(unlockAction: .confirmAuthorizeApplication, pinAction: .checkPin(pin: password)).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.unlocked)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [lockScreenSettings.copy(failsCount: .value(0), lockTime: .value(nil)), lockScreenSettings.copy(scope: .value(.application))])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 0)
    }
    
    func test_wrongPin() {
        // given
        let password = "123"
        let lockScreenSettings = LockScreenSettings(scope: .accounts, pinSum: password.sha1(), biometricAllowed: false, failsCount: 2, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        
        // when
        useCase.invoke(unlockAction: .authorizeApplication, pinAction: .checkPin(pin: "234")).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.failure)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [lockScreenSettings.copy(failsCount: .value(3))])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 0)
    }
    
    func test_biometricRejected_firstLockTime() {
        // given
        let password = "123"
        let lockScreenSettings = LockScreenSettings(scope: .accounts, pinSum: password.sha1(), biometricAllowed: false, failsCount: 5, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        dateProvider.currentTimestampReturns = .single(1000)
        
        // when
        useCase.invoke(unlockAction: .authorizeApplication, pinAction: .biometricRejected).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.failure)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [lockScreenSettings.copy(failsCount: .value(6), lockTime: .value(1005))])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 1)
    }
    
    func test_biometricRejected_secondLockTime() {
        // given
        let password = "123"
        let lockScreenSettings = LockScreenSettings(scope: .accounts, pinSum: password.sha1(), biometricAllowed: false, failsCount: 10, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        dateProvider.currentTimestampReturns = .single(1000)
        
        // when
        useCase.invoke(unlockAction: .authorizeApplication, pinAction: .biometricRejected).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.failure)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [lockScreenSettings.copy(failsCount: .value(11), lockTime: .value(1060))])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 1)
    }
    
    func test_biometricRejected_thirdLockTime() {
        // given
        let password = "123"
        let lockScreenSettings = LockScreenSettings(scope: .accounts, pinSum: password.sha1(), biometricAllowed: false, failsCount: 15, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        dateProvider.currentTimestampReturns = .single(1000)
        
        // when
        useCase.invoke(unlockAction: .authorizeApplication, pinAction: .biometricRejected).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.failure)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [lockScreenSettings.copy(failsCount: .value(16), lockTime: .value(1300))])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 1)
    }
    
    func test_biometricRejected_fourthLockTime() {
        // given
        let password = "123"
        let lockScreenSettings = LockScreenSettings(scope: .accounts, pinSum: password.sha1(), biometricAllowed: false, failsCount: 20, lockTime: 10)
        settings.lockScreenSettingsReturns = lockScreenSettings
        dateProvider.currentTimestampReturns = .single(1000)
        
        // when
        useCase.invoke(unlockAction: .authorizeApplication, pinAction: .biometricRejected).subscribe(observer).disposed(by: disposeBag)
        
        // then
        let checkPinResult = try? result?.get()
        XCTAssertEqual(checkPinResult, CheckPinResult.failure)
        
        XCTAssertEqual(stateHolder.handleParameters, [])
        XCTAssertEqual(settings.lockScreenSettingsValues, [lockScreenSettings.copy(failsCount: .value(21), lockTime: .value(1600))])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 1)
    }
}
