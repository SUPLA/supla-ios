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

final class LineChartData: ChartData {
    
    override func combinedData() -> CombinedChartData? {
        var lineDataSets: [LineChartDataSet] = []
        sets.forEach { set in
            if (set.active && !set.entries.isEmpty) {
                set.entries.forEach {
                    let entries = $0.map { ChartDataEntry(x: $0.date, y: $0.value, data: set.toDetails($0)) }
                    lineDataSets.append(lineDataSet(entries, set.color, set.setId.type))
                }
            }
        }
        
        if (lineDataSets.isEmpty) {
            return nil
        }
        
        let data = CombinedChartData()
        data.lineData = DGCharts.LineChartData(dataSets: lineDataSets)
        return data
    }
    
    override func newInstance(sets: [HistoryDataSet]) -> ChartData {
        LineChartData(dateRange, chartRange, aggregation, sets)
    }
    
    func lineDataSet(_ set: [ChartDataEntry], _ color: UIColor, _ type: ChartEntryType) -> LineChartDataSet {
        let set = LineChartDataSet(entries: set, label: "")
        set.drawValuesEnabled = false
        set.mode = .horizontalBezier
        set.cubicIntensity = 0.05
        set.colors = [color]
        set.circleColors = [color]
        set.drawCircleHoleEnabled = false
        set.drawCirclesEnabled = false
        set.lineWidth = 2
        switch (type) {
        case .humidity: set.axisDependency = .right
        default: set.axisDependency = .left
        }
        set.highlightColor = .primary
        
        set.drawFilledEnabled = true
        set.fillColor = color
        set.fillAlpha = 0.08
        return set
    }
    
}
