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

final class BarChartData: CombinedChartData {
    override func combinedData() -> DGCharts.CombinedChartData? {
        var barDataSets: [BarChartDataSet] = []

        for channelSet in sets {
            for dataSet in channelSet.dataSets {
                if let set = dataSet.asBarChartData(
                    toCoordinate: toCoordinate,
                    aggregation: aggregation!,
                    customData: channelSet.customData
                ) {
                    barDataSets.append(contentsOf: set)
                }
            }
        }

        if (barDataSets.isEmpty) {
            return nil
        }

        let data = DGCharts.CombinedChartData()
        data.barData = DGCharts.BarChartData(dataSets: barDataSets)
        data.barData.barWidth = (aggregation?.timeInSec ?? 1) * 0.8
        return data
    }

    override func newInstance(sets: [ChannelChartSets]) -> ChartData {
        BarChartData(dateRange, chartRange, aggregation, sets)
    }

    override func getAxisMaxValue(_ filter: (ChartEntryType) -> Bool) -> Double? {
        let maxValue = super.getAxisMaxValue(filter)

        if let maxValue = maxValue, maxValue <= 0 {
            if let minValue = getAxisMinValueRaw(filter) {
                return abs(minValue) * CHART_TOP_MARGIN
            }
        }

        return maxValue
    }
}

private extension HistoryDataSet {
    func asBarChartData(toCoordinate: (Double) -> Double, aggregation: ChartDataAggregation, customData: (any Equatable)?) -> [BarChartDataSet]? {
        if (!active || entries.isEmpty) {
            return nil
        }

        return entries
            .map { aggregatedEntries in
                barDataSet(
                    set: aggregatedEntries.map {
                        $0.toBarChartDataEntry(
                            toCoordinate: toCoordinate,
                            data: toChartDetails(aggregation: aggregation, entity: $0, customData: customData)
                        )
                    },
                    label: label,
                    type: type
                )
            }
    }
}

private extension AggregatedEntity {
    func toBarChartDataEntry(toCoordinate: (Double) -> Double, data: Any? = nil) -> BarChartDataEntry {
        switch (value) {
        case .single(let value, _, _, _, _):
            BarChartDataEntry(x: toCoordinate(date), y: value, data: data)
        case .multiple(let values):
            BarChartDataEntry(x: toCoordinate(date), yValues: values, data: data)
        case .withPhase(let value, _, _, _):
            BarChartDataEntry(x: toCoordinate(date), y: value, data: data)
        }
    }
}

private func barDataSet(set: [ChartDataEntry], label: HistoryDataSet.Label, type: ChartEntryType) -> BarChartDataSet {
    let set = BarChartDataSet(entries: set, label: "")
    set.drawValuesEnabled = false
    set.colors = label.colors
    set.barShadowColor = .transparent

    return set
}
