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


class BaseDistanceValueStringProvider: ChannelValueStringProvider {
    
    private lazy var smallValueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter
    }()
    
    private lazy var bigValueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 1
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter
    }()
    
    var valueProvider: ChannelValueProvider {
        fatalError("valueProvider has not been implemented")
    }
    
    var unknownValue: Double {
        fatalError("unknownValue has not been implemented")
    }
    
    func handle(function: Int32) -> Bool {
        fatalError("handle(function:) has not been implemented")
    }
    
    func value(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String {
        if let value = valueProvider.value(channel, valueType: valueType) as? Double,
           value > unknownValue {
            return formatDistance(value, withUnit)
        }
        else {
            return NO_VALUE_TEXT
        }
    }
    
    func formatDistance(_ value: Double, _ withUnit: Bool) -> String {
        if (fabs(value) >= 1000) {
            return stringValue(value / 1000, "km", bigValueFormatter, withUnit)
        }
        else if (fabs(value) >= 1) {
            return stringValue(value, "m", bigValueFormatter, withUnit)
        }
        
        let value = value * 100
        
        if (fabs(value) >= 1) {
            return stringValue(value, "cm", smallValueFormatter, withUnit)
        } else {
            return stringValue(value * 10, "mm", smallValueFormatter, withUnit)
        }
    }
    
    private func stringValue(_ value: Double, _ unit: String, _ formatter: NumberFormatter, _ withUnit: Bool) -> String {
        if let stringValue = formatter.string(from: NSNumber(value: value)) {
            if (withUnit) {
                return String(format: "%@ \(unit)", stringValue)
            } else {
                return stringValue
            }
        }
        
        return NO_VALUE_TEXT
    }
}
