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

protocol DownloadImpulseCounterLogUseCase {
    func invoke(remoteId: Int32) -> Observable<Float>
}

final class DownloadImpulseCounterLogUseCaseImpl:
    BaseDownloadLogUseCase<SuplaCloudClient.ImpulseCounterMeasurement, SAImpulseCounterMeasurementItem>,
    DownloadImpulseCounterLogUseCase {
    
    @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
    
    override func iterateAndImport(
        _ totalCount: Int,
        _ databaseCount: Int,
        _ cleanMeasurements: Bool,
        _ remoteId: Int32,
        _ serverId: Int32,
        _ observer: AnyObserver<Float>,
        _ disposable: BooleanDisposable
    ) throws {
        let entriesToImport = totalCount - databaseCount
        let lastEntity = impulseCounterMeasurementItemRepository
            .findOldestEntity(remoteId: remoteId, serverId: serverId)
            .subscribeSynchronous(defaultValue: nil)
        
        var importedEntries = 0
        var afterTimestamp = lastEntity?.date?.timeIntervalSince1970 ?? 0
        var lastEntry = try getLastMeasurement(remoteId, afterTimestamp: afterTimestamp)
        
        
        while (!disposable.isDisposed) {
            let measurements = try impulseCounterMeasurementItemRepository
                .getMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp)
                .toBlocking()
                .single()
            if (measurements.isEmpty) {
                SALog.debug("Measurements end reached")
                return
            }
            
            SALog.info("Measurements fetched \(measurements.count)")
            lastEntry = try impulseCounterMeasurementItemRepository.storeMeasurements(
                measurements: measurements,
                latestItem: lastEntry,
                serverId: serverId,
                remoteId: remoteId
            )
            afterTimestamp = lastEntry?.date_timestamp.timeIntervalSince1970 ?? 0
            
            importedEntries += measurements.count
            observer.onNext(Float(importedEntries) / Float(entriesToImport))
        }
    }
    
    private func getLastMeasurement(_ remoteId: Int32, afterTimestamp: Double) throws -> SuplaCloudClient.ImpulseCounterMeasurement? {
        if (afterTimestamp == 0.0) {
            // Skip call when we know that we start from the beginning.
            return nil
        }
        let lastMeasurements = try cloudService.getLastImpulseCounterMeasurements(remoteId: remoteId, beforeTimestamp: afterTimestamp + 1)
            .toBlocking()
            .single()
        
        
        return lastMeasurements.isEmpty ? nil : lastMeasurements[0]
    }
}
