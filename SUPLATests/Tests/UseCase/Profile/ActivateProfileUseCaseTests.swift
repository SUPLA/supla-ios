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

final class ActivateProfileUseCaseTests: CompletableTestCase {
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var runtimeConfig: RuntimeConfigMock! = {
        RuntimeConfigMock()
    }()
    
    private lazy var cloudConfigHolder: SuplaCloudConfigHolderMock! = {
        SuplaCloudConfigHolderMock()
    }()
    
    private lazy var reconnectUseCase: ReconnectUseCaseMock! = ReconnectUseCaseMock()
    
    private lazy var useCase: ActivateProfileUseCaseImpl! = {
        ActivateProfileUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: RuntimeConfig.self, runtimeConfig!)
        DiContainer.shared.register(type: SuplaCloudConfigHolder.self, cloudConfigHolder!)
        DiContainer.shared.register(type: ReconnectUseCase.self, reconnectUseCase!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        runtimeConfig = nil
        cloudConfigHolder = nil
        reconnectUseCase = nil
        
        useCase = nil
    }
    
    func test_shouldReturnFalseWhenProfileNotFound() {
        // given
        let id = AuthProfileItem(testContext: nil).objectID
        
        profileRepository.queryItemByIdObservable = .just(nil)
        
        // when
        useCase.invoke(profileId: id, force: false)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [ .completed ])
    }
    
    func test_shouldReturnFalseWhenProfileActiveAndForceFalse() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = true
        
        profileRepository.queryItemByIdObservable = .just(profile)
        
        // when
        useCase.invoke(profileId: profile.objectID, force: false)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [ .completed ])
        
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [])
        XCTAssertEqual(cloudConfigHolder.cleanCalls, 0)
    }
    
    func test_shouldActivateOtherProfile() {
        // given
        let activeProfile = AuthProfileItem(testContext: nil)
        activeProfile.isActive = true
        
        let notActiveProfile = AuthProfileItem(testContext: nil)
        
        profileRepository.queryItemByIdObservable = .just(notActiveProfile)
        profileRepository.allProfilesObservable = .just([activeProfile, notActiveProfile])
        profileRepository.saveObservable = .just(())
        reconnectUseCase.returns = .complete()
        
        // when
        useCase.invoke(profileId: notActiveProfile.objectID, force: false)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [ .completed ])
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [notActiveProfile.objectID])
        XCTAssertEqual(cloudConfigHolder.cleanCalls, 1)
    }
    
    func test_shouldActivateActiveProfileWhenForceTrue() {
        // given
        let activeProfile = AuthProfileItem(testContext: nil)
        activeProfile.isActive = true
        
        profileRepository.queryItemByIdObservable = .just(activeProfile)
        profileRepository.allProfilesObservable = .just([activeProfile])
        profileRepository.saveObservable = .just(())
        reconnectUseCase.returns = .complete()
        
        // when
        useCase.invoke(profileId: activeProfile.objectID, force: true)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [ .completed ])
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [activeProfile.objectID])
        XCTAssertEqual(cloudConfigHolder.cleanCalls, 1)
    }
}
