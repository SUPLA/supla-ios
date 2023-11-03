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

protocol LoadChannelWithChildrenMeasurementsDateRangeUseCase {
    func invoke(remoteId: Int32) -> Observable<DaysRange?>
}

final class LoadChannelWithChildrenMeasurementsDateRangeUseCaseImpl: LoadChannelWithChildrenMeasurementsDateRangeUseCase {
    
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChidlrenUseCase
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke(remoteId: Int32) -> Observable<DaysRange?> {
        readChannelWithChidlrenUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channel in
                self.profileRepository.getActiveProfile().map { (channel, $0) }
            }
            .flatMapFirst {
                if ($0.0.channel.isHvacThermostat()) {
                    return Observable.zip(
                        self.findMinTime(channelWithChildren: $0.0, profile: $0.1),
                        self.findMaxTime(channelWithChildren: $0.0, profile: $0.1)
                    ) { min, max in
                        var result: DaysRange? = nil
                        if let start = min,
                           let end = max,
                           (start > 0 && end > 0) {
                            result = DaysRange(
                                start: Date(timeIntervalSince1970: start),
                                end: Date(timeIntervalSince1970: end)
                            )
                        }
                        
                        return result
                    }
                } else {
                    return Observable.error(GeneralError.illegalArgument(
                        message: "Channel function not supported (\($0.0.channel.func))"
                    ))
                }
            }
    }
    
    private func findMinTime(channelWithChildren: ChannelWithChildren, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        var channelsWithMeasurements = channelWithChildren.children
            .sorted(by: { $0.relationType.rawValue > $1.relationType.rawValue })
            .filter { $0.channel.hasMeasurements() }
            .map { $0.channel }
        if (channelWithChildren.channel.hasMeasurements()) {
            channelsWithMeasurements.append(channelWithChildren.channel)
        }
        
        var observables: [Observable<TimeInterval?>] = []
        
        channelsWithMeasurements.forEach {
            if ($0.func == SUPLA_CHANNELFNC_THERMOMETER) {
                observables.append(
                    temperatureMeasurementItemRepository.findMinTimestamp(
                        remoteId: $0.remote_id,
                        profile: profile
                    )
                )
            } else if ($0.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
                observables.append(
                    tempHumidityMeasurementItemRepository.findMinTimestamp(
                        remoteId: $0.remote_id,
                        profile: profile
                    )
                )
            }
        }
        
        return Observable.zip(observables) { items in
            var minTime: TimeInterval? = nil
            
            items.forEach {
                if let new = $0 {
                    if let min = minTime {
                        if (new.isLess(than: min)) {
                            minTime = new
                        }
                    } else {
                        // Not initialized yet
                        minTime = new
                    }
                }
            }
            
            return minTime
        }
    }
    
    private func findMaxTime(channelWithChildren: ChannelWithChildren, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        var channelsWithMeasurements = channelWithChildren.children
            .sorted(by: { $0.relationType.rawValue > $1.relationType.rawValue })
            .filter { $0.channel.hasMeasurements() }
            .map { $0.channel }
        if (channelWithChildren.channel.hasMeasurements()) {
            channelsWithMeasurements.append(channelWithChildren.channel)
        }
        
        var observables: [Observable<TimeInterval?>] = []
        
        channelsWithMeasurements.forEach {
            if ($0.func == SUPLA_CHANNELFNC_THERMOMETER) {
                observables.append(
                    temperatureMeasurementItemRepository.findMaxTimestamp(
                        remoteId: $0.remote_id,
                        profile: profile
                    )
                )
            } else if ($0.func == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
                observables.append(
                    tempHumidityMeasurementItemRepository.findMaxTimestamp(
                        remoteId: $0.remote_id,
                        profile: profile
                    )
                )
            }
        }
        
        return Observable.zip(observables) { items in
            var maxTime: TimeInterval? = nil
            
            items.forEach {
                if let new = $0 {
                    if let max = maxTime {
                        if (max.isLess(than: new)) {
                            maxTime = new
                        }
                    } else {
                        // Not initialized yet
                        maxTime = new
                    }
                }
            }
            
            return maxTime!
        }
    }
}
