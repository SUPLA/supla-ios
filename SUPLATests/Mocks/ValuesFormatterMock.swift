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

final class ValuesFormatterMock: ValuesFormatter {
    
    func temperatureToString(value: Float?, withUnit: Bool, withDegree: Bool, precision: Int) -> String {
        if let value = value {
            return String(format: "%.1f", value)
        } else {
            return "0.0"
        }
    }
    
    func minutesToString(minutes: Int) -> String { "\(minutes)" }
    
    func secondsToString(_ time: TimeInterval) -> String { "\(time)" }
    
    func getHourString(hour: Hour?) -> String? {
        guard let hour = hour else { return "nil" }
        return "\(hour.hour):\(hour.minute)"
    }
    
    func getTimeString(hour: Int?, minute: Int?, second: Int?) -> String {
        var result = ""
        
        if let hour = hour {
            result += "\(hour)"
        } else {
            result += "nil"
        }
        
        if let minute = minute {
            result += "\(minute)"
        } else {
            result += "nil"
        }
        
        if let second = second {
            result += "\(second)"
        } else {
            result += "nil"
        }
        
        return result
    }
    
    
    func percentageToString(_ value: Float) -> String {
        ""
    }
    
    func humidityToString(value: Double?, withPercentage: Bool, precision: Int) -> String {
        ""
    }
    
    func getDateString(date: Date?) -> String? {
        ""
    }
    
    func getDateShortString(date: Date?) -> String? {
        ""
    }
    
    func getHourString(date: Date?) -> String? {
        ""
    }
    
    func getDayHourDateString(date: Date?) -> String? {
        ""
    }
    
    func getDayAndHourDateString(date: Date?) -> String? {
        ""
    }
    
    func getMonthString(date: Date?) -> String? {
        ""
    }
    
    func getFullDateString(date: Date?) -> String? {
        ""
    }
    
    func getMonthAndYearString(date: Date?) -> String? {
        ""
    }
    
    func getYearString(date: Date?) -> String? {
        ""
    }
}
