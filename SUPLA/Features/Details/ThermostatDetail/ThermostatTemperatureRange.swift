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

enum ThermostatTemperatureRange {
    static func isValid(minimum: Float, maximum: Float) -> Bool {
        minimum.isFinite && maximum.isFinite && minimum <= maximum &&
            (minimum == maximum || (maximum - minimum).isFinite)
    }

    static func isAdjustable(minimum: Float, maximum: Float) -> Bool {
        isValid(minimum: minimum, maximum: maximum) && minimum < maximum
    }

    static func isCollapsed(minimum: Float, maximum: Float) -> Bool {
        isValid(minimum: minimum, maximum: maximum) && minimum == maximum
    }
}

extension Float {
    func thermostatPosition(
        minimum: Float,
        maximum: Float
    ) -> Float? {
        guard ThermostatTemperatureRange.isValid(minimum: minimum, maximum: maximum), isFinite else { return nil }
        guard ThermostatTemperatureRange.isAdjustable(minimum: minimum, maximum: maximum) else { return 0 }

        let position = (self - minimum) / (maximum - minimum)
        return position.isFinite ? position : nil
    }

    func thermostatTemperature(
        minimum: Float,
        maximum: Float
    ) -> Float? {
        guard ThermostatTemperatureRange.isValid(minimum: minimum, maximum: maximum), isFinite else { return nil }
        guard ThermostatTemperatureRange.isAdjustable(minimum: minimum, maximum: maximum) else {
            return ThermostatTemperatureRange.isCollapsed(minimum: minimum, maximum: maximum) ? minimum : nil
        }

        let boundedPosition = clamped(to: 0...1)
        let temperature = (minimum + (maximum - minimum) * boundedPosition).roundToTenths()
        return temperature.isFinite ? temperature : nil
    }

    func hvacClamped(
        minimum: Float,
        maximum: Float
    ) -> Float? {
        guard ThermostatTemperatureRange.isValid(minimum: minimum, maximum: maximum), isFinite else { return nil }
        guard ThermostatTemperatureRange.isAdjustable(minimum: minimum, maximum: maximum) else {
            return ThermostatTemperatureRange.isCollapsed(minimum: minimum, maximum: maximum) ? minimum : nil
        }
        return clamped(to: minimum...maximum)
    }

    func isInThermostatRange(
        minimum: Float,
        maximum: Float
    ) -> Bool {
        ThermostatTemperatureRange.isValid(minimum: minimum, maximum: maximum) && isFinite &&
            self >= minimum && self <= maximum
    }
}
