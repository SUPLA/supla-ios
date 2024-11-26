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

import Foundation
import RxSwift

protocol ElectricityMeasurementItemRepository: BaseMeasurementRepository<SuplaCloudClient.ElectricityMeasurement, SAElectricityMeasurementItem> where T == SAElectricityMeasurementItem {
    func deleteAll(for serverId: Int32?) -> Observable<Void>
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SAElectricityMeasurementItem]>
    func storeMeasurements(
        measurements: [SuplaCloudClient.ElectricityMeasurement],
        latestItem: DownloadElectricityMeterLogUseCaseImpl.Latest?,
        serverId: Int32,
        remoteId: Int32
    ) throws -> DownloadElectricityMeterLogUseCaseImpl.Latest?
    func findOldestEntity(remoteId: Int32, serverId: Int32?) -> Observable<SAElectricityMeasurementItem?>
}

final class ElectricityMeasurementItemRepositoryImpl: Repository<SAElectricityMeasurementItem>, ElectricityMeasurementItemRepository {
    @Singleton<SuplaCloudService> private var cloudService
    
    func deleteAll(for serverId: Int32?) -> Observable<Void> {
        deleteAll(SAElectricityMeasurementItem.fetchRequest().filtered(by: NSPredicate(format: "server_id = %d", serverId ?? 0)))
    }
    
    func deleteAll(remoteId: Int32, serverId: Int32?) -> Observable<Void> {
        deleteAll(
            SAElectricityMeasurementItem
                .fetchRequest()
                .filtered(by: NSPredicate(format: "server_id = %d AND channel_id = %d", serverId ?? 0, remoteId))
        )
    }
    
    func findMeasurements(remoteId: Int32, serverId: Int32?, startDate: Date, endDate: Date) -> Observable<[SAElectricityMeasurementItem]> {
        return query(
            SAElectricityMeasurementItem
                .fetchRequest()
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
        let request = SAElectricityMeasurementItem.fetchRequest()
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
        let request = SAElectricityMeasurementItem.fetchRequest()
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
    
    func findOldestEntity(remoteId: Int32, serverId: Int32?) -> Observable<SAElectricityMeasurementItem?> {
        let request = SAElectricityMeasurementItem.fetchRequest()
            .filtered(by: NSPredicate(format: "channel_id = %d AND server_id = %d", remoteId, serverId ?? 0))
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
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.ElectricityMeasurement]> {
        cloudService.getElectricityMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp)
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.ElectricityMeasurement], timestamp: TimeInterval, serverId: Int32, remoteId: Int32) throws -> TimeInterval {
        fatalError("Intentionally left not implemented")
    }
    
    func storeMeasurements(
        measurements: [SuplaCloudClient.ElectricityMeasurement],
        latestItem: DownloadElectricityMeterLogUseCaseImpl.Latest?,
        serverId: Int32,
        remoteId: Int32
    ) throws -> DownloadElectricityMeterLogUseCaseImpl.Latest? {
        var oldestEntity = latestItem
        
        var saveError: Error? = nil
        context.performAndWait {
            for measurement in measurements {
                if let oldest = oldestEntity {
                    let entity = createEntityAndComplementMissing(measurement, oldest, remoteId, serverId)
                    if (oldest.date.timeIntervalSince1970 < entity.date!.timeIntervalSince1970) {
                        oldestEntity = measurement.toLatest()
                    }
                } else {
                    oldestEntity = measurement.toLatest()
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
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.ElectricityMeasurement] {
        try SuplaCloudClient.ElectricityMeasurement.fromJson(data: data)
    }
    
    private func createEntityAndComplementMissing(
        _ measurement: SuplaCloudClient.ElectricityMeasurement,
        _ oldest: DownloadElectricityMeterLogUseCaseImpl.Latest,
        _ remoteId: Int32,
        _ serverId: Int32
    ) -> SAElectricityMeasurementItem {
        var valueDiff = measurement.diff(oldest)
        let timeDiff = measurement.date_timestamp.timeIntervalSince1970 - oldest.date.timeIntervalSince1970
        
        let entity: SAElectricityMeasurementItem = context.create()
        entity.server_id = serverId
        entity.channel_id = remoteId
        entity.setDateAndDateParts(measurement.date_timestamp)
        
        if (timeDiff > ChartDataAggregation.minutes.timeInSec * 2) {
            let missingItemsCount = Int(round(timeDiff / ChartDataAggregation.minutes.timeInSec))
            let valueDivided = valueDiff.div(missingItemsCount)
            
            generateMissingEntities(missingItemsCount, measurement, remoteId, serverId, valueDivided, valueDiff)
            
            valueDiff = valueDivided
        }
        
        entity.phase1_fae = valueDiff.phase1.fae ?? measurement.phase1_fae.toKWh()
        entity.phase1_rae = valueDiff.phase1.rae ?? measurement.phase1_rae.toKWh()
        entity.phase1_fre = valueDiff.phase1.fre ?? measurement.phase1_fre.toKWh()
        entity.phase1_rre = valueDiff.phase1.rre ?? measurement.phase1_rre.toKWh()
        entity.phase2_fae = valueDiff.phase2.fae ?? measurement.phase2_fae.toKWh()
        entity.phase2_rae = valueDiff.phase2.rae ?? measurement.phase2_rae.toKWh()
        entity.phase2_fre = valueDiff.phase2.fre ?? measurement.phase2_fre.toKWh()
        entity.phase2_rre = valueDiff.phase2.rre ?? measurement.phase2_rre.toKWh()
        entity.phase3_fae = valueDiff.phase3.fae ?? measurement.phase3_fae.toKWh()
        entity.phase3_rae = valueDiff.phase3.rae ?? measurement.phase3_rae.toKWh()
        entity.phase3_fre = valueDiff.phase3.fre ?? measurement.phase3_fre.toKWh()
        entity.phase3_rre = valueDiff.phase3.rre ?? measurement.phase3_rre.toKWh()
        entity.fae_balanced = valueDiff.faeBalanced ?? measurement.fae_balanced.toKWh()
        entity.rae_balanced = valueDiff.raeBalanced ?? measurement.rae_balanced.toKWh()
        entity.calculated = false
        entity.counter_reset = valueDiff.resetRecognized()
        
        return entity
    }
    
    private func generateMissingEntities(
        _ missingItemsCount: Int,
        _ measurement: SuplaCloudClient.ElectricityMeasurement,
        _ remoteId: Int32,
        _ serverId: Int32,
        _ valueDivided: ElectricityMeterDiff,
        _ valueDiff: ElectricityMeterDiff
    ) {
        for itemNo in 1 ..< missingItemsCount {
            let itemTimestamp = measurement.date_timestamp.timeIntervalSince1970 - (ChartDataAggregation.minutes.timeInSec * Double(itemNo))
            let entity: SAElectricityMeasurementItem = context.create()
            entity.server_id = serverId
            entity.channel_id = remoteId
            entity.setDateAndDateParts(Date(timeIntervalSince1970: itemTimestamp))
            
            entity.phase1_fae = valueDivided.phase1.fae ?? measurement.phase1_fae.toKWh()
            entity.phase1_rae = valueDivided.phase1.rae ?? measurement.phase1_rae.toKWh()
            entity.phase1_fre = valueDivided.phase1.fre ?? measurement.phase1_fre.toKWh()
            entity.phase1_rre = valueDivided.phase1.rre ?? measurement.phase1_rre.toKWh()
            entity.phase2_fae = valueDivided.phase2.fae ?? measurement.phase2_fae.toKWh()
            entity.phase2_rae = valueDivided.phase2.rae ?? measurement.phase2_rae.toKWh()
            entity.phase2_fre = valueDivided.phase2.fre ?? measurement.phase2_fre.toKWh()
            entity.phase2_rre = valueDivided.phase2.rre ?? measurement.phase2_rre.toKWh()
            entity.phase3_fae = valueDivided.phase3.fae ?? measurement.phase3_fae.toKWh()
            entity.phase3_rae = valueDivided.phase3.rae ?? measurement.phase3_rae.toKWh()
            entity.phase3_fre = valueDivided.phase3.fre ?? measurement.phase3_fre.toKWh()
            entity.phase3_rre = valueDivided.phase3.rre ?? measurement.phase3_rre.toKWh()
            entity.fae_balanced = valueDivided.faeBalanced ?? measurement.fae_balanced.toKWh()
            entity.rae_balanced = valueDivided.raeBalanced ?? measurement.rae_balanced.toKWh()
            entity.calculated = true
            entity.counter_reset = itemNo == missingItemsCount - 1 ? valueDiff.resetRecognized() : false
        }
    }
}

extension SuplaCloudClient.ElectricityMeasurement {
    func toLatest() -> DownloadElectricityMeterLogUseCaseImpl.Latest {
        DownloadElectricityMeterLogUseCaseImpl.Latest(
            date: date_timestamp,
            phase1_fae: phase1_fae.toKWh(),
            phase1_rae: phase1_rae.toKWh(),
            phase1_fre: phase1_fre.toKWh(),
            phase1_rre: phase1_rre.toKWh(),
            phase2_fae: phase2_fae.toKWh(),
            phase2_rae: phase2_rae.toKWh(),
            phase2_fre: phase2_fre.toKWh(),
            phase2_rre: phase2_rre.toKWh(),
            phase3_fae: phase3_fae.toKWh(),
            phase3_rae: phase3_rae.toKWh(),
            phase3_fre: phase3_fre.toKWh(),
            phase3_rre: phase3_rre.toKWh(),
            faeBalanced: fae_balanced.toKWh(),
            raeBalanced: rae_balanced.toKWh()
        )
    }
}

private extension SuplaCloudClient.ElectricityMeasurement {
    func diff(_ latest: DownloadElectricityMeterLogUseCaseImpl.Latest) -> ElectricityMeterDiff {
        var diff = ElectricityMeterDiff(
            phase1: PhaseValues(reset: false),
            phase2: PhaseValues(reset: false),
            phase3: PhaseValues(reset: false),
            reset: false
        )
        diff.phase1.set(type: .fae, current: phase1_fae.toKWh(), previous: latest.phase1_fae)
        diff.phase1.set(type: .rae, current: phase1_rae.toKWh(), previous: latest.phase1_rae)
        diff.phase1.set(type: .fre, current: phase1_fre.toKWh(), previous: latest.phase1_fre)
        diff.phase1.set(type: .rre, current: phase1_rre.toKWh(), previous: latest.phase1_rre)
        diff.phase2.set(type: .fae, current: phase2_fae.toKWh(), previous: latest.phase2_fae)
        diff.phase2.set(type: .rae, current: phase2_rae.toKWh(), previous: latest.phase2_rae)
        diff.phase2.set(type: .fre, current: phase2_fre.toKWh(), previous: latest.phase2_fre)
        diff.phase2.set(type: .rre, current: phase2_rre.toKWh(), previous: latest.phase2_rre)
        diff.phase3.set(type: .fae, current: phase3_fae.toKWh(), previous: latest.phase3_fae)
        diff.phase3.set(type: .rae, current: phase3_rae.toKWh(), previous: latest.phase3_rae)
        diff.phase3.set(type: .fre, current: phase3_fre.toKWh(), previous: latest.phase3_fre)
        diff.phase3.set(type: .rre, current: phase3_rre.toKWh(), previous: latest.phase3_rre)
        diff.set(type: .faeBalanced, current: fae_balanced.toKWh(), previous: latest.faeBalanced)
        diff.set(type: .raeBalanced, current: rae_balanced.toKWh(), previous: latest.raeBalanced)
        
        return diff
    }
}

private struct ElectricityMeterDiff: SetWithResetDetection {
    var phase1: PhaseValues
    var phase2: PhaseValues
    var phase3: PhaseValues
    var faeBalanced: Double?
    var raeBalanced: Double?
    var reset: Bool
    
    mutating func setReset() {
        reset = true
    }
    
    mutating func set(type: EnergyType, value: Double?) {
        switch (type) {
        case .faeBalanced: faeBalanced = value
        case .raeBalanced: raeBalanced = value
        default: fatalError("Type `\(type)` is not applicable here!")
        }
    }
    
    func resetRecognized() -> Bool {
        phase1.reset || phase2.reset || phase3.reset || reset
    }
    
    func div(_ divider: Int) -> ElectricityMeterDiff {
        ElectricityMeterDiff(
            phase1: phase1.div(Double(divider)),
            phase2: phase2.div(Double(divider)),
            phase3: phase3.div(Double(divider)),
            faeBalanced: faeBalanced?.also { $0 / Double(divider) },
            raeBalanced: raeBalanced?.also { $0 / Double(divider) },
            reset: reset
        )
    }
}

private struct PhaseValues: SetWithResetDetection {
    var reset: Bool
    var fae: Double?
    var rae: Double?
    var fre: Double?
    var rre: Double?
    
    mutating func set(type: EnergyType, value: Double?) {
        switch (type) {
        case .fae: fae = value
        case .rae: rae = value
        case .fre: fre = value
        case .rre: rre = value
        default: fatalError("Type `\(type)` is not applicable here!")
        }
    }
    
    mutating func setReset() {
        reset = true
    }
    
    func div(_ divider: Double) -> PhaseValues {
        return PhaseValues(
            reset: reset,
            fae: fae.also { $0 / divider },
            rae: rae.also { $0 / divider },
            fre: fre.also { $0 / divider },
            rre: rre.also { $0 / divider }
        )
    }
    
    func valueFor(_ chartType: ElectricityMeterChartType) -> Double? {
        switch (chartType) {
        case .forwardActiveEnergy: fae
        case .reverseActiveEnergy: rae
        case .forwardReactiveEnergy: fre
        case .reverseReactiveEnergy: rre
        default: nil
        }
    }
    
    func valueFor(_ spec: ChartDataSpec) -> Double? {
        if let electricityFilters = spec.customFilters as? ElectricityChartFilters {
            valueFor(electricityFilters.type)
        } else {
            valueFor(.forwardActiveEnergy)
        }
    }
    
    static func + (left: PhaseValues, right: PhaseValues) -> PhaseValues {
        PhaseValues(
            reset: left.reset || right.reset,
            fae: left.fae.also { $0 + (right.fae ?? 0) } ?? right.fae,
            rae: left.rae.also { $0 + (right.rae ?? 0) } ?? right.rae,
            fre: left.fre.also { $0 + (right.fre ?? 0) } ?? right.fre,
            rre: left.rre.also { $0 + (right.rre ?? 0) } ?? right.rre
        )
    }
}

private protocol SetWithResetDetection {
    var reset: Bool { get }
    mutating func setReset()
    mutating func set(type: EnergyType, value: Double?)
}

private extension SetWithResetDetection {
    mutating func set(type: EnergyType, current: Double?, previous: Double?) {
        guard let current = current,
              let previous = previous
        else {
            if (current != nil) {
                set(type: type, value: current)
            }
            return
        }
        
        let diff = current - previous
        if (diff < 0 && abs(diff) > previous * 0.1) {
            set(type: type, value: 0)
            setReset()
        } else {
            set(type: type, value: max(0, diff))
        }
    }
}

private enum EnergyType {
    case fae, rae, fre, rre, faeBalanced, raeBalanced
}

private extension String? {
    func toKWh() -> Double {
        if let self = self,
           let value = Double(self)
        {
            return value / 100_000.0
        }
        return 0.0
    }
}
