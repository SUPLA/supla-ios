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

final class GpmHistoryDetailVM: BaseHistoryDetailVM {
    @Singleton<DownloadEventsManager> private var downloadEventsManager
    @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
    @Singleton<LoadChannelMeasurementsUseCase> private var loadChannelMeasurementsUseCase
    @Singleton<LoadChannelMeasurementsDateRangeUseCase> private var loadChannelMeasurementsDateRangeUseCase
    @Singleton<LoadChannelConfigUseCase> private var loadChannelConfigUseCase
    @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
    
    override func loadData(remoteId: Int32) {
        super.loadData(remoteId: remoteId)
        
        channelConfigEventsManager.observeConfig(id: remoteId)
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] _ in self?.reloadMeasurements() }
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
            loadChannelMeasurementsDateRangeUseCase.invoke(remoteId: remoteId),
            loadChannelConfigUseCase.invoke(remoteId: remoteId)
        ) { (self.createChartData($0, DaysRange(start: spec.startDate, end: spec.endDate), chartRange, spec.aggregation, $2), $1) }
    }
    
    func reloadMeasurements() {
        guard let remoteId = currentState()?.remoteId else { return }
        loadChannelConfigUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] in
                    if let config = $0 as? SuplaChannelGeneralPurposeBaseConfig {
                        self?.updateView {
                            self?.triggerMeasurementsLoad(state: $0)
                            return $0.changing(path: \.showHistory, to: config.keepHistory)
                                .changing(path: \.downloadState, to: .finished)
                        }
                    }
                }
            )
            .disposed(by: self)
    }
    
    override func handleData(channel: ChannelWithChildren, channelDto: ChannelDto, chartState: ChartState?) {
        updateView {
            $0.changing(path: \.profileId, to: channel.channel.profile.id)
                .changing(path: \.channelFunction, to: channel.channel.func)
        }
        
        restoreRange(chartState: chartState)
        if ((channel.channel.config?.configAsSuplaConfig() as? SuplaChannelGeneralPurposeBaseConfig)?.keepHistory == true) {
            configureDownloadObserver(channel: channel.channel)
            startInitialDataLoad(channel)
        } else {
            updateView {
                $0.changing(path: \.showHistory, to: false)
                    .changing(path: \.downloadState, to: .finished)
                    .changing(path: \.chartStyle, to: .gpm)
            }
            if let state = currentState() {
                triggerMeasurementsLoad(state: state)
            }
        }
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
    
    private func createChartData(
        _ sets: ChannelChartSets,
        _ daysRange: DaysRange,
        _ chartRange: ChartRange,
        _ aggregation: ChartDataAggregation,
        _ config: SuplaChannelConfig?
    ) -> ChartData {
        if let config = config as? SuplaChannelGeneralPurposeMeterConfig {
            switch (config.chartType) {
            case .bar: return BarChartData(daysRange, chartRange, aggregation, [sets])
            case .linear: return LineChartData(daysRange, chartRange, aggregation, [sets])
            }
        }
        
        if let config = config as? SuplaChannelGeneralPurposeMeasurementConfig {
            switch (config.chartType) {
            case .bar: return BarChartData(daysRange, chartRange, aggregation, [sets])
            case .linear: return LineChartData(daysRange, chartRange, aggregation, [sets])
            case .candle: return CandleChartData(daysRange, chartRange, aggregation, [sets])
            }
        }
        
        return LineChartData(daysRange, chartRange, aggregation, [sets])
    }
}
