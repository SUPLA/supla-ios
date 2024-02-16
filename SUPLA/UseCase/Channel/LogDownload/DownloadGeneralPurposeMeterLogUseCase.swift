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

protocol DownloadGeneralPurposeMeterLogUseCase {
    func invoke(remoteId: Int32) -> Observable<Float>
}

final class DownloadGeneralPurposeMeterLogUseCaseImpl:
    BaseDownloadLogUseCase<SuplaCloudClient.GeneralPurposeMeter, SAGeneralPurposeMeterItem>,
    DownloadGeneralPurposeMeterLogUseCase
{
    @Singleton<LoadChannelConfigUseCase> private var loadChannelConfigUseCase
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository
    
    override func iterateAndImport(
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
        var lastEntity = generalPurposeMeterItemRepository
            .findOldestEntity(remoteId: remoteId, profile: profile)
            .subscribeSynchronous(defaultValue: nil)?
            .toLatest()
        var afterTimestamp = lastEntity?.date?.timeIntervalSince1970 ?? 0
        guard let channelConfig = loadChannelConfigUseCase
            .invoke(remoteId: remoteId)
            .subscribeSynchronous(defaultValue: nil) as? SuplaChannelGeneralPurposeMeterConfig
        else {
            throw GeneralError.illegalState(message: "Channel config not found")
        }
        
        while (!disposable.isDisposed) {
            let measurements = try cloudService
                .getGeneralPurposeMeter(remoteId: remoteId, afterTimestamp: afterTimestamp)
                .toBlocking()
                .single()
            if (measurements.isEmpty) {
                NSLog("Measurements end reached")
                return
            }
            
            NSLog("Measurements fetched \(measurements.count)")
            lastEntity = try generalPurposeMeterItemRepository.storeMeasurements(
                measurements: measurements,
                latestItem: lastEntity,
                profile: profile,
                remoteId: remoteId,
                channelConfig: channelConfig
            )
            afterTimestamp = lastEntity?.date?.timeIntervalSince1970 ?? 0
            
            importedEntries += measurements.count
            observer.on(.next(Float(importedEntries) / Float(entriesToImport)))
        }
    }
    
    struct Latest {
        let value: NSDecimalNumber?
        let date: Date?
    }
}

fileprivate extension SAGeneralPurposeMeterItem {
    func toLatest() -> DownloadGeneralPurposeMeterLogUseCaseImpl.Latest {
        DownloadGeneralPurposeMeterLogUseCaseImpl.Latest(value: value, date: date)
    }
}
