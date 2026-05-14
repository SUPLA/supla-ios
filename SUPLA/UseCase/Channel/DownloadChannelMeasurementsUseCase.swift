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

protocol DownloadChannelMeasurementsUseCase {
    func invoke(_ channelWithChildren: ChannelWithChildren, type: DownloadEventsManagerDataType)
}

extension DownloadChannelMeasurementsUseCase {
    func invoke(_ channelWithChildren: ChannelWithChildren) {
        invoke(channelWithChildren, type: .default)
    }
}

final class DownloadChannelMeasurementsUseCaseImpl: DownloadChannelMeasurementsUseCase {
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<DownloadEventsManager> private var downloadEventsManager
    @Singleton<DownloadTemperatureLogUseCase> private var downloadTemperatureLogUseCase
    @Singleton<DownloadTempHumidityLogUseCase> private var downloadTempHumidityLogUseCase
    @Singleton<DownloadGeneralPurposeMeasurementLogUseCase> private var downloadGeneralPurposeMeasurementLogUseCase
    @Singleton<DownloadGeneralPurposeMeterLogUseCase> private var downloadGeneralPurposeMeterLogUseCase
    @Singleton<DownloadElectricityMeterLogUseCase> private var downloadElectricityMeterLogUseCase
    @Singleton<DownloadHumidityLogUseCase> private var downloadHumidityLogUseCase
    @Singleton<DownloadImpulseCounterLogUseCase> private var downloadImpulseCounterLogUseCase
    @Singleton<DownloadVoltageLogUseCase> private var downloadVoltageLogUseCase
    @Singleton<DownloadCurrentLogUseCase> private var downloadCurrentLogUseCase
    @Singleton<DownloadPowerActiveLogUseCase> private var downloadPowerActiveLogUseCase
    @Singleton<DownloadThermostatHeatpolLogUseCase> private var downloadThermostatHeatpolLogUseCase
    @Singleton<SuplaSchedulers> private var schedulers
    
    private let syncedQueue = DispatchQueue(label: "MeasurementsPrivateQueue", attributes: .concurrent)
    private var workingList: [Id] = []
    private let disposeBag = DisposeBag()
    
    // used in tests
    var lastTask: Task<Void, Never>? = nil
    
    func invoke(_ channelWithChildren: ChannelWithChildren, type: DownloadEventsManagerDataType) {
        syncedQueue.sync {
            let id = Id(channelWithChildren.remoteId, type)
            if (workingList.contains(id)) {
                SALog.debug("Download skipped as the \(channelWithChildren.remoteId) is on working list")
                return
            }

            do {
                try startDownload(channelWithChildren, id)
            } catch {
                SALog.error(error.localizedDescription)
                return
            }
            workingList.append(id)
        }
    }
    
    private func startDownload(_ channelWithChildren: ChannelWithChildren, _ id: Id) throws {
        let function = channelWithChildren.function
        let profile = channelWithChildren.channel.profile
        
        if (function == SUPLA_CHANNELFNC_THERMOMETER) {
            startTemperatureDownload(id, profile)
        } else if (function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            startTemperatureAndHumidityDownload(id, profile)
        } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT) {
            startGeneralPurposeMeasurementDownload(id, profile)
        } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER) {
            startGeneralPurposeMeterDownload(id, profile)
        } else if (channelWithChildren.isOrHasElectricityMeter) {
            switch (id.type) {
            case .default: startElectricityMeasurementsDownload(id, profile)
            case .electricityCurrent: startCurrentMeasurementsDownload(id, profile)
            case .electricityVoltage: startVoltageMeasurementsDownload(id, profile)
            case .electricityPowerActive: startPowerActiveMeasurementsDownload(id, profile)
            }
        } else if (channelWithChildren.isOrHasImpulseCounter) {
            startImpulseCounterMeasurementsDownload(id, profile)
        } else if (function == SUPLA_CHANNELFNC_HUMIDITY) {
            startHumidityMeasurementsDownload(id, profile)
        } else if (function == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS) {
            startThermostatHeatpolMeasurementsDownload(id, profile)
        } else {
            throw GeneralError.illegalArgument(message: "Trying to start download for unsupported function \(function)")
        }
    }
    
    private func startTemperatureDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadTemperatureLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startTemperatureAndHumidityDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadTempHumidityLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startGeneralPurposeMeasurementDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadGeneralPurposeMeasurementLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startGeneralPurposeMeterDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadGeneralPurposeMeterLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startElectricityMeasurementsDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadElectricityMeterLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startHumidityMeasurementsDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadHumidityLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startImpulseCounterMeasurementsDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadImpulseCounterLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startCurrentMeasurementsDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadCurrentLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startVoltageMeasurementsDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadVoltageLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startPowerActiveMeasurementsDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadPowerActiveLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func startThermostatHeatpolMeasurementsDownload(_ id: Id, _ profile: AuthProfileItem) {
        setupTask(id: id) {
            try await self.downloadThermostatHeatpolLogUseCase.invoke(remoteId: id.id, profile: profile, observer: $0)
        }
    }
    
    private func setupTask(id: Id, runner: @escaping ((Float) -> Void) async throws -> Void) {
        lastTask = Task.detached(priority: .userInitiated) {
            await MainActor.run {
                self.downloadEventsManager.emitProgressState(remoteId: id.id, dataType: id.type, state: .started)
                self.updateEventsManager.emitChannelUpdate(remoteId: Int(id.id))
            }
            
            do {
                try await runner { progress in
                    self.downloadEventsManager.emitProgressState(
                        remoteId: id.id,
                        dataType: id.type,
                        state: .inProgress(progress: progress)
                    )
                }
                
                await MainActor.run {
                    self.downloadEventsManager.emitProgressState(remoteId: id.id, dataType: id.type, state: .finished)
                }
                
                SALog.info("Measurements download for \(id.id) (type: \(id.type)) finished successfully")
            } catch {
                await MainActor.run {
                    self.downloadEventsManager.emitProgressState(remoteId: id.id, dataType: id.type, state: .failed)
                }
                
                let errorMessage = String(describing: error)
                SALog.error("Measurements download for \(id.id) (type: \(id.type)) failed with \(errorMessage)")
            }
            
            self.updateEventsManager.emitChannelUpdate(remoteId: Int(id.id))
            self.removeFromWorkingList(id)
        }
    }
    
    private func removeFromWorkingList(_ id: Id) {
        syncedQueue.sync {
            workingList = workingList.filter { $0 != id }
        }
    }
    
    private struct Id: Hashable, Equatable {
        let id: Int32
        let type: DownloadEventsManagerDataType
        
        init(_ id: Int32, _ type: DownloadEventsManagerDataType) {
            self.id = id
            self.type = type
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(type)
        }
    }
}
