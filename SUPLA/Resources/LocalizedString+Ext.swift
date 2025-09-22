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

extension LocalizedString {
    var string: String {
        switch onEnum(of: self) {
        case .constant(let item): item.text
        case .withId(let item): item.toString()
        case .withIdIntStringInt(let item): item.id.value.arguments(item.arg1, item.arg2.string, item.arg3)
        case .withIdAndString(let item): "\(item.id.value) \(item.string)"
        case .empty(_), .else: ""
        }
    }

}

private extension LocalizedStringWithId {
    func toString() -> String {
        var text = id.value
        for argument in arguments {
            text = format(text, argument)
        }
        return text
    }
    
    private func format(_ text: String, _ argument: Any) -> String {
        if let localizedString = argument as? LocalizedString {
            return localizedString.string
        } else if let string = argument as? String {
            return text.arguments(string)
        } else if let number = argument as? NSNumber {
            return switch (number.type) {
            case .sInt8Type, .charType: text.arguments(number.int8Value)
            case .sInt16Type, .shortType: text.arguments(number.int16Value)
            case .sInt32Type: text.arguments(number.int32Value)
            case .sInt64Type, .longType, .longLongType: text.arguments(number.int64Value)
            case .intType, .nsIntegerType:
                text.arguments(number.intValue)
            case .doubleType:
                text.arguments(number.doubleValue)
            case .floatType, .float32Type, .float64Type, .cgFloatType:
                text.arguments(number.floatValue)
            case .cfIndexType:
                fatalError("Unsupported argument type: \(type(of: argument))")
            @unknown default:
                fatalError("Unsupported argument type: \(type(of: argument))")
            }
        } else {
            fatalError("Unsupported argument type: \(type(of: argument))")
        }
    }
}

private extension NSNumber {
    var type: CFNumberType {
        return CFNumberGetType(self as CFNumber)
    }
}
