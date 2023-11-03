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
    
    var deleteAllObservable: Observable<Void> = Observable.empty()
    var deleteAllCounter = 0
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAllCounter += 1
        return deleteAllObservable
    }
    
    var findMeasurementsParameters: [(Int32, AuthProfileItem, Date, Date)] = []
    var findMeasurementsReturns: Observable<[SATemperatureMeasurementItem]> = Observable.empty()
    func findMeasurements(remoteId: Int32, profile: AuthProfileItem, startDate: Date, endDate: Date) -> Observable<[SATemperatureMeasurementItem]> {
        findMeasurementsParameters.append((remoteId, profile, startDate, endDate))
        return findMeasurementsReturns
    }
    
    var findMinTimestampParameters: [(Int32, AuthProfileItem)] = []
    var findMinTimestampReturns: Observable<TimeInterval?> = Observable.empty()
    func findMinTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        findMinTimestampParameters.append((remoteId, profile))
        return findMinTimestampReturns
    }
    
    var findMaxTimestampParameters: [(Int32, AuthProfileItem)] = []
    var findMaxTimestampReturns: Observable<TimeInterval?> = Observable.empty()
    func findMaxTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        findMaxTimestampParameters.append((remoteId, profile))
        return findMaxTimestampReturns
    }
    
    var findCountParameters: [(Int32, AuthProfileItem)] = []
    var findCountReturns: Observable<Int> = Observable.empty()
    func findCount(remoteId: Int32, profile: AuthProfileItem) -> Observable<Int> {
        findCountParameters.append((remoteId, profile))
        return findCountReturns
    }
    
    var storeMeasurementsParameters: [([SuplaCloudClient.TemperatureMeasurement], TimeInterval, AuthProfileItem, Int32)] = []
    var storeMeasurementsReturns: () throws -> TimeInterval = { 0 }
    func storeMeasurements(measurements: [SuplaCloudClient.TemperatureMeasurement], timestamp: TimeInterval, profile: AuthProfileItem, remoteId: Int32) throws -> TimeInterval {
        storeMeasurementsParameters.append((measurements, timestamp, profile, remoteId))
        return try storeMeasurementsReturns()
    }
}
