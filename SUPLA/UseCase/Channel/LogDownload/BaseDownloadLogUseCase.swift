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

fileprivate let ALLOWED_TIME_DIFFERENCE: Double = 1800

class BaseDownloadLogUseCase<M: SuplaCloudClient.Measurement, E: SAMeasurementItem> {
    
    @Singleton<ProfileRepository> var profileRepository
    
    let baseMeasurementRepository: any BaseMeasurementRepository<M, E>
    var cleanupHistoryWHenOldestDiffers: Bool { true }
    
    init(_ repository: any BaseMeasurementRepository<M, E>) {
        self.baseMeasurementRepository = repository
    }
    
    func invoke(remoteId: Int32) -> Observable<Float> {
        return Observable.create { observer in
            let disposable = BooleanDisposable()
            guard let serverId = self.loadCurrentProfile()?.server?.id else {
                observer.onError(GeneralError.illegalState(message: "Could not load active profile's server ID"))
                return disposable
            }
            guard let (measurements, totalCount) = self.loadInitialMeasurements(remoteId) else {
                observer.onError(GeneralError.illegalState(message: "Could not load initial measurements"))
                return disposable
            }
            
            SALog.info("Found initial remote entries (count: \(measurements.count), total count: \(totalCount))")
            
            guard let cleanMeasurements = self.checkCleanNeeded(measurements, remoteId, serverId) else {
                observer.onError(GeneralError.illegalState(message: "Could not verify if clean needed"))
                return disposable
            }
            
            do {
                try self.performImport(totalCount, cleanMeasurements, remoteId, serverId, observer, disposable)
                observer.on(.completed)
            } catch {
                observer.on(.error(error))
            }
            return disposable
        }
    }
    
    private func loadCurrentProfile() -> AuthProfileItem? {
        do {
            return try profileRepository.getActiveProfile().subscribeSynchronous()
        } catch {
            return nil
        }
    }
    
    private func loadInitialMeasurements(
        _ remoteId: Int32
    ) -> (measurements: [M], totalCount: Int)? {
        do {
            let firstMeasurements = try baseMeasurementRepository
                .getInitialMeasurements(remoteId: remoteId)
                .subscribeSynchronous()
            guard let code = firstMeasurements?.response.statusCode else { return nil }
            if (code != 200) {
                SALog.error("Initial measurements load failed: \(code)")
                return nil
            }
            
            guard
                let countAny = getTotalCount(firstMeasurements),
                let countString = countAny as? String,
                let count = Int(countString),
                let data = firstMeasurements?.data
            else { return nil }
            
            return (measurements: try baseMeasurementRepository.fromJson(data: data), totalCount: count)
        } catch {
            SALog.error("Initial measurements load failed: \(error.localizedDescription)")
            SALog.error(String(describing: error))
            return nil
        }
    }
    
    private func checkCleanNeeded(
        _ measurements: [M],
        _ remoteId: Int32,
        _ serverId: Int32
    ) -> Bool? {
        do {
            if (measurements.isEmpty) {
                SALog.info("No entries to get - cleaning measurements")
                return true
            }
            
            let timestamp = try baseMeasurementRepository
                .findMinTimestamp(remoteId: remoteId, serverId: serverId)
                .subscribeSynchronous()
            
            guard let firstUnwrap = timestamp,
                  let minTimestamp = firstUnwrap
            else {
                SALog.info("No entries in DB - no cleaning needed")
                return false
            }
            
            SALog.debug("Found local minimal timestamp \(minTimestamp)")
            if (cleanupHistoryWHenOldestDiffers) {
                for measurement in measurements {
                    let difference = abs(minTimestamp - measurement.date_timestamp.timeIntervalSince1970)
                    if (difference.isLess(than: ALLOWED_TIME_DIFFERENCE)) {
                        SALog.debug("Entries similar - no cleaning needed")
                        return false
                    }
                }
            } else {
                SALog.debug("Oldest check skipped - no cleanup needed")
                return false
            }
            
            return true
        } catch {
            SALog.error("Could not verify if clean needed: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func performImport(
        _ totalCount: Int,
        _ cleanMeasurements: Bool,
        _ remoteId: Int32,
        _ serverId: Int32,
        _ observer: AnyObserver<Float>,
        _ disposable: BooleanDisposable
    ) throws {
        SALog.debug("Check for cleaning (cleanMeasurements: `\(cleanMeasurements))`")
        if (cleanMeasurements) {
            try baseMeasurementRepository.deleteAll(remoteId: remoteId, serverId: serverId).subscribeSynchronous()
        }
        
        let databaseCount = baseMeasurementRepository.findCount(
            remoteId: remoteId,
            serverId: serverId
        ).subscribeSynchronous(defaultValue: 0)
        if (databaseCount == totalCount && !cleanMeasurements) {
            SALog.info("Database and cloud has same size of measurements. Import skipped")
            return
        }
        
        SALog.info("Measurements import started (db count: \(databaseCount), remote count: \(totalCount))")
        try iterateAndImport(totalCount, databaseCount, cleanMeasurements, remoteId, serverId, observer, disposable)
    }
    
    func iterateAndImport(
        _ totalCount: Int,
        _ databaseCount: Int,
        _ cleanMeasurements: Bool,
        _ remoteId: Int32,
        _ serverId: Int32,
        _ observer: AnyObserver<Float>,
        _ disposable: BooleanDisposable
    ) throws {
        let entriesToImport = totalCount - databaseCount
        var importedEntries = 0
        var afterTimestamp = baseMeasurementRepository
            .findMaxTimestamp(remoteId: remoteId, serverId: serverId)
            .subscribeSynchronous(defaultValue: 0) ?? 0
        
        while (!disposable.isDisposed) {
            let measurements = try baseMeasurementRepository.getMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp).toBlocking().single()
            if (measurements.isEmpty) {
                SALog.debug("Measurements end reached")
                return
            }
            
            SALog.info("Measurements fetched \(measurements.count)")
            afterTimestamp = try baseMeasurementRepository.storeMeasurements(
                measurements: measurements,
                timestamp: afterTimestamp,
                serverId: serverId,
                remoteId: remoteId
            )
            
            importedEntries += measurements.count
            observer.on(.next(Float(importedEntries) / Float(entriesToImport)))
        }
    }
    
    private func getTotalCount(_ responseData: (response: HTTPURLResponse, data: Data)?) -> Any? {
        if let count = responseData?.response.allHeaderFields["X-Total-Count"] {
            return count
        }
        if let count = responseData?.response.allHeaderFields["x-total-count"] {
            return count
        }
        
        return nil
    }
}
