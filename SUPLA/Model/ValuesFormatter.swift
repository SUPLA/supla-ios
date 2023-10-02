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

protocol ValuesFormatter {
    func temperatureToString(_ value: Float?, withUnit: Bool, withDegree: Bool) -> String
    func minutesToString(minutes: Int) -> String
}

extension ValuesFormatter {
    func temperatureToString(_ value: Float?, withUnit: Bool = true, withDegree: Bool = true) -> String {
        temperatureToString(value, withUnit: withUnit, withDegree: withDegree)
    }
}

final class ValuesFormatterImpl: ValuesFormatter {
    
    @Singleton<GlobalSettings> private var settings
    
    var decimalSeparator = Locale.current.decimalSeparator
    
    private lazy var formatter: NumberFormatter! = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = decimalSeparator
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    func temperatureToString(_ value: Float?, withUnit: Bool = true, withDegree: Bool = true) -> String {
        guard let value = value,
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
    
    func minutesToString(minutes: Int) -> String {
        let hours = minutes / 60
        
        if (hours < 1) {
            return Strings.General.time_just_minutes.arguments(minutes)
        } else {
            return Strings.General.time_hours_and_mintes.arguments(hours, (minutes % 60))
        }
    }
    
    private func convert(_ value: Float) -> Float {
        switch (settings.temperatureUnit) {
        case .celsius: return value
        case .fahrenheit: return (value * 9.0/5.0) + 32.0
        }
    }
}
