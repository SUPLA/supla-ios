//
//  DeleteAllProfileDataUseCase.swift
//  SUPLA
//
//  Created by Michał Polański on 30/05/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

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
            self.thermostatMeasurementItemRepository.deleteAll(for: profile)
        ]).map {
            $0.first
        }
    }
}
