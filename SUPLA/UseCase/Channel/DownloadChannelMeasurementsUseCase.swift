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
    func invoke(_ channelWithChildren: ChannelWithChildren)
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
    @Singleton<SuplaSchedulers> private var schedulers
    
    private let syncedQueue = DispatchQueue(label: "MeasurementsPrivateQueue", attributes: .concurrent)
    private var workingList: [Int32] = []
    private let disposeBag = DisposeBag()
    
    func invoke(_ channelWithChildren: ChannelWithChildren) {
        syncedQueue.sync {
            if (workingList.contains(channelWithChildren.remoteId)) {
                SALog.debug("Download skipped as the \(channelWithChildren.remoteId) is on working list")
                return
            }

            do {
                try startDownload(channelWithChildren)
            } catch {
                SALog.error(error.localizedDescription)
                return
            }
            workingList.append(channelWithChildren.remoteId)
        }
    }
    
    private func startDownload(_ channelWithChildren: ChannelWithChildren) throws {
        let function = channelWithChildren.function
        let remoteId = channelWithChildren.remoteId
        
        if (function == SUPLA_CHANNELFNC_THERMOMETER) {
            startTemperatureDownload(remoteId)
        } else if (function == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            startTemperatureAndHumidityDownload(remoteId)
        } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT) {
            startGeneralPurposeMeasurementDownload(remoteId)
        } else if (function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER) {
            startGeneralPurposeMeterDownload(remoteId)
        } else if (channelWithChildren.isOrHasElectricityMeter) {
            startElectricityMeasurementsDownload(remoteId)
        } else if (channelWithChildren.isOrHasImpulseCounter) {
            startImpulseCounterMeasurementsDownload(remoteId)
        } else if (function == SUPLA_CHANNELFNC_HUMIDITY) {
            startHumidityMeasurementsDownload(remoteId)
        } else {
            throw GeneralError.illegalArgument(message: "Trying to start download for unsupported function \(function)")
        }
    }
    
    private func startTemperatureDownload(_ remoteId: Int32) {
        setupObservable(
            remoteId: remoteId,
            observable: downloadTemperatureLogUseCase.invoke(remoteId: remoteId)
        )
    }
    
    private func startTemperatureAndHumidityDownload(_ remoteId: Int32) {
        setupObservable(
            remoteId: remoteId,
            observable: downloadTempHumidityLogUseCase.invoke(remoteId: remoteId)
        )
    }
    
    private func startGeneralPurposeMeasurementDownload(_ remoteId: Int32) {
        setupObservable(
            remoteId: remoteId,
            observable: downloadGeneralPurposeMeasurementLogUseCase.invoke(remoteId: remoteId)
        )
    }
    
    private func startGeneralPurposeMeterDownload(_ remoteId: Int32) {
        setupObservable(
            remoteId: remoteId,
            observable: downloadGeneralPurposeMeterLogUseCase.invoke(remoteId: remoteId)
        )
    }
    
    private func startElectricityMeasurementsDownload(_ remoteId: Int32) {
        setupObservable(
            remoteId: remoteId,
            observable: downloadElectricityMeterLogUseCase.invoke(remoteId: remoteId)
        )
    }
    
    private func startHumidityMeasurementsDownload(_ remoteId: Int32) {
        setupObservable(
            remoteId: remoteId,
            observable: downloadHumidityLogUseCase.invoke(remoteId: remoteId)
        )
    }
    
    private func startImpulseCounterMeasurementsDownload(_ remoteId: Int32) {
        setupObservable(
            remoteId: remoteId,
            observable: downloadImpulseCounterLogUseCase.invoke(remoteId: remoteId)
        )
    }
    
    private func setupObservable(remoteId: Int32, observable: Observable<Float>) {
        observable
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .do(onSubscribe: {
                self.downloadEventsManager.emitProgressState(remoteId: remoteId, state: .started)
            })
            .subscribe(
                onNext: {
                    self.downloadEventsManager.emitProgressState(
                        remoteId: remoteId,
                        state: .inProgress(progress: $0)
                    )
                },
                onError: { error in
                    self.downloadEventsManager.emitProgressState(remoteId: remoteId, state: .failed)
                    self.removeFromWorkingList(remoteId)
                    
                    let errorMessage = String(describing: error)
                    SALog.error("Measurements download for \(remoteId) failed with \(error.localizedDescription)")
                    NSLog(errorMessage)
                },
                onCompleted: {
                    self.downloadEventsManager.emitProgressState(remoteId: remoteId, state: .finished)
                    self.removeFromWorkingList(remoteId)
                    
                    SALog.info("Measurements download for \(remoteId) finished successfully")
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func removeFromWorkingList(_ remoteId: Int32) {
        syncedQueue.sync {
            workingList = workingList.filter { $0 != remoteId }
        }
    }
}
