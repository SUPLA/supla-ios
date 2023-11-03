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

protocol DownloadTempHumidityMeasurementsUseCase {
    func loadMeasurements(remoteId: Int32) -> Observable<Float>
}

final class DownloadTempHumidityMeasurementsUseCaseImpl: BaseDownloadMeasurementsUseCase, DownloadTempHumidityMeasurementsUseCase {
    typealias Dto = SuplaCloudClient.TemperatureAndHumidityMeasurement
    
    @Singleton<SuplaCloudService> var service
    @Singleton<ProfileRepository> var profileRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        tempHumidityMeasurementItemRepository.deleteAll(for: profile)
    }
    
    func findMinTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        tempHumidityMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, profile: profile)
    }
    
    func findMaxTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        tempHumidityMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, profile: profile)
    }
    
    func findCount(remoteId: Int32, profile: AuthProfileItem) -> Observable<Int> {
        tempHumidityMeasurementItemRepository.findCount(remoteId: remoteId, profile: profile)
    }
    
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]> {
        service.getTemperatureAndHumidityMeasurements(remoteId: remoteId, afterTimestamp: afterTimestamp)
    }
    
    func storeMeasurements(measurements: [SuplaCloudClient.TemperatureAndHumidityMeasurement], timestamp: TimeInterval, profile: AuthProfileItem, remoteId: Int32) throws -> TimeInterval {
        try tempHumidityMeasurementItemRepository.storeMeasurements(measurements: measurements, timestamp: timestamp, profile: profile, remoteId: remoteId)
    }
    
    func fromJson(data: Data) throws -> [SuplaCloudClient.TemperatureAndHumidityMeasurement] {
        try SuplaCloudClient.TemperatureAndHumidityMeasurement.fromJson(data: data)
    }
}
