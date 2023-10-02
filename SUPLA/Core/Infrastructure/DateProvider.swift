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

protocol DateProvider {
    func currentDate() -> Date
    func currentTimestamp() -> TimeInterval
    func currentDayOfWeek() -> DayOfWeek
    func currentHour() -> Int
    func currentMinute() -> Int
}

final class DateProviderImpl: DateProvider {
    
    let calendar = Calendar.current
    
    func currentDate() -> Date {
        Date()
    }
    
    func currentTimestamp() -> TimeInterval {
        Date().timeIntervalSince1970
    }
    
    func currentDayOfWeek() -> DayOfWeek {
        DayOfWeek.from(value: UInt8(calendar.component(.weekday, from: Date()) - 1))
    }
    
    func currentHour() -> Int {
        calendar.component(.hour, from: Date())
    }
    
    func currentMinute() -> Int {
        calendar.component(.minute, from: Date())
    }
}
