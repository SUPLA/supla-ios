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

protocol GeneralPurposeMeasurementItemRepository: BaseMeasurementRepository where
    M == SuplaCloudClient.GeneralPurposeMeasurement,
    E == SAGeneralPurposeMeasurementItem,
    T == SAGeneralPurposeMeasurementItem
{
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
    func findMeasurements(remoteId: Int32, profile: AuthProfileItem, startDate: Date, endDate: Date) -> Observable<[SAGeneralPurposeMeasurementItem]>
    func findMinTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
    func findMaxTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
    func findCount(remoteId: Int32, profile: AuthProfileItem) -> Observable<Int>
    func storeMeasurements(
        measurements: [SuplaCloudClient.GeneralPurposeMeasurement],
        timestamp: TimeInterval,
        profile: AuthProfileItem,
        remoteId: Int32
    ) throws -> TimeInterval
}

final class GeneralPurposeMeasurementItemRepositoryImpl: Repository<SAGeneralPurposeMeasurementItem>, GeneralPurposeMeasurementItemRepository {
    
    @Singleton<SuplaCloudService> var cloudService
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(
            SAGeneralPurposeMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "profile = %@", profile))
        )
    }
    
    func findMeasurements(remoteId: Int32, profile: AuthProfileItem, startDate: Date, endDate: Date) -> Observable<[SAGeneralPurposeMeasurementItem]> {
        return query(
            SAGeneralPurposeMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(
                    format: "channel_id = %d AND profile = %@ AND date >= %@ AND date <= %@",
                    remoteId,
                    profile,
                    startDate as NSDate,
                    endDate as NSDate
                ))
                .ordered(by: "date")
        )
    }
    
    func findMinTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        let request = SAGeneralPurposeMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND profile = %@", remoteId, profile))
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
    
    func findMaxTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        let request = SAGeneralPurposeMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND profile = %@", remoteId, profile))
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
    
    func findCount(remoteId: Int32, profile: AuthProfileItem) -> Observable<Int> {
        count(NSPredicate(format: "channel_id = %d AND profile = %@", remoteId, profile))
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.GeneralPurposeMeasurement], timestamp: TimeInterval, profile: AuthProfileItem, remoteId: Int32) throws -> TimeInterval {
        var timestampToReturn = timestamp
        
        var saveError: Error? = nil
        context.performAndWait {
            for measurement in measurements {
                if (timestampToReturn.isLess(than: measurement.date_timestamp.timeIntervalSince1970)) {
                    timestampToReturn = measurement.date_timestamp.timeIntervalSince1970
                }
                
                let entity: SAGeneralPurposeMeasurementItem = context.create()
                entity.profile = profile
                entity.channel_id = remoteId
                entity.value_average = NSDecimalNumber(string: measurement.avg_value)
                entity.value_min = NSDecimalNumber(string: measurement.min_value)
                entity.value_max = NSDecimalNumber(string: measurement.max_value)
                entity.value_open = NSDecimalNumber(string: measurement.open_value)
                entity.value_close = NSDecimalNumber(string: measurement.close_value)
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
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.GeneralPurposeMeasurement]> {
        cloudService.getGeneralPurposeMeasurement(remoteId: remoteId, afterTimestamp: afterTimestamp)
    }
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.GeneralPurposeMeasurement] {
        try SuplaCloudClient.GeneralPurposeMeasurement.fromJson(data: data)
    }
}
