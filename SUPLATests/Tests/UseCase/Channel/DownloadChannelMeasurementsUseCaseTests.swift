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
@testable import SUPLA

final class DownloadChannelMeasurementsUseCaseTests: UseCaseTest<Void> {
    
    private lazy var downloadEventsManager: DownloadEventsManagerMock! = {
        DownloadEventsManagerMock()
    }()
    
    private lazy var downloadTemperatureMeasurementsUseCase: DownloadTemperatureMeasurementsUseCaseMock! = {
        DownloadTemperatureMeasurementsUseCaseMock()
    }()
    
    private lazy var downloadTempHumidityMeasurementsUseCase: DownloadTempHumidityMeasurementsUseCaseMock! = {
        DownloadTempHumidityMeasurementsUseCaseMock()
    }()
    
    private lazy var useCase: DownloadChannelMeasurementsUseCase! = {
        DownloadChannelMeasurementsUseCaseImpl()
    }()
    
    override func setUp() {
        // super.setUp() intentionally commented out
        DiContainer.shared.register(type: SuplaSchedulers.self, SuplaSchedulersImpl())
        
        DiContainer.shared.register(type: DownloadEventsManager.self, downloadEventsManager!)
        DiContainer.shared.register(type: DownloadTemperatureLogUseCase.self, downloadTemperatureMeasurementsUseCase!)
        DiContainer.shared.register(type: DownloadTempHumidityLogUseCase.self, downloadTempHumidityMeasurementsUseCase!)
    }
    
    override func tearDown() {
        useCase = nil
        downloadEventsManager = nil
        downloadTemperatureMeasurementsUseCase = nil
        downloadTempHumidityMeasurementsUseCase = nil
        
        super.tearDown()
    }
    
    func test_shouldStartThermometerDownload() {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_THERMOMETER
        
        // when
        useCase.invoke(remoteId: remoteId, function: function)
        
        // then
        XCTAssertEqual(downloadTemperatureMeasurementsUseCase.parameters, [remoteId])
        XCTAssertTuples(downloadEventsManager.emitProgressStateParameters, [
            (remoteId, .started)
        ])
        XCTAssertEqual(downloadTempHumidityMeasurementsUseCase.parameters.count, 0)
    }
    
    func test_shouldStartThermometerAndHumidityDownload() {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        
        // when
        useCase.invoke(remoteId: remoteId, function: function)
        
        // then
        XCTAssertEqual(downloadTempHumidityMeasurementsUseCase.parameters, [remoteId])
        XCTAssertTuples(downloadEventsManager.emitProgressStateParameters, [
            (remoteId, .started)
        ])
        XCTAssertEqual(downloadTemperatureMeasurementsUseCase.parameters.count, 0)
    }
}
