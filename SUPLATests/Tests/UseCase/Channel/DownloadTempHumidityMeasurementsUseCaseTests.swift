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

final class DownloadTempHumidityMeasurementsUseCaseTests: UseCaseTest<Float> {
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var tempHumidityMeasurementItemRepository: TempHumidityMeasurementItemRepositoryMock! = {
        TempHumidityMeasurementItemRepositoryMock()
    }()
    
    private lazy var useCase: DownloadTempHumidityLogUseCase! = {
        DownloadTempHumidityLogUseCaseImpl(tempHumidityMeasurementItemRepository)
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, tempHumidityMeasurementItemRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        profileRepository = nil
        tempHumidityMeasurementItemRepository = nil
        
        super.tearDown()
    }
    
    func test_shouldFailWhenCouldNotLoadInitialMeasurements() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock()
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(.empty())
        
        // when
        do {
            try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        } catch {
            // then
            guard let generalError = error as? GeneralError else { XCTFail(); return }
            XCTAssertEqual(generalError, GeneralError.illegalState(message: "Could not load initial measurements"))
        }
        
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
    }
    
    func test_shouldFailWhenInitialMeasurementsReturns400() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock()
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: HTTPURLResponse(url: .init(string: "url")!, statusCode: 400, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )))
        
        // when
        do {
            try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        } catch {
            // then
            guard let generalError = error as? GeneralError else { XCTFail(); return }
            XCTAssertEqual(generalError, GeneralError.illegalState(message: "Could not load initial measurements"))
        }
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
    }
    
    func test_shouldFailWhenInitialMeasurementsHasMissingData() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock()
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )))
        
        // when
        do {
            try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        } catch {
            // then
            guard let generalError = error as? GeneralError else { XCTFail(); return }
            XCTAssertEqual(generalError, GeneralError.illegalState(message: "Could not load initial measurements"))
        }
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
    }
    
    func test_shouldCleanDataWhenNoMeasurements() async throws {
        // given
        let remoteId: Int32 = 213
        let serverId: Int32 = 3
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(),
            data: mockedData()
        )))
        tempHumidityMeasurementItemRepository.getMeasurementsReturns = [Observable.just([])]
        
        // when
        try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        
        // then
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [(remoteId, serverId)])
    }
    
    func test_shouldImportDataWhenDbIsEmpty() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock()
        let measurement = SuplaCloudClient.TemperatureAndHumidityMeasurement(
            date_timestamp: Date(),
            temperature: 10.0,
            humidity: 50.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        
        tempHumidityMeasurementItemRepository.getMeasurementsReturns = [
            Observable.just([measurement]),
            Observable.just([])
        ]
        
        // when
        try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        
        // then
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.getMeasurementsParameters, [
            (remoteId, 0),
            (remoteId, 0)
        ])
    }
    
    func test_shouldDoNotImportWhenThereIsNothingMoreOnCloud() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock()
        let measurementDate = Date()
        let measurement = SuplaCloudClient.TemperatureAndHumidityMeasurement(
            date_timestamp: measurementDate,
            temperature: 10.0,
            humidity: 50.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        tempHumidityMeasurementItemRepository.getMeasurementsReturns = [
            Observable.just([])
        ]
        tempHumidityMeasurementItemRepository.findMinTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        tempHumidityMeasurementItemRepository.findMaxTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        
        // when
        try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        
        // then
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.getMeasurementsParameters, [(remoteId, measurementDate.timeIntervalSince1970)])
    }
    
    func test_shouldSkipImportWhenDbAndCloudAreSimilar() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock()
        let measurementDate = Date()
        let measurement = SuplaCloudClient.TemperatureAndHumidityMeasurement(
            date_timestamp: measurementDate,
            temperature: 10.0,
            humidity: 50.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        tempHumidityMeasurementItemRepository.findMinTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        tempHumidityMeasurementItemRepository.findCountReturns = .just(1)
        
        // when
        try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        
        // then
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.getMeasurementsParameters, [])
    }
    
    func test_shouldCleanDbAndImportNewMeasurements() async throws {
        // given
        let remoteId: Int32 = 213
        let serverId: Int32 = 3
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        let measurementDate = Date()
        let measurement = SuplaCloudClient.TemperatureAndHumidityMeasurement(
            date_timestamp: measurementDate,
            temperature: 10.0,
            humidity: 50.0
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        tempHumidityMeasurementItemRepository.getMeasurementsReturns = [
            Observable.just([])
        ]
        let oldDate = Date.create(year: 2018)!.timeIntervalSince1970
        tempHumidityMeasurementItemRepository.findMinTimestampReturns = .just(oldDate)
        tempHumidityMeasurementItemRepository.findMaxTimestampReturns = .just(oldDate)
        
        // when
        try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        
        // then
        XCTAssertEqual(tempHumidityMeasurementItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.getMeasurementsParameters, [(remoteId, oldDate)])
        XCTAssertTuples(tempHumidityMeasurementItemRepository.deleteAllForRemoteIdAndProfileParameters, [(remoteId, serverId)])
    }
    
    private func mockedHttpResponse(count: Int = 0) -> HTTPURLResponse {
        let headers: [String:String] = ["X-Total-Count" : "\(count)"]
        return HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: headers)!
    }
    
    private func mockedData(measurements: [SuplaCloudClient.TemperatureAndHumidityMeasurement] = []) -> Data {
        return try! SuplaCloudClient.encoder.encode(measurements)
    }
}
