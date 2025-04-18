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

final class DateProviderMock: DateProvider {
    
    var currentDateReturns = Date()
    var currentDateCalls = 0
    func currentDate() -> Date {
        currentDateCalls += 1
        return currentDateReturns
    }
    
    var currentTimestampReturns: MockReturns<TimeInterval> = .empty()
    var currentTimestampCalls = 0
    func currentTimestamp() -> TimeInterval {
        currentTimestampCalls += 1
        return currentTimestampReturns.next()
    }
    
    var currentDayOfWeekCalls = 0
    var currentDayOfWeekReturns = DayOfWeek.monday
    func currentDayOfWeek() -> DayOfWeek {
        currentDayOfWeekCalls += 1
        return currentDayOfWeekReturns
    }
    
    var currentHourCalls = 0
    var currentHourReturns = 0
    func currentHour() -> Int {
        currentHourCalls += 1
        return currentHourReturns
    }
    
    var currentMinuteCalls = 0
    var currentMinuteReturns = 0
    func currentMinute() -> Int {
        currentMinuteCalls += 1
        return currentMinuteReturns
    }
}
