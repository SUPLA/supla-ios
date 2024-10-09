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
    @Singleton<ProfileRepository> private var profileRepository

    private let providers: [ChannelDataRangeProvider] = [
        ThermometerDataRangeProvider(),
        HumidityAndTemperatureDataRangeProvide(),
        GeneralPurposeMeterDataRangeProvide(),
        GeneralPurposeMeasurementDataRangeProvide(),
        ElectricityMeterDataRangeProvide()
    ]

    func invoke(remoteId: Int32) -> Observable<DaysRange?> {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channel in
                self.profileRepository.getActiveProfile().map { (channel, $0) }
            }
            .flatMapFirst { channel, profile in
                for provider in self.providers {
                    if (provider.handle(function: channel.func)) {
                        return Observable.zip(
                            provider.minTime(remoteId: channel.remote_id, profile: profile),
                            provider.maxTime(remoteId: channel.remote_id, profile: profile)
                        ) { self.createDaysRange($0, $1) }
                    }
                }
                return Observable.error(GeneralError.illegalArgument(
                    message: "LoadChannelMeasurementsDateRangeUseCase: channel function not supported (\(channel.func))"
                ))
            }
    }

    private func createDaysRange(_ min: TimeInterval?, _ max: TimeInterval?) -> DaysRange? {
        if let start = min,
           let end = max,
           (start > 0 && end > 0)
        {
            DaysRange(start: Date(timeIntervalSince1970: start), end: Date(timeIntervalSince1970: end))
        } else {
            nil
        }
    }
}

protocol ChannelDataRangeProvider {
    func handle(function: Int32) -> Bool
    func minTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
    func maxTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
}

final class ThermometerDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository

    func handle(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_THERMOMETER
    }

    func minTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        temperatureMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, profile: profile)
    }

    func maxTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        temperatureMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, profile: profile)
    }
}

final class HumidityAndTemperatureDataRangeProvide: ChannelDataRangeProvider {
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository

    func handle(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
    }

    func minTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        tempHumidityMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, profile: profile)
    }

    func maxTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        tempHumidityMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, profile: profile)
    }
}

final class GeneralPurposeMeterDataRangeProvide: ChannelDataRangeProvider {
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository

    func handle(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
    }

    func minTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        generalPurposeMeterItemRepository.findMinTimestamp(remoteId: remoteId, profile: profile)
    }

    func maxTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        generalPurposeMeterItemRepository.findMaxTimestamp(remoteId: remoteId, profile: profile)
    }
}

final class GeneralPurposeMeasurementDataRangeProvide: ChannelDataRangeProvider {
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository

    func handle(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
    }

    func minTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        generalPurposeMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, profile: profile)
    }

    func maxTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        generalPurposeMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, profile: profile)
    }
}

final class ElectricityMeterDataRangeProvide: ChannelDataRangeProvider {
    @Singleton<ElectricityMeasurementItemRepository> private var electricityMeasurementItemRepository

    func handle(function: Int32) -> Bool {
        switch (function) {
        case SUPLA_CHANNELFNC_ELECTRICITY_METER,
             SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER: true
        default: false
        }
    }

    func minTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        electricityMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, profile: profile)
    }

    func maxTime(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?> {
        electricityMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, profile: profile)
    }
}
