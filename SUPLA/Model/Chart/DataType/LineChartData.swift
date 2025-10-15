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

import DGCharts

final class LineChartData: CombinedChartData {
    override func combinedData() -> DGCharts.CombinedChartData? {
        var lineDataSets: [LineChartDataSet] = []
        sets.flatMap { $0.dataSets }
            .forEach {
                if let set = $0.asLineChartData(aggregation: aggregation!) {
                    lineDataSets.append(contentsOf: set)
                }
            }

        if (lineDataSets.isEmpty) {
            return nil
        }

        let data = DGCharts.CombinedChartData()
        data.lineData = DGCharts.LineChartData(dataSets: lineDataSets)
        return data
    }

    override func newInstance(sets: [ChannelChartSets]) -> ChartData {
        LineChartData(dateRange, chartRange, aggregation, sets)
    }
}

private extension HistoryDataSet {
    func asLineChartData(aggregation: ChartDataAggregation) -> [LineChartDataSet]? {
        if (!active || entries.isEmpty) {
            return nil
        }

        return entries
            .map { aggregatedEntries in
                lineDataSet(
                    set: aggregatedEntries.map {
                        ChartDataEntry(x: $0.date, y: $0.value.y, data: toChartDetails(aggregation: aggregation, entity: $0))
                    },
                    label: label,
                    type: type
                )
            }
    }
}

private extension AggregatedValue {
    var y: Double {
        switch (self) {
        case .single(let value, _, _, _, _): return value
        case .multiple(let values): return values.reduce(0, +)
        case .withPhase(let value, _, _, _): return value
        }
    }
}

private func lineDataSet(set: [ChartDataEntry], label: HistoryDataSet.Label, type: ChartEntryType) -> LineChartDataSet {
    let set = LineChartDataSet(entries: set, label: "")
    set.drawValuesEnabled = false
    set.mode = .horizontalBezier
    set.cubicIntensity = 0.05
    set.colors = label.colors
    set.circleColors = label.colors
    set.fillColor = label.colors.first!
    set.drawCircleHoleEnabled = false
    set.drawCirclesEnabled = false
    set.lineWidth = 2
    switch (type) {
    case .humidity: set.axisDependency = .right
    default: set.axisDependency = .left
    }
    set.highlightColor = .primary

    set.drawFilledEnabled = true
    set.fillAlpha = 0.08
    return set
}
