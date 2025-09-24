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
    @Singleton<VoltageMeasurementItemRepository> private var voltageMeasurementItemRepository
    @Singleton<CurrentMeasurementItemRepository> private var currentMeasurementItemRepository
    @Singleton<HumidityMeasurementItemRepository> private var humidityMeasurementItemRepository
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository
    @Singleton<PowerActiveMeasurementItemRepository> private var powerActiveMeasurementItemRepository
    @Singleton<ElectricityMeasurementItemRepository> private var electricityMeasurementItemRepository
    @Singleton<TemperatureMeasurementItemRepository> private var temperatureMeasurementItemRepository
    @Singleton<TempHumidityMeasurementItemRepository> private var tempHumidityMeasurementItemRepository
    @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
    @Singleton<GeneralPurposeMeasurementItemRepository> private var generalPurposeMeasurementItemRepository
    @Singleton<ThermostatMeasurementItemRepository> private var thermostatMeasurementItemRepository

    func invoke(remoteId: Int32) -> Observable<Void> {
        readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
            .flatMap { channelWithChildren in
                let function = channelWithChildren.function
                let remoteId = channelWithChildren.remoteId
                let serverId = channelWithChildren.channel.profile.server?.id

                return if (function == SUPLA_CHANNELFNC_THERMOMETER) {
                    self.temperatureMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                } else if (function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
                    self.tempHumidityMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT) {
                    self.generalPurposeMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER) {
                    self.generalPurposeMeterItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                } else if (function == SUPLA_CHANNELFNC_HUMIDITY) {
                    self.humidityMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                } else if (function == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS) {
                    self.thermostatMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                } else if (channelWithChildren.isOrHasElectricityMeter) {
                    Observable.merge([
                        self.currentMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId),
                        self.voltageMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId),
                        self.powerActiveMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId),
                        self.electricityMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                    ])
                } else if (channelWithChildren.isOrHasImpulseCounter) {
                    self.impulseCounterMeasurementItemRepository.deleteAll(remoteId: remoteId, serverId: serverId)
                } else if (channelWithChildren.channel.isHvacThermostat()) {
                    Observable.merge(
                        channelWithChildren.children.filter { $0.relationType.isThermometer() }
                            .map {
                                switch ($0.channel.func) {
                                    case SUPLA_CHANNELFNC_THERMOMETER:
                                    self.temperatureMeasurementItemRepository.deleteAll(
                                        remoteId: $0.channel.remote_id,
                                        serverId: $0.channel.profile.server?.id
                                    )
                                    case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
                                        self.tempHumidityMeasurementItemRepository.deleteAll(
                                            remoteId: $0.channel.remote_id,
                                            serverId: $0.channel.profile.server?.id
                                        )
                                    default: self.invalidFunctionCompletable(function: $0.channel.func)
                                }
                            }
                    )
                } else {
                    self.invalidFunctionCompletable(function: channelWithChildren.function)
                }
            }
    }

    private func invalidFunctionCompletable(function: Int32) -> Observable<Void> {
        Observable.error(GeneralError.illegalState(
            message: "Trying to delete history of unsupported function `\(function)`."
        ))
    }
}
