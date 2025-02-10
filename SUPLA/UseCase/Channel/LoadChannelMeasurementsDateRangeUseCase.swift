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
    func invoke(remoteId: Int32, type: DownloadEventsManagerDataType) -> Observable<DaysRange?>
}

extension LoadChannelMeasurementsDateRangeUseCase {
    func invoke(remoteId: Int32) -> Observable<DaysRange?> {
        invoke(remoteId: remoteId, type: .default)
    }
}

final class LoadChannelMeasurementsDateRangeUseCaseImpl: LoadChannelMeasurementsDateRangeUseCase {
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase

    private let providers: [ChannelDataRangeProvider] = [
        ThermometerDataRangeProvider(),
        HumidityAndTemperatureDataRangeProvider(),
        GeneralPurposeMeterDataRangeProvider(),
        GeneralPurposeMeasurementDataRangeProvider(),
        ElectricityMeterDataRangeProvider(),
        HumidityMeasurementsDataRangeProvider(),
        ImpulseCounterDataRangeProvider(),
        VoltageDataRangeProvider(),
        CurrentDataRangeProvider(),
        PowerActiveDataRangeProvider()
    ]
    
    func invoke(remoteId: Int32, type: DownloadEventsManagerDataType) -> Observable<DaysRange?> {
        readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
            .flatMapFirst { channelWithChildren in
                let channel = channelWithChildren.channel
                for provider in self.providers {
                    if (provider.handle(channelWithChildren, type)) {
                        return Observable.zip(
                            provider.minTime(remoteId: channel.remote_id, serverId: channel.profile.server?.id),
                            provider.maxTime(remoteId: channel.remote_id, serverId: channel.profile.server?.id)
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
    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool
    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?>
    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?>
}

final class ThermometerDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_THERMOMETER
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        temperatureMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        temperatureMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class HumidityAndTemperatureDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        tempHumidityMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        tempHumidityMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class GeneralPurposeMeterDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        generalPurposeMeterItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        generalPurposeMeterItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class GeneralPurposeMeasurementDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        generalPurposeMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        generalPurposeMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class ElectricityMeterDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<ElectricityMeasurementItemRepository> private var electricityMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.isOrHasElectricityMeter && type == .default
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        electricityMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        electricityMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class HumidityMeasurementsDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<HumidityMeasurementItemRepository> private var humidityMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.function == SUPLA_CHANNELFNC_HUMIDITY
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        humidityMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        humidityMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class ImpulseCounterDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.isOrHasImpulseCounter
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        impulseCounterMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        impulseCounterMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class VoltageDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<VoltageMeasurementItemRepository> private var voltageMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.isOrHasElectricityMeter && type == .electricityVoltage
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        voltageMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        voltageMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class CurrentDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<CurrentMeasurementItemRepository> private var currentMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.isOrHasElectricityMeter && type == .electricityCurrent
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        currentMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        currentMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}

final class PowerActiveDataRangeProvider: ChannelDataRangeProvider {
    @Singleton<PowerActiveMeasurementItemRepository> private var powerActiveMeasurementItemRepository

    func handle(_ channelWithChildren: ChannelWithChildren, _ type: DownloadEventsManagerDataType) -> Bool {
        channelWithChildren.isOrHasElectricityMeter && type == .electricityPowerActive
    }

    func minTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        powerActiveMeasurementItemRepository.findMinTimestamp(remoteId: remoteId, serverId: serverId)
    }

    func maxTime(remoteId: Int32, serverId: Int32?) -> Observable<TimeInterval?> {
        powerActiveMeasurementItemRepository.findMaxTimestamp(remoteId: remoteId, serverId: serverId)
    }
}
