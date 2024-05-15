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

protocol DeleteChannelMeasurementsUseCase {
    func invoke(remoteId: Int32) -> Observable<Void>
}

final class DeleteChannelMeasurementsUseCaseImpl: DeleteChannelMeasurementsUseCase {
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository

    func invoke(remoteId: Int32) -> Observable<Void> {
        readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
            .map { self.channelWithChildrenToChannels($0) }
            .flatMap { channels in
                Observable.merge(channels.map { self.getDeleteCompletable($0.func, remoteId: $0.remote_id, profile: $0.profile) })
            }
    }

    private func channelWithChildrenToChannels(_ channelWithChildren: ChannelWithChildren) -> [SAChannel] {
        var channels: [SAChannel] = []

        if (channelWithChildren.channel.hasHistory()) {
            channels.append(channelWithChildren.channel)
        }
        channels.append(contentsOf: channelWithChildren.children.map { $0.channel }.filter { $0.hasHistory() })

        return channels
    }

    private func getDeleteCompletable(_ function: Int32, remoteId: Int32, profile: AuthProfileItem) -> Observable<Void> {
        switch (function) {
        case SUPLA_CHANNELFNC_THERMOMETER:
            temperatureMeasurementItemRepository.deleteAll(remoteId: remoteId, profile: profile)
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            tempHumidityMeasurementItemRepository.deleteAll(remoteId: remoteId, profile: profile)
        case SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT:
            generalPurposeMeasurementItemRepository.deleteAll(remoteId: remoteId, profile: profile)
        case SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER:
            generalPurposeMeterItemRepository.deleteAll(remoteId: remoteId, profile: profile)
        default:
            fatalError("Deleting measurements for channel with function `\(function)` is not supported yet!")
        }
        
    }
}
