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

class BaseHistoryDetailVM: BaseViewModel<BaseHistoryDetailViewState, BaseHistoryDetailViewEvent> {
    
    @Singleton<DateProvider> var dateProvider
    @Singleton<UserStateHolder> var userStateHolder
    @Singleton<ProfileRepository> var profileRepository
    
    override func defaultViewState() -> BaseHistoryDetailViewState { BaseHistoryDetailViewState() }
    
    func triggerDataLoad(remoteId: Int32) {
        fatalError("triggedDataLoad(remoteId:) needs to be implemented")
    }
    
    func measurementsObservable(remoteId: Int32, start: Date, end: Date, aggregation: ChartDataAggregation) -> Observable<([HistoryDataSet], DaysRange?)> {
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
                .changing(path: \.sets, to: $0.sets.map { set in set.changing(path: \.entries, to: []) })
        }
        if let remoteId = currentState()?.remoteId {
            triggerDataLoad(remoteId: remoteId)
        }
    }
    
    func changeSetActive(setId: HistoryDataSet.Id) {
        updateView { state in
            state.changing(
                path: \.sets,
                to: state.sets.map { set in
                    if (set.setId == setId) {
                        set.changing(path: \.active, to: !set.active)
                    } else {
                        set
                    }
                }
            )
        }
        updateUserState()
    }
    
    func changeRange(range: ChartRange) {
        updateView { state in
            guard let currentRange = state.range,
                  let maxDate = state.maxDate
            else { return state }
            
            let currentDate = dateProvider.currentDate()
            
            var rangeStart = getStartDateForRange(range, currentRange.end, currentDate)
            var rangeEnd = getEndDateForRange(range, currentRange.end, currentDate)
            if (rangeStart.timeIntervalSince1970 > maxDate.timeIntervalSince1970) {
                rangeStart = getStartDateForRange(range, maxDate, currentDate)
                rangeEnd = getEndDateForRange(range, maxDate, currentDate)
            }
            
            let newRange = DaysRange(start: rangeStart, end: rangeEnd)
            
            return state
                .changing(path: \.ranges, to: state.ranges?.changing(path: \.selected, to: range))
                .changing(path: \.range, to: newRange)
                .changing(path: \.aggregations, to: aggregations(newRange, state.aggregations?.selected))
                .changing(path: \.sets, to: state.sets.map({ $0.changing(path: \.entries, to: []) }))
                .changing(path: \.chartParameters, to: HideableValue(ChartParameters(scaleX: 1, scaleY: 1, x: 0, y: 0)))
        }
        
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
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
            $0.changing(path: \.aggregations, to: $0.aggregations?.changing(path: \.selected, to: aggregation))
        }
        
        if let state = currentState() { triggerMeasurementsLoad(state: state) }
        updateUserState()
    }
    
    func updateChartPosition(parameters: ChartParameters) {
        updateView {
            return $0.changing(path: \.chartParameters, to: HideableValue(parameters, hide: true))
        }
        updateUserState()
    }
    
    func aggregations(_ currentRange: DaysRange, _ selectedAggregation: ChartDataAggregation? = .minutes) -> SelectableList<ChartDataAggregation> {
        let minAggregation = currentRange.minAggregation
        let maxAggregation = currentRange.maxAggregation
        let aggregation = selectedAggregation?.between(min: minAggregation, max: maxAggregation) == true ? selectedAggregation! : minAggregation
        
        return SelectableList(
            selected: aggregation,
            items: ChartDataAggregation.allCases.filter { $0.between(min: minAggregation, max: maxAggregation) }
        )
    }
    
    func triggerMeasurementsLoad(state: BaseHistoryDetailViewState) {
        guard let start = state.range?.start,
              let end = state.range?.end,
              let remoteId = state.remoteId,
              let profileId = state.profileId
        else {
            return
        }
        let aggregation = state.aggregations?.selected ?? .minutes
        
        measurementsObservable(remoteId: remoteId, start: start, end: end, aggregation: aggregation)
            .asDriverWithoutError()
            .drive(onNext: {
                self.handleMeasurements(
                    sets: $0.0,
                    range: $0.1,
                    chartState: self.userStateHolder.getTemperatureChartState(
                        profileId: profileId,
                        remoteId: remoteId
                    )
                )
            })
            .disposed(by: self)
    }
    
    func restoreRange(chartState: TemperatureChartState) {
        let selectedRange = chartState.chartRange
        let chartParameters = chartState.chartParameters != nil ? HideableValue(chartState.chartParameters!) : nil
        
        let dateRange: DaysRange = getDateRangeForChartRange(selectedRange, chartState.dateRange)
        
        updateView {
            $0.changing(path: \.ranges, to: SelectableList(selected: selectedRange, items: ChartRange.allCases))
                .changing(path: \.aggregations, to: aggregations(dateRange, chartState.aggregation))
                .changing(path: \.range, to: dateRange)
                .changing(path: \.chartParameters, to: chartParameters)
        }
    }
    
    func handleDownloadEvents(downloadState: DownloadEventsManagerState) {
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
        default:
            updateView {
                $0.changing(path: \.downloadState, to: downloadState)
                    .changing(path: \.loading, to: false)
            }
        }
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
    
    private func getStartDateForRange(_ range: ChartRange, _ date: Date, _ currentDate: Date) -> Date {
        switch (range) {
        case .day: date.dayStart()
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter: currentDate.shift(days: -range.roundedDaysCount)
            
        case .week: date.weekStart()
        case .month: date.monthStart()
        case .quarter: date.quarterStart()
        case .year: date.yearStart()
        }
    }
    
    private func getEndDateForRange(_ range: ChartRange, _ date: Date, _ currentDate: Date) -> Date {
        switch (range) {
        case .day: date.dayEnd()
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter: currentDate
            
        case .week: date.weekEnd()
        case .month: date.monthEnd()
        case .quarter: date.quarterEnd()
        case .year: date.yearEnd()
        }
    }
    
    private func shiftByRange(forward: Bool) {
        updateView {
            guard let range = $0.ranges?.selected else { return $0 }
            return $0.shiftRange(chartRange: range, forward: forward)
        }
    }
    
    private func moveToDate(state: BaseHistoryDetailViewState, date: Date?) -> BaseHistoryDetailViewState {
        guard let range = state.ranges?.selected else { return state }
        
        let rangeStart: Date? = switch(range) {
        case .day: date?.dayStart()
        case .week: date?.weekStart()
        case .month: date?.monthStart()
        case .quarter: date?.quarterStart()
        case .year: date?.yearStart()
        default: nil
        }
        
        let rangeEnd: Date? = switch(range) {
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
            .changing(path: \.sets, to: state.sets.map({ $0.changing(path: \.entries, to: [])}))
    }
    
    private func handleMeasurements(sets: [HistoryDataSet], range: DaysRange?, chartState: TemperatureChartState) {
        updateView {
            $0.changing(
                path: \.sets,
                to: sets.map {
                    $0.changing(path: \.active, to: chartState.visibleSets?.contains($0.setId) ?? true)
                }
            )
                .changing(path: \.withHumidity, to: sets.first(where: { $0.setId.type == .humidity}) != nil)
                .changing(
                    path: \.maxTemperature,
                    to: sets.filter { $0.setId.type == .temperature }
                        .map { $0.entries.map { $0.map { $0.y } }.maxOrNull() }.maxOrNull()?.plus(2)
                )
                .changing(path: \.minDate, to: range?.start ?? $0.minDate)
                .changing(path: \.maxDate, to: range?.end ?? $0.maxDate)
                .changing(path: \.loading, to: false)
        }
    }
    
    private func updateUserState() {
        guard let state = currentState(),
              let aggregation = state.aggregations?.selected,
              let chartRange = state.ranges?.selected,
              let dateRange = state.range,
              let profileId = state.profileId,
              let remoteId = state.remoteId else { return }
        let visibleSets = state.sets.filter { $0.active }.map { $0.setId }
        
        userStateHolder.setTemperatureChartState(
            TemperatureChartState(
                aggregation: aggregation,
                chartRange: chartRange,
                dateRange: dateRange,
                chartParameters: state.chartParameters?.value,
                visibleSets: visibleSets
            ),
            profileId: profileId,
            remoteId: remoteId
        )
    }
}

enum BaseHistoryDetailViewEvent: ViewEvent {
}

struct BaseHistoryDetailViewState: ViewState {
    var remoteId: Int32? = nil
    var profileId: String? = nil
    var downloadConfigured: Bool = false
    var initialLoadStarted: Bool = false
    var sets: [HistoryDataSet] = []
    var range: DaysRange? = nil
    var ranges: SelectableList<ChartRange>? = nil
    var aggregations: SelectableList<ChartDataAggregation>? = nil
    var loading: Bool = true
    var downloadState: DownloadEventsManagerState? = nil
    
    var minDate: Date? = nil
    var maxDate: Date? = nil
    var withHumidity: Bool = false
    var maxTemperature: Double? = nil
    var chartParameters: HideableValue<ChartParameters>? = nil
    
    var combinedData: CombinedChartData? {
        get {
            var lineDataSets: [LineChartDataSet] = []
            sets.forEach { set in
                if (set.active && !set.entries.isEmpty) {
                    set.entries.forEach {
                        lineDataSets.append(lineDataSet(set: $0, color: set.color, type: set.setId.type))
                    }
                }
            }
            
            if (lineDataSets.isEmpty) {
                return nil
            } else {
                let data = CombinedChartData()
                data.lineData = LineChartData(dataSets: lineDataSets)
                return data
            }
        }
    }
    
    var shiftRightEnabled: Bool {
        get {
            guard let endDate = range?.end,
                  let maxDate = maxDate else { return false }
            return endDate.timeIntervalSince1970 < maxDate.timeIntervalSince1970
        }
    }
    
    var shiftLeftEnabled: Bool {
        get {
            guard let startDate = range?.start,
                  let minDate = minDate else { return false }
            return startDate.timeIntervalSince1970 > minDate.timeIntervalSince1970
        }
    }
    
    var emptyChartMessage: String {
        get {
            @Singleton<ValuesFormatter> var formatter
            
            switch (downloadState) {
            case .started: return Strings.Charts.refreshing
            case .inProgress(let progress):
                let percentage = formatter.percentageToString(value: progress)
                return "\(Strings.Charts.loading) \(percentage)"
            case .finished:
                if (loading) {
                    return Strings.Charts.refreshing
                } else if (sets.first(where: { $0.active }) == nil) {
                    return Strings.Charts.noDataSelected
                } else if (minDate == nil && maxDate == nil) {
                    return Strings.Charts.noDataAvailable
                } else {
                    return Strings.Charts.noDataInSelectedPeriod
                }
            case .failed: return Strings.Charts.refreshingFailed
            default: return Strings.Charts.refreshing
            }
        }
    }
    
    var paginationHidden: Bool {
        get {
            guard let range = ranges?.selected else { return true }
            
            return switch (range) {
            case .day, .week, .month, .quarter, .year: false
            default: true
            }
        }
    }
    
    var xMin: Double? {
        get {
            if (chartMarginNotNeeded()) {
                return range?.start.timeIntervalSince1970
            }
            guard let daysCount = range?.daysCount else { return range?.start.timeIntervalSince1970 }
            return range?.start.timeIntervalSince1970.minus(chartRnageMargin(daysCount))
        }
    }
    
    var xMax: Double? {
        get {
            if (chartMarginNotNeeded()) {
                return range?.end.timeIntervalSince1970
            }
            guard let daysCount = range?.daysCount else { return range?.end.timeIntervalSince1970 }
            return range?.end.timeIntervalSince1970.plus(chartRnageMargin(daysCount))
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
            
        case .week, .month, .lastQuarter, .quarter: dateString(formatter, dateRange)
            
        case .year: formatter.getYearString(date: dateRange.start)
        }
    }
    
    private func chartRnageMargin(_ daysCount: Int) -> Double {
        return if (daysCount <= 1) {
            60 * 60 // 1 hour in seconds
        } else {
            24 * 60 * 60 // 1 day in seconds
        }
    }
    
    private func chartMarginNotNeeded() -> Bool {
        switch (ranges?.selected) {
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter: false
        default: true
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
}

fileprivate func lineDataSet(set: [ChartDataEntry], color: UIColor, type: ChartEntryType) -> LineChartDataSet {
    let set = LineChartDataSet(entries: set, label: "")
    set.drawValuesEnabled = false
    set.mode = .horizontalBezier
    set.cubicIntensity = 0.05
    set.colors = [color]
    set.circleColors = [color]
    set.drawCircleHoleEnabled = false
    set.circleRadius = 1.5
    switch (type) {
    case .temperature: set.axisDependency = .left
    case .humidity: set.axisDependency = .right
    }
    return set
}
