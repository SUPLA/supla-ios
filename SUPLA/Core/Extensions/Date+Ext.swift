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
    calendar.timeZone = TimeZone.current
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
        var components = DateComponents(timeZone: TimeZone.current)
        components.hour = 12
        return calendar.date(byAdding: components, to: dayStart())!
    }
    
    func dayEnd() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: dayStart())!
    }
    
    func weekStart() -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    func weekEnd() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.weekOfYear = 1
        components.second = -1
        return calendar.date(byAdding: components, to: weekStart())!
    }
    
    func monthStart() -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
    
    func monthHalf() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.day = 15
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func monthNext() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = 1
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func monthPrevious() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.second = -1
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func monthEnd() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: monthStart())!
    }
    
    func quarterStart() -> Date {
        let quarterBegin = ((calendar.component(.month, from: monthHalf()) - 1) / 3 * 3)
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = quarterBegin
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func quarterEnd() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = 3
        components.second = -1
        return calendar.date(byAdding: components, to: quarterStart())!
    }
    
    func quarterNext() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = 3
        return calendar.date(byAdding: components, to: quarterStart())!
    }
    
    func quarterPrevious() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.second = -1
        return calendar.date(byAdding: components, to: quarterStart())!
    }
    
    func yearStart() -> Date {
        return calendar.date(from: calendar.dateComponents([.year], from: self))!
    }
    
    func yearHalf() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = 6
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func yearEnd() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = 12
        components.second = -1
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func yearNext() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.month = 12
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func yearPrevious() -> Date {
        var components = DateComponents(timeZone: TimeZone.current)
        components.second = -1
        return calendar.date(byAdding: components, to: yearStart())!
    }
    
    func shift(days: Int) -> Date {
        let toShift: Double = Double(days * DAY_IN_SEC)
        return Date(timeIntervalSince1970: self.timeIntervalSince1970 + toShift)
    }
    
    func differenceInSeconds(_ otherDate: Date) -> Int {
        Int(abs(timeIntervalSince1970 - otherDate.timeIntervalSince1970))
    }
    
    static func create(year: Int, month: Int = 1, day: Int = 1, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone.current
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        return calendar.date(from: dateComponents)
    }
    
    static func create(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone.current
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        return calendar.date(from: dateComponents)
    }
}
