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
    

import XCTest
@testable import SUPLA

final class InitializationUseCaseTests: XCTestCase {
    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var stateHolder: SuplaAppStateHolderMock! = SuplaAppStateHolderMock()
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var threadHandler: ThreadHandlerMock! = ThreadHandlerMock()
    private lazy var databaseProxy: DatabaseProxyMock! = DatabaseProxyMock()
    
    override func setUp() {
        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: SuplaAppStateHolder.self, stateHolder!)
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: ThreadHandler.self, threadHandler!)
        DiContainer.shared.register(type: DatabaseProxy.self, databaseProxy!)
    }
    
    override func tearDown() {
        dateProvider = nil
        profileRepository = nil
        stateHolder = nil
        settings = nil
        threadHandler = nil
        databaseProxy = nil
    }
    
    func test_shouldRequirePin() {
        // given
        dateProvider.currentTimestampReturns = .many([0.0, 0.2])
        settings.lockScreenSettingsReturns = LockScreenSettings(scope: .application, pinSum: "123", biometricAllowed: false)
        
        // when
        InitializationUseCase.invoke()
        
        // then
        XCTAssertEqual(stateHolder.handleParameters, [.lock])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 2)
        XCTAssertEqual(threadHandler.usleepParameters, [800_000])
        XCTAssertEqual(databaseProxy.setupCalls, 1)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
    }
    
    func test_shouldEmitNoAccount() {
        // given
        dateProvider.currentTimestampReturns = .many([0.0, 0.2])
        settings.lockScreenSettingsReturns = LockScreenSettings.DEFAULT
        
        // when
        InitializationUseCase.invoke()
        
        // then
        XCTAssertEqual(stateHolder.handleParameters, [.noAccount])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 2)
        XCTAssertEqual(threadHandler.usleepParameters, [800_000])
        XCTAssertEqual(databaseProxy.setupCalls, 1)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
    }
    
    func test_shouldEmitInitialized() {
        // given
        dateProvider.currentTimestampReturns = .many([0.0, 1.3])
        settings.lockScreenSettingsReturns = LockScreenSettings.DEFAULT
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = true
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        InitializationUseCase.invoke()
        
        // then
        XCTAssertEqual(stateHolder.handleParameters, [.initialized])
        XCTAssertEqual(dateProvider.currentTimestampCalls, 2)
        XCTAssertEqual(threadHandler.usleepParameters, [])
        XCTAssertEqual(databaseProxy.setupCalls, 1)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
    }
}
