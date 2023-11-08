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

@testable import SUPLA
import XCTest

final class ChartDataAggregationTests: XCTestCase {
    
    // 2023.11.03 13:00 (GMT)
    let date = Date(timeIntervalSince1970: TimeInterval(1699016400))
    
    override func setUp() {
        NSTimeZone.default = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    }
    
    func test_shouldGetYearAggregator() {
        // given
        let aggregation = ChartDataAggregation.years
        let item = SATemperatureMeasurementItem(testContext: nil)
        item.setDateAndDateParts(date)
        
        // when
        let aggregator = aggregation.aggregator(item: item)
        
        // then
        XCTAssertEqual(aggregator, 2023)
    }
    
    func test_shouldGetMonthAggregator() {
        // given
        let aggregation = ChartDataAggregation.months
        let item = SATemperatureMeasurementItem(testContext: nil)
        item.setDateAndDateParts(date)
        
        // when
        let aggregator = aggregation.aggregator(item: item)
        
        // then
        XCTAssertEqual(aggregator, 202311)
    }
    
    func test_shouldGetDayAggregator() {
        // given
        let aggregation = ChartDataAggregation.days
        let item = SATemperatureMeasurementItem(testContext: nil)
        item.setDateAndDateParts(date)
        
        // when
        let aggregator = aggregation.aggregator(item: item)
        
        // then
        XCTAssertEqual(aggregator, 20231103)
    }
    
    func test_shouldGetHourAggregator() {
        // given
        let aggregation = ChartDataAggregation.hours
        let item = SATemperatureMeasurementItem(testContext: nil)
        item.setDateAndDateParts(date)
        
        // when
        let aggregator = aggregation.aggregator(item: item)
        
        // then
        XCTAssertEqual(aggregator, 2023110313)
    }
    
    func test_checkBetweenRanges() {
        XCTAssertEqual(ChartDataAggregation.days.between(min: .minutes, max: .days), true)
        XCTAssertEqual(ChartDataAggregation.days.between(min: .months, max: .years), false)
        XCTAssertEqual(ChartDataAggregation.days.between(min: .minutes, max: .hours), false)
    }
    
    func test_shouldGetTimeGroupForMinutes() {
        // given
        let aggregation = ChartDataAggregation.minutes
        
        // when
        let timeinterval = aggregation.groupTimeProvider(date: date)
        
        // then
        XCTAssertEqual(date.timeIntervalSince1970, timeinterval)
    }
    
    func test_shouldGetTimeGroupForHours() {
        // given
        let aggregation = ChartDataAggregation.hours
        
        // when
        let timeinterval = aggregation.groupTimeProvider(date: date)
        
        // then
        XCTAssertEqual(date.timeIntervalSince1970, timeinterval)
    }
    
    func test_shouldGetTimeGroupForDays() {
        // given
        let aggregation = ChartDataAggregation.days
        
        // when
        let timeinterval = aggregation.groupTimeProvider(date: date)
        
        // then
        let expectedDate = Date.create(year: 2023, month: 11, day: 3, hour: 12)?.timeIntervalSince1970
        XCTAssertEqual(expectedDate, timeinterval)
    }
    
    func test_shouldGetTimeGroupForMonths() {
        // given
        let aggregation = ChartDataAggregation.months
        
        // when
        let timeinterval = aggregation.groupTimeProvider(date: date)
        
        // then
        let expectedDate = Date.create(year: 2023, month: 11, day: 16)?.timeIntervalSince1970
        XCTAssertEqual(expectedDate, timeinterval)
    }
    
    func test_shouldGetTimeGroupForYears() {
        // given
        let aggregation = ChartDataAggregation.years
        
        // when
        let timeinterval = aggregation.groupTimeProvider(date: date)
        
        // then
        let expectedDate = Date.create(year: 2023, month: 7)?.timeIntervalSince1970
        XCTAssertEqual(expectedDate, timeinterval)
    }
}
