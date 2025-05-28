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
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var globalSettings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var suplaAppStateHolder: SuplaAppStateHolderMock! = SuplaAppStateHolderMock()
    private lazy var readOrCreateProfileServerUseCase: ReadOrCreateProfileServerUseCaseMock! = ReadOrCreateProfileServerUseCaseMock()
    
    private lazy var useCase: SaveOrCreateProfileUseCase! = SaveOrCreateProfileUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: GlobalSettings.self, globalSettings!)
        DiContainer.shared.register(type: SuplaAppStateHolder.self, suplaAppStateHolder!)
        DiContainer.shared.register(type: ReadOrCreateProfileServerUseCase.self, readOrCreateProfileServerUseCase!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        globalSettings = nil
        suplaAppStateHolder = nil
        readOrCreateProfileServerUseCase = nil
        
        useCase = nil
    }
    
    func test_shouldFailWithDuplicatedName() {
        // given
        let name = "name"
        let profileDto = ProfileDto(id: 1, name: name)
        let existingProfile = AuthProfileItem(testContext: nil)
        existingProfile.name = name
        
        profileRepository.allProfilesObservable = .just([existingProfile])
        
        // when
        useCase.invoke(profileDto: profileDto)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(SaveOrCreateProfileError.duplicatedName)
        ])
    }
    
    func test_shouldFailWithDataIncomplete() {
        // given
        let profileDto = ProfileDto(id: 1, name: name)

        profileRepository.allProfilesObservable = .just([])

        // when
        useCase.invoke(profileDto: profileDto)
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
        let profile = AuthProfileItem(testContext: nil)
        let profileDto = ProfileDto(id: 1, name: name, advancedSetup: false, serverAutoDetect: true, email: "some@email.com")

        profileRepository.allProfilesObservable = .just([])
        profileRepository.queryItemByIdObservable = .just(nil)
        profileRepository.createObservable = .just(profile)
        profileRepository.saveObservable = .just(())
        readOrCreateProfileServerUseCase.mock.returns = .single(.just(SAProfileServer(testContext: nil)))

        // when
        useCase.invoke(profileDto: profileDto)
            .subscribe(observer)
            .disposed(by: disposeBag)

        // then
        assertEvents([
            .next(.init(saved: true, needsReauth: true)),
            .completed
        ])
        XCTAssertEqual(profile.name, name)
        XCTAssertEqual(profile.advancedSetup, false)
        XCTAssertEqual(profile.email, profileDto.email)
        XCTAssertEqual(profile.preferredProtocolVersion, SUPLA_PROTO_VERSION)
        XCTAssertEqual(profile.isActive, true)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues, [true])
        XCTAssertEqual(suplaAppStateHolder.handleParameters, [.connecting])
    }

    func test_shouldUpdateExistingProfile() {
        // given
        let name = "name"
        let profileDto = ProfileDto(id: 1, name: name, advancedSetup: false, serverAutoDetect: true, email: "some@email.com")
        let profile = AuthProfileItem(testContext: nil)
        profile.id = 1
        profile.name = "other name"
        profile.isActive = false
        profile.advancedSetup = false
        profile.serverAutoDetect = true
        profile.email = "some@email.com"

        profileRepository.allProfilesObservable = .just([profile])
        profileRepository.saveObservable = .just(())
        readOrCreateProfileServerUseCase.mock.returns = .single(.just(SAProfileServer(testContext: nil)))

        // when
        useCase.invoke(profileDto: profileDto)
            .subscribe(observer)
            .disposed(by: disposeBag)

        // then
        assertEvents([
            .next(.init(saved: true, needsReauth: false)),
            .completed
        ])
        XCTAssertEqual(profile.name, name)
        XCTAssertEqual(profile.advancedSetup, false)
        XCTAssertEqual(profile.serverAutoDetect, true)
        XCTAssertEqual(profile.isActive, false)
        XCTAssertEqual(profile.email, "some@email.com")
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues, [true])
        XCTAssertEqual(suplaAppStateHolder.handleParameters, [])
    }

    func test_shouldReauthWhenAuthInfoChanged() {
        // given
        let name = "name"
        let profileDto = ProfileDto(id: 1, name: name, advancedSetup: false, serverAutoDetect: true, email: "some@email.com")
        let profile = AuthProfileItem(testContext: nil)
        profile.id = 1
        profile.name = "other name"
        profile.isActive = true
        profile.advancedSetup = false
        profile.serverAutoDetect = true
        profile.email = "another@email.com"

        profileRepository.allProfilesObservable = .just([profile])
        profileRepository.saveObservable = .just(())

        // when
        useCase.invoke(profileDto: profileDto)
            .subscribe(observer)
            .disposed(by: disposeBag)

        // then
        assertEvents([
            .next(.init(saved: true, needsReauth: true)),
            .completed
        ])
        XCTAssertEqual(profile.id, 1)
        XCTAssertEqual(profile.name, name)
        XCTAssertEqual(profile.advancedSetup, false)
        XCTAssertEqual(profile.serverAutoDetect, true)
        XCTAssertEqual(profile.email, profileDto.email)
        XCTAssertEqual(profile.isActive, true)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues, [true])
        XCTAssertEqual(suplaAppStateHolder.handleParameters, [.connecting])
    }
}
