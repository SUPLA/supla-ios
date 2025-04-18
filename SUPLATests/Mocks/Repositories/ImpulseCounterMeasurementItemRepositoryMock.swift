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

final class ImpulseCounterMeasurementItemRepositoryMock: BaseRepositoryMock<SAImpulseCounterMeasurementItem>, ImpulseCounterMeasurementItemRepository {
    
    var deleteAllObservable: Observable<Void> = Observable.empty()
    var deleteAllCounter = 0
    
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        deleteAllCounter += 1
        return deleteAllObservable
    }
    
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SAImpulseCounterMeasurementItem]> {
        .empty()
    }
    
    func storeMeasurements(measurements: [SUPLA.SuplaCloudClient.ImpulseCounterMeasurement], latestItem: SUPLA.SuplaCloudClient.ImpulseCounterMeasurement?, serverId: Int32, remoteId: Int32) throws -> SUPLA.SuplaCloudClient.ImpulseCounterMeasurement? {
        nil
    }
    
    func findOldestEntity(remoteId: Int32, serverId: Int32) -> Observable<SAImpulseCounterMeasurementItem?> {
        .empty()
    }
    
    func deleteAll(remoteId: Int32, serverId: Int32?) -> Observable<Void> {
        .empty()
    }
    
    func findMinTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        .empty()
    }
    
    func findMaxTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        .empty()
    }
    
    func findCount(remoteId: Int32, serverId: Int32?) -> Observable<Int> {
        .empty()
    }
    
    func getInitialMeasurements(remoteId: Int32) -> Observable<(response: HTTPURLResponse, data: Data)> {
        Observable.empty()
    }
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SUPLA.SuplaCloudClient.ImpulseCounterMeasurement]> {
        .empty()
    }
    
    func storeMeasurements(measurements: [SUPLA.SuplaCloudClient.ImpulseCounterMeasurement], timestamp: TimeInterval, serverId: Int32, remoteId: Int32) throws -> TimeInterval {
        0
    }
    
    func fromJson(data: Data) throws -> [SUPLA.SuplaCloudClient.ImpulseCounterMeasurement] {
        []
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
    }
}
