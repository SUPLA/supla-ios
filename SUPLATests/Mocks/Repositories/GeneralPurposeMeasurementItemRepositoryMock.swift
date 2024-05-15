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

final class GeneralPurposeMeasurementItemRepositoryMock: BaseRepositoryMock<SAGeneralPurposeMeasurementItem>, GeneralPurposeMeasurementItemRepository {
    var deleteAllForRemoteIdAndProfileParameters: [(Int32, AuthProfileItem)] = []
    var deleteAllForRemoteIdAndProfileReturns: Observable<Void> = .empty()
    func deleteAll(remoteId: Int32, profile: AuthProfileItem) -> RxSwift.Observable<Void> {
        deleteAllForRemoteIdAndProfileParameters.append((remoteId, profile))
        return deleteAllForRemoteIdAndProfileReturns
    }
    
    var deleteAllForProfileParameters: [AuthProfileItem] = []
    var deleteAllForProfileReturns: Observable<Void> = .empty()
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAllForProfileParameters.append(profile)
        return deleteAllForProfileReturns
    }
    
    var findMeasurementsParameters: [(Int32, AuthProfileItem, Date, Date)] = []
    var findMeasurementsReturns: Observable<[SAGeneralPurposeMeasurementItem]> = .empty()
    func findMeasurements(
        remoteId: Int32,
        profile: AuthProfileItem,
        startDate: Date,
        endDate: Date
    ) -> Observable<[SAGeneralPurposeMeasurementItem]> {
        findMeasurementsParameters.append((remoteId, profile, startDate, endDate))
        return findMeasurementsReturns
    }
    
    var findMinTimestampParameters: [(Int32, AuthProfileItem)] = []
    var findMinTimestampReturns: Observable<TimeInterval?> = .empty()
    func findMinTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        findMinTimestampParameters.append((remoteId, profile))
        return findMinTimestampReturns
    }
    
    var findMaxTimestampParameters: [(Int32, AuthProfileItem)] = []
    var findMaxTimestampReturns: Observable<TimeInterval?> = .empty()
    func findMaxTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        findMaxTimestampParameters.append((remoteId, profile))
        return findMaxTimestampReturns
    }
    
    var findCountParameters: [(Int32, AuthProfileItem)] = []
    var findCountReturns: Observable<Int> = .empty()
    func findCount(remoteId: Int32, profile: AuthProfileItem) -> Observable<Int> {
        findCountParameters.append((remoteId, profile))
        return findCountReturns
    }
    
    var storeMeasurementsParameters: [([SuplaCloudClient.GeneralPurposeMeasurement], TimeInterval, AuthProfileItem, Int32)] = []
    var storeMeasurementsReturns: TimeInterval = 0
    func storeMeasurements(measurements: [SuplaCloudClient.GeneralPurposeMeasurement], timestamp: TimeInterval, profile: AuthProfileItem, remoteId: Int32) throws -> TimeInterval {
        storeMeasurementsParameters.append((measurements, timestamp, profile, remoteId))
        return storeMeasurementsReturns
    }
    
    var getMeasurementsParameters: [(Int32, TimeInterval)] = []
    var getMeasurementsReturns: [Observable<[SuplaCloudClient.GeneralPurposeMeasurement]>] = []
    private var getMeasurementsCurrent = 0
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.GeneralPurposeMeasurement]> {
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
    var fromJsonReturns: [SuplaCloudClient.GeneralPurposeMeasurement]? = nil
    func fromJson(data: Data) throws -> [SuplaCloudClient.GeneralPurposeMeasurement] {
        fromJsonParameters.append(data)
        if let fromJsonReturns = fromJsonReturns {
            return fromJsonReturns
        }
        return try SuplaCloudClient.GeneralPurposeMeasurement.fromJson(data: data)
    }
}
