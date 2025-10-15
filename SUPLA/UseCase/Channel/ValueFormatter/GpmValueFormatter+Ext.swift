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

import SharedCore

extension SharedCore.GpmValueFormatter {
    static func staticFormatter(_ config: SuplaChannelConfig?) -> SharedCore.GpmValueFormatter {
        let gpmConfig = config as? SuplaChannelGeneralPurposeBaseConfig
        
        return SharedCore.GpmValueFormatter(
            defaultFormatSpecification: ValueFormatSpecification(
                precision: ValuePrecisionKt.exactPrecision(value: Int32(gpmConfig?.valuePrecision ?? 2)),
                withUnit: true,
                unit: gpmConfig?.unit,
                predecessor: gpmConfig?.predecessor,
                showNoValueText: true
            )
        )
    }
}

private extension SuplaChannelGeneralPurposeBaseConfig {
    var unit: String? {
        if (unitAfterValue.isEmpty) {
            nil
        } else if (noSpaceAfterValue) {
            unitAfterValue
        } else {
            " \(unitAfterValue)"
        }
    }
    
    var predecessor: String? {
        if (unitBeforValue.isEmpty) {
            nil
        } else if (noSpaceBeforeValue) {
            unitBeforValue
        } else {
            "\(unitBeforValue) "
        }
    }
}
