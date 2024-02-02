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

class BaseDownloadLogUseCase<M: SuplaCloudMeasurement, E: SAMeasurementItem> {
    
    @Singleton<SuplaCloudService> var cloudService
    @Singleton<ProfileRepository> var profileRepository
    
    let baseMeasurementRepository: any BaseMeasurementRepository<M, E>
    
    init(_ repository: any BaseMeasurementRepository<M, E>) {
        self.baseMeasurementRepository = repository
    }
    
    func invoke(remoteId: Int32) -> Observable<Float> {
        return Observable.create { observer in
            let disposable = BooleanDisposable()
            guard let profile = self.loadCurrentProfile() else {
                observer.onError(GeneralError.illegalState(message: "Could not load active profile"))
                return disposable
            }
            guard let (measurements, totalCount) = self.loadInitialMeasurements(remoteId) else {
                observer.onError(GeneralError.illegalState(message: "Could not load initial measurements"))
                return disposable
            }
            
            NSLog("Found initial remote entries (count: \(measurements.count), total count: \(totalCount))")
            
            guard let cleanMeasurements = self.checkCleanNeeded(measurements, remoteId, profile) else {
                observer.onError(GeneralError.illegalState(message: "Could not verify if clean needed"))
                return disposable
            }
            
            do {
                try self.performImport(totalCount, cleanMeasurements, remoteId, profile, observer, disposable)
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
            let firstMeasurements = try cloudService
                .getInitialMeasurements(remoteId: remoteId)
                .subscribeSynchronous()
            guard let code = firstMeasurements?.response.statusCode else { return nil }
            if (code != 200) {
                NSLog("Initial measurements load failed: \(code)")
                return nil
            }
            
            guard
                let countAny = firstMeasurements?.response.allHeaderFields["X-Total-Count"],
                let countString = countAny as? String,
                let count = Int(countString),
                let data = firstMeasurements?.data
            else { return nil }
            
            return (measurements: try baseMeasurementRepository.fromJson(data: data), totalCount: count)
        } catch {
            NSLog(String(describing: error))
            NSLog("Initial measurements load failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func checkCleanNeeded(
        _ measurements: [M],
        _ remoteId: Int32,
        _ profile: AuthProfileItem
    ) -> Bool? {
        do {
            if (measurements.isEmpty) {
                NSLog("No entries to get - cleaning measurements")
                return true
            }
            
            let timestamp = try baseMeasurementRepository
                .findMinTimestamp(remoteId: remoteId, profile: profile)
                .subscribeSynchronous()
            
            guard let firstUnwrap = timestamp,
                  let minTimestamp = firstUnwrap
            else {
                NSLog("No entries in DB - no cleaning needed")
                return false
            }
            
            NSLog("Found local minimal timestamp \(minTimestamp)")
            for measurement in measurements {
                let difference = abs(minTimestamp - measurement.date_timestamp.timeIntervalSince1970)
                if (difference.isLess(than: ALLOWED_TIME_DIFFERENCE)) {
                    NSLog("Entries similar - no cleaning needed")
                    return false
                }
            }
            
            return true
        } catch {
            NSLog("Could not verify if clean needed: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func performImport(
        _ totalCount: Int,
        _ cleanMeasurements: Bool,
        _ remoteId: Int32,
        _ profile: AuthProfileItem,
        _ observer: AnyObserver<Float>,
        _ disposable: BooleanDisposable
    ) throws {
        NSLog("Check for cleaning (cleanMeasurements: `\(cleanMeasurements))`")
        if (cleanMeasurements) {
            try baseMeasurementRepository.deleteAll(for: profile).subscribeSynchronous()
        }
        
        let databaseCount = baseMeasurementRepository.findCount(
            remoteId: remoteId,
            profile: profile
        ).subscribeSynchronous(defaultValue: 0)
        if (databaseCount == totalCount && !cleanMeasurements) {
            NSLog("Database and cloud has same size of measurements. Import skipped")
            return
        }
        
        NSLog("Measurements import started (db count: \(databaseCount), remote count: \(totalCount))")
        try iterateAndImport(totalCount, databaseCount, cleanMeasurements, remoteId, profile, observer, disposable)
    }
    
    func iterateAndImport(
        _ totalCount: Int,
        _ databaseCount: Int,
        _ cleanMeasurements: Bool,
        _ remoteId: Int32,
        _ profile: AuthProfileItem,
        _ observer: AnyObserver<Float>,
        _ disposable: BooleanDisposable
    ) throws {
        let entriesToImport = totalCount - databaseCount
        var importedEntries = 0
        var afterTimestamp = baseMeasurementRepository
            .findMaxTimestamp(remoteId: remoteId, profile: profile)
            .subscribeSynchronous(defaultValue: 0) ?? 0
        
        while (!disposable.isDisposed) {
            let measurements = try baseMeasurementRepository.getMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp).toBlocking().single()
            if (measurements.isEmpty) {
                NSLog("Measurements end reached")
                return
            }
            
            NSLog("Measurements fetched \(measurements.count)")
            afterTimestamp = try baseMeasurementRepository.storeMeasurements(
                measurements: measurements,
                timestamp: afterTimestamp,
                profile: profile,
                remoteId: remoteId
            )
            
            importedEntries += measurements.count
            observer.on(.next(Float(importedEntries) / Float(entriesToImport)))
        }
    }
}
