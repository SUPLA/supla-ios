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

import XCTest
@testable import SUPLA

final class DaysRangeTests: XCTestCase {
    
    func test_shouldGetMinAggregationMinutesWhenDaysCountBelow31() {
        // given
        let start: Date = .create(year: 2023, month: 11, day: 4)!
        let end: Date = .create(year: 2023, month: 11, day: 23)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let minAggregation = range.minAggregation
        
        // then
        XCTAssertEqual(minAggregation, .minutes)
    }
    
    func test_shouldGetMinAggregationHoursWhenDaysCountBelow92() {
        // given
        let start: Date = .create(year: 2023, month: 11, day: 4)!
        let end: Date = .create(year: 2023, month: 12, day: 23)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let minAggregation = range.minAggregation
        
        // then
        XCTAssertEqual(minAggregation, .hours)
    }
    
    func test_shouldGetMinAggregationDaysWhenDaysCountAbove92() {
        // given
        let start: Date = .create(year: 2023, month: 9, day: 4)!
        let end: Date = .create(year: 2023, month: 12, day: 23)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let minAggregation = range.minAggregation
        
        // then
        XCTAssertEqual(minAggregation, .days)
    }
    
    func test_shouldGetMaxAggregationHoursWhenDaysCountBelow1() {
        // given
        let start: Date = .create(year: 2023, month: 11, day: 4, hour: 1)!
        let end: Date = .create(year: 2023, month: 11, day: 4, hour: 3)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let minAggregation = range.maxAggregation
        
        // then
        XCTAssertEqual(minAggregation, .hours)
    }
    
    func test_shouldGetMaxAggregationDaysWhenDaysCountBelow31() {
        // given
        let start: Date = .create(year: 2023, month: 11, day: 4)!
        let end: Date = .create(year: 2023, month: 11, day: 23)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let minAggregation = range.maxAggregation
        
        // then
        XCTAssertEqual(minAggregation, .days)
    }
    
    func test_shouldGetMaxAggregationMonthsWhenDaysCountBelow548() {
        // given
        let start: Date = .create(year: 2022, month: 11, day: 4)!
        let end: Date = .create(year: 2023, month: 11, day: 23)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let minAggregation = range.maxAggregation
        
        // then
        XCTAssertEqual(minAggregation, .months)
    }
    
    func test_shouldGetMaxAggregationYearsWhenDaysCountAbove548() {
        // given
        let start: Date = .create(year: 2021, month: 11, day: 4)!
        let end: Date = .create(year: 2023, month: 11, day: 23)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let minAggregation = range.maxAggregation
        
        // then
        XCTAssertEqual(minAggregation, .years)
    }
    
    func test_shouldShiftRangeByDay() {
        // given
        let start: Date = .create(year: 2023, month: 11, day: 4)!
        let end: Date = .create(year: 2023, month: 11, day: 10)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .day, forward: true)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2023, month: 11, day: 5)!)
        XCTAssertEqual(shifted.end, .create(year: 2023, month: 11, day: 11)!)
    }
    
    func test_shouldShiftRangeByWeek() {
        // given
        let start: Date = .create(year: 2023, month: 11, day: 6)!
        let end: Date = .create(year: 2023, month: 11, day: 10)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .week, forward: false)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2023, month: 10, day: 30)!)
        XCTAssertEqual(shifted.end, .create(year: 2023, month: 11, day: 3)!)
    }
    
    func test_shouldShiftRangeByMonthForward() {
        // given
        let start: Date = .create(year: 2023, month: 11, day: 1)!
        let end: Date = .create(year: 2023, month: 11, day: 30)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .month, forward: true)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2023, month: 12, day: 1)!)
        XCTAssertEqual(shifted.end, .create(year: 2023, month: 12, day: 31, hour: 23, minute: 59, second: 59)!)
    }
    
    func test_shouldShiftRangeByMonthBackward() {
        // given
        let start: Date = .create(year: 2023, month: 12, day: 1)!
        let end: Date = .create(year: 2023, month: 12, day: 31)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .month, forward: false)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2023, month: 11, day: 1)!)
        XCTAssertEqual(shifted.end, .create(year: 2023, month: 11, day: 30, hour: 23, minute: 59, second: 59)!)
    }
    
    func test_shouldShiftRangeByQuarterForward() {
        // given
        let start: Date = .create(year: 2023, month: 10, day: 1)!
        let end: Date = .create(year: 2023, month: 12, day: 31)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .quarter, forward: true)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2024, month: 1, day: 1)!)
        XCTAssertEqual(shifted.end, .create(year: 2024, month: 3, day: 31, hour: 23, minute: 59, second: 59)!)
    }
    
    func test_shouldShiftRangeByQuarterBackward() {
        // given
        let start: Date = .create(year: 2023, month: 10, day: 1)!
        let end: Date = .create(year: 2023, month: 12, day: 31)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .quarter, forward: false)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2023, month: 7, day: 1)!)
        XCTAssertEqual(shifted.end, .create(year: 2023, month: 9, day: 30, hour: 23, minute: 59, second: 59)!)
    }
    
    func test_shouldShiftRangeByYearForward() {
        // given
        let start: Date = .create(year: 2023, month: 1, day: 1)!
        let end: Date = .create(year: 2023, month: 12, day: 31)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .year, forward: true)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2024, month: 1, day: 1)!)
        XCTAssertEqual(shifted.end, .create(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59)!)
    }
    
    func test_shouldShiftRangeByYearBackward() {
        // given
        let start: Date = .create(year: 2023, month: 1, day: 1)!
        let end: Date = .create(year: 2023, month: 12, day: 31)!
        let range = DaysRange(start: start, end: end)
        
        // when
        let shifted = range.shift(by: .year, forward: false)
        
        // then
        XCTAssertEqual(shifted.start, .create(year: 2022, month: 1, day: 1)!)
        XCTAssertEqual(shifted.end, .create(year: 2022, month: 12, day: 31, hour: 23, minute: 59, second: 59)!)
    }
}
