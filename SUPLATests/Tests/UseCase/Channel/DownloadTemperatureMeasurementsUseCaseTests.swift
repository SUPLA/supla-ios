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

import RxTest
import XCTest
import RxSwift
@testable import SUPLA

final class DownloadTemperatureMeasurementsUseCaseTests: UseCaseTest<Float> {
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var temperatureMeasurementItemRepository: TemperatureMeasurementItemRepositoryMock! = {
        TemperatureMeasurementItemRepositoryMock()
    }()
    
    private lazy var useCase: DownloadTemperatureLogUseCase! = {
        DownloadTemperatureLogUseCaseImpl(temperatureMeasurementItemRepository)
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, temperatureMeasurementItemRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        profileRepository = nil
        temperatureMeasurementItemRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldFailWhenCouldNotLoadActiveProfile() {
        // given
        let remoteId: Int32 = 213
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(GeneralError.illegalState(message: "Could not load active profile\'s server ID"))
        ])
    }
    
    func test_shouldFailWhenCouldNotLoadInitialMeasurements() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 2)
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(.empty())
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(GeneralError.illegalState(message: "Could not load initial measurements"))
        ])
    }
    
    func test_shouldFailWhenInitialMeasurementsReturns400() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 2)
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: HTTPURLResponse(url: .init(string: "url")!, statusCode: 400, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )))
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(GeneralError.illegalState(message: "Could not load initial measurements"))
        ])
    }
    
    func test_shouldFailWhenInitialMeasurementsHasMissingData() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 2)
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )))
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(GeneralError.illegalState(message: "Could not load initial measurements"))
        ])
    }
    
    func test_shouldCleanDataWhenNoMeasurements() {
        // given
        let remoteId: Int32 = 213
        let serverId: Int32 = 1
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(),
            data: mockedData()
        )))
        temperatureMeasurementItemRepository.getMeasurementsReturns = [Observable.just([])]
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .completed
        ])
        XCTAssertTuples(temperatureMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [(remoteId, serverId)])
    }
    
    func test_shouldImportDataWhenDbIsEmpty() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 2)
        let measurement = SuplaCloudClient.TemperatureMeasurement(
            date_timestamp: Date(),
            temperature: 10.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        temperatureMeasurementItemRepository.getMeasurementsReturns = [
            Observable.just([measurement]),
            Observable.just([])
        ]
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(1),
            .completed
        ])
    }
    
    func test_shouldDoNotImportWhenThereIsNothingMoreOnCloud() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 2)
        let measurementDate = Date()
        let measurement = SuplaCloudClient.TemperatureMeasurement(
            date_timestamp: measurementDate,
            temperature: 10.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        temperatureMeasurementItemRepository.findMinTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        temperatureMeasurementItemRepository.findMaxTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        temperatureMeasurementItemRepository.getMeasurementsReturns = [Observable.just([])]
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .completed
        ])
        XCTAssertTuples(temperatureMeasurementItemRepository.getMeasurementsParameters, [(remoteId, measurementDate.timeIntervalSince1970)])
    }
    
    func test_shouldSkipImportWhenDbAndCloudAreSimilar() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 2)
        let measurementDate = Date()
        let measurement = SuplaCloudClient.TemperatureMeasurement(
            date_timestamp: measurementDate,
            temperature: 10.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        temperatureMeasurementItemRepository.findMinTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        temperatureMeasurementItemRepository.findCountReturns = .just(1)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .completed
        ])
        XCTAssertTuples(temperatureMeasurementItemRepository.getMeasurementsParameters, [])
    }
    
    func test_shouldCleanDbAndImportNewMeasurements() {
        // given
        let remoteId: Int32 = 213
        let serverId: Int32 = 2
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        let measurementDate = Date()
        let measurement = SuplaCloudClient.TemperatureMeasurement(
            date_timestamp: measurementDate,
            temperature: 10.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        temperatureMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1, "x-total-count"),
            data: mockedData(measurements: [measurement])
        )))
        let oldDate = Date.create(year: 2018)!.timeIntervalSince1970
        temperatureMeasurementItemRepository.findMinTimestampReturns = .just(oldDate)
        temperatureMeasurementItemRepository.findMaxTimestampReturns = .just(oldDate)
        temperatureMeasurementItemRepository.getMeasurementsReturns = [Observable.just([])]
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .completed
        ])
        XCTAssertTuples(temperatureMeasurementItemRepository.getMeasurementsParameters, [(remoteId, oldDate)])
        XCTAssertTuples(temperatureMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [(remoteId, serverId)])
    }
    
    private func mockedHttpResponse(count: Int = 0, _ totalCountHeader: String = "X-Total-Count") -> HTTPURLResponse {
        let headers: [String:String] = [totalCountHeader : "\(count)"]
        return HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: headers)!
    }
    
    private func mockedData(measurements: [SuplaCloudClient.TemperatureMeasurement] = []) -> Data {
        return try! SuplaCloudClient.encoder.encode(measurements)
    }
}
