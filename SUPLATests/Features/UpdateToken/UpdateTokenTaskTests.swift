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
import RxTest
import RxSwift

@testable import SUPLA

final class UpdateTokenTaskTests: XCTestCase {
    private lazy var updateTokenTask: UpdateTokenTask! = { UpdateTokenTask() }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    private lazy var singleCall: SingleCallMock! = {
        SingleCallMock()
    }()
    private lazy var settings: GlobalSettingsMock! = {
        GlobalSettingsMock()
    }()
    private lazy var dateProvider: DateProviderMock! = {
        DateProviderMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
        DiContainer.shared.register(type: SingleCall.self, component: singleCall!)
        DiContainer.shared.register(type: GlobalSettings.self, component: settings!)
        DiContainer.shared.register(type: DateProvider.self, component: dateProvider!)
    }
    
    override func tearDown() {
        updateTokenTask = nil
        
        profileRepository = nil
        singleCall = nil
        settings = nil
        dateProvider = nil
    }
    
    func test_shouldNotUpdateTokenWhenTokensAreEqualAndUpdateNotNeeded() async {
        // given
        let token = Data()
        settings.pushTokenReturns = token
        
        // when
        await updateTokenTask.update(token: token, updateSelf: false)
        
        // then
        XCTAssertEqual(profileRepository.allProfilesCalls, 0)
        XCTAssertEqual(singleCall.registerPushTokenCalls, 0)
        XCTAssertEqual(settings.pushTokenLastUpdateValues.count, 0)
    }
    
    func test_shouldUpdateTokenWhenTokensEqualButPauseTimeElapsed() async {
        // given
        let token = Data()
        settings.pushTokenReturns = token
        dateProvider.currentTimestampReturns = 8 * 24 * 60 * 60.0
        
        // when
        await updateTokenTask.update(token: token, updateSelf: false)
        
        // then
        XCTAssertEqual(profileRepository.allProfilesCalls, 1)
        XCTAssertEqual(singleCall.registerPushTokenCalls, 0)
        XCTAssertEqual(settings.pushTokenLastUpdateValues.count, 0)
    }
    
    func test_shouldNotUpdateTokenWhenThereIsNoProfile() async {
        // given
        let token = Data()
        settings.pushTokenReturns = token
        
        // when
        await updateTokenTask.update(token: Data([1]), updateSelf: false)
        
        // then
        XCTAssertEqual(profileRepository.allProfilesCalls, 1)
        XCTAssertEqual(singleCall.registerPushTokenCalls, 0)
        XCTAssertEqual(settings.pushTokenLastUpdateValues.count, 0)
    }
    
    func test_shouldNotUpdateTokenForProfileWithIncompleteData() async {
        // given
        let token = Data()
        settings.pushTokenReturns = token
        
        let profile = AuthProfileItem(testContext: nil)
        profileRepository.allProfilesObservable = Observable.just([profile])
        
        // when
        await updateTokenTask.update(token: Data([1]), updateSelf: false)
        
        // then
        XCTAssertEqual(profileRepository.allProfilesCalls, 1)
        XCTAssertEqual(singleCall.registerPushTokenCalls, 0)
        XCTAssertEqual(settings.pushTokenLastUpdateValues.count, 1)
    }
    
    func test_shouldUpdateToken() async {
        // given
        let token = Data()
        settings.pushTokenReturns = token
        dateProvider.currentTimestampReturns = 12.0
        
        let profile = AuthProfileItem(testContext: nil)
        profile.authInfo = AuthInfo(
            emailAuth: true,
            serverAutoDetect: true,
            emailAddress: "test@supla.org",
            serverForEmail: "supla.org",
            serverForAccessID: "",
            accessID: 0,
            accessIDpwd: ""
        )
        profileRepository.allProfilesObservable = Observable.just([profile])
        
        // when
        await updateTokenTask.update(token: Data([1]), updateSelf: false)
        
        // then
        XCTAssertEqual(profileRepository.allProfilesCalls, 1)
        XCTAssertEqual(singleCall.registerPushTokenCalls, 1)
        XCTAssertEqual(settings.pushTokenLastUpdateValues.count, 1)
        XCTAssertEqual(settings.pushTokenLastUpdateValues[0], 12.0)
    }
    
    func test_shouldNotUpdateTokenForActiveProfile() async {
        // given
        let token = Data()
        settings.pushTokenReturns = token
        
        let profile = AuthProfileItem(testContext: nil)
        profile.isActive = true
        profileRepository.allProfilesObservable = Observable.just([profile])
        
        // when
        await updateTokenTask.update(token: Data([1]), updateSelf: false)
        
        // then
        XCTAssertEqual(profileRepository.allProfilesCalls, 1)
        XCTAssertEqual(singleCall.registerPushTokenCalls, 0)
        XCTAssertEqual(settings.pushTokenLastUpdateValues.count, 1)
    }
}
