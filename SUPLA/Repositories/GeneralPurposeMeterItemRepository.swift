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

protocol GeneralPurposeMeterItemRepository:
    BaseMeasurementRepository<SuplaCloudClient.GeneralPurposeMeter, SAGeneralPurposeMeterItem> where
    T == SAGeneralPurposeMeterItem
{
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
    func deleteAll(remoteId: Int32, profile: AuthProfileItem) -> Observable<Void>
    func findMeasurements(remoteId: Int32, profile: AuthProfileItem, startDate: Date, endDate: Date) -> Observable<[SAGeneralPurposeMeterItem]>
    func findMinTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
    func findMaxTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
    func findCount(remoteId: Int32, profile: AuthProfileItem) -> Observable<Int>
    func storeMeasurements(
        measurements: [SuplaCloudClient.GeneralPurposeMeter],
        latestItem: DownloadGeneralPurposeMeterLogUseCaseImpl.Latest?,
        profile: AuthProfileItem,
        remoteId: Int32,
        channelConfig: SuplaChannelGeneralPurposeMeterConfig
    ) throws -> DownloadGeneralPurposeMeterLogUseCaseImpl.Latest?
    func findOldestEntity(remoteId: Int32, profile: AuthProfileItem) -> Observable<SAGeneralPurposeMeterItem?>
}

final class GeneralPurposeMeterItemRepositoryImpl: Repository<SAGeneralPurposeMeterItem>, GeneralPurposeMeterItemRepository {
    
    @Singleton<SuplaCloudService> private var cloudService
    
    func deleteAll(remoteId: Int32, profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(
            SAGeneralPurposeMeterItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "profile = %@ AND channel_id = %d", profile, remoteId))
        )
    }

    func deleteAll(for profile: AuthProfileItem) -> RxSwift.Observable<Void> {
        deleteAll(
            SAGeneralPurposeMeterItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "profile = %@", profile))
        )
    }
    
    func findMeasurements(remoteId: Int32, profile: AuthProfileItem, startDate: Date, endDate: Date) -> Observable<[SAGeneralPurposeMeterItem]> {
        query(
            SAGeneralPurposeMeterItem
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
        let request = SAGeneralPurposeMeterItem.fetchRequest()
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
        let request = SAGeneralPurposeMeterItem.fetchRequest()
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
    
    func findOldestEntity(remoteId: Int32, profile: AuthProfileItem) -> Observable<SAGeneralPurposeMeterItem?> {
        let request = SAGeneralPurposeMeterItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND profile = %@", remoteId, profile))
            .ordered(by: "date", ascending: false)
        request.fetchLimit = 1
        
        return query(request).map { measurements in
            if (measurements.isEmpty) {
                return nil
            } else {
                return measurements[0]
            }
        }
    }
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.GeneralPurposeMeter]> {
        cloudService.getGeneralPurposeMeter(remoteId: remoteId, afterTimestamp: afterTimestamp)
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.GeneralPurposeMeter], timestamp: TimeInterval, profile: AuthProfileItem, remoteId: Int32) throws -> TimeInterval {
        fatalError("Intentionally left not implemented")
    }
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.GeneralPurposeMeter] {
        try SuplaCloudClient.GeneralPurposeMeter.fromJson(data: data)
    }
    
    func storeMeasurements(
        measurements: [SuplaCloudClient.GeneralPurposeMeter],
        latestItem: DownloadGeneralPurposeMeterLogUseCaseImpl.Latest?,
        profile: AuthProfileItem,
        remoteId: Int32,
        channelConfig: SuplaChannelGeneralPurposeMeterConfig
    ) throws -> DownloadGeneralPurposeMeterLogUseCaseImpl.Latest? {
        var oldestEntity = latestItem
        
        var saveError: Error? = nil
        context.performAndWait {
            for measurement in measurements {
                if (oldestEntity == nil) {
                    oldestEntity = DownloadGeneralPurposeMeterLogUseCaseImpl.Latest(
                        value: NSDecimalNumber(string: measurement.value),
                        date: measurement.date_timestamp
                    )
                } else {
                    let entity = createEntityAndComplementMissing(measurement, oldestEntity!, remoteId, profile, channelConfig)
                    if (oldestEntity == nil || oldestEntity!.date!.timeIntervalSince1970 < entity.date!.timeIntervalSince1970) {
                        oldestEntity = DownloadGeneralPurposeMeterLogUseCaseImpl.Latest(value: entity.value, date: entity.date)
                    }
                }
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
        
        return oldestEntity
    }
    
    private func createEntityAndComplementMissing(
        _ measurement: SuplaCloudClient.GeneralPurposeMeter,
        _ oldest: DownloadGeneralPurposeMeterLogUseCaseImpl.Latest,
        _ remoteId: Int32,
        _ profile: AuthProfileItem,
        _ channelConfig: SuplaChannelGeneralPurposeMeterConfig
    ) -> SAGeneralPurposeMeterItem {
        let measurementValue = NSDecimalNumber(string: measurement.value)
        let valueDiff = measurementValue.doubleValue - oldest.value!.doubleValue
        let reset = switch (channelConfig.counterType) {
        case .alwaysIncrement:
            valueDiff < 0 && abs(valueDiff) > oldest.value!.doubleValue * 0.1
        case .alwaysDecrement:
            valueDiff > 0 && valueDiff > oldest.value!.doubleValue * 0.1
        case .incrementAndDecrement:
            false
        }
        let timeDiff = measurement.date_timestamp.timeIntervalSince1970 - oldest.date!.timeIntervalSince1970
        let valueIncrement = switch (channelConfig.counterType) {
        case .alwaysIncrement: (reset || valueDiff < 0) ? 0 : valueDiff
        case .alwaysDecrement: (reset || valueDiff > 0) ? 0 : valueDiff
        case .incrementAndDecrement: valueDiff
        }
        
        let entity: SAGeneralPurposeMeterItem = context.create()
        entity.profile = profile
        entity.channel_id = remoteId
        entity.value = NSDecimalNumber(string: measurement.value)
        entity.setDateAndDateParts(measurement.date_timestamp)
        
        if (channelConfig.fillMissingData && timeDiff > ChartDataAggregation.minutes.timeInSec * 1.5) {
            let missingItemsCount = round(timeDiff / (ChartDataAggregation.minutes.timeInSec))
            let valueDivided = valueIncrement / missingItemsCount
            
            generateMissingEntities(Int(missingItemsCount), valueIncrement, valueDivided, measurement.date_timestamp, remoteId, profile, reset)
            
            entity.value_increment = NSDecimalNumber(value: valueDivided)
        } else {
            entity.value_increment = NSDecimalNumber(value: valueIncrement)
        }
        
        return entity
    }
    
    private func generateMissingEntities(
        _ missingItemsCount: Int,
        _ valueIncrement: Double,
        _ valueDivided: Double,
        _ entryDate: Date,
        _ remoteId: Int32,
        _ profile: AuthProfileItem,
        _ reset: Bool
    ) {
        for itemNo in 1 ..< missingItemsCount {
            let itemTimestamp = entryDate.timeIntervalSince1970 - (ChartDataAggregation.minutes.timeInSec * Double(itemNo))
            let entity: SAGeneralPurposeMeterItem = context.create()
            entity.profile = profile
            entity.channel_id = remoteId
            entity.value = NSDecimalNumber(value: valueIncrement - (valueDivided * Double(itemNo)))
            entity.value_increment = NSDecimalNumber(value: valueDivided)
            entity.setDateAndDateParts(Date(timeIntervalSince1970: itemTimestamp))
        }
    }
}
