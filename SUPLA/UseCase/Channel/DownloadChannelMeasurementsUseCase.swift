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
    @Singleton<SuplaSchedulers> private var schedulers
    
    private let syncedQueue = DispatchQueue(label: "MeasurementsPrivateQueue", attributes: .concurrent)
    private var workingList: [Id] = []
    private let disposeBag = DisposeBag()
    
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
        
        if (function == SUPLA_CHANNELFNC_THERMOMETER) {
            startTemperatureDownload(id)
        } else if (function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            startTemperatureAndHumidityDownload(id)
        } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT) {
            startGeneralPurposeMeasurementDownload(id)
        } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER) {
            startGeneralPurposeMeterDownload(id)
        } else if (channelWithChildren.isOrHasElectricityMeter) {
            switch (id.type) {
            case .default: startElectricityMeasurementsDownload(id)
            case .electricityCurrent: startCurrentMeasurementsDownload(id)
            case .electricityVoltage: startVoltageMeasurementsDownload(id)
            case .electricityPowerActive: startPowerActiveMeasurementsDownload(id)
            }
        } else if (channelWithChildren.isOrHasImpulseCounter) {
            startImpulseCounterMeasurementsDownload(id)
        } else if (function == SUPLA_CHANNELFNC_HUMIDITY) {
            startHumidityMeasurementsDownload(id)
        } else {
            throw GeneralError.illegalArgument(message: "Trying to start download for unsupported function \(function)")
        }
    }
    
    private func startTemperatureDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadTemperatureLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startTemperatureAndHumidityDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadTempHumidityLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startGeneralPurposeMeasurementDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadGeneralPurposeMeasurementLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startGeneralPurposeMeterDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadGeneralPurposeMeterLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startElectricityMeasurementsDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadElectricityMeterLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startHumidityMeasurementsDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadHumidityLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startImpulseCounterMeasurementsDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadImpulseCounterLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startCurrentMeasurementsDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadCurrentLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startVoltageMeasurementsDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadVoltageLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func startPowerActiveMeasurementsDownload(_ id: Id) {
        setupObservable(
            id: id,
            observable: downloadPowerActiveLogUseCase.invoke(remoteId: id.id)
        )
    }
    
    private func setupObservable(id: Id, observable: Observable<Float>) {
        observable
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .do(onSubscribe: {
                self.downloadEventsManager.emitProgressState(remoteId: id.id, dataType: id.type, state: .started)
            })
            .subscribe(
                onNext: {
                    self.downloadEventsManager.emitProgressState(
                        remoteId: id.id,
                        dataType: id.type,
                        state: .inProgress(progress: $0)
                    )
                },
                onError: { error in
                    self.downloadEventsManager.emitProgressState(remoteId: id.id, dataType: id.type, state: .failed)
                    self.removeFromWorkingList(id)
                    
                    let errorMessage = String(describing: error)
                    SALog.error("Measurements download for \(id.id) (type: \(id.type)) failed with \(error.localizedDescription)")
                    NSLog(errorMessage)
                },
                onCompleted: {
                    self.downloadEventsManager.emitProgressState(remoteId: id.id, dataType: id.type, state: .finished)
                    self.removeFromWorkingList(id)
                    
                    SALog.info("Measurements download for \(id.id) (type: \(id.type)) finished successfully")
                }
            )
            .disposed(by: disposeBag)
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
