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

protocol ChartState: Codable {
    var aggregation: ChartDataAggregation { get }
    var chartRange: ChartRange { get }
    var dateRange: DaysRange? { get }
    var chartParameters: ChartParameters? { get }
    var visibleSets: [ChartStateVisibleSet]? { get }

    func toJson() throws -> Data
}

struct ChartStateVisibleSet: Codable {
    let id: Int32
    let type: ChartEntryType
}

struct DefaultChartState: ChartState {
    let aggregation: ChartDataAggregation
    let chartRange: ChartRange
    let dateRange: DaysRange?
    let chartParameters: ChartParameters?
    let visibleSets: [ChartStateVisibleSet]?

    func toJson() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    static func empty() -> DefaultChartState {
        DefaultChartState(
            aggregation: .minutes,
            chartRange: .lastWeek,
            dateRange: nil,
            chartParameters: nil,
            visibleSets: nil
        )
    }
}

struct ElectricityChartState: ChartState {
    let aggregation: ChartDataAggregation
    let chartRange: ChartRange
    let dateRange: DaysRange?
    let chartParameters: ChartParameters?
    let visibleSets: [ChartStateVisibleSet]?
    let customFilters: ElectricityChartFilters?

    func toJson() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    func copy(
        aggregation: OptionalValue<ChartDataAggregation> = .unset(.minutes),
        chartRange: OptionalValue<ChartRange> = .unset(.day),
        dateRange: OptionalValue<DaysRange?> = .unset(nil),
        chartParameters: OptionalValue<ChartParameters?> = .unset(nil),
        visibleSets: OptionalValue<[ChartStateVisibleSet]?> = .unset(nil),
        customFilters: OptionalValue<ElectricityChartFilters?> = .unset(nil)
    ) -> ElectricityChartState {
        ElectricityChartState(
            aggregation: aggregation.getValue(self.aggregation),
            chartRange: chartRange.getValue(self.chartRange),
            dateRange: dateRange.getValue(self.dateRange),
            chartParameters: chartParameters.getValue(self.chartParameters),
            visibleSets: visibleSets.getValue(self.visibleSets),
            customFilters: customFilters.getValue(self.customFilters)
        )
    }

    static func empty() -> ElectricityChartState {
        ElectricityChartState(
            aggregation: .minutes,
            chartRange: .lastWeek,
            dateRange: nil,
            chartParameters: nil,
            visibleSets: nil,
            customFilters: nil
        )
    }
}
