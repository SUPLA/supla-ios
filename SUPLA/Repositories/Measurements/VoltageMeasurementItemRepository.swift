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

protocol VoltageMeasurementItemRepository:
    BaseMeasurementRepository<SuplaCloudClient.HistoryMeasurement, SAVoltageMeasurementItem>, RemoveHiddenChannelsUseCaseImpl.Deletable where
    T == SAVoltageMeasurementItem
{
    func deleteAll(for serverId: Int32?) -> Observable<Void>
    func findMeasurements(remoteId: Int32, serverId: Int32?, phase: Phase, startDate: Date, endDate: Date) -> Observable<[SAVoltageMeasurementItem]>
}

final class VoltageMeasurementItemRepositoryImpl: Repository<SAVoltageMeasurementItem>, VoltageMeasurementItemRepository {
    
    @Singleton<SuplaCloudService> private var cloudService
    
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        deleteAll(
            SAVoltageMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "server_id = %d", serverId ?? 0))
        )
    }
    
    func findMeasurements(remoteId: Int32, serverId: Int32?, phase: Phase, startDate: Date, endDate: Date) -> Observable<[SAVoltageMeasurementItem]> {
        query(
            SAVoltageMeasurementItem.fetchRequest()
                .filtered(by: NSPredicate(
                    format: "channel_id = %d AND server_id = %d AND phase = %d AND date >= %@ AND date <= %@",
                    remoteId,
                    serverId ?? 0,
                    phase.rawValue,
                    startDate as NSDate,
                    endDate as NSDate
                ))
                .ordered(by: "date")
        )
    }
    
    func deleteAll(remoteId: Int32, serverId: Int32?) -> Observable<Void> {
        deleteAll(
            SAVoltageMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId ?? 0))
        )
    }
    
    func findMinTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        let request = SAVoltageMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId ?? 0))
            .ordered(by: "date", ascending: true)
        request.fetchLimit = 1
        
        return query(request).map { measurements in
            if (measurements.isEmpty) {
                return nil
            } else {
                return measurements[0].date?.timeIntervalSince1970 ?? nil
            }
        }
    }
    
    func findMaxTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        let request = SAVoltageMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId ?? 0))
            .ordered(by: "date", ascending: false)
        request.fetchLimit = 1
        
        return query(request).map { measurements in
            if (measurements.isEmpty) {
                return nil
            } else {
                return measurements[0].date?.timeIntervalSince1970 ?? nil
            }
        }
    }
    
    func findCount(remoteId: Int32, serverId: Int32?) -> Observable<Int> {
        count(NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId ?? 0))
    }
    
    func getInitialMeasurements(remoteId: Int32) -> Observable<(response: HTTPURLResponse, data: Data)> {
        cloudService.getInitialMeasurements(remoteId: remoteId, type: .voltage)
    }
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.HistoryMeasurement]> {
        cloudService.getHistoryMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp, type: .voltage)
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.HistoryMeasurement], timestamp: TimeInterval, serverId: Int32, remoteId: Int32) throws -> TimeInterval {
        var timestampToReturn = timestamp
        
        var saveError: Error? = nil
        context.performAndWait {
            for measurement in measurements {
                if (timestampToReturn.isLess(than: measurement.date_timestamp.timeIntervalSince1970)) {
                    timestampToReturn = measurement.date_timestamp.timeIntervalSince1970
                }
                
                let entity: SAVoltageMeasurementItem = context.create()
                entity.server_id = serverId
                entity.channel_id = remoteId
                entity.phase = Int32(measurement.phaseNo)
                entity.avg = measurement.avg
                entity.min = measurement.min
                entity.max = measurement.max
                entity.setDateAndDateParts(measurement.date_timestamp)
            }
            
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError {
            throw error
        }
        
        return timestampToReturn
    }
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.HistoryMeasurement] {
        try SuplaCloudClient.HistoryMeasurement.fromJson(data: data)
    }

    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
        let context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext
        context.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SAVoltageMeasurementItem")
            fetch.predicate = NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, profile.server?.id ?? 0)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            if (try? context.execute(request)) != nil {
                try? context.save()
            }
        }
    }
}
