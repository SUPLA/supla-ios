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

final class CandleChartData: CombinedChartData {
    override var divider: Double { aggregation?.timeInSec ?? 1.0 }

    override func combinedData() -> DGCharts.CombinedChartData? {
        var candleDataSets: [ChartDataSetProtocol] = []
        sets.flatMap { $0.dataSets }
            .forEach {
                if let set = $0.asCandleChartData(toCoordinate: toCoordinate, aggregation: aggregation!) {
                    candleDataSets.append(contentsOf: set)
                }
            }

        if (candleDataSets.isEmpty) {
            return nil
        }

        let data = DGCharts.CombinedChartData()
        data.candleData = DGCharts.CandleChartData(dataSets: candleDataSets)
        return data
    }

    override func newInstance(sets: [ChannelChartSets]) -> ChartData {
        CandleChartData(dateRange, chartRange, aggregation, sets)
    }
}

private extension HistoryDataSet {
    func asCandleChartData(toCoordinate: (Double) -> Double, aggregation: ChartDataAggregation) -> [ChartDataSetProtocol]? {
        if (!active || entries.isEmpty) {
            return nil
        }

        return entries
            .map { aggregatedEntries in
                candleDataSet(
                    set: aggregatedEntries.map {
                        $0.toCandleChartDataEntry(
                            toCoordinate: toCoordinate,
                            data: toChartDetails(aggregation: aggregation, entity: $0)
                        )
                    },
                    label: label,
                    type: type
                )
            }
    }
}

private extension AggregatedEntity {
    func toCandleChartDataEntry(toCoordinate: (Double) -> Double, data: Any? = nil) -> CandleChartDataEntry {
        switch (value) {
        case .single(let value, let min, let max, let open, let close):
            CandleChartDataEntry(
                x: toCoordinate(date),
                shadowH: max ?? value,
                shadowL: min ?? value,
                open: open ?? value,
                close: close ?? value,
                data: data
            )
        case .multiple(_),
             .withPhase:
            fatalError("Candle chart is not supported for multiple values!")
        }
    }
}

private func candleDataSet(set: [CandleChartDataEntry], label: HistoryDataSet.Label, type: ChartEntryType) -> CandleChartDataSet {
    let set = CandleChartDataSet(entries: set, label: "")
    set.drawValuesEnabled = false
    set.colors = label.colors
    switch (type) {
    case .humidity: set.axisDependency = .right
    default: set.axisDependency = .left
    }
    set.highlightColor = .primary
    set.shadowColor = .onBackground
    set.shadowWidth = 0.7
    set.decreasingColor = .red
    set.decreasingFilled = true
    set.increasingColor = .suplaGreen
    set.increasingFilled = true
    set.neutralColor = .blue

    return set
}
