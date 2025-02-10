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
    
final class VoltageValueFormatter: ChannelValueFormatter {
    func handle(function: Int32) -> Bool {
        fatalError("Not expected to be called")
    }
    
    func format(_ value: Any, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        guard let doubleValue = value as? Double else {
            return NO_VALUE_TEXT
        }
        
        return if (withUnit) {
            doubleValue.toString(precision: precision.value) + " V"
        } else {
            doubleValue.toString(precision: precision.value)
        }
    }
}
