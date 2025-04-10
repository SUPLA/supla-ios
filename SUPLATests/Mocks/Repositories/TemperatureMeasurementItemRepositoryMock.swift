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

import RxSwift

@testable import SUPLA

final class TemperatureMeasurementItemRepositoryMock: BaseRepositoryMock<SATemperatureMeasurementItem>, TemperatureMeasurementItemRepository {
    
    var deleteAllForRemoteIdAndProfileReturns: Observable<Void> = Observable.empty()
    var deleteAllForRemoteIdAndProfileParameters: [(Int32, Int32?)] = []
    func deleteAll(remoteId: Int32, serverId: Int32?) -> RxSwift.Observable<Void> {
        deleteAllForRemoteIdAndProfileParameters.append((remoteId, serverId))
        return deleteAllForRemoteIdAndProfileReturns
    }
    
    var deleteAllForProfileReturns: Observable<Void> = Observable.empty()
    var deleteAllForProfileParameters: [Int32?] = []
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        deleteAllForProfileParameters.append(serverId)
        return deleteAllForProfileReturns
    }
    
    var findMeasurementsParameters: [(Int32, Int32?, Date, Date)] = []
    var findMeasurementsReturns: Observable<[SATemperatureMeasurementItem]> = Observable.empty()
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SATemperatureMeasurementItem]> {
        findMeasurementsParameters.append((remoteId, serverId, startDate, endDate))
        return findMeasurementsReturns
    }
    
    var findMinTimestampParameters: [(Int32, Int32?)] = []
    var findMinTimestampReturns: Observable<TimeInterval?> = Observable.empty()
    func findMinTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        findMinTimestampParameters.append((remoteId, serverId))
        return findMinTimestampReturns
    }
    
    var findMaxTimestampParameters: [(Int32, Int32?)] = []
    var findMaxTimestampReturns: Observable<TimeInterval?> = Observable.empty()
    func findMaxTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        findMaxTimestampParameters.append((remoteId, serverId))
        return findMaxTimestampReturns
    }
    
    var findCountParameters: [(Int32, Int32?)] = []
    var findCountReturns: Observable<Int> = Observable.empty()
    func findCount(remoteId: Int32, serverId: Int32?) -> Observable<Int> {
        findCountParameters.append((remoteId, serverId))
        return findCountReturns
    }
    
    var storeMeasurementsParameters: [([SuplaCloudClient.TemperatureMeasurement], TimeInterval, Int32, Int32)] = []
    var storeMeasurementsReturns: () throws -> TimeInterval = { 0 }
    func storeMeasurements(measurements: [SuplaCloudClient.TemperatureMeasurement], timestamp: TimeInterval, serverId: Int32, remoteId: Int32) throws -> TimeInterval {
        storeMeasurementsParameters.append((measurements, timestamp, serverId, remoteId))
        return try storeMeasurementsReturns()
    }
    
    var getInitialMeasurementsMock: FunctionMock<Int32, Observable<(response: HTTPURLResponse, data: Data)>> = .init()
    func getInitialMeasurements(remoteId: Int32) -> Observable<(response: HTTPURLResponse, data: Data)> {
        getInitialMeasurementsMock.handle(remoteId)
    }
    
    var getMeasurementsParameters: [(Int32, TimeInterval)] = []
    var getMeasurementsReturns: [Observable<[SuplaCloudClient.TemperatureMeasurement]>] = []
    private var getMeasurementsCurrent = 0
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.TemperatureMeasurement]> {
        getMeasurementsParameters.append((remoteId, afterTimestamp))
        let id = getMeasurementsCurrent
        getMeasurementsCurrent += 1
        if (id < getMeasurementsReturns.count) {
            return getMeasurementsReturns[id]
        } else {
            return .empty()
        }
    }
    
    var fromJsonParameters: [Data] = []
    var fromJsonReturns: [SuplaCloudClient.TemperatureMeasurement]? = nil
    func fromJson(data: Data) throws -> [SuplaCloudClient.TemperatureMeasurement] {
        fromJsonParameters.append(data)
        if let fromJsonReturns = fromJsonReturns {
            return fromJsonReturns
        }
        return try SuplaCloudClient.TemperatureMeasurement.fromJson(data: data)
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
    }
}
