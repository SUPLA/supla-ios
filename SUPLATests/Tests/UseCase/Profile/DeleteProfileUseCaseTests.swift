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

final class DeleteProfileUseCaseTests: UseCaseTest<DeleteProfileResult> {
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var singleCall: SingleCallMock! = {
        SingleCallMock()
    }()
    
    private lazy var deleteAllProfileDataUseCase: DeleteAllProfileDataUseCaseMock! = {
        DeleteAllProfileDataUseCaseMock()
    }()
    
    private lazy var activateProfileUseCase: ActivateProfileUseCaseMock! = {
        ActivateProfileUseCaseMock()
    }()
    
    private lazy var suplaApp: SuplaAppWrapperMock! = {
        SuplaAppWrapperMock()
    }()
    
    private lazy var runtimeConfig: RuntimeConfigMock! = {
        RuntimeConfigMock()
    }()
    
    private lazy var settings: GlobalSettingsMock! = {
        GlobalSettingsMock()
    }()
    
    private lazy var useCase: DeleteProfileUseCase! = {
        DeleteProfileUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: SingleCall.self, singleCall!)
        DiContainer.shared.register(type: DeleteAllProfileDataUseCase.self, deleteAllProfileDataUseCase!)
        DiContainer.shared.register(type: ActivateProfileUseCase.self, activateProfileUseCase!)
        DiContainer.shared.register(type: SuplaAppWrapper.self, suplaApp!)
        DiContainer.shared.register(type: RuntimeConfig.self, runtimeConfig!)
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        singleCall = nil
        deleteAllProfileDataUseCase = nil
        activateProfileUseCase = nil
        suplaApp = nil
        runtimeConfig = nil
        settings = nil
        
        useCase = nil
    }
    
    func test_shouldGetErrorWhenProfileDoesNotExist() {
        // given
        let id = AuthProfileItem(testContext: nil).objectID
        
        profileRepository.queryItemByIdObservable = .just(nil)
        
        // when
        useCase.invoke(profileId: id)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(DeleteProfileError.profileNotExist)
        ])
    }
    
    func test_shouldRemoveInactiveProfile() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = false
        profile.authInfo = AuthInfo.mock(email: "some@email.com")
        
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.deleteObservable = .just(())
        deleteAllProfileDataUseCase.returns = .just(())
        
        // when
        useCase.invoke(profileId: profile.objectID)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(DeleteProfileResult(restartNeeded: false, reauthNeeded: false, servertAddress: nil)),
            .completed
        ])
        
        XCTAssertEqual(singleCall.registerPushTokenCalls, 1)
        XCTAssertEqual(profileRepository.deleteParameters, [profile])
        XCTAssertEqual(deleteAllProfileDataUseCase.parameters, [profile])
    }
    
    func test_shouldRemoveLastActiveProfileAndCleanupSettings() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = true
        profile.authInfo = AuthInfo.mock(serverAutoDetect: false, email: "some@email.com", serverForEmail: "www")
        
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.allProfilesObservable = .just([profile])
        profileRepository.deleteObservable = .just(())
        deleteAllProfileDataUseCase.returns = .just(())
        
        // when
        useCase.invoke(profileId: profile.objectID)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(DeleteProfileResult(restartNeeded: true, reauthNeeded: true, servertAddress: "www")),
            .completed
        ])
        
        XCTAssertEqual(singleCall.registerPushTokenCalls, 1)
        XCTAssertEqual(profileRepository.deleteParameters, [profile])
        XCTAssertEqual(deleteAllProfileDataUseCase.parameters, [profile])
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [nil])
        XCTAssertEqual(settings.anyAccountRegisteredValues, [false])
    }
    
    func test_shouldRemoveActiveProfileAndActivateOtherOne() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = true
        profile.authInfo = AuthInfo.mock(emailAuth: false, serverForAccessID: "xxx", accessID: 10, accessIDpwd: "pwd")
        
        let otherProfile = AuthProfileItem(testContext: nil)
        
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.allProfilesObservable = .just([profile, otherProfile])
        profileRepository.deleteObservable = .just(())
        deleteAllProfileDataUseCase.returns = .just(())
        activateProfileUseCase.returns = .just(true)
        
        // when
        useCase.invoke(profileId: profile.objectID)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(DeleteProfileResult(restartNeeded: false, reauthNeeded: true, servertAddress: "xxx")),
            .completed
        ])
        
        XCTAssertEqual(singleCall.registerPushTokenCalls, 1)
        XCTAssertEqual(profileRepository.deleteParameters, [profile])
        XCTAssertEqual(deleteAllProfileDataUseCase.parameters, [profile])
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [])
        XCTAssertEqual(settings.anyAccountRegisteredValues, [])
        XCTAssertTuples(activateProfileUseCase.parameters, [(otherProfile.objectID, true)])
    }
    
    func test_shouldNotRemoveActiveAccountWhenActivationOfAnotherOneFailes() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = true
        profile.authInfo = AuthInfo.mock(email: "some@email.com")
        
        let otherProfile = AuthProfileItem(testContext: nil)
        
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.allProfilesObservable = .just([profile, otherProfile])
        profileRepository.deleteObservable = .just(())
        deleteAllProfileDataUseCase.returns = .just(())
        activateProfileUseCase.returns = .just(false)
        
        // when
        useCase.invoke(profileId: profile.objectID)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(DeleteProfileError.otherProfileNotActivated)
        ])
        
        XCTAssertEqual(singleCall.registerPushTokenCalls, 0)
        XCTAssertEqual(profileRepository.deleteParameters, [])
        XCTAssertEqual(deleteAllProfileDataUseCase.parameters, [])
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [])
        XCTAssertEqual(settings.anyAccountRegisteredValues, [])
        XCTAssertTuples(activateProfileUseCase.parameters, [(otherProfile.objectID, true)])
    }
    
    func test_shouldRemoveAccountWithoutTokenRemovalWhenAuthDataIsNotComplete() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.authInfo = AuthInfo.mock()
        
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.allProfilesObservable = .just([profile])
        profileRepository.deleteObservable = .just(())
        deleteAllProfileDataUseCase.returns = .just(())
        
        // when
        useCase.invoke(profileId: profile.objectID)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(DeleteProfileResult(restartNeeded: false, reauthNeeded: false, servertAddress: nil)),
            .completed
        ])
        
        XCTAssertEqual(singleCall.registerPushTokenCalls, 0)
        XCTAssertEqual(profileRepository.deleteParameters, [profile])
        XCTAssertEqual(deleteAllProfileDataUseCase.parameters, [profile])
    }
}
