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

final class ImpulseCounterChartValueFormatter: ChannelValueFormatter {
    
    private let unit: String?
    
    init(unit: String? = nil) {
        self.unit = unit
    }
    
    func handle(function: Int32) -> Bool {
        switch (function) {
        case SUPLA_CHANNELFNC_IC_GAS_METER,
             SUPLA_CHANNELFNC_IC_HEAT_METER,
             SUPLA_CHANNELFNC_IC_WATER_METER,
             SUPLA_CHANNELFNC_IC_ELECTRICITY_METER: true
        default: false
        }
    }

    func format(_ value: Any?, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        if let doubleValue = value as? Double {
            let precision = getPrecision(precision)

            return if (withUnit), let unit {
                "\(doubleValue.toString(precision: precision)) \(unit)"
            } else {
                doubleValue.toString(precision: precision)
            }
        } else {
            return NO_VALUE_TEXT
        }
    }
    
    func formatChartLabel(_ value: Any?, precision: Int, withUnit: Bool) -> String {
        format(value, withUnit: withUnit, precision: .defaultPrecision(value: precision), custom: nil)
    }

    private func getPrecision(_ precision: ChannelValuePrecision) -> Int {
        switch (precision) {
        case .defaultPrecision(_): 3
        case .customPrecision(let value): value
        }
    }
}
