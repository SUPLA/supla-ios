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

final class DownloadGeneralPurposeMeterLogUseCaseTests: UseCaseTest<Float> {
    
    private lazy var generalPurposeMeterItemRepository: GeneralPurposeMeterItemRepositoryMock! = {
        GeneralPurposeMeterItemRepositoryMock()
    }()
    
    private lazy var loadChannelConfigUseCase: LoadChannelConfigUseCaseMock! = {
        LoadChannelConfigUseCaseMock()
    }()
    
    private lazy var useCase: DownloadGeneralPurposeMeterLogUseCase! = {
        DownloadGeneralPurposeMeterLogUseCaseImpl(generalPurposeMeterItemRepository)
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository!)
        DiContainer.shared.register(type: LoadChannelConfigUseCase.self, loadChannelConfigUseCase!)
    }
    
    override func tearDown() {
        useCase = nil
        generalPurposeMeterItemRepository = nil
        loadChannelConfigUseCase = nil
        
        super.tearDown()
    }
    
    func test_shouldImportDataWhenDbIsEmpty() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 1)
        let date = Date()
        let measurement = SuplaCloudClient.GeneralPurposeMeter(
            date_timestamp: date,
            value: 10.0
        )
        generalPurposeMeterItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        generalPurposeMeterItemRepository.getMeasurementsReturns = [
            Observable.just([measurement]),
            Observable.just([])
        ]
        loadChannelConfigUseCase.returns = .just(SuplaChannelGeneralPurposeMeterConfig.mock())
        
        // when
        try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        
        // then
        XCTAssertEqual(generalPurposeMeterItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
        XCTAssertTuples(generalPurposeMeterItemRepository.getMeasurementsParameters, [
            (remoteId, 0),
            (remoteId, 0)
        ])
    }
    
    func test_shouldDoNotImportWhenThereIsNothingMoreOnCloud() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 1)
        let measurementDate = Date()
        let measurement = SuplaCloudClient.GeneralPurposeMeter(
            date_timestamp: measurementDate,
            value: 10.0
        )
        generalPurposeMeterItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        generalPurposeMeterItemRepository.findMinTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        generalPurposeMeterItemRepository.getMeasurementsReturns = [Observable.just([])]
        loadChannelConfigUseCase.returns = .just(SuplaChannelGeneralPurposeMeterConfig.mock())
        generalPurposeMeterItemRepository.findOldestEntityReturns = .just(SAGeneralPurposeMeterItem.mock(date: measurementDate))
        
        // when
        try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        
        // then
        XCTAssertEqual(generalPurposeMeterItemRepository.getInitialMeasurementsMock.parameters, [remoteId])
        XCTAssertTuples(generalPurposeMeterItemRepository.getMeasurementsParameters, [(remoteId, measurementDate.timeIntervalSince1970)])
    }
    
    func test_shouldNotImportDataWhenThereIsNoChannelConfig() async throws {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: 1)
        let measurement = SuplaCloudClient.GeneralPurposeMeter(
            date_timestamp: Date(),
            value: 10.0
        )
        generalPurposeMeterItemRepository.getInitialMeasurementsMock.returns = .single(Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        )))
        generalPurposeMeterItemRepository.getMeasurementsReturns = [
            Observable.just([measurement]),
            Observable.just([])
        ]
        
        // when
        do {
            try await useCase.invoke(remoteId: remoteId, profile: profile, observer: { _ in })
        } catch {
            guard let generalError = error as? GeneralError else { XCTFail(); return }
            XCTAssertEqual(generalError, GeneralError.illegalState(message: "Channel config not found"))
        }
        
        // then
        XCTAssertEqual(generalPurposeMeterItemRepository.storeMeasurementsParameters.count, 0)
    }
    
    private func mockedHttpResponse(count: Int = 0) -> HTTPURLResponse {
        let headers: [String:String] = ["X-Total-Count" : "\(count)"]
        return HTTPURLResponse(url: .init(string: "url")!, statusCode: 200, httpVersion: nil, headerFields: headers)!
    }
    
    private func mockedData(measurements: [SuplaCloudClient.GeneralPurposeMeter] = []) -> Data {
        return try! SuplaCloudClient.encoder.encode(measurements)
    }
}
