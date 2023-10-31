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

protocol LoadChannelMeasurementsDateRangeUseCase {
    func invoke(remoteId: Int32) -> Observable<DaysRange?>
}

final class LoadChannelMeasurementsDateRangeUseCaseImpl: LoadChannelMeasurementsDateRangeUseCase {
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke(remoteId: Int32) -> Observable<DaysRange?> {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channel in
                self.profileRepository.getActiveProfile().map { (channel, $0) }
            }
            .flatMapFirst {
                if ($0.0.isThermometer()) {
                    return Observable.zip(
                        self.findMinTime(channel: $0.0, profile: $0.1),
                        self.findMaxTime(channel: $0.0, profile: $0.1)
                    ) { min, max in
                        var result: DaysRange? = nil
                        if (min > 0 && max > 0) {
                            result = DaysRange(
                                start: Date(timeIntervalSince1970: min),
                                end: Date(timeIntervalSince1970: max)
                            )
                        }
                        
                        return result
                    }
                } else {
                    return Observable.error(GeneralError.illegalArgument(
                        message: "LoadChannelMeasurementsDateRangeUseCase: channel function not supported (\($0.0.func))"
                    ))
                }
            }
    }
    
    private func findMinTime(channel: SAChannel, profile: AuthProfileItem) -> Observable<Double> {
        if (channel.func == SUPLA_CHANNELFNC_THERMOMETER) {
            return temperatureMeasurementItemRepository.findMinTimestamp(remoteId: channel.remote_id, profile: profile)
        } else if (channel.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            return tempHumidityMeasurementItemRepository.findMinTimestamp(remoteId: channel.remote_id, profile: profile)
        } else {
            return Observable.just(0)
        }
    }
    
    private func findMaxTime(channel: SAChannel, profile: AuthProfileItem) -> Observable<Double> {
        if (channel.func == SUPLA_CHANNELFNC_THERMOMETER) {
            return temperatureMeasurementItemRepository.findMaxTimestamp(remoteId: channel.remote_id, profile: profile)
        } else if (channel.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            return tempHumidityMeasurementItemRepository.findMaxTimestamp(remoteId: channel.remote_id, profile: profile)
        } else {
            return Observable.just(0)
        }
    }
}
