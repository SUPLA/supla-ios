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

final class HumidityValueFormatter: ChannelValueFormatter {
    func handle(function: Int) -> Bool {
        function == SUPLA_CHANNELFNC_HUMIDITY
    }

    func format(_ value: Any, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        if let doubleValue = value as? Double,
           doubleValue > HumidityValueProviderImpl.UNKNOWN_VALUE
        {
            let precision = getPrecision(precision)
            
            return if (withUnit) {
                "\(doubleValue.toString(precision: precision))%"
            } else {
                doubleValue.toString(precision: precision)
            }
        } else {
            return NO_VALUE_TEXT
        }
    }

    private func getPrecision(_ precision: ChannelValuePrecision) -> Int {
        switch (precision) {
        case .defaultPrecision(let value): value
        case .customPrecision(let value): value
        }
    }
}
