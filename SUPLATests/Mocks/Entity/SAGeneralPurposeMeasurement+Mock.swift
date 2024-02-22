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

@testable import SUPLA

extension SAGeneralPurposeMeasurementItem {
    static func mock(
        date: Date? = nil,
        valueAverage: Double? = nil,
        valueMin: Double? = nil,
        valueMax: Double? = nil,
        valueOpen: Double? = nil,
        valueClose: Double? = nil
    ) -> SAGeneralPurposeMeasurementItem {
        let entity = SAGeneralPurposeMeasurementItem(testContext: nil)
        entity.date = date
        if let value = valueAverage { entity.value_average = NSDecimalNumber(value: value) }
        if let value = valueMin { entity.value_min = NSDecimalNumber(value: value) }
        if let value = valueMax { entity.value_max = NSDecimalNumber(value: value) }
        if let value = valueOpen { entity.value_open = NSDecimalNumber(value: value) }
        if let value = valueClose { entity.value_close = NSDecimalNumber(value: value) }
        
        return entity
    }
}
