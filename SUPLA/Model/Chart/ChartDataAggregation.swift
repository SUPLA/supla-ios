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

fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMddHHmm"
    return formatter
}()

enum ChartDataAggregation: Equatable, Codable, CaseIterable {
    case minutes
    case hours
    case days
    case months
    case years
    
    var timeInSec: TimeInterval {
        get {
            switch (self) {
            case .minutes: 60
            case .hours: 3600
            case .days: 86400
            case .months: 2592000
            case .years: 31536000
            }
        }
    }
    
    var label: String {
        get {
            switch (self) {
            case .minutes: Strings.Charts.minutes
            case .hours: Strings.Charts.hours
            case .days: Strings.Charts.days
            case .months: Strings.Charts.months
            case .years: Strings.Charts.year
            }
        }
    }
    
    func aggregator(item: SAMeasurementItem) -> TimeInterval {
        let year = Double(item.year)
        if (self == .years) {
            return TimeInterval(year)
        }
        let month = Double(item.month)
        if (self == .months) {
            return TimeInterval((year * 100) + month)
        }
        
        let day = Double(item.day)
        if (self == .days) {
            return TimeInterval((year * 10000) + (100 * month) + day)
        }
        
        let hour = Double(item.hour)
        if (self == .hours) {
            return TimeInterval((year * 1000000) + (10000 * month) + (100 * day) + hour)
        }
        
        return 0
    }
    
    func groupTimeProvider(date: Date) -> TimeInterval {
        return switch(self) {
        case .minutes: date.timeIntervalSince1970
        case .hours: date.inHalfOfHour().timeIntervalSince1970
        case .days: date.dayNoon().timeIntervalSince1970
        case .months: date.monthHalf().timeIntervalSince1970
        case .years: date.yearHalf().timeIntervalSince1970
        }
    }
    
    func between(min: ChartDataAggregation, max: ChartDataAggregation) -> Bool {
        self.timeInSec >= min.timeInSec && self.timeInSec <= max.timeInSec
    }
}

