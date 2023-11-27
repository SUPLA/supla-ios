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

fileprivate let DAY_IN_SEC: Double = 24 * 60 * 60

struct DaysRange: Equatable, Codable {
    let start: Date
    let end: Date
    
    var daysCount: Int {
        get { Int(abs(end.timeIntervalSince1970 - start.timeIntervalSince1970) / DAY_IN_SEC) }
    }
    
    var minAggregation: ChartDataAggregation {
        get {
            let days = daysCount
            if (days < 31) {
                return .minutes
            } else if (days < 92) {
                return .hours
            } else {
                return .days
            }
        }
    }
    
    var maxAggregation: ChartDataAggregation {
        get {
            let days = daysCount
            if (days <= 1) {
                return .hours
            } else if (days <= 31) {
                return .days
            } else if (daysCount <= 548) {
                return .months
            } else {
                return .years
            }
        }
    }
    
    func shift(by range: ChartRange, forward: Bool) -> DaysRange {
        switch (range) {
        case .day, .week: forward ? shift(range.roundedDaysCount) : shift(-range.roundedDaysCount)
        case .month: forward ? nextMonth() : previousMonth()
        case .quarter: forward ? nextQuarter() : previousQuarter()
        case .year: forward ? nextYear() : previousYear()
        default: self
        }
    }
    
    private func shift(_ days: Int) -> DaysRange {
        return DaysRange(start: start.shift(days: days), end: end.shift(days: days))
    }
    
    private func previousMonth() -> DaysRange {
        let start = start.monthPrevious().monthStart()
        return DaysRange(start: start, end: start.monthEnd())
    }
    
    private func nextMonth() -> DaysRange {
        let start = start.monthNext().monthStart()
        return DaysRange(start: start, end: start.monthEnd())
    }
    
    private func previousQuarter() -> DaysRange {
        let start = start.quarterPrevious().quarterStart()
        return DaysRange(start: start, end: start.quarterEnd())
    }
    
    private func nextQuarter() -> DaysRange {
        let start = start.quarterNext().quarterStart()
        return DaysRange(start: start, end: start.quarterEnd())
    }
    
    private func previousYear() -> DaysRange {
        let start = start.yearPrevious().yearStart()
        return DaysRange(start: start, end: start.yearEnd())
    }
    
    private func nextYear() -> DaysRange {
        let start = start.yearNext().yearStart()
        return DaysRange(start: start, end: start.yearEnd())
    }
}
