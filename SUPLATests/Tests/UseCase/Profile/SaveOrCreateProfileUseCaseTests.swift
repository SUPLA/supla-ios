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

final class SaveOrCreateProfileUseCaseTests: UseCaseTest<SaveOrCreateProfileResult> {
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = {
        SuplaClientProviderMock()
    }()
    
    private lazy var globalSettings: GlobalSettingsMock! = {
        GlobalSettingsMock()
    }()
    
    private lazy var useCase: SaveOrCreateProfileUseCase! = {
        SaveOrCreateProfileUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
        DiContainer.shared.register(type: GlobalSettings.self, globalSettings!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        suplaClientProvider = nil
        globalSettings = nil
        
        useCase = nil
    }
    
    func test_shouldFailWithDuplicatedName() {
        // given
        let name = "name"
        let existingProfile = AuthProfileItem(testContext: nil)
        existingProfile.name = name
        
        profileRepository.allProfilesObservable = .just([existingProfile])
        
        // when
        useCase.invoke(
            profileId: nil,
            name: name,
            advancedMode: true,
            authInfo: AuthInfo.mock()
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(SaveOrCreateProfileError.duplicatedName)
        ])
    }
    
    func test_shouldFailWithDataIncomplete() {
        // given
        let name = "name"
        let authInfo = AuthInfo.mock()
        
        profileRepository.allProfilesObservable = .just([])
        
        // when
        useCase.invoke(profileId: nil, name: name, advancedMode: false, authInfo: authInfo)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(SaveOrCreateProfileError.dataIncomplete)
        ])
    }
    
    func test_shouldCreateNewProfile() {
        // given
        let name = "name"
        let authInfo = AuthInfo.mock(email: "some@email.com")
        let profile = AuthProfileItem(testContext: nil)
        
        profileRepository.allProfilesObservable = .just([])
        profileRepository.queryItemByIdObservable = .just(nil)
        profileRepository.createObservable = .just(profile)
        profileRepository.saveObservable = .just(())
        
        // when
        useCase.invoke(profileId: nil, name: name, advancedMode: false, authInfo: authInfo)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.init(saved: true, needsReauth: true)),
            .completed
        ])
        XCTAssertEqual(profile.name, name)
        XCTAssertEqual(profile.advancedSetup, false)
        XCTAssertEqual(profile.authInfo, authInfo.copy(preferredProtocolVersion: Int(SUPLA_PROTO_VERSION)))
        XCTAssertEqual(profile.isActive, true)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues, [true])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 1)
    }
    
    func test_shouldUpdateExistingProfile() {
        // given
        let name = "name"
        let authInfo = AuthInfo.mock(email:"some@email.com")
        let profile = AuthProfileItem(testContext: nil)
        profile.name = "other name"
        profile.isActive = false
        profile.authInfo = authInfo
        
        profileRepository.allProfilesObservable = .just([])
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.saveObservable = .just(())
        
        // when
        useCase.invoke(profileId: profile.objectID, name: name, advancedMode: false, authInfo: authInfo)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.init(saved: true, needsReauth: false)),
            .completed
        ])
        XCTAssertEqual(profile.name, name)
        XCTAssertEqual(profile.advancedSetup, false)
        XCTAssertEqual(profile.authInfo, authInfo)
        XCTAssertEqual(profile.isActive, false)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues, [true])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 0)
    }
    
    func test_shouldReauthWhenAuthInfoChanged() {
        // given
        let name = "name"
        let authInfo = AuthInfo.mock(email:"some@email.com")
        let profile = AuthProfileItem(testContext: nil)
        profile.name = "other name"
        profile.isActive = true
        profile.authInfo = authInfo.copy(emailAddress: "another@email.com")
        
        profileRepository.allProfilesObservable = .just([])
        profileRepository.queryItemByIdObservable = .just(profile)
        profileRepository.saveObservable = .just(())
        
        // when
        useCase.invoke(profileId: profile.objectID, name: name, advancedMode: false, authInfo: authInfo)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.init(saved: true, needsReauth: true)),
            .completed
        ])
        XCTAssertEqual(profile.name, name)
        XCTAssertEqual(profile.advancedSetup, false)
        XCTAssertEqual(profile.authInfo, authInfo.copy(preferredProtocolVersion: Int(SUPLA_PROTO_VERSION)))
        XCTAssertEqual(profile.isActive, true)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues, [true])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 1)
    }
}
