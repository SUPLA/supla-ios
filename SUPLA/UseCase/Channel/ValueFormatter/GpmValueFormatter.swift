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

final class GpmValueFormatter: ChannelValueFormatter {
    private let beforeValue: String
    private let afterValue: String
    private let precision: Int

    init(config: SuplaChannelGeneralPurposeBaseConfig?) {
        let unitBefore = config?.unitBeforValue ?? ""
        self.beforeValue = config?.noSpaceBeforeValue ?? false ? unitBefore : "\(unitBefore) "
        let unitAfter = config?.unitAfterValue ?? ""
        self.afterValue = config?.noSpaceAfterValue ?? false ? unitAfter : " \(unitAfter)"
        self.precision = Int(config?.valuePrecision ?? 2)
    }

    func handle(function: Int) -> Bool {
        function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT ||
            function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
    }

    func format(_ value: Any, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        guard let doubleValue = value as? Double else { return NO_VALUE_TEXT }
        if (doubleValue.isNaN) {
            return NO_VALUE_TEXT
        }

        let formatterValue = doubleValue.toString(precision: self.precision)
        if (withUnit) {
            return "\(beforeValue)\(formatterValue)\(afterValue)"
        } else {
            return formatterValue
        }
    }
}
