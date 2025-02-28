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
import SharedCore

final class HumidityHistoryDetailVM: BaseHistoryDetailVM {
    
    @Singleton<DownloadEventsManager> private var downloadEventsManager
    @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
    @Singleton<LoadChannelMeasurementsUseCase> private var loadChannelMeasurementsUseCase
    @Singleton<LoadChannelMeasurementsDateRangeUseCase> private var loadChannelMeasurementsDateRangeUseCase
    
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
    
    override func handleData(channel: ChannelWithChildren, channelDto: ChannelDto, chartState: ChartState?) {
        updateView {
            $0.changing(path: \.profileId, to: channel.channel.profile.id)
                .changing(path: \.channelFunction, to: channel.channel.func)
                .changing(path: \.chartStyle, to: .humidity)
        }
        
        restoreRange(chartState: chartState)
        configureDownloadObserver(channel: channel.channel)
        startInitialDataLoad(channel)
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
    
    private func startInitialDataLoad(_ channelWithChildren: ChannelWithChildren) {
        if (currentState()?.initialLoadStarted == true) {
            return
        }
        updateView { $0.changing(path: \.initialLoadStarted, to: true) }
        downloadChannelMeasurementsUseCase.invoke(channelWithChildren)
    }
}
