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
    
protocol RemoveHiddenChannelsUseCase {
    func invoke()
}

final class RemoveHiddenChannelsUseCaseImpl: RemoveHiddenChannelsUseCase {
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ChannelConfigRepository> private var channelConfigRepository
    @Singleton<ChannelExtendedValueRepository> private var channelExtendedValueRepository
    @Singleton<ChannelStateRepository> private var channelStateRepository
    @Singleton<ChannelValueRepository> private var channelValueRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository
    @Singleton<PowerActiveMeasurementItemRepository> private var powerActiveMeasurementItemRepository
    @Singleton<VoltageMeasurementItemRepository> private var voltageMeasurementItemRepository
    @Singleton<CurrentMeasurementItemRepository> private var currentMeasurementItemRepository
    @Singleton<ElectricityMeasurementItemRepository> private var electricityMeasurementItemRepository
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository
    @Singleton<HumidityMeasurementItemRepository> private var humidityMeasurementItemRepository
    @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<ThermostatMeasurementItemRepository> private var thermostatMeasurementItemRepository
    
    private lazy var deletables: [Deletable] = {
        [
            channelConfigRepository,
            channelExtendedValueRepository,
            channelStateRepository,
            channelValueRepository,
            channelRelationRepository,
            powerActiveMeasurementItemRepository,
            voltageMeasurementItemRepository,
            currentMeasurementItemRepository,
            electricityMeasurementItemRepository,
            generalPurposeMeasurementItemRepository,
            generalPurposeMeterItemRepository,
            humidityMeasurementItemRepository,
            impulseCounterMeasurementItemRepository,
            temperatureMeasurementItemRepository,
            thermostatMeasurementItemRepository,
            channelRepository
        ]
    }()
    
    func invoke() {
        let channels = channelRepository.getHiddenChannelsSync()
        SALog.info("Found channels to remove: \(channels.count)")
        
        channels.forEach { channel in
            deletables.forEach { deletable in
                deletable.deleteSync(channel.remote_id, channel.profile)
            }
        }
        
        SALog.info("Hidden channels removal finished")
    }
    
    protocol Deletable {
        func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem)
    }
}
