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

import Foundation

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!
    calendar.firstWeekday = 2
    return calendar
}()

extension Date {
    
    func inHalfOfHour() -> Date {
        let hour = calendar.component(.hour, from: self)
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: self)!
    }
    
    func dayStart() -> Date {
        return calendar.startOfDay(for: self)
    }
    
    func dayNoon() -> Date {
        var components = DateComponents()
        components.hour = 12
        return calendar.date(byAdding: components, to: dayStart())!
    }
    
    func dayEnd() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: dayStart())!
    }
    
    func weekStart() -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    func weekEnd() -> Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return calendar.date(byAdding: components, to: weekStart())!
    }
    
    func monthStart() -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
    
    func monthHalf() -> Date {
        var components = DateComponents()
        components.day = 15
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func monthNext() -> Date {
        var components = DateComponents()
        components.month = 1
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func monthPrevious() -> Date {
        var components = DateComponents()
        components.second = -1
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func monthEnd() -> Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func quarterStart() -> Date {
        var quarterBegin = ((calendar.component(.month, from: monthHalf()) - 1) / 3 * 3)
        var components = DateComponents()
        components.month = quarterBegin
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func quarterEnd() -> Date {
        var components = DateComponents()
        components.month = 3
        components.second = -1
        return calendar.date(byAdding: components, to: quarterStart())!
    }
    
    func quarterNext() -> Date {
        var components = DateComponents()
        components.month = 3
        return calendar.date(byAdding: components, to: quarterStart())!
    }
    
    func quarterPrevious() -> Date {
        var components = DateComponents()
        components.second = -1
        return calendar.date(byAdding: components, to: quarterStart())!
    }
    
    func yearStart() -> Date {
        return calendar.date(from: calendar.dateComponents([.year], from: self))!
    }
    
    func yearHalf() -> Date {
        var date = calendar.date(bySetting: .month, value: 7, of: self)!
        date = calendar.date(bySetting: .day, value: 1, of: date)!
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
    }
    
    func yearEnd() -> Date {
        var components = DateComponents()
        components.month = 12
        components.second = -1
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func yearNext() -> Date {
        var components = DateComponents()
        components.month = 12
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func yearPrevious() -> Date {
        var components = DateComponents()
        components.second = -1
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func shift(days: Int) -> Date {
        let toShift: Double = Double(days) * 24 * 60 * 60
        return Date(timeIntervalSince1970: self.timeIntervalSince1970 + toShift)
    }
}
