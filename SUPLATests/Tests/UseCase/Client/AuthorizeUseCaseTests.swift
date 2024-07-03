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

final class AuthorizeUseCaseTests: CompletableTestCase {
    private lazy var notificationCenterWrapper: NotificationCenterWrapperMock! = NotificationCenterWrapperMock()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = SuplaClientProviderMock()
    
    private lazy var threadHandler: ThreadHandlerMock! = ThreadHandlerMock()
    
    private lazy var useCase: AuthorizeUseCase! = AuthorizeUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: NotificationCenterWrapper.self, notificationCenterWrapper!)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
        DiContainer.shared.register(type: ThreadHandler.self, threadHandler!)
    }
    
    override func tearDown() {
        super.tearDown()
        notificationCenterWrapper = nil
        suplaClientProvider = nil
        threadHandler = nil
        useCase = nil
    }
    
    func test_shouldAuthorizeUser() {
        // given
        let username: String = "username"
        let password: String = "password"
        
        notificationCenterWrapper.registerObserverAction = { object, selector, name in
            let result = SASuperuserAuthorizationResult(true, withCode: 0)
            let notification: Notification = Notification(name: name, userInfo: ["result": result])
            (object as? NSObjectProtocol)?.perform(selector, with: notification)
        }
        
        // when
        useCase.invoke(userName: username, password: password).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.completed])
        
        XCTAssertEqual(notificationCenterWrapper.registerObserverParameters.count, 1)
        XCTAssertEqual(notificationCenterWrapper.unregisterObserverParameters.count, 2)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.superuserAuthorizationRequestParameters, [
            (username, password)
        ])
    }
    
    func test_shouldFailUserAuthorization_unauthorized() {
        // given
        let username: String = "username"
        let password: String = "password"
        
        notificationCenterWrapper.registerObserverAction = { object, selector, name in
            let result = SASuperuserAuthorizationResult(false, withCode: SUPLA_RESULTCODE_UNAUTHORIZED)
            let notification: Notification = Notification(name: name, userInfo: ["result": result])
            (object as? NSObjectProtocol)?.perform(selector, with: notification)
        }
        
        // when
        useCase.invoke(userName: username, password: password).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.error(AuthorizationError(errorMessage: Strings.Status.errorInvalidData))])
        
        XCTAssertEqual(notificationCenterWrapper.registerObserverParameters.count, 1)
        XCTAssertEqual(notificationCenterWrapper.unregisterObserverParameters.count, 2)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.superuserAuthorizationRequestParameters, [
            (username, password)
        ])
    }
    
    func test_shouldFailUserAuthorization_unavailable() {
        // given
        let username: String = "username"
        let password: String = "password"
        
        notificationCenterWrapper.registerObserverAction = { object, selector, name in
            let result = SASuperuserAuthorizationResult(false, withCode: SUPLA_RESULTCODE_TEMPORARILY_UNAVAILABLE)
            let notification: Notification = Notification(name: name, userInfo: ["result": result])
            (object as? NSObjectProtocol)?.perform(selector, with: notification)
        }
        
        // when
        useCase.invoke(userName: username, password: password).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.error(AuthorizationError(errorMessage: Strings.Status.errorUnavailable))])
        
        XCTAssertEqual(notificationCenterWrapper.registerObserverParameters.count, 1)
        XCTAssertEqual(notificationCenterWrapper.unregisterObserverParameters.count, 2)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.superuserAuthorizationRequestParameters, [
            (username, password)
        ])
    }
    
    func test_shouldFailUserAuthorization_generalError() {
        // given
        let username: String = "username"
        let password: String = "password"
        
        notificationCenterWrapper.registerObserverAction = { object, selector, name in
            let result = SASuperuserAuthorizationResult(false, withCode: 0)
            let notification: Notification = Notification(name: name, userInfo: ["result": result])
            (object as? NSObjectProtocol)?.perform(selector, with: notification)
        }
        
        // when
        useCase.invoke(userName: username, password: password).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.error(AuthorizationError(errorMessage: Strings.Status.errorUnknown))])
        
        XCTAssertEqual(notificationCenterWrapper.registerObserverParameters.count, 1)
        XCTAssertEqual(notificationCenterWrapper.unregisterObserverParameters.count, 2)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.superuserAuthorizationRequestParameters, [
            (username, password)
        ])
    }
    
    func test_shouldTimeoutAuthorization() {
        // given
        let username: String = "username"
        let password: String = "password"
        
        notificationCenterWrapper.registerObserverAction = { object, selector, name in
            let notification: Notification = Notification(name: name)
            (object as? NSObjectProtocol)?.perform(selector, with: notification)
        }
        
        // when
        useCase.invoke(userName: username, password: password).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.error(AuthorizationError(errorMessage: Strings.AuthorizationDialog.timeout))])
        
        XCTAssertEqual(notificationCenterWrapper.registerObserverParameters.count, 1)
        XCTAssertEqual(notificationCenterWrapper.unregisterObserverParameters.count, 1)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.superuserAuthorizationRequestParameters, [
            (username, password)
        ])
    }
}
