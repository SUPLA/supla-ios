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
    
extension ElectricityMeterHistoryFeature {
    class ViewModel: BaseHistoryDetailVM {
        @Singleton<GlobalSettings> private var settings
        @Singleton<SuplaCloudService> private var cloudService
        @Singleton<DownloadEventsManager> private var downloadEventsManager
        @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
        @Singleton<LoadChannelMeasurementsDateRangeUseCase> private var loadChannelMeasurementsDateRangeUseCase
        
        var introductionState = IntroductionState()
        
        private var downloadEventsDisposable: Disposable? = nil
        
        private var dataType: DownloadEventsManagerDataType {
            switch ((currentState()?.chartCustomFilters?.filters as? ElectricityChartFilters)?.type) {
            case .voltage: .electricityVoltage
            case .current: .electricityCurrent
            case .powerActive: .electricityPowerActive
            default: .default
            }
        }
        
        override var aggregations: [ChartDataAggregation] {
            ChartDataAggregation.allCases
        }
        
        override func loadChartState(_ profileId: Int32, _ remoteId: Int32) -> ChartState {
            userStateHolder.getElectricityChartState(profileId: profileId, remoteId: remoteId)
                .copy(visibleSets: .value(nil))
        }
        
        override func exportChartState(_: BaseHistoryDetailViewState) -> ChartState? {
            guard let state = currentState(),
                  let aggregation = state.aggregations?.selected,
                  let chartRange = state.ranges?.selected,
                  let dateRange = state.range else { return nil }
            
            return ElectricityChartState(
                aggregation: aggregation,
                chartRange: chartRange,
                dateRange: dateRange,
                chartParameters: state.chartParameters?.value,
                visibleSets: state.chartData.visibleSets,
                customFilters: state.chartCustomFilters?.filters as? ElectricityChartFilters
            )
        }
        
        override func measurementsObservable(remoteId: Int32, spec: ChartDataSpec, chartRange: ChartRange) -> Observable<(ChartData, DaysRange?)> {
            loadChannelMeasurementsDateRangeUseCase.invoke(remoteId: remoteId, type: dataType)
                .flatMapFirst { range in
                    // while the data range is changing (voltage, current, power active has different range) it has to be corrected
                    let correctedSpec = chartRange == .allHistory ? spec.correctBy(range: range) : spec
                    @Singleton<LoadChannelMeasurementsUseCase> var loadChannelMeasurementsUseCase
                    return loadChannelMeasurementsUseCase.invoke(remoteId: remoteId, spec: correctedSpec)
                        .map { (getChartData(correctedSpec, chartRange, $0), range) }
                }
        }
        
        override func aggregations(
            _ currentRange: DaysRange,
            _ selectedAggregation: ChartDataAggregation? = .minutes,
            _ customFilters: (any ChartDataSpec.Filters)?
        ) -> SelectableList<ChartDataAggregation> {
            let rawAggregations = super.aggregations(currentRange, selectedAggregation, customFilters)
            
            guard let filters = customFilters as? ElectricityChartFilters
            else { return rawAggregations }
            
            let aggregations = filterRank(filters, rawAggregations)
            
            return if filters.type == .balanceHourly && aggregations.items.contains(.minutes) {
                SelectableList(
                    selected: aggregations.selected == .minutes ? .hours : aggregations.selected,
                    items: aggregations.items.filter { $0 != .minutes }
                )
            } else if (filters.type == .voltage || filters.type == .current || filters.type == .powerActive ) {
                // There are to many items to display and charts are not able to handel it, so for range longer than 1 day we skip minutes
                if (currentRange.daysCount > 1) {
                    SelectableList(
                        selected: aggregations.selected == .minutes ? .hours : aggregations.selected,
                        items: aggregations.items.filter { $0 != .minutes }
                    )
                } else {
                    aggregations
                }
            } else {
                aggregations
            }
        }
        
        func onDataSelectionChange(type: ElectricityMeterChartType, phases: [Phase]) {
            var previousType: ElectricityMeterChartType? = nil
            
            updateView { state in
                guard let dateRange = state.range,
                      let filters = state.chartCustomFilters?.filters as? ElectricityChartFilters
                else { return state }
                
                previousType = filters.type
                let customFilters = filters.copy(type: type, selectedPhases: phases)
                return state
                    .changing(path: \.chartCustomFilters, to: CustomChartFiltersContainer(filters: customFilters))
                    .changing(path: \.loading, to: true)
                    .changing(path: \.initialLoadStarted, to: false)
                    .changing(path: \.aggregations, to: aggregations(dateRange, state.aggregations?.selected, customFilters))
                    .changing(path: \.chartData, to: state.chartData.empty())
            }
            updateUserState()
            
            if previousType?.needsRefresh(type) != false {
                refresh()
            } else {
                if let state = currentState() {
                    triggerMeasurementsLoad(state: state)
                }
            }
        }
        
        func closeIntroductionView() {
            settings.showEmHistoryIntroduction = false
            updateView { $0.changing(path: \.showIntroduction, to: false) }
        }
        
        override func cloudChannelProvider(_ channelWithChildren: ChannelWithChildren) -> Observable<ChannelDto> {
            let remoteId = channelWithChildren.children
                .first { $0.relationType == .meter }?.channel.remote_id ?? channelWithChildren.remoteId
            
            return cloudService.getElectricityMeterChannel(remoteId: remoteId).map { $0 }
        }
        
        override func handleData(channel: ChannelWithChildren, channelDto: ChannelDto, chartState: ChartState?) {
            updateView {
                $0.changing(path: \.profileId, to: channel.channel.profile.id)
                    .changing(path: \.channelFunction, to: channel.channel.func)
            }
            let electricityMeterConfigDto = (channelDto as? ElectricityChannelDto)?.config
            
            restoreCustomFilters(channel.channel.flags, channel.channel.ev?.electricityMeter(), electricityMeterConfigDto, chartState)
            restoreRange(chartState: chartState)
            configureDownloadObserver(channel: channel.channel)
            startInitialDataLoad(channel)
            
            if settings.showEmHistoryIntroduction {
                let moreThanOnePhase = Phase.allCases
                    .filter { channel.channel.flags & $0.disabledFlag == 0 }
                    .count > 1
                introductionState.pages = moreThanOnePhase ? [.firstForMultiplePhases, .second] : [.firstForSinglePhase, .second]
            }
            updateView { $0.changing(path: \.showIntroduction, to: settings.showEmHistoryIntroduction) }
        }
        
        private func configureDownloadObserver(channel: SAChannel) {
            if currentState()?.downloadConfigured == true {
                // Needs to be performed only once
                return
            }
            
            downloadEventsDisposable?.dispose()
            updateView { $0.changing(path: \.downloadConfigured, to: true) }
            
            downloadEventsDisposable = downloadEventsManager.observeProgress(remoteId: channel.remote_id, dataType: dataType)
                .distinctUntilChanged()
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleDownloadEvents(downloadState: $0) })
        }
        
        private func startInitialDataLoad(_ channelWithChildren: ChannelWithChildren) {
            if currentState()?.initialLoadStarted == true {
                return
            }
            updateView { $0.changing(path: \.initialLoadStarted, to: true) }
            downloadChannelMeasurementsUseCase.invoke(channelWithChildren, type: dataType)
        }
        
        private func restoreCustomFilters(
            _ flags: Int64,
            _ value: SAElectricityMeterExtendedValue?,
            _ configDto: ElectricityMeterConfigDto?,
            _ state: ChartState?
        ) {
            updateView {
                let customFilters = ElectricityChartFilters.restore(flags: flags, value: value, configDto: configDto, state: state)
                let chartStyle: ChartStyle =
                    switch customFilters.type {
                    case .voltage, .current, .powerActive: .electricityHistory
                    default: .electricity
                    }
                
                return $0.changing(path: \.chartCustomFilters, to: CustomChartFiltersContainer(filters: customFilters))
                    .changing(path: \.chartStyle, to: chartStyle)
            }
        }
        
        private func filterRank(
            _ filters: ElectricityChartFilters,
            _ aggregations: SelectableList<ChartDataAggregation>
        ) -> SelectableList<ChartDataAggregation> {
            if filters.type.hideRankings {
                let items = aggregations.items.filter { !$0.isRank }
                let selected = aggregations.selected.isRank ? items.first! : aggregations.selected
                
                return SelectableList(selected: selected, items: items)
            } else {
                return aggregations
            }
        }
        
        deinit {
            downloadEventsDisposable?.dispose()
        }
    }
}

private func getChartData(_ spec: ChartDataSpec, _ chartRange: ChartRange, _ sets: [ChannelChartSets]) -> ChartData {
    if (spec.isVoltageType || spec.isCurrentType || spec.isPowerActiveType) {
        LineChartData(DaysRange(start: spec.startDate, end: spec.endDate), chartRange, spec.aggregation, sets)
    } else if spec.aggregation.isRank {
        PieChartData(DaysRange(start: spec.startDate, end: spec.endDate), chartRange, spec.aggregation, sets)
    } else {
        BarChartData(DaysRange(start: spec.startDate, end: spec.endDate), chartRange, spec.aggregation, sets)
    }
}

private extension ChartDataSpec {
    var isVoltageType: Bool {
        (customFilters as? ElectricityChartFilters)?.type == .voltage
    }
    
    var isCurrentType: Bool {
        (customFilters as? ElectricityChartFilters)?.type == .current
    }
    
    var isPowerActiveType: Bool {
        (customFilters as? ElectricityChartFilters)?.type == .powerActive
    }
}
