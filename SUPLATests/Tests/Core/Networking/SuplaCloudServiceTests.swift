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

class SuplaCloudServiceTests: ObservableTestCase {
    
    private lazy var requestHelper: RequestHelperMock! = {
        RequestHelperMock()
    }()
    
    private lazy var configHolder: SuplaCloudConfigHolderMock! = {
        SuplaCloudConfigHolderMock()
    }()
    
    private lazy var service: SuplaCloudService! = {
        SuplaCloudServiceImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: RequestHelper.self, requestHelper!)
        DiContainer.shared.register(type: SuplaCloudConfigHolder.self, configHolder!)
    }
    
    override func tearDown() {
        requestHelper = nil
        configHolder = nil
        service = nil
        
        super.tearDown()
    }
    
    func test_shoulGetInitialMeasurements() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { "supla.org" }
        let observer = schedulers.testScheduler.createObserver((response: HTTPURLResponse, data: Data).self)
        
        // when
        service.getInitialMeasurements(remoteId: remoteId)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [.completed])
        XCTAssertEqual(
            requestHelper.oauthRequestParameters,
            ["supla.org/api/2.2.0/channels/123/measurement-logs?order=ASC&limit=2&offset=0"]
        )
    }
    
    func test_shoulGetErrorWhenTokenMissing() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { throw GeneralError.illegalState(message: "No Token") }
        let observer = schedulers.testScheduler.createObserver((response: HTTPURLResponse, data: Data).self)
        
        // when
        service.getInitialMeasurements(remoteId: remoteId)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [.error(GeneralError.illegalState(message: "No Token"))])
        XCTAssertEqual(requestHelper.oauthRequestParameters, [])
    }
    
    func test_shoulGetTemperatureMeasurements() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { "supla.org" }
        let observer = schedulers.testScheduler.createObserver([SuplaCloudClient.TemperatureMeasurement].self)
        let measurement = SuplaCloudClient.TemperatureMeasurement(
            date_timestamp: Date(),
            temperature: "12.5"
        )
        let data = try! SuplaCloudClient.encoder.encode([measurement])
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        requestHelper.oauthRequestReturns = Observable.just((response: response!, data: data))
        
        // when
        service.getTemperatureMeasurements(remoteId: remoteId, afterTimestamp: 222)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [
            .next([measurement]),
            .completed
        ])
        XCTAssertEqual(
            requestHelper.oauthRequestParameters,
            ["supla.org/api/2.2.0/channels/123/measurement-logs?order=ASC&limit=5000&afterTimestamp=222"]
        )
    }
    
    func test_shoulEmitErrorWhenCouldNotParseTemperatureMeasurements() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { "supla.org" }
        let observer = schedulers.testScheduler.createObserver([SuplaCloudClient.TemperatureMeasurement].self)
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        requestHelper.oauthRequestReturns = Observable.just((response: response!, data: Data()))
        
        // when
        service.getTemperatureMeasurements(remoteId: remoteId, afterTimestamp: 222)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [
            .error(DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "The given data was not valid JSON.",
                    underlyingError: NSError(
                        domain: NSCocoaErrorDomain,
                        code: 3840,
                        userInfo: [NSDebugDescriptionErrorKey: "Unexpected end of file"]
                    )
                )
            ))
        ])
        XCTAssertEqual(
            requestHelper.oauthRequestParameters,
            ["supla.org/api/2.2.0/channels/123/measurement-logs?order=ASC&limit=5000&afterTimestamp=222"]
        )
    }
    
    func test_shoulEmitErrorWhenTemperatureMeasurementsRequestFails() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { "supla.org" }
        let observer = schedulers.testScheduler.createObserver([SuplaCloudClient.TemperatureMeasurement].self)
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        requestHelper.oauthRequestReturns = Observable.just((response: response!, data: Data()))
        
        // when
        service.getTemperatureMeasurements(remoteId: remoteId, afterTimestamp: 222)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [
            .error(SuplaCloudError.statusCodeNoSuccess(code: 404))
        ])
        XCTAssertEqual(
            requestHelper.oauthRequestParameters,
            ["supla.org/api/2.2.0/channels/123/measurement-logs?order=ASC&limit=5000&afterTimestamp=222"]
        )
    }
    
    func test_shoulGetTemperatureAndHumidityMeasurements() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { "supla.org" }
        let observer = schedulers.testScheduler.createObserver([SuplaCloudClient.TemperatureAndHumidityMeasurement].self)
        let measurement = SuplaCloudClient.TemperatureAndHumidityMeasurement(
            date_timestamp: Date(),
            temperature: "12.5",
            humidity: "55"
        )
        let data = try! SuplaCloudClient.encoder.encode([measurement])
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        requestHelper.oauthRequestReturns = Observable.just((response: response!, data: data))
        
        // when
        service.getTemperatureAndHumidityMeasurements(remoteId: remoteId, afterTimestamp: 222)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [
            .next([measurement]),
            .completed
        ])
        XCTAssertEqual(
            requestHelper.oauthRequestParameters,
            ["supla.org/api/2.2.0/channels/123/measurement-logs?order=ASC&limit=5000&afterTimestamp=222"]
        )
    }
    
    func test_shoulEmitErrorWhenTemperatureAndHumidityMeasurementsRequestFails() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { "supla.org" }
        let observer = schedulers.testScheduler.createObserver([SuplaCloudClient.TemperatureAndHumidityMeasurement].self)
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        requestHelper.oauthRequestReturns = Observable.just((response: response!, data: Data()))
        
        // when
        service.getTemperatureAndHumidityMeasurements(remoteId: remoteId, afterTimestamp: 222)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [
            .error(SuplaCloudError.statusCodeNoSuccess(code: 404))
        ])
        XCTAssertEqual(
            requestHelper.oauthRequestParameters,
            ["supla.org/api/2.2.0/channels/123/measurement-logs?order=ASC&limit=5000&afterTimestamp=222"]
        )
    }
    
    func test_shoulEmitErrorWhenCouldNotParseTemperatureAndHumidityMeasurements() {
        // given
        let remoteId: Int32 = 123
        configHolder.requireUrlReturns = { "supla.org" }
        let observer = schedulers.testScheduler.createObserver([SuplaCloudClient.TemperatureAndHumidityMeasurement].self)
        let response = HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        requestHelper.oauthRequestReturns = Observable.just((response: response!, data: Data()))
        
        // when
        service.getTemperatureAndHumidityMeasurements(remoteId: remoteId, afterTimestamp: 222)
            .subscribe(observer)
            .disposed(by: disposeBag)
        schedulers.testScheduler.start()
        
        // then
        assertEvents(observer, items: [
            .error(DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "The given data was not valid JSON.",
                    underlyingError: NSError(
                        domain: NSCocoaErrorDomain,
                        code: 3840,
                        userInfo: [NSDebugDescriptionErrorKey: "Unexpected end of file"]
                    )
                )
            ))
        ])
        XCTAssertEqual(
            requestHelper.oauthRequestParameters,
            ["supla.org/api/2.2.0/channels/123/measurement-logs?order=ASC&limit=5000&afterTimestamp=222"]
        )
    }
}
