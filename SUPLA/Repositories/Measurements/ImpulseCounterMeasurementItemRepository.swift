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

protocol ImpulseCounterMeasurementItemRepository: BaseMeasurementRepository<SuplaCloudClient.ImpulseCounterMeasurement, SAImpulseCounterMeasurementItem> where T == SAImpulseCounterMeasurementItem {
    func deleteAll(for serverId: Int32?) -> Observable<Void>
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SAImpulseCounterMeasurementItem]>
    func storeMeasurements(
        measurements: [SuplaCloudClient.ImpulseCounterMeasurement],
        latestItem: SuplaCloudClient.ImpulseCounterMeasurement?,
        serverId: Int32,
        remoteId: Int32
    ) throws -> SuplaCloudClient.ImpulseCounterMeasurement?
    func findOldestEntity(remoteId: Int32, serverId: Int32) -> Observable<SAImpulseCounterMeasurementItem?>
}

final class ImpulseCounterMeasurementItemRepositoryImpl: Repository<SAImpulseCounterMeasurementItem>, ImpulseCounterMeasurementItemRepository {
    
    @Singleton<SuplaCloudService> private var cloudService
    
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        guard let serverId else { return Observable.just(()) }
        
        return deleteAll(
            SAImpulseCounterMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "server_id = %d", serverId))
        )
    }
    
    func deleteAll(remoteId: Int32, serverId: Int32?) -> Observable<Void> {
        guard let serverId else { return Observable.just(()) }
        
        return deleteAll(
            SAImpulseCounterMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "server_id = %d AND channel_id = %d", serverId))
        )
    }
    
    func findMinTimestamp(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        guard let serverId else { return Observable.just(nil) }
        
        let request = SAImpulseCounterMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId))
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
        guard let serverId else { return Observable.just(nil) }
        
        let request = SAImpulseCounterMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId))
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
        guard let serverId else { return Observable.just(0) }
        
        return count(NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId))
    }
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.ImpulseCounterMeasurement]> {
        cloudService.getImpulseCounterMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp)
    }
    
    func getInitialMeasurements(remoteId: Int32) -> Observable<(response: HTTPURLResponse, data: Data)> {
        cloudService.getInitialMeasurements(remoteId: remoteId)
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.ImpulseCounterMeasurement], timestamp: TimeInterval, serverId: Int32, remoteId: Int32) throws -> TimeInterval {
        fatalError("Intentionally left not implemented")
    }
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.ImpulseCounterMeasurement] {
        try SuplaCloudClient.ImpulseCounterMeasurement.fromJson(data: data)
    }
    
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SAImpulseCounterMeasurementItem]> {
        guard let serverId else { return Observable.error(GeneralError.illegalArgument(message: "Server id must not be nil")) }
        
        return query(
            SAImpulseCounterMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(
                    format: "channel_id = %d AND server_id = %d AND date >= %@ AND date <= %@",
                    remoteId,
                    serverId,
                    startDate as NSDate,
                    endDate as NSDate
                ))
                .ordered(by: "date")
        )
    }
    
    func storeMeasurements(
        measurements: [SuplaCloudClient.ImpulseCounterMeasurement],
        latestItem: SuplaCloudClient.ImpulseCounterMeasurement?,
        serverId: Int32,
        remoteId: Int32
    ) throws -> SuplaCloudClient.ImpulseCounterMeasurement? {
        var oldestEntity = latestItem
        
        var saveError: Error? = nil
        context.performAndWait {
            for measurement in measurements {
                if let oldest = oldestEntity {
                    let entity = createEntityAndComplementMissing(measurement, oldest, remoteId, serverId)
                    if (oldest.date_timestamp.timeIntervalSince1970 < entity.date!.timeIntervalSince1970) {
                        oldestEntity = measurement
                    }
                } else {
                    oldestEntity = measurement
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
    
    func findOldestEntity(remoteId: Int32, serverId: Int32) -> Observable<SAImpulseCounterMeasurementItem?> {
        let request = SAImpulseCounterMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId))
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
    
    private func createEntityAndComplementMissing(
        _ measurement: SuplaCloudClient.ImpulseCounterMeasurement,
        _ oldest: SuplaCloudClient.ImpulseCounterMeasurement,
        _ remoteId: Int32,
        _ serverId: Int32
    ) -> SAImpulseCounterMeasurementItem {
        let measurementCounter = measurement.counter
        let oldestCounter = oldest.counter
        let measurementCalculatedValue = measurement.calculated_value
        let oldestCalculatedValue = oldest.calculated_value
        
        let counterDiff = measurementCounter - oldestCounter
        let calculatedValueDiff = measurementCalculatedValue - oldestCalculatedValue
        let timeDiff = measurement.date_timestamp.timeIntervalSince1970 - oldest.date_timestamp.timeIntervalSince1970
        
        let counterDiffDouble = Double(counterDiff)
        let reset = counterDiffDouble < 0 && abs(counterDiffDouble) > counterDiffDouble * 0.1
        
        let counterIncrement = (reset || counterDiff < 0) ? 0 : counterDiff
        let calculatedValueIncrement = (reset || calculatedValueDiff < 0) ? 0 : calculatedValueDiff
        
        let entity: SAImpulseCounterMeasurementItem = context.create()
        entity.server_id = serverId
        entity.channel_id = remoteId
        entity.setDateAndDateParts(measurement.date_timestamp)
        
        if (timeDiff > ChartDataAggregation.minutes.timeInSec * 2) {
            let missingItemsCount = Int(round(timeDiff / ChartDataAggregation.minutes.timeInSec))
            let counterDivided = counterIncrement / Int64(missingItemsCount)
            let calculatedValueDivided = calculatedValueIncrement / Double(missingItemsCount)
            
            generateMissingEntities(missingItemsCount, measurement, remoteId, serverId, reset, counterDivided, calculatedValueDivided)
            
            entity.counter = Int64(counterDivided)
            entity.calculated_value = calculatedValueDivided
        } else {
            entity.counter = Int64(counterIncrement)
            entity.calculated_value = calculatedValueIncrement
        }
        
        entity.calculated = false
        entity.counter_reset = reset
        
        return entity
    }
    
    private func generateMissingEntities(
        _ missingItemsCount: Int,
        _ measurement: SuplaCloudClient.ImpulseCounterMeasurement,
        _ remoteId: Int32,
        _ serverId: Int32,
        _ reset: Bool,
        _ counterDivided: Int64,
        _ calculatedValueDivided: Double
    ) {
        for itemNo in 1 ..< missingItemsCount {
            let itemTimestamp = measurement.date_timestamp.timeIntervalSince1970 - (ChartDataAggregation.minutes.timeInSec * Double(itemNo))
            let entity: SAImpulseCounterMeasurementItem = context.create()
            entity.server_id = serverId
            entity.channel_id = remoteId
            entity.setDateAndDateParts(Date(timeIntervalSince1970: itemTimestamp))
            
            entity.counter = counterDivided
            entity.calculated_value = calculatedValueDivided
            entity.calculated = true
            entity.counter_reset = itemNo == missingItemsCount - 1 ? reset : false
        }
    }
}
