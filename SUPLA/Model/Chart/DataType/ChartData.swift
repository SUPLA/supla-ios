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

let CHART_TOP_MARGIN = 0.2

/**
 For bar chart we need to place all values next to each other
 (distance between values must be equal to 1: x2-x1 = 1).
 Otherwise bar chart is not displayed correctly.
 */
protocol CoordinatesConverter {
    var divider: Double { get }

    /**
     Converts from coordinate value to real value.

     - Parameters:
        - x - x to convert
     - Returns: x multiplied by `divider`
     */
    func fromCoordinate(x: Double) -> Double

    /**
     Converts from real value to coordinate value.

     - Parameters:
        - x - x to convert
     - Returns: x divided by `divider`
     */
    func toCoordinate(x: Double) -> Double
}

class CombinedChartData: ChartData {
    func combinedData() -> DGCharts.CombinedChartData? {
        fatalError("combinedData() has not been implented!")
    }
}

class ChartData: CoordinatesConverter, Equatable, CustomStringConvertible {
    var divider: Double { 1.0 }
    
    let dateRange: DaysRange?
    let chartRange: ChartRange?
    let aggregation: ChartDataAggregation?
    let sets: [ChannelChartSets]
    
    init(
        _ dateRange: DaysRange?,
        _ chartRange: ChartRange?,
        _ aggregation: ChartDataAggregation?,
        _ sets: [ChannelChartSets]
    ) {
        self.dateRange = dateRange
        self.chartRange = chartRange
        self.aggregation = aggregation
        self.sets = sets
    }
    
    var description: String {
        "SUPLA.ChartData(dateRange: \(String(describing: dateRange)), chartRange: \(String(describing: chartRange)), aggregation: \(String(describing: aggregation)), sets: \(String(describing: sets)))"
    }
    
    var xMin: Double? {
        if (chartMarginNotNeeded()) {
            return toCoordinate(dateRange?.start.timeIntervalSince1970)
        }
        guard let daysCount = dateRange?.daysCount else { return dateRange?.start.timeIntervalSince1970 }
        return toCoordinate(dateRange?.start.timeIntervalSince1970.minus(chartRangeMargin(daysCount)))
    }
    
    var xMax: Double? {
        if (chartMarginNotNeeded()) {
            return toCoordinate((dateRange?.end.timeIntervalSince1970))
        }
        guard let daysCount = dateRange?.daysCount else { return dateRange?.end.timeIntervalSince1970 }
        return toCoordinate(dateRange?.end.timeIntervalSince1970.plus(chartRangeMargin(daysCount)))
    }
    
    var leftAxisFormatter: ChannelValueFormatter {
        sets.flatMap { $0.dataSets }.first { $0.type.leftAxis() }?.valueFormatter ?? DefaultValueFormatter()
    }
    
    var rightAxisFormatter: ChannelValueFormatter {
        sets.flatMap { $0.dataSets }.first { $0.type.rightAxis() }?.valueFormatter ?? DefaultValueFormatter()
    }
    
    var distanceInDays: Int? { dateRange?.daysCount }
    
    var isEmpty: Bool {
        var empty = true
        
        sets.flatMap { $0.dataSets }
            .forEach {
                if ($0.isEmpty == false) {
                    empty = false
                }
            }
        
        return empty
    }
    
    var noActiveSet: Bool {
        sets.flatMap { $0.dataSets }.first { $0.active } == nil
    }
    
    var onlyOneSetAndActive: Bool {
        sets.count == 1 && sets.first!.dataSets.count == 1 && sets.first!.active
    }
    
    var onlyOneSet: Bool {
        sets.count == 1 && sets.first!.dataSets.count == 1
    }
    
    var visibleSets: [ChartStateVisibleSet] {
        sets.flatMap { set in set.dataSets.map { (set.remoteId, $0.active, $0.type) }}
            .filter { $0.1 }
            .map { ChartStateVisibleSet(id: $0.0, type: $0.2) }
    }
    
    var withRightAxis: Bool {
        sets.flatMap { $0.dataSets }.first(where: { $0.type.rightAxis() && $0.active }) != nil
    }
    
    var withLeftAxis: Bool {
        sets.flatMap { $0.dataSets }.first(where: { $0.type.leftAxis() && $0.active }) != nil
    }
    
    func empty() -> ChartData { newInstance(sets: emptySets()) }
    
    func activateSets(visibleSets: [ChartStateVisibleSet]?) -> ChartData {
        if (onlyOneSet) {
            noActiveSet ? newInstance(sets: sets.map { $0.activate() }) : self
        } else {
            newInstance(
                sets: sets.map { set in
                    if let visibleSets = visibleSets {
                        if (visibleSets.map { $0.id }.contains(set.remoteId)) {
                            set.setActive(types: visibleSets.map(\.type))
                        } else {
                            set.deactivate()
                        }
                    } else {
                        set
                    }
                }
            )
        }
    }
    
    func distanceInDays(start: CGFloat, end: CGFloat) -> Double {
        (fromCoordinate(x: end) - fromCoordinate(x: start)) / 3600 / 24
    }
    
    func toggleActive(remoteId: Int32, type: ChartEntryType) -> ChartData {
        newInstance(sets: sets.map { $0.remoteId == remoteId ? $0.toggleActive(type: type) : $0 })
    }
    
    func fromCoordinate(x: Double) -> Double { x * divider }
    
    func toCoordinate(x: Double) -> Double { toCoordinate(x)! }
    
    func newInstance(sets: [ChannelChartSets]) -> ChartData {
        fatalError("newInstance(sets:) has not been implented!")
    }
    
    func getAxisMaxValue(_ filter: (ChartEntryType) -> Bool) -> Double? {
        if let maxValue = getAxisMaxValueRaw(filter),
           let minValue = getAxisMinValueRaw(filter)
        {
            if (maxValue == minValue) {
                if (maxValue == 0.0) {
                    return 2.0
                } else if (maxValue > 0) {
                    return maxValue + (maxValue * CHART_TOP_MARGIN)
                } else {
                    let result = maxValue - (maxValue * CHART_TOP_MARGIN)
                    return result < 0 ? 0 : result
                }
            } else if (maxValue == 0) {
                return maxValue + (maxValue - minValue) * CHART_TOP_MARGIN
            } else if (maxValue > 0) {
                return maxValue + (maxValue + (minValue > 0 ? 0 : abs(minValue))) * CHART_TOP_MARGIN
            } else {
                let result = maxValue + abs(minValue) * CHART_TOP_MARGIN
                return result < 0 ? 0 : result
            }
        }
        
        return nil
    }
    
    func getAxisMinValueRaw(_ filter: (ChartEntryType) -> Bool) -> Double? {
        sets
            .flatMap { $0.dataSets }
            .filter { filter($0.type) }
            .map { $0.entries.map { $0.map { $0.value.min } }.minOrNull() }
            .minOrNull()
    }
    
    func getAxisMaxValueRaw(_ filter: (ChartEntryType) -> Bool) -> Double? {
        sets
            .flatMap { $0.dataSets }
            .filter { filter($0.type) }
            .map { $0.entries.map { $0.map { $0.value.max } }.maxOrNull() }
            .maxOrNull()
    }
    
    private func toCoordinate(_ x: Double?) -> Double? {
        if let x = x {
            return x / divider
        } else {
            return nil
        }
    }
    
    private func emptySets() -> [ChannelChartSets] { sets.map { $0.empty() } }
    
    private func chartMarginNotNeeded() -> Bool {
        switch (chartRange) {
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter, .lastYear, .custom, .allHistory: false
        default: true
        }
    }
    
    private func chartRangeMargin(_ daysCount: Int) -> Double {
        guard let aggregation = aggregation else {
            return if (daysCount <= 1) {
                60 * 60 // 1 hour in seconds
            } else {
                24 * 60 * 60 // 1 day in seconds
            }
        }
        
        return aggregation.timeInSec * 0.6
    }
    
    static func == (lhs: ChartData, rhs: ChartData) -> Bool {
        lhs.dateRange == rhs.dateRange &&
            lhs.chartRange == rhs.chartRange &&
            lhs.aggregation == rhs.aggregation &&
            lhs.sets == rhs.sets
    }
}

private class DefaultValueFormatter: ChannelValueFormatter {
    func handle(function: Int32) -> Bool { true }
    
    func format(_ value: Any, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        if let doubleValue = value as? Double {
            return String(format: "%.2f", doubleValue)
        }
        if let floatValue = value as? Float {
            return String(format: "%.2f", floatValue)
        }
        if let intValue = value as? Int {
            return "\(intValue)"
        }
        
        return String(describing: value)
    }
    
    func formatChartLabel(_ value: Any, precision: Int, withUnit: Bool) -> String {
        format(value, withUnit: withUnit, precision: .defaultPrecision(value: precision), custom: nil)
    }
}
