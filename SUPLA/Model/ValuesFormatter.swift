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

let NO_VALUE_TEXT = "---"
private let MIN_TEMPERATURE_VALUE: Float = -273

protocol ValuesFormatter {
    // Values
    func temperatureToString(value: Float?, withUnit: Bool, withDegree: Bool, precision: Int) -> String
    func humidityToString(value: Double?, withPercentage: Bool, precision: Int) -> String
    func percentageToString(_ value: Float) -> String
    
    // Time
    func minutesToString(minutes: Int) -> String
    func secondsToString(_ time: TimeInterval) -> String
    func getHourString(hour: Hour?) -> String?
    func getTimeString(hour: Int?, minute: Int?, second: Int?) -> String
    func getDateString(date: Date?) -> String?
    func getDateShortString(date: Date?) -> String?
    func getHourString(date: Date?) -> String?
    func getDayHourDateString(date: Date?) -> String?
    func getDayAndHourDateString(date: Date?) -> String?
    func getMonthString(date: Date?) -> String?
    func getFullDateString(date: Date?) -> String?
    func getMonthAndYearString(date: Date?) -> String?
    func getYearString(date: Date?) -> String?
}

extension ValuesFormatter {
    func temperatureToString(_ value: Float?, withUnit: Bool = true, withDegree: Bool = true, precision: Int = 1) -> String {
        temperatureToString(value: value, withUnit: withUnit, withDegree: withDegree, precision: precision)
    }
    func temperatureToString(_ value: Double?, withUnit: Bool = true, withDegree: Bool = true, precision: Int = 1) -> String {
        if let value = value {
            return temperatureToString(value: Float(value), withUnit: withUnit, withDegree: withDegree, precision: precision)
        } else {
            return temperatureToString(value: nil, withUnit: withUnit, withDegree: withDegree, precision: precision)
        }
    }
    func humidityToString(_ value: Double?, withPercentage: Bool = false, precision: Int = 1) -> String {
        humidityToString(value: value, withPercentage: withPercentage, precision: precision)
    }
    func getTimeString(hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> String {
        getTimeString(hour: hour, minute: minute, second: second)
    }
}

final class ValuesFormatterImpl: ValuesFormatter {
    
    @Singleton<GlobalSettings> private var settings
    
    let dateFormatter = DateFormatter()
    
    private lazy var formatter: NumberFormatter! = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter
    }()
    
    // MARK: - Values
    
    func temperatureToString(value: Float?, withUnit: Bool = true, withDegree: Bool = true, precision: Int = 1) -> String {
        formatter.minimumFractionDigits = precision
        formatter.maximumFractionDigits = precision
        guard let value = value,
              value >= MIN_TEMPERATURE_VALUE,
              let formatted = formatter.string(from: NSNumber(value: convert(value)))
        else {
            return NO_VALUE_TEXT
        }
        
        if (withUnit) {
            return "\(formatted) \(settings.temperatureUnit.symbol)"
        } else if (withDegree) {
            return "\(formatted)°"
        } else {
            return formatted
        }
    }
    
    func humidityToString(value: Double?, withPercentage: Bool, precision: Int = 1) -> String {
        formatter.minimumFractionDigits = precision
        formatter.maximumFractionDigits = precision
        guard let value = value,
              value >= 0 && value <= 100,
              let formatted = formatter.string(from: NSNumber(value: convert(Float(value))))
        else {
            return NO_VALUE_TEXT
        }
        
        return if (withPercentage) {
            "\(formatted)%"
        } else {
            "\(formatted)"
        }
    }
    
    func percentageToString(_ value: Float) -> String {
        let percentage = Int((value * 100).rounded())
        return "\(percentage)%"
    }
    
    // MARK: - Time
    
    func minutesToString(minutes: Int) -> String {
        let hours = minutes / 60
        
        if (hours < 1) {
            return Strings.General.time_just_minutes.arguments(minutes)
        } else {
            return Strings.General.time_hours_and_mintes.arguments(hours, (minutes % 60))
        }
    }
    
    func getHourString(hour: Hour?) -> String? {
        guard let hour = hour else { return nil }
        return getTimeString(hour: hour.hour, minute: hour.minute)
    }
    
    func getTimeString(hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> String {
        var result = ""
        
        if let hour = hour {
            result += hour < 10 ? "0\(hour)" : "\(hour)"
        }
        if let minute = minute {
            if (!result.isEmpty) {
                result += ":"
            }
            result += minute < 10 ? "0\(minute)" : "\(minute)"
        }
        if let second = second {
            if (!result.isEmpty) {
                result += ":"
            }
            result += second < 10 ? "0\(second)" : "\(second)"
        }
        
        return result
    }
    
    func secondsToString(_ time: TimeInterval) -> String {
        let hours = time / Double(HOUR_IN_SEC)
        let minutes = (time.truncatingRemainder(dividingBy: Double(HOUR_IN_SEC))) / Double(MINUTE_IN_SEC)
        let seconds = time.truncatingRemainder(dividingBy: Double(MINUTE_IN_SEC))
        
        return getTimeString(hour: Int(hours), minute: Int(minutes), second: Int(seconds))
    }
    
    func getDateString(date: Date?) -> String? {
        formattedDate(date: date, format: "dd.MM.yyyy")
    }
    
    func getDateShortString(date: Date?) -> String? {
        formattedDate(date: date, format: "dd.MM.yy")
    }
    
    func getHourString(date: Date?) -> String? {
        formattedDate(date: date, format: "HH:mm")
    }
    
    func getDayHourDateString(date: Date?) -> String? {
        formattedDate(date: date, format: "EEEE HH:mm")
    }
    
    func getDayAndHourDateString(date: Date?) -> String? {
        formattedDate(date: date, format: "dd MMM HH:mm")
    }
    
    func getMonthString(date: Date?) -> String? {
        formattedDate(date: date, format: "dd MMM")
    }
    
    func getFullDateString(date: Date?) -> String? {
        formattedDate(date: date, format: "dd.MM.yyyy HH:mm")
    }
    
    func getMonthAndYearString(date: Date?) -> String? {
        formattedDate(date: date, format: "yyyy MMM")
    }
    
    func getYearString(date: Date?) -> String? {
        formattedDate(date: date, format: "yyyy")
    }
    
    private func formattedDate(date: Date?, format: String, timezone: TimeZone = TimeZone.current) -> String? {
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone
        return if let date = date {
            dateFormatter.string(from: date)
        } else {
            nil
        }
    }
    
    private func convert(_ value: Float) -> Float {
        switch (settings.temperatureUnit) {
        case .celsius: return value
        case .fahrenheit: return (value * 9.0/5.0) + 32.0
        }
    }
}
