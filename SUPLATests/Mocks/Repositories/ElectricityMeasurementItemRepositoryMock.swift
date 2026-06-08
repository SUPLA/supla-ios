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

final class ElectricityMeasurementItemRepositoryMock: BaseRepositoryMock<SAElectricityMeasurementItem>, ElectricityMeasurementItemRepository {
    
    var deleteAllMock: FunctionMock<Int32?, Observable<Void>> = .init()
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        deleteAllMock.handle(serverId)
    }
    
    var findMeasurementsMock: FunctionMock<(Int32, Int32?, Date, Date), Observable<[SAElectricityMeasurementItem]>> = .init()
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SAElectricityMeasurementItem]> {
        return findMeasurementsMock.handle((remoteId, serverId, startDate, endDate))
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.ElectricityMeasurement], latestItem: DownloadElectricityMeterLogUseCaseImpl.Latest?, serverId: Int32, remoteId: Int32) throws -> DownloadElectricityMeterLogUseCaseImpl.Latest? {
        return nil
    }
    
    var findOldestEntityMock: FunctionMock<(Int32, Int32?), Observable<SAElectricityMeasurementItem?>> = .init()
    func findOldestEntity(remoteId: Int32, serverId: Int32?) -> Observable<SAElectricityMeasurementItem?> {
        return findOldestEntityMock.handle((remoteId, serverId))
    }
    
    func deleteAll(remoteId: Int32, serverId: Int32?) -> Observable<Void> {
        return Observable.empty()
    }
    
    func findMinTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        return Observable.empty()
    }
    
    func findMaxTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        return Observable.empty()
    }
    
    func findCount(remoteId: Int32, serverId: Int32?) -> Observable<Int> {
        return Observable.empty()
    }
    
    func getInitialMeasurements(remoteId: Int32) -> Observable<(response: HTTPURLResponse, data: Data)> {
        Observable.empty()
    }
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.ElectricityMeasurement]> {
        return Observable.empty()
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.ElectricityMeasurement], timestamp: TimeInterval, serverId: Int32, remoteId: Int32) throws -> TimeInterval {
        return 0.0
    }
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.ElectricityMeasurement] {
        return []
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
    }
}
