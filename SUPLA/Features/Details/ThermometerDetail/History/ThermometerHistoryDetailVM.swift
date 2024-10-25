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

final class ThermometerHistoryDetailVM: BaseHistoryDetailVM {
    
    @Singleton<DownloadEventsManager> private var downloadEventsManager
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
    @Singleton<LoadChannelMeasurementsUseCase> private var loadChannelMeasurementsUseCase
    @Singleton<LoadChannelMeasurementsDateRangeUseCase> private var loadChannelMeasurementsDateRangeUseCase
    
    override func triggerDataLoad(remoteId: Int32) {
        Observable.zip(
            readChannelByRemoteIdUseCase.invoke(remoteId: remoteId),
            profileRepository.getActiveProfile().map { [weak self] in self?.loadChartState($0.idString, remoteId) }
        ) { ($0, $1) }
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] in self?.handleData(channel: $0.0, chartState: $0.1) }
            )
            .disposed(by: self)
    }
    
    override func measurementsObservable(
        remoteId: Int32,
        spec: ChartDataSpec,
        chartRange: ChartRange
    ) -> Observable<(ChartData, DaysRange?)> {
        Observable.zip(
            loadChannelMeasurementsUseCase.invoke(remoteId: remoteId, spec: spec),
            loadChannelMeasurementsDateRangeUseCase.invoke(remoteId: remoteId)
        ) { (LineChartData(DaysRange(start: spec.startDate, end: spec.endDate), chartRange, spec.aggregation, [$0]), $1) }
    }
    
    private func handleData(channel: SAChannel, chartState: ChartState?) {
        updateView {
            $0.changing(path: \.profileId, to: channel.profile.idString)
                .changing(path: \.channelFunction, to: channel.func)
        }
        
        restoreRange(chartState: chartState)
        configureDownloadObserver(channel: channel)
        startInitialDataLoad(channel: channel)
    }
    
    private func configureDownloadObserver(channel: SAChannel) {
        if (currentState()?.downloadConfigured == true) {
            // Needs to be performed only once
            return
        }
        updateView { $0.changing(path: \.downloadConfigured, to: true) }
        
        downloadEventsManager.observeProgress(remoteId: channel.remote_id)
            .distinctUntilChanged()
            .asDriverWithoutError()
            .drive(onNext: { [weak self] in self?.handleDownloadEvents(downloadState: $0) })
            .disposed(by: self)
    }
    
    private func startInitialDataLoad(channel: SAChannel) {
        if (currentState()?.initialLoadStarted == true) {
            return
        }
        updateView { $0.changing(path: \.initialLoadStarted, to: true) }
        downloadChannelMeasurementsUseCase.invoke(remoteId: channel.remote_id, function: channel.func)
    }
}
