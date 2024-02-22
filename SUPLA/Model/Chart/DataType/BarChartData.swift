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

final class BarChartData: ChartData {
    override func combinedData() -> CombinedChartData? {
        var barDataSets: [BarChartDataSet] = []
        for set in sets {
            if (set.active && !set.entries.isEmpty) {
                for entry in set.entries {
                    let entries = entry.map {
                        BarChartDataEntry(x: $0.date, y: $0.value, data: set.toDetails($0))
                    }
                    barDataSets.append(barDataSet(entries, set.color, set.setId.type))
                }
            }
        }

        if (barDataSets.isEmpty) {
            return nil
        }

        let data = CombinedChartData()
        data.barData = DGCharts.BarChartData(dataSets: barDataSets)
        data.barData.barWidth = (aggregation?.timeInSec ?? 1) * 0.8
        return data
    }

    override func newInstance(sets: [HistoryDataSet]) -> ChartData {
        BarChartData(dateRange, chartRange, aggregation, sets)
    }

    private func barDataSet(_ set: [ChartDataEntry], _ color: UIColor, _ type: ChartEntryType) -> BarChartDataSet {
        let set = BarChartDataSet(entries: set, label: "")
        set.drawValuesEnabled = false
        set.colors = [color]
        set.barShadowColor = .transparent

        return set
    }
}
