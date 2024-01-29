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
import RxSwift
@testable import SUPLA
import RxTest

class RequestHelperTests: ObservableTestCase {
    
    private lazy var suplaCloudConfigHolder: SuplaCloudConfigHolderMock! = {
        SuplaCloudConfigHolderMock()
    }()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = {
        SuplaClientProviderMock()
    }()
    
    private lazy var sessionResponseProvider: SessionResponseProviderMock! = {
        SessionResponseProviderMock()
    }()
    
    private lazy var helper: RequestHelper! = {
        RequestHelperImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: SuplaCloudConfigHolder.self, suplaCloudConfigHolder!)
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
        DiContainer.shared.register(type: SessionResponseProvider.self, sessionResponseProvider!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        suplaCloudConfigHolder = nil
        suplaClientProvider = nil
        sessionResponseProvider = nil
        helper = nil
    }
    
    func test_shouldFailWhenCouldNotParseUrl() {
        // given
        let url = ""
        let observer: TestableObserver<(response: HTTPURLResponse, data: Data)> = observer()
        
        // when
        helper.getOAuthRequest(urlString: url)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 1)
        assertEvents(observer, items: [.error(RequestHelperError.wrongUrl(url: url))])
    }
    
    func test_shouldFailWhenTokenNil() {
        // given
        let url = "https://www.supla.org"
        let observer: TestableObserver<(response: HTTPURLResponse, data: Data)> = observer()
        
        // when
        helper.getOAuthRequest(urlString: url)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(observer, items: [.error(RequestHelperError.tokenNotValid(message: "By preparing request"))])
    }
    
    func test_shouldFailWhenTokenExpired() {
        // given
        let url = "https://www.supla.org"
        let observer: TestableObserver<(response: HTTPURLResponse, data: Data)> = observer()
        suplaCloudConfigHolder.token = SAOAuthToken.mock()
        
        // when
        helper.getOAuthRequest(urlString: url)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(observer, items: [.error(RequestHelperError.tokenNotValid(message: "By preparing request"))])
    }
    
    func test_shouldGetResponseWhenOAuthTokenCorrect() {
        // given
        let url = "https://www.supla.org"
        let observer: TestableObserver<(response: HTTPURLResponse, data: Data)> = observer()
        suplaCloudConfigHolder.token = SAOAuthToken.mock(expirationTime: 50)
        
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: "5.0", headerFields: nil)!
        let data = Data()
        let sessionResult = (response: response, data: data)
        sessionResponseProvider.responseReturns = Observable.just(sessionResult)
        
        // when
        helper.getOAuthRequest(urlString: url)
            .subscribe(observer)
            .disposed(by: disposeBag)
        startScheduler()
        
        // then
        assertEvents(observer, items: [
            .next(sessionResult),
            .completed
        ])
        XCTAssertEqual(sessionResponseProvider.responseParameters.count, 1)
    }
    
    func test_shouldReloadTokenWhenRequestFailsWith401AndProvideResponse() {
        // given
        let url = "https://www.supla.org"
        let observer: TestableObserver<(response: HTTPURLResponse, data: Data)> = observer()
        suplaCloudConfigHolder.token = SAOAuthToken.mock(expirationTime: 50)
        
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 401, httpVersion: "5.0", headerFields: nil)!
        let data = Data()
        let sessionResult = (response: response, data: data)
        sessionResponseProvider.responseReturns = Observable.just(sessionResult)
        
        // when
        helper.getOAuthRequest(urlString: url)
            .subscribe(observer)
            .disposed(by: disposeBag)
        startScheduler()
        
        // then
        assertEvents(observer, items: [
            .next(sessionResult),
            .completed
        ])
        XCTAssertEqual(sessionResponseProvider.responseParameters.count, 2)
    }
    
    func test_shouldReloadTokenWhenRequestFailsWith401AndEmitErrorWhenCouldNotReloadToken() {
        // given
        let url = "https://www.supla.org"
        let observer: TestableObserver<(response: HTTPURLResponse, data: Data)> = observer()
        suplaCloudConfigHolder.token = SAOAuthToken.mock(expirationTime: 50)
        
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 401, httpVersion: "5.0", headerFields: nil)!
        let data = Data()
        let sessionResult = (response: response, data: data)
        sessionResponseProvider.responseReturns = Observable.just(sessionResult)
        
        // when
        helper.getOAuthRequest(urlString: url)
            .subscribe(observer)
            .disposed(by: disposeBag)
        suplaCloudConfigHolder.token = nil
        startScheduler()
        
        // then
        assertEvents(observer, items: [
            .error(RequestHelperError.tokenNotValid(message: "By refreshing during the request")),
        ])
        XCTAssertEqual(sessionResponseProvider.responseParameters.count, 1)
    }
}
