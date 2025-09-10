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

final class ThermometerValueFormatter: ChannelValueFormatter {
    @Singleton<GroupShared.Settings> private var settings
    
    func handle(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_THERMOMETER
    }
    
    func format(_ value: Any?, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        let format = custom as? TemperatureFormat ?? TemperatureFormat.default
        
        return if let doubleValue = value as? Double, doubleValue > ThermometerValueFormatter.UNKNOWN_VALUE {
             toString(doubleValue, withUnit: withUnit, format: format)
        } else if let floatValue = value as? Float, floatValue > Float(ThermometerValueFormatter.UNKNOWN_VALUE) {
             toString(Double(floatValue), withUnit: withUnit, format: format)
        } else {
             NO_VALUE_TEXT
        }
    }
    
    func formatChartLabel(_ value: Any?, precision: Int, withUnit: Bool) -> String {
        format(value, withUnit: withUnit, precision: .defaultPrecision(value: precision), custom: nil)
    }
    
    private func toString(_ value: Double, withUnit: Bool, format: TemperatureFormat) -> String {
        let stringValue = convert(value).toString(precision: settings.temperaturePrecision)
        return if (withUnit) {
            "\(stringValue) \(settings.temperatureUnit.symbol)"
        } else if (format.withDegreeSymbol) {
            "\(stringValue)°"
        } else {
            stringValue
        }
    }
    
    private func convert(_ value: Double) -> Double {
        switch (settings.temperatureUnit) {
        case .celsius: return value
        case .fahrenheit: return (value * 9.0 / 5.0) + 32.0
        }
    }
    
    static let UNKNOWN_VALUE = -273.0
}

struct TemperatureFormat {
    let withDegreeSymbol: Bool
    
    static let scheduleSettings = TemperatureFormat(withDegreeSymbol: false)
    static let `default` = TemperatureFormat(withDegreeSymbol: true)
}
