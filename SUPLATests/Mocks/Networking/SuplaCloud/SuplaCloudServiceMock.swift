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
import SharedCore
import RxSwift

final class SuplaCloudServiceMock: SuplaCloudService {
    var getInitialMeasurementsMock: FunctionMock<(Int32, SUPLA.SuplaCloudClient.HistoryMeasurementType?), Observable<(response: HTTPURLResponse, data: Data)>> = .init()
    func getInitialMeasurements(remoteId: Int32, type: SUPLA.SuplaCloudClient.HistoryMeasurementType?) -> Observable<(response: HTTPURLResponse, data: Data)> {
        getInitialMeasurementsMock.handle((remoteId, type))
    }
    
    var temperatureMeasurementsParameters: [(Int32, TimeInterval)] = []
    var temperatureMeasurementsReturns: [Observable<[SuplaCloudClient.TemperatureMeasurement]>] = []
    private var temperatureMeasurementsCurrent = 0
    func getTemperatureMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.TemperatureMeasurement]> {
        temperatureMeasurementsParameters.append((remoteId, afterTimestamp))
        
        let id = temperatureMeasurementsCurrent
        temperatureMeasurementsCurrent += 1
        if (id < temperatureMeasurementsReturns.count) {
            return temperatureMeasurementsReturns[id]
        } else {
            return .empty()
        }
    }
    
    var temperatureAndHumidityMeasurementsParameters: [(Int32, TimeInterval)] = []
    var temperatureAndHumidityMeasurementsReturns: [Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]>] = []
    private var temperatureAndHumidityMeasurementsCurrent = 0
    func getTemperatureAndHumidityMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]> {
        temperatureAndHumidityMeasurementsParameters.append((remoteId, afterTimestamp))
        
        let id = temperatureAndHumidityMeasurementsCurrent
        temperatureAndHumidityMeasurementsCurrent += 1
        if (id < temperatureAndHumidityMeasurementsReturns.count) {
            return temperatureAndHumidityMeasurementsReturns[id]
        } else {
            return .empty()
        }
    }
    
    var generalPurposeMeasurementParameters: [(Int32, TimeInterval)] = []
    var genenralPurposeMeasurementReturns: [Observable<[SuplaCloudClient.GeneralPurposeMeasurement]>] = []
    private var generalPurposeMeasurementCurrent = 0
    func getGeneralPurposeMeasurement(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.GeneralPurposeMeasurement]> {
        generalPurposeMeasurementParameters.append((remoteId, afterTimestamp))
        
        let id = generalPurposeMeasurementCurrent
        generalPurposeMeasurementCurrent += 1
        if (id < genenralPurposeMeasurementReturns.count) {
            return genenralPurposeMeasurementReturns[id]
        } else {
            return .empty()
        }
    }
    
    var generalPurposeMeterParameters: [(Int32, TimeInterval)] = []
    var generalPurposeMeterReturns: [Observable<[SuplaCloudClient.GeneralPurposeMeter]>] = []
    private var generalPurposeMeterCurrent = 0
    func getGeneralPurposeMeter(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.GeneralPurposeMeter]> {
        generalPurposeMeterParameters.append((remoteId, afterTimestamp))
        
        let id = generalPurposeMeterCurrent
        generalPurposeMeterCurrent += 1
        if (id < generalPurposeMeterReturns.count) {
            return generalPurposeMeterReturns[id]
        } else {
            return .empty()
        }
    }
    
    var electricityMeasurementsParameters: [(Int32, TimeInterval)] = []
    var electricityMeasurementsReturns: [Observable<[SuplaCloudClient.ElectricityMeasurement]>] = []
    private var electricityMeasurementsCurrent = 0
    func getElectricityMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.ElectricityMeasurement]> {
        electricityMeasurementsParameters.append((remoteId, afterTimestamp))
        
        let id = electricityMeasurementsCurrent
        electricityMeasurementsCurrent += 1
        if (id < electricityMeasurementsReturns.count) {
            return electricityMeasurementsReturns[id]
        } else {
            return .empty()
        }
    }
    
    var lastElectricityMeasurementsParameters: [(Int32, TimeInterval)] = []
    var lastElectricityMeasurementsReturns: [Observable<[SuplaCloudClient.ElectricityMeasurement]>] = []
    private var lastElectricityMeasurementsCurrent = 0
    func getLastElectricityMeasurements(remoteId: Int32, beforeTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.ElectricityMeasurement]> {
        lastElectricityMeasurementsParameters.append((remoteId, beforeTimestamp))
        
        let id = lastElectricityMeasurementsCurrent
        lastElectricityMeasurementsCurrent += 1
        if (id < lastElectricityMeasurementsReturns.count) {
            return lastElectricityMeasurementsReturns[id]
        } else {
            return .empty()
        }
    }
    
    var getImpulseCounterPhotoMock: FunctionMock<Int32, Observable<ImpulseCounterPhotoDto>> = .init()
    func getImpulseCounterPhoto(remoteId: Int32) -> Observable<ImpulseCounterPhotoDto> {
        getImpulseCounterPhotoMock.parameters.append(remoteId)
        return getImpulseCounterPhotoMock.returns.next()
    }
    
    var getHistoryMeasurementsMock: FunctionMock<(Int32, TimeInterval, SUPLA.SuplaCloudClient.HistoryMeasurementType), Observable<[SUPLA.SuplaCloudClient.HistoryMeasurement]>> = .init()
    func getHistoryMeasurements(remoteId: Int32, afterTimestamp: TimeInterval, type: SUPLA.SuplaCloudClient.HistoryMeasurementType) -> Observable<[SUPLA.SuplaCloudClient.HistoryMeasurement]> {
        getHistoryMeasurementsMock.handle((remoteId, afterTimestamp, type))
    }
    
    var getElectricityMeterChannelMock: FunctionMock<Int32, Observable<ElectricityChannelDto>> = .init()
    func getElectricityMeterChannel(remoteId: Int32) -> Observable<ElectricityChannelDto> {
        getElectricityMeterChannelMock.handle(remoteId)
    }
    
    var getHumidityMeasurementsMock: FunctionMock<(Int32, TimeInterval), Observable<[SUPLA.SuplaCloudClient.HumidityMeasurement]>> = .init()
    func getHumidityMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SUPLA.SuplaCloudClient.HumidityMeasurement]> {
        getHumidityMeasurementsMock.handle((remoteId, afterTimestamp))
    }
    
    func getImpulseCounterMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SUPLA.SuplaCloudClient.ImpulseCounterMeasurement]> {
        .empty()
    }
    
    func getLastImpulseCounterMeasurements(remoteId: Int32, beforeTimestamp: TimeInterval) -> Observable<[SUPLA.SuplaCloudClient.ImpulseCounterMeasurement]> {
        .empty()
    }
    
    func getImpulseCounterPhotoHistory(remoteId: Int32) -> Observable<[ImpulseCounterPhotoDto]> {
        .empty()
    }
    
    func getUserIcons(_ remoteIds: [Int32]) -> Observable<[SUPLA.SuplaCloudClient.UserIcon]> {
        .empty()
    }
    
    func getThermostatMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SUPLA.SuplaCloudClient.ThermostatMeasurement]> {
        .empty()
    }
}
