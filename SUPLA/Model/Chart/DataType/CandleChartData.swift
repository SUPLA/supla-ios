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


final class CandleChartData: ChartData {
    override var divider: Double { aggregation?.timeInSec ?? 1.0 }
    
    override func combinedData() -> CombinedChartData? {
        var candleDataSets: [ChartDataSetProtocol] = []
        for set in sets {
            if (set.active && !set.entries.isEmpty) {
                for entries in set.entries {
                    let candleEntries = entries.map { entry in
                        let min = entry.min ?? entry.value
                        let max = entry.max ?? entry.value
                        let open = entry.open ?? entry.value
                        let close = entry.close ?? entry.value
                        return CandleChartDataEntry(
                            x: toCoordinate(x: entry.date),
                            shadowH: max,
                            shadowL: min,
                            open: open,
                            close: close,
                            data: set.toDetails(entry)
                        )
                    }
                    candleDataSets.append(candleDataSet(candleEntries, set.color, set.setId.type))
                }
            }
        }
        
        if (candleDataSets.isEmpty) {
            return nil
        }
        
        let data = CombinedChartData()
        data.candleData = DGCharts.CandleChartData(dataSets: candleDataSets)
        return data
    }
    
    override func newInstance(sets: [HistoryDataSet]) -> ChartData {
        CandleChartData(dateRange, chartRange, aggregation, sets)
    }
    
    private func candleDataSet(_ set: [CandleChartDataEntry], _ color: UIColor, _ type: ChartEntryType) -> CandleChartDataSet {
        let set = CandleChartDataSet(entries: set, label: "")
        set.drawValuesEnabled = false
        set.colors = [color]
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
}
