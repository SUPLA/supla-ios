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

import Foundation
import RxSwift

protocol DeleteAllProfileDataUseCase {
    func invoke(profile: AuthProfileItem) -> Observable<Void>
}

final class DeleteAllProfileDataUseCaseImpl: DeleteAllProfileDataUseCase {
    
    @Singleton<ChannelExtendedValueRepository> private var channelExtendedValueRepository
    @Singleton<ChannelValueRepository> private var channelValueRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<ElectricityMeasurementItemRepository> private var electricityMeasurementItemRepository
    @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
    @Singleton<LocationRepository> private var locationRepository
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<UserIconRepository> private var userIconRepository
    @Singleton<ThermostatMeasurementItemRepository> private var thermostatMeasurementItemRepository
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository
    @Singleton<ChannelConfigRepository> private var channelConfigRepository
    
    func invoke(profile: AuthProfileItem) -> Observable<Void> {
        return Observable.combineLatest([
            self.channelExtendedValueRepository.deleteAll(for: profile),
            self.channelValueRepository.deleteAll(for: profile),
            self.channelRepository.deleteAll(for: profile),
            self.groupRepository.deleteAll(for: profile),
            self.electricityMeasurementItemRepository.deleteAll(for: profile),
            self.impulseCounterMeasurementItemRepository.deleteAll(for: profile),
            self.locationRepository.deleteAll(for: profile),
            self.sceneRepository.deleteAll(for: profile),
            self.temperatureMeasurementItemRepository.deleteAll(for: profile),
            self.tempHumidityMeasurementItemRepository.deleteAll(for: profile),
            self.userIconRepository.deleteAll(for: profile),
            self.thermostatMeasurementItemRepository.deleteAll(for: profile),
            self.generalPurposeMeterItemRepository.deleteAll(for: profile),
            self.generalPurposeMeasurementItemRepository.deleteAll(for: profile),
            self.channelConfigRepository.deleteAllFor(profile: profile)
        ]).map {
            $0.first
        }
    }
}
