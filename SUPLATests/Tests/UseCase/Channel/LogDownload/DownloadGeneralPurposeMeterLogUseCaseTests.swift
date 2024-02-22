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
    
    private lazy var suplaCloudService: SuplaCloudServiceMock! = {
        SuplaCloudServiceMock()
    }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
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
        
        DiContainer.shared.register(type: SuplaCloudService.self, suplaCloudService!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository!)
        DiContainer.shared.register(type: LoadChannelConfigUseCase.self, loadChannelConfigUseCase!)
    }
    
    override func tearDown() {
        useCase = nil
        suplaCloudService = nil
        profileRepository = nil
        generalPurposeMeterItemRepository = nil
        loadChannelConfigUseCase = nil
        
        super.tearDown()
    }
    
    func test_shouldImportDataWhenDbIsEmpty() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        let measurement = SuplaCloudClient.GeneralPurposeMeter(
            date_timestamp: Date(),
            value: "10.0"
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        suplaCloudService.initialMeasurementsReturns = Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        ))
        generalPurposeMeterItemRepository.getMeasurementsReturns = [
            Observable.just([measurement]),
            Observable.just([])
        ]
        loadChannelConfigUseCase.returns = .just(SuplaChannelGeneralPurposeMeterConfig.mock())
        
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
        let measurementDate = Date()
        let measurement = SuplaCloudClient.GeneralPurposeMeter(
            date_timestamp: measurementDate,
            value: "10.0"
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        suplaCloudService.initialMeasurementsReturns = Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        ))
        generalPurposeMeterItemRepository.findMinTimestampReturns = .just(measurementDate.timeIntervalSince1970)
        generalPurposeMeterItemRepository.getMeasurementsReturns = [Observable.just([])]
        loadChannelConfigUseCase.returns = .just(SuplaChannelGeneralPurposeMeterConfig.mock())
        generalPurposeMeterItemRepository.findOldestEntityReturns = .just(SAGeneralPurposeMeterItem.mock(date: measurementDate))
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .completed
        ])
        XCTAssertTuples(generalPurposeMeterItemRepository.getMeasurementsParameters, [(remoteId, measurementDate.timeIntervalSince1970)])
    }
    
    func test_shouldNotImportDataWhenThereIsNoChannelConfig() {
        // given
        let remoteId: Int32 = 213
        let profile = AuthProfileItem(testContext: nil)
        let measurement = SuplaCloudClient.GeneralPurposeMeter(
            date_timestamp: Date(),
            value: "10.0"
        )
        profileRepository.activeProfileObservable = Observable.just(profile)
        suplaCloudService.initialMeasurementsReturns = Observable.just((
            response: mockedHttpResponse(count: 1),
            data: mockedData(measurements: [measurement])
        ))
        generalPurposeMeterItemRepository.getMeasurementsReturns = [
            Observable.just([measurement]),
            Observable.just([])
        ]
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .error(GeneralError.illegalState(message: "Channel config not found"))
        ])
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
