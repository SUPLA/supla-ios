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

final class GeneralPurposeMeterItemRepositoryMock: BaseRepositoryMock<SAGeneralPurposeMeterItem>, GeneralPurposeMeterItemRepository {
    var deleteAllForRemoteIdAndProfileParameters: [(Int32, Int32?)] = []
    var deleteAllForRemoteIdAndProfileReturns: Observable<Void> = .empty()
    func deleteAll(remoteId: Int32, serverId: Int32?) -> RxSwift.Observable<Void> {
        deleteAllForRemoteIdAndProfileParameters.append((remoteId, serverId))
        return deleteAllForRemoteIdAndProfileReturns
    }
    
    var deleteAllForProfileParameters: [Int32?] = []
    var deleteAllForProfileReturns: Observable<Void> = .empty()
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        deleteAllForProfileParameters.append(serverId)
        return deleteAllForProfileReturns
    }
    
    var findMeasurementsParameters: [(Int32, Int32?, Date, Date)] = []
    var findMeasurementsReturns: Observable<[SAGeneralPurposeMeterItem]> = .empty()
    func findMeasurements(
        remoteId: Int32,
        serverId: Int32?,
        startDate: Date,
        endDate: Date
    ) -> Observable<[SAGeneralPurposeMeterItem]> {
        findMeasurementsParameters.append((remoteId, serverId, startDate, endDate))
        return findMeasurementsReturns
    }
    
    var findMinTimestampParameters: [(Int32, Int32?)] = []
    var findMinTimestampReturns: Observable<TimeInterval?> = .empty()
    func findMinTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        findMinTimestampParameters.append((remoteId, serverId))
        return findMinTimestampReturns
    }
    
    var findMaxTimestampParameters: [(Int32, Int32?)] = []
    var findMaxTimestampReturns: Observable<TimeInterval?> = .empty()
    func findMaxTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        findMaxTimestampParameters.append((remoteId, serverId))
        return findMaxTimestampReturns
    }
    
    var findCountParameters: [(Int32, Int32?)] = []
    var findCountReturns: Observable<Int> = .empty()
    func findCount(remoteId: Int32, serverId: Int32?) -> Observable<Int> {
        findCountParameters.append((remoteId, serverId))
        return findCountReturns
    }
    
    var storeMeasurementsParameters: [([SuplaCloudClient.GeneralPurposeMeter], DownloadGeneralPurposeMeterLogUseCaseImpl.Latest?, Int32?, Int32, SuplaChannelGeneralPurposeMeterConfig)] = []
    var storeMeasurementsReturns: DownloadGeneralPurposeMeterLogUseCaseImpl.Latest? = nil
    func storeMeasurements(
        measurements: [SuplaCloudClient.GeneralPurposeMeter],
        latestItem: DownloadGeneralPurposeMeterLogUseCaseImpl.Latest?,
        serverId: Int32,
        remoteId: Int32,
        channelConfig: SuplaChannelGeneralPurposeMeterConfig
    ) throws -> DownloadGeneralPurposeMeterLogUseCaseImpl.Latest? {
        storeMeasurementsParameters.append((measurements, latestItem, serverId, remoteId, channelConfig))
        return storeMeasurementsReturns
    }
    
    var findOldestEntityParameters: [(Int32, Int32)] = []
    var findOldestEntityReturns: Observable<SAGeneralPurposeMeterItem?> = .empty()
    func findOldestEntity(remoteId: Int32, serverId: Int32) -> Observable<SAGeneralPurposeMeterItem?> {
        findOldestEntityParameters.append((remoteId, serverId))
        return findOldestEntityReturns
    }
    
    var getInitialMeasurementsMock: FunctionMock<Int32, Observable<(response: HTTPURLResponse, data: Data)>> = .init()
    func getInitialMeasurements(remoteId: Int32) -> Observable<(response: HTTPURLResponse, data: Data)> {
        getInitialMeasurementsMock.handle(remoteId)
    }
    
    var getMeasurementsParameters: [(Int32, TimeInterval)] = []
    var getMeasurementsReturns: [Observable<[SuplaCloudClient.GeneralPurposeMeter]>] = []
    private var getMeasurementsCurrent = 0
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.GeneralPurposeMeter]> {
        getMeasurementsParameters.append((remoteId, afterTimestamp))
        let id = getMeasurementsCurrent
        getMeasurementsCurrent += 1
        if (id < getMeasurementsReturns.count) {
            return getMeasurementsReturns[id]
        } else {
            return .empty()
        }
    }
    
    func storeMeasurements(
        measurements: [SuplaCloudClient.GeneralPurposeMeter],
        timestamp: TimeInterval,
        serverId: Int32,
        remoteId: Int32
    ) throws -> TimeInterval {
        0
    }
    
    var fromJsonParameters: [Data] = []
    var fromJsonReturns: [SuplaCloudClient.GeneralPurposeMeter]? = nil
    func fromJson(data: Data) throws -> [SuplaCloudClient.GeneralPurposeMeter] {
        fromJsonParameters.append(data)
        if let fromJsonReturns = fromJsonReturns {
            return fromJsonReturns
        }
        return try SuplaCloudClient.GeneralPurposeMeter.fromJson(data: data)
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
    }
}
