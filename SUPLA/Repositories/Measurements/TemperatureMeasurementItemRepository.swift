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

protocol TemperatureMeasurementItemRepository:
    BaseMeasurementRepository<SuplaCloudClient.TemperatureMeasurement, SATemperatureMeasurementItem> where
    T == SATemperatureMeasurementItem
{
    
    func deleteAll(for serverId: Int32?) -> Observable<Void>
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SATemperatureMeasurementItem]>
}

final class TemperatureMeasurementItemRepositoryImpl: Repository<SATemperatureMeasurementItem>, TemperatureMeasurementItemRepository {
    
    @Singleton<SuplaCloudService> private var cloudService
    
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        deleteAll(
            SATemperatureMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "server_id = %d", serverId ?? 0))
        )
    }
    
    func deleteAll(remoteId: Int32, serverId: Int32?) -> Observable<Void> {
        deleteAll(
            SATemperatureMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId ?? 0))
        )
    }
    
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SATemperatureMeasurementItem]> {
        query(
            SATemperatureMeasurementItem.fetchRequest()
                .filtered(by: NSPredicate(
                    format: "channel_id = %d AND server_id = %d AND date >= %@ AND date <= %@",
                    remoteId,
                    serverId ?? 0,
                    startDate as NSDate,
                    endDate as NSDate
                ))
                .ordered(by: "date")
        )
    }
    
    func findMinTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        let request = SATemperatureMeasurementItem.fetchRequest()
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
        let request = SATemperatureMeasurementItem.fetchRequest()
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
    
    func storeMeasurements(
        measurements: [SuplaCloudClient.TemperatureMeasurement],
        timestamp: TimeInterval,
        serverId: Int32,
        remoteId: Int32
    ) throws -> TimeInterval {
        var timestampToReturn = timestamp
        
        var saveError: Error? = nil
        context.performAndWait {
            for measurement in measurements {
                if (timestampToReturn.isLess(than: measurement.date_timestamp.timeIntervalSince1970)) {
                    timestampToReturn = measurement.date_timestamp.timeIntervalSince1970
                }
                
                let entity: SATemperatureMeasurementItem = context.create()
                entity.server_id = serverId
                entity.channel_id = remoteId
                entity.temperature = NSDecimalNumber(value: measurement.temperature)
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
    
    func getInitialMeasurements(remoteId: Int32) -> Observable<(response: HTTPURLResponse, data: Data)> {
        cloudService.getInitialMeasurements(remoteId: remoteId)
    }
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.TemperatureMeasurement]> {
        cloudService.getTemperatureMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp)
    }
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.TemperatureMeasurement] {
        try SuplaCloudClient.TemperatureMeasurement.fromJson(data: data)
    }
}
