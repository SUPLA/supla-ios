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

class TemperaturePresenter: NSObject {
    
    private let _unit: TemperatureUnit
    private let _formatter: NumberFormatter
    private let _displayUnit: Bool
    
    
    init(temperatureUnit: TemperatureUnit, locale: Locale = Locale.current,
         shouldDisplayUnit: Bool = true) {
        _unit = temperatureUnit
        _displayUnit = shouldDisplayUnit
        _formatter = NumberFormatter()
        _formatter.decimalSeparator = locale.decimalSeparator
        _formatter.minimumFractionDigits = 1
        _formatter.maximumFractionDigits = 1
        super.init()
    }
    
    /**
        return temperature value converted from Celsius to target temperature unit.
     */
    @objc
    func converted(_ value: Float) -> Float {
        switch _unit {
        case .celsius: return value
        case .fahrenheit: return (value * 9.0/5.0) + 32.0
        }
    }
    
    @objc
    func stringRepresentation(_ value: Float) -> String {
        let cnv = NSNumber(value: converted(value))
        var out = (_formatter.string(from: cnv) ?? "")
        if _displayUnit {
            out += " " + _unit.symbol
        } else {
            out += "°"
        }
        return out
    }

    @objc
    var unitString: String { return _unit.symbol }
}
