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

final class RainValueStringProvider: ChannelValueStringProvider {
    @Singleton<RainValueProvider> private var rainValueProvider
    
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 1
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter
    }()
    
    func handle(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_RAINSENSOR
    }
    
    func value(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String {
        if let value = rainValueProvider.value(channel, valueType: valueType) as? Double,
           value > RainValueProviderImpl.UNKNOWN_VALUE,
           let stringValue = formatter.string(from: NSNumber(value: value / 1000.0))
        {
            return withUnit ? "\(stringValue) l/m²" : stringValue
        } else {
            return NO_VALUE_TEXT
        }
    }
}
