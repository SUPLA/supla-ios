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
import RxSwift
import XCTest

final class ActivateProfileUseCaseTests: CompletableTestCase {
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var cloudConfigHolder: SuplaCloudConfigHolderMock! = {
        SuplaCloudConfigHolderMock()
    }()
    
    private lazy var reconnectUseCase: ReconnectUseCaseMock! = ReconnectUseCaseMock()
    
    private lazy var useCase: ActivateProfileUseCase! = {
        ActivateProfileUseCase()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: SuplaCloudConfigHolder.self, cloudConfigHolder!)
        DiContainer.shared.register(type: ReconnectUseCase.self, reconnectUseCase!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        cloudConfigHolder = nil
        reconnectUseCase = nil
        
        useCase = nil
    }
    
    func test_shouldReturnFalseWhenProfileNotFound() {
        // given
        let id: Int32 = 1
        
        profileRepository.getProfileWithIdMock.returns = .single(.just(nil))
        
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
        profile.id = 2
        profile.isActive = true
        
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))
        
        // when
        useCase.invoke(profileId: profile.id, force: false)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [ .completed ])
        
        XCTAssertEqual(cloudConfigHolder.cleanCalls, 0)
    }
    
    func test_shouldActivateOtherProfile() {
        // given
        let notActiveProfile = ProfileDto(id: 2)
        
        let notActiveProfileEntity = AuthProfileItem(testContext: nil)
        notActiveProfileEntity.id = 2
        
        profileRepository.getProfileWithIdMock.returns = .single(.just(notActiveProfileEntity))
        profileRepository.markProfileActiveMock.returns = .single(.just(()))
        reconnectUseCase.returns = .complete()
        
        // when
        useCase.invoke(profileId: notActiveProfile.id, force: false)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [ .completed ])
        XCTAssertEqual(cloudConfigHolder.cleanCalls, 1)
    }
    
    func test_shouldActivateActiveProfileWhenForceTrue() {
        // given
        let activeProfile = ProfileDto(id: 32, isActive: true)
        let activeProfileEntity = AuthProfileItem(testContext: nil)
        activeProfileEntity.id = 32
        activeProfileEntity.isActive = true
        
        profileRepository.getProfileWithIdMock.returns = .single(.just(activeProfileEntity))
        profileRepository.markProfileActiveMock.returns = .single(.just(()))
        reconnectUseCase.returns = .complete()
        
        // when
        useCase.invoke(profileId: activeProfile.id, force: true)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [ .completed ])
        XCTAssertEqual(cloudConfigHolder.cleanCalls, 1)
    }

    func test_shouldWaitForDisconnectBeforeActivatingProfileAndStartingClient() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        profile.id = 7
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))

        var events: [String] = []
        var completeDisconnect: (() -> Void)?
        let disconnectUseCase = DisconnectUseCaseMock()
        disconnectUseCase.invokeReturns = Completable.create { completable in
            events.append("disconnect")
            completeDisconnect = { completable(.completed) }
            return Disposables.create()
        }

        let appProvider = SuplaAppProviderMock()
        appProvider.onInitSuplaClient = { events.append("start client") }
        cloudConfigHolder.onClean = { events.append("clean cloud config") }

        profileRepository.markProfileActiveMock.returns = .single(
            .deferred {
                events.append("activate profile")
                return .just(())
            }
        )

        DiContainer.shared.register(type: DisconnectUseCase.self, disconnectUseCase)
        DiContainer.shared.register(type: SuplaAppProvider.self, appProvider)
        DiContainer.shared.register(type: ReconnectUseCase.self, ReconnectUseCaseImpl())

        // when
        useCase.invoke(profileId: profile.id, force: false)
            .subscribe(observer)
            .disposed(by: disposeBag)

        // then: the profile must remain untouched while disconnect is pending
        XCTAssertEqual(events, ["disconnect"])
        XCTAssertEqual(appProvider.initSuplaClientCalls, 0)

        completeDisconnect?()

        XCTAssertEqual(events, ["disconnect", "activate profile", "clean cloud config", "start client"])
        XCTAssertEqual(profileRepository.markProfileActiveMock.parameters.count, 1)
        XCTAssertEqual(appProvider.initSuplaClientCalls, 1)
        assertEvents(contains: [.completed])
    }
}
