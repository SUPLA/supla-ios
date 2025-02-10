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

private let valueFont = UIFont(name: "OpenSans", size: 8)!
private let labelFont = UIFont(name: "OpenSans", size: 11)!

final class PieChartData: ChartData {
    func pieData() -> DGCharts.PieChartData? {
        let formatter = DateFormatter()

        var pieDataSets: [PieChartDataSet] = []
        for channelSet in sets {
            for dataSet in channelSet.dataSets {
                if let set = dataSet.asPieChartData(
                    aggregation: aggregation!,
                    formatter: dataSet.valueFormatter,
                    dateFormatter: formatter,
                    customData: channelSet.customData
                ) {
                    pieDataSets.append(contentsOf: set)
                }
            }
        }

        if (pieDataSets.isEmpty) {
            return nil
        }

        let data = DGCharts.PieChartData(dataSets: pieDataSets)
        return data
    }

    override func newInstance(sets: [ChannelChartSets]) -> ChartData {
        PieChartData(dateRange, chartRange, aggregation, sets)
    }
}

private extension HistoryDataSet {
    func asPieChartData(
        aggregation: ChartDataAggregation,
        formatter: ChannelValueFormatter,
        dateFormatter: DateFormatter,
        customData: (any Equatable)?
    ) -> [PieChartDataSet]? {
        if (!active || entries.isEmpty) {
            return nil
        }

        return entries
            .map { aggregatedEntries in
                pieDataSet(
                    set: aggregatedEntries.map {
                        entryToPieChartDataEntry($0, aggregation, dateFormatter, customData)
                    },
                    aggregation: aggregation,
                    formatter: formatter
                )
            }
    }

    private func entryToPieChartDataEntry(
        _ entry: AggregatedEntity,
        _ aggregation: ChartDataAggregation,
        _ formatter: DateFormatter,
        _ customData: (any Equatable)?
    ) -> PieChartDataEntry {
        switch (entry.value) {
        case .single(let value, _, _, _, _):
            PieChartDataEntry(
                value: value,
                label: aggregation.label(entry.date, formatter),
                data: toChartDetails(aggregation: aggregation, entity: entry, customData: customData)
            )
        case .multiple(let values):
            PieChartDataEntry(
                value: values.sum(),
                label: aggregation.label(entry.date, formatter),
                data: toChartDetails(aggregation: aggregation, entity: entry, customData: customData)
            )
        case .withPhase(let value, _, _, _):
            PieChartDataEntry(
                value: value,
                label: aggregation.label(entry.date, formatter),
                data: toChartDetails(aggregation: aggregation, entity: entry, customData: customData)
            )
        }
    }
}

private func pieDataSet(set: [ChartDataEntry], aggregation: ChartDataAggregation, formatter: ChannelValueFormatter) -> PieChartDataSet {
    let set = PieChartDataSet(entries: set, label: "")
    set.colors = aggregation.colors
    set.valueFont = valueFont
    set.valueTextColor = .onBackground
    set.entryLabelFont = labelFont
    set.entryLabelColor = .onBackground
    set.valueFormatter = PieChartSetFormatter(formatter: formatter)
    return set
}

private class PieChartSetFormatter: ValueFormatter {
    let formatter: ChannelValueFormatter

    init(formatter: ChannelValueFormatter) {
        self.formatter = formatter
    }

    func stringForValue(_ value: Double, entry: DGCharts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: DGCharts.ViewPortHandler?) -> String {
        formatter.format(value)
    }
}

private extension ChartDataAggregation {
    func label(_ value: TimeInterval, _ formatter: DateFormatter) -> String {
        switch (self) {
        case .rankHours: String(format: "%.0f", value)
        case .rankWeekdays: "\(formatter.shortWeekdaySymbols[Int(value - 1)])"
        case .rankMonths: "\(formatter.shortMonthSymbols[Int(value - 1)])"
        default: ""
        }
    }
}
