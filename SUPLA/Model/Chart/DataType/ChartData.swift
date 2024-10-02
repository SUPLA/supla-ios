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

class ChartData: CoordinatesConverter, Equatable {
    var divider: Double { 1.0 }
    
    let dateRange: DaysRange?
    let chartRange: ChartRange?
    let aggregation: ChartDataAggregation?
    let sets: [HistoryDataSet]
    
    var isEmpty: Bool {
        var empty = true
        if (sets.isEmpty) {
            return empty
        }
        
        for set in sets {
            if (!set.entries.isEmpty) {
                empty = false
                continue
            }
        }
        return empty
    }

    init(
        _ dateRange: DaysRange?,
        _ chartRange: ChartRange?,
        _ aggregation: ChartDataAggregation?,
        _ sets: [HistoryDataSet]
    ) {
        self.dateRange = dateRange
        self.chartRange = chartRange
        self.aggregation = aggregation
        self.sets = sets
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
        sets.first { $0.setId.type.leftAxis() }?.valueFormatter ?? DefaultValueFormatter()
    }
    
    var rightAxisFormatter: ChannelValueFormatter {
        sets.first { $0.setId.type.rightAxis() }?.valueFormatter ?? DefaultValueFormatter()
    }
    
    var distanceInDays: Int? { dateRange?.daysCount }
    
    func empty() -> ChartData { newInstance(sets: sets.map { $0.changing(path: \.entries, to: []) }) }
    
    func activateSet(setId: HistoryDataSet.Id) -> ChartData {
        newInstance(
            sets: sets.map {
                if ($0.setId == setId) {
                    return $0.changing(path: \.active, to: !$0.active)
                } else {
                    return $0
                }
            }
        )
    }
    
    func activateSets(setIds: [HistoryDataSet.Id]?) -> ChartData {
        newInstance(sets: sets.map { $0.changing(path: \.active, to: setIds?.contains($0.setId) ?? true) })
    }
    
    func combinedData() -> CombinedChartData? {
        fatalError("combinedData() has not been implented!")
    }
    
    func fromCoordinate(x: Double) -> Double { x * divider }
    
    func toCoordinate(x: Double) -> Double { toCoordinate(x)! }
    
    func newInstance(sets: [HistoryDataSet]) -> ChartData {
        fatalError("newInstance(sets:) has not been implented!")
    }
    
    func getAxisMaxValue(_ filter: (ChartEntryType) -> Bool) -> Double? {
        if let maxValue = getAxisMaxValueRaw(filter),
           let minValue = getAxisMinValueRaw(filter)
        {
            if (maxValue == minValue) {
                if (maxValue == 0.0) {
                    return 2.0
                } else {
                    return maxValue - (maxValue * CHART_TOP_MARGIN)
                }
            } else {
                return (maxValue * (CHART_TOP_MARGIN + 1)) - (minValue * CHART_TOP_MARGIN)
            }
        }
        
        return nil
    }
    
    func getAxisMinValueRaw(_ filter: (ChartEntryType) -> Bool) -> Double? {
        sets
            .filter { filter($0.setId.type) }
            .map { $0.entries.map { $0.map { $0.value } }.minOrNull() }
            .minOrNull()
    }
    
    func getAxisMaxValueRaw(_ filter: (ChartEntryType) -> Bool) -> Double? {
        sets
            .filter { filter($0.setId.type) }
            .map { $0.entries.map { $0.map { $0.value } }.maxOrNull() }
            .maxOrNull()
    }
    
    private func toCoordinate(_ x: Double?) -> Double? {
        if let x = x {
            return x / divider
        } else {
            return nil
        }
    }
    
    private func emptySets() -> [HistoryDataSet] { sets.map { $0.changing(path: \.entries, to: []) } }
    
    private func chartMarginNotNeeded() -> Bool {
        switch (chartRange) {
        case .lastDay, .lastWeek, .lastMonth, .lastQuarter, .custom, .allHistory: false
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
    func handle(function: Int) -> Bool { true }
    
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
}
