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

class BaseHistoryDetailVM: BaseViewModel<BaseHistoryDetailViewState, BaseHistoryDetailViewEvent> {
    @Singleton<DateProvider> var dateProvider
    @Singleton<UserStateHolder> var userStateHolder
    @Singleton<ProfileRepository> var profileRepository
    @Singleton<DeleteChannelMeasurementsUseCase> var deleteChannelMeasurementsUseCase
    
    var chartStyle: any ChartStyle {
        ThermometerChartStyle()
    }
    
    var aggregations: [ChartDataAggregation] {
        ChartDataAggregation.defaultEntries
    }
    
    override func defaultViewState() -> BaseHistoryDetailViewState { BaseHistoryDetailViewState() }
    
    func triggerDataLoad(remoteId: Int32) {
        fatalError("triggedDataLoad(remoteId:) needs to be implemented")
    }
    
    func measurementsObservable(remoteId: Int32, spec: ChartDataSpec, chartRange: ChartRange) -> Observable<(ChartData, DaysRange?)> {
        fatalError("measurementsObservable(remoteId: start: end: aggregation:) needs to be implemented")
    }
    
    func loadData(remoteId: Int32) {
        updateView { $0.changing(path: \.remoteId, to: remoteId).changing(path: \.loading, to: true) }
        triggerDataLoad(remoteId: remoteId)
    }
    
    func refresh() {
        updateView {
            $0.changing(path: \.loading, to: true)
                .changing(path: \.initialLoadStarted, to: false)
                .changing(path: \.chartData, to: $0.chartData.empty())
        }
        if let remoteId = currentState()?.remoteId {
            triggerDataLoad(remoteId: remoteId)
        }
    }
    
    func changeSetActive(remoteId: Int32, type: ChartEntryType) {
        send(event: .clearHighlight)
        updateView { state in
            guard let channelSets = state.chartData.sets.first(where: { $0.remoteId == remoteId }) else { return state }
            
            if (channelSets.hasCustomFilters == true) {
                send(event: .showDataSelectionDialog(channelSets: channelSets, filters: state.chartCustomFilters))
                return state
            } else if (state.chartData.onlyOneSetAndActive) {
                return state
            } else {
                let chartData = state.chartData.toggleActive(remoteId: remoteId, type: type)
                return state.changing(path: \.chartData, to: chartData)
                    .changing(
                        path: \.withRightAxis,
                        to: chartData.withRightAxis
                    )
                    .changing(
                        path: \.withLeftAxis,
                        to: chartData.withLeftAxis
                    )
            }
        }
        updateUserState()
    }
    
    func changeRange(range: ChartRange) {
        if (range == .custom) {
            updateView {
                // For custom range no reload is needed
                $0.changing(path: \.ranges, to: $0.ranges?.changing(path: \.selected, to: range))
            }
        } else {
            updateView { state in
                guard let currentRange = state.range,
                      let minDate = state.minDate,
                      let maxDate = state.maxDate
                else { return state }
                
                let currentDate = dateProvider.currentDate()
                
                var rangeStart = getStartDateForRange(range, currentRange.end, currentDate, currentRange.start, minDate)
                var rangeEnd = getEndDateForRange(range, currentRange.end, currentDate, currentRange.end, maxDate)
                if (rangeStart.timeIntervalSince1970 > maxDate.timeIntervalSince1970) {
                    rangeStart = getStartDateForRange(range, maxDate, currentDate, maxDate.dayStart(), minDate)
                    rangeEnd = getEndDateForRange(range, maxDate, currentDate, maxDate.dayEnd(), maxDate)
                }
                
                let newRange = DaysRange(start: rangeStart, end: rangeEnd)
                
                return state
                    .changing(path: \.ranges, to: state.ranges?.changing(path: \.selected, to: range))
                    .changing(path: \.range, to: newRange)
                    .changing(path: \.aggregations, to: aggregations(newRange, state.aggregations?.selected, state.chartCustomFilters?.filters))
                    .changing(path: \.chartData, to: state.chartData.empty())
                    .changing(path: \.chartParameters, to: HideableValue(ChartParameters(scaleX: 1, scaleY: 1, x: 0, y: 0)))
                    .changing(path: \.loading, to: true)
            }
            
            if let state = currentState() { triggerMeasurementsLoad(state: state) }
        }
        updateUserState()
    }
    
    func moveRangeLeft() {
        shiftByRange(forward: false)
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
        updateUserState()
    }
    
    func moveRangeRight() {
        shiftByRange(forward: true)
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
        updateUserState()
    }
    
    func moveToDataBegin() {
        updateView {
            moveToDate(state: $0, date: $0.minDate)
        }
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
        updateUserState()
    }
    
    func moveToDataEnd() {
        updateView {
            moveToDate(state: $0, date: $0.maxDate)
        }
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
        updateUserState()
    }
    
    func changeAggregation(aggregation: ChartDataAggregation) {
        updateView {
            let aggregations = $0.aggregations?.changing(path: \.selected, to: aggregation)
            return $0.changing(path: \.aggregations, to: aggregations)
                .changing(path: \.loading, to: true)
        }
        
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
        updateUserState()
    }
    
    func updateChartPosition(parameters: ChartParameters) {
        updateView {
            $0.changing(path: \.chartParameters, to: HideableValue(parameters, hide: true))
        }
        updateUserState()
    }
    
    func loadChartState(_ profileId: String, _ remoteId: Int32) -> ChartState {
        userStateHolder.getDefaultChartState(profileId: profileId, remoteId: remoteId)
    }
    
    func triggerMeasurementsLoad(state: BaseHistoryDetailViewState) {
        guard let start = state.range?.start,
              let end = state.range?.end,
              let remoteId = state.remoteId,
              let profileId = state.profileId,
              let chartRange = state.ranges?.selected
        else {
            return
        }
        let aggregation = state.aggregations?.selected ?? .minutes
        let filters = state.chartCustomFilters?.filters
        let spec = ChartDataSpec(startDate: start, endDate: end, aggregation: aggregation, customFilters: filters)
        measurementsObservable(
            remoteId: remoteId,
            spec: spec,
            chartRange: chartRange
        )
        .asDriverWithoutError()
        .drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.handleMeasurements(
                data: $0.0,
                range: $0.1,
                chartState: self.loadChartState(profileId, remoteId)
            )
        })
        .disposed(by: self)
    }
    
    func restoreRange(chartState: ChartState?) {
        guard let chartState = chartState else { return }
        let selectedRange = chartState.chartRange
        let chartParameters = chartState.chartParameters != nil ? HideableValue(chartState.chartParameters!) : nil
        
        let dateRange: DaysRange = getDateRangeForChartRange(selectedRange, chartState.dateRange)
        
        updateView {
            $0.changing(path: \.ranges, to: SelectableList(selected: selectedRange, items: ChartRange.allCases))
                .changing(path: \.aggregations, to: aggregations(dateRange, chartState.aggregation, $0.chartCustomFilters?.filters))
                .changing(path: \.range, to: dateRange)
                .changing(path: \.chartParameters, to: chartParameters)
        }
    }
    
    func handleDownloadEvents(downloadState: DownloadEventsManagerState?) {
        switch (downloadState) {
        case .inProgress(_), .started:
            updateView {
                $0.changing(path: \.downloadState, to: downloadState)
                    .changing(path: \.loading, to: true)
            }
        case .finished:
            updateView {
                triggerMeasurementsLoad(state: $0)
                return $0.changing(path: \.downloadState, to: downloadState)
            }
        case .refresh:
            refresh()
        default:
            updateView {
                $0.changing(path: \.downloadState, to: downloadState)
                    .changing(path: \.loading, to: false)
            }
        }
    }
    
    func customRangeEditDate(_ type: RangeValueType) {
        updateView {
            $0.changing(path: \.editDate, to: type)
        }
    }
    
    func customRangeEditCancel() {
        updateView {
            $0.changing(path: \.editDate, to: nil)
        }
    }
    
    func customRangeEditSave(_ date: Date?) {
        updateView { state in
            guard
                let editValueType = state.editDate,
                let range = state.range,
                let date = date
            else { return state }
            
            let newRange = switch (editValueType) {
            case .start: DaysRange(start: date, end: range.end)
            case .end: DaysRange(start: range.start, end: date)
            }
            
            return state
                .changing(path: \.range, to: newRange)
                .changing(path: \.aggregations, to: aggregations(newRange, state.aggregations?.selected, state.chartCustomFilters?.filters))
                .changing(path: \.chartData, to: state.chartData.empty())
                .changing(path: \.chartParameters, to: HideableValue(ChartParameters(scaleX: 1, scaleY: 1, x: 0, y: 0)))
                .changing(path: \.loading, to: true)
                .changing(path: \.editDate, to: nil)
        }
        
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
        updateUserState()
    }
    
    func deleteAndDownloadData(remoteId: Int32) {
        if let state = currentState(),
           state.downloadState?.isInProgress() == true
        {
            send(event: .showDownloadInProgress)
            return
        }
        
        updateView {
            $0.changing(path: \.loading, to: true)
                .changing(path: \.initialLoadStarted, to: false)
                .changing(path: \.chartData, to: $0.chartData.empty())
        }
        
        deleteChannelMeasurementsUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(
                onCompleted: { [weak self] in self?.triggerDataLoad(remoteId: remoteId) }
            )
            .disposed(by: self)
    }
    
    func aggregations(
        _ currentRange: DaysRange,
        _ selectedAggregation: ChartDataAggregation? = .minutes,
        _ customFilters: ChartDataSpec.Filters?
    ) -> SelectableList<ChartDataAggregation> {
        let minAggregation = currentRange.minAggregation
        let maxAggregation = currentRange.maxAggregation
        let aggregation = selectedAggregation?.between(min: minAggregation, max: maxAggregation) == true ? selectedAggregation! : minAggregation
        
        return SelectableList(
            selected: aggregation,
            items: aggregations.filter { $0.between(min: minAggregation, max: maxAggregation) }
        )
    }
    
    private func getDateRangeForChartRange(_ chartRange: ChartRange, _ dateRange: DaysRange?) -> DaysRange {
        let date = dateProvider.currentDate()
        return switch (chartRange) {
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter:
            DaysRange(start: date.shift(days: -chartRange.roundedDaysCount), end: date)
        default:
            dateRange ?? DaysRange(start: date.shift(days: -chartRange.roundedDaysCount), end: date)
        }
    }
    
    private func getStartDateForRange(_ range: ChartRange, _ date: Date, _ currentDate: Date, _ dateForCustom: Date, _ minDate: Date) -> Date {
        switch (range) {
        case .day: date.dayStart()
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter: currentDate.shift(days: -range.roundedDaysCount)
            
        case .week: date.weekStart()
        case .month: date.monthStart()
        case .quarter: date.quarterStart()
        case .year: date.yearStart()
        case .custom: dateForCustom
        case .allHistory: minDate
        }
    }
    
    private func getEndDateForRange(_ range: ChartRange, _ date: Date, _ currentDate: Date, _ dateForCustom: Date, _ maxDate: Date) -> Date {
        switch (range) {
        case .day: date.dayEnd()
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter: currentDate
            
        case .week: date.weekEnd()
        case .month: date.monthEnd()
        case .quarter: date.quarterEnd()
        case .year: date.yearEnd()
        case .custom: dateForCustom
        case .allHistory: maxDate
        }
    }
    
    private func shiftByRange(forward: Bool) {
        updateView {
            guard let range = $0.ranges?.selected else { return $0 }
            return $0.shiftRange(chartRange: range, forward: forward)
                .changing(path: \.loading, to: true)
                .changing(path: \.chartData, to: $0.chartData.empty())
        }
    }
    
    private func moveToDate(state: BaseHistoryDetailViewState, date: Date?) -> BaseHistoryDetailViewState {
        guard let range = state.ranges?.selected else { return state }
        
        let rangeStart: Date? = switch (range) {
        case .day: date?.dayStart()
        case .week: date?.weekStart()
        case .month: date?.monthStart()
        case .quarter: date?.quarterStart()
        case .year: date?.yearStart()
        default: nil
        }
        
        let rangeEnd: Date? = switch (range) {
        case .day: date?.dayEnd()
        case .week: date?.weekEnd()
        case .month: date?.monthEnd()
        case .quarter: date?.quarterEnd()
        case .year: date?.yearEnd()
        default: nil
        }
        
        guard let start = rangeStart,
              let end = rangeEnd else { return state }
        
        return state.changing(path: \.range, to: DaysRange(start: start, end: end))
            .changing(path: \.chartData, to: state.chartData.empty())
            .changing(path: \.loading, to: true)
    }
    
    private func handleMeasurements(data: ChartData, range: DaysRange?, chartState: ChartState) {
        updateView {
            let dataWithActiveSet = data.activateSets(visibleSets: chartState.visibleSets)
            
            return $0.changing(path: \.chartData, to: dataWithActiveSet)
                .changing(path: \.withRightAxis, to: dataWithActiveSet.withRightAxis)
                .changing(path: \.withLeftAxis, to: dataWithActiveSet.withLeftAxis)
                .changing(path: \.maxLeftAxis, to: dataWithActiveSet.getAxisMaxValue { $0.leftAxis() })
                .changing(path: \.minLeftAxis, to: dataWithActiveSet.getAxisMinValueRaw { $0.leftAxis() })
                .changing(path: \.maxRightAxis, to: dataWithActiveSet.getAxisMaxValue { $0.rightAxis() })
                .changing(path: \.minDate, to: range?.start ?? $0.minDate)
                .changing(path: \.maxDate, to: range?.end ?? $0.maxDate)
                .changing(path: \.loading, to: false)
        }
    }
    
    func exportChartState(_: BaseHistoryDetailViewState) -> ChartState? {
        guard let state = currentState(),
              let aggregation = state.aggregations?.selected,
              let chartRange = state.ranges?.selected,
              let dateRange = state.range else { return nil }
        
        return DefaultChartState(
            aggregation: aggregation,
            chartRange: chartRange,
            dateRange: dateRange,
            chartParameters: state.chartParameters?.value,
            visibleSets: state.chartData.visibleSets
        )
    }
    
    func updateUserState() {
        guard let state = currentState(),
              let chartState = exportChartState(state),
              let profileId = state.profileId,
              let remoteId = state.remoteId else { return }
        
        @Singleton<UserStateHolder> var userStateHolder
        
        userStateHolder.setChartState(
            chartState,
            profileId: profileId,
            remoteId: remoteId
        )
    }
}

enum BaseHistoryDetailViewEvent: ViewEvent {
    case clearHighlight
    case showDownloadInProgress
    case showDataSelectionDialog(channelSets: ChannelChartSets, filters: CustomChartFiltersContainer?)
}

struct BaseHistoryDetailViewState: ViewState {
    var remoteId: Int32? = nil
    var profileId: String? = nil
    var channelFunction: Int32 = 0
    var downloadConfigured: Bool = false
    var initialLoadStarted: Bool = false
    var chartData: ChartData = EmptyChartData()
    var range: DaysRange? = nil
    var ranges: SelectableList<ChartRange>? = nil
    var aggregations: SelectableList<ChartDataAggregation>? = nil
    var loading: Bool = true
    var downloadState: DownloadEventsManagerState? = nil
    var chartCustomFilters: CustomChartFiltersContainer? = nil
    
    var minDate: Date? = nil
    var maxDate: Date? = nil
    var withLeftAxis: Bool = false
    var withRightAxis: Bool = false
    var maxLeftAxis: Double? = nil
    var minLeftAxis: Double? = nil
    var maxRightAxis: Double? = nil
    var chartParameters: HideableValue<ChartParameters>? = nil
    var showHistory: Bool = true
    
    var editDate: RangeValueType? = nil
    
    var shiftRightEnabled: Bool {
        guard let endDate = range?.end,
              let maxDate = maxDate else { return false }
        return endDate.timeIntervalSince1970 < maxDate.timeIntervalSince1970
    }
    
    var shiftLeftEnabled: Bool {
        guard let startDate = range?.start,
              let minDate = minDate else { return false }
        return startDate.timeIntervalSince1970 > minDate.timeIntervalSince1970
    }
    
    var emptyChartMessage: String {
        @Singleton<ValuesFormatter> var formatter
            
        switch (downloadState) {
        case .started: return Strings.Charts.refreshing
        case .inProgress(let progress):
            let percentage = formatter.percentageToString(progress)
            return "\(Strings.Charts.loading) \(percentage)"
        case .finished:
            if (loading) {
                return Strings.Charts.refreshing
            } else if (chartData.sets.first(where: { $0.active }) == nil) {
                return Strings.Charts.noDataSelected
            } else if (minDate == nil && maxDate == nil) {
                return Strings.Charts.noDataAvailable
            } else {
                return Strings.Charts.noDataInSelectedPeriod
            }
        case .failed: return Strings.Charts.refreshingFailed
        default:
            if (!loading && chartData.sets.isEmpty) {
                return Strings.Charts.noDataAvailable
            } else {
                return Strings.Charts.refreshing
            }
        }
    }
    
    var paginationHidden: Bool {
        guard let range = ranges?.selected else { return true }
            
        return switch (range) {
        case .day, .week, .month, .quarter, .year, .allHistory: false
        default: true
        }
    }
    
    var paginationAllowed: Bool {
        guard let range = ranges?.selected else { return false }
            
        return switch (range) {
        case .day, .week, .month, .quarter, .year: true
        default: false
        }
    }
    
    var dateForEdit: Date? {
        switch (editDate) {
        case .start: range?.start
        case .end: range?.end
        default: nil
        }
    }
    
    func shiftRange(chartRange: ChartRange, forward: Bool) -> BaseHistoryDetailViewState {
        changing(path: \.ranges, to: ranges?.changing(path: \.selected, to: chartRange))
            .changing(path: \.range, to: range?.shift(by: chartRange, forward: forward))
    }
    
    var rangeText: String? {
        @Singleton<ValuesFormatter> var formatter
        
        guard let dateRange = range,
              let chartRange = ranges?.selected
        else { return nil }
        
        return switch (chartRange) {
        case .day: formatter.getDateString(date: dateRange.start)
        case .lastDay: weekdayAndHourString(formatter, dateRange)
            
        case .lastWeek, .lastMonth: dayAndHourString(formatter, dateRange)
            
        case .week, .lastQuarter, .quarter: dateString(formatter, dateRange)
            
        case .month: formatter.getMonthAndYearString(date: dateRange.start)?.capitalized
        case .year: formatter.getYearString(date: dateRange.start)
        case .custom, .allHistory: longDateString(formatter, dateRange)
        }
    }
    
    private func weekdayAndHourString(_ formatter: ValuesFormatter, _ range: DaysRange) -> String {
        let rangeStart = formatter.getDayHourDateString(date: range.start) ?? ""
        let rangeEnd = formatter.getDayHourDateString(date: range.end) ?? ""
        return "\(rangeStart) - \(rangeEnd)"
    }
    
    private func dayAndHourString(_ formatter: ValuesFormatter, _ range: DaysRange) -> String {
        let rangeStart = formatter.getDayAndHourDateString(date: range.start) ?? ""
        let rangeEnd = formatter.getDayAndHourDateString(date: range.end) ?? ""
        return "\(rangeStart) - \(rangeEnd)"
    }
    
    private func dateString(_ formatter: ValuesFormatter, _ range: DaysRange) -> String {
        let rangeStart = formatter.getDateShortString(date: range.start) ?? ""
        let rangeEnd = formatter.getDateShortString(date: range.end) ?? ""
        return "\(rangeStart) - \(rangeEnd)"
    }
    
    private func longDateString(_ formatter: ValuesFormatter, _ range: DaysRange) -> String {
        let rangeStart = formatter.getFullDateString(date: range.start) ?? ""
        let rangeEnd = formatter.getFullDateString(date: range.end) ?? ""
        return "\(rangeStart) - \(rangeEnd)"
    }
}

struct CustomChartFiltersContainer: Equatable {
    let filters: ChartDataSpec.Filters?
    
    static func == (lhs: CustomChartFiltersContainer, rhs: CustomChartFiltersContainer) -> Bool {
        (lhs.filters == nil && rhs.filters == nil) || lhs.filters?.isEqualTo(rhs.filters) == true
    }
}
