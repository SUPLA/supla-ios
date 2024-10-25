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
    func invoke(remoteId: Int32, function: Int32)
}

final class DownloadChannelMeasurementsUseCaseImpl: DownloadChannelMeasurementsUseCase {
    @Singleton<DownloadEventsManager> private var downloadEventsManager
    @Singleton<DownloadTemperatureLogUseCase> private var downloadTemperatureLogUseCase
    @Singleton<DownloadTempHumidityLogUseCase> private var downloadTempHumidityLogUseCase
    @Singleton<DownloadGeneralPurposeMeasurementLogUseCase> private var downloadGeneralPurposeMeasurementLogUseCase
    @Singleton<DownloadGeneralPurposeMeterLogUseCase> private var downloadGeneralPurposeMeterLogUseCase
    @Singleton<DownloadElectricityMeterLogUseCase> private var downloadElectricityMeterLogUseCase
    @Singleton<SuplaSchedulers> private var schedulers
    
    private let syncedQueue = DispatchQueue(label: "MeasurementsPrivateQueue", attributes: .concurrent)
    private var workingList: [Int32] = []
    private let disposeBag = DisposeBag()
    
    func invoke(remoteId: Int32, function: Int32) {
        syncedQueue.sync {
            if (workingList.contains(remoteId)) {
                SALog.debug("Download skipped as the \(remoteId) is on working list")
                return
            }
            
            do {
                try startDownload(remoteId, function)
            } catch {
                SALog.error(error.localizedDescription)
                return
            }
            workingList.append(remoteId)
        }
    }
    
    private func startDownload(_ remoteId: Int32, _ function: Int32) throws {
        switch (function) {
        case SUPLA_CHANNELFNC_THERMOMETER:
            startTemperatureDownload(remoteId)
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            startTemperatureAndHumidityDownload(remoteId)
        case SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT:
            startGeneralPurposeMeasurementDownload(remoteId)
        case SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER:
            startGeneralPurposeMeterDownload(remoteId)
        case SUPLA_CHANNELFNC_ELECTRICITY_METER,
             SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER:
            startElectricityMeasurementsDownload(remoteId)
        default:
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
