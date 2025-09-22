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

extension SharedCore.ImpulseCounterValueFormatter {
    static func staticFormatter(_ channelWithChildren: ChannelWithChildren) -> SharedCore.ValueFormatter {
        SharedCore.ImpulseCounterValueFormatter(
            defaultFormatSpecification: ValueFormatSpecification(
                precision: ValuePrecisionKt.ImpulseCounterPrecision,
                withUnit: true,
                unit: channelWithChildren.unit,
                predecessor: nil,
                showNoValueText: true
            )
        )
    }
}

private extension ChannelWithChildren {
    var unit: String? {
        let unit = if (channel.isImpulseCounter()) {
            channel.ev?.impulseCounter().unit()
        } else {
            children.first { $0.relationType == .meter }?.channel.ev?.impulseCounter().unit()
        }
        
        if let unit {
            return " \(unit)"
        } else {
            return nil
        }
    }
}
