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

public extension LocalizedString {
    var string: String {
        switch onEnum(of: self) {
        case .constant(let item): item.text
        case .withId(let item): item.toString()
        case .withFormat(let item): item.toString()
        case .empty(_), .else: ""
        }
    }

}

private extension LocalizedStringWithId {
    func toString() -> String {
        switch (arguments.count) {
        case 1: return id.value.arguments(toArgument(arguments[0]))
        case 2: return id.value.arguments(toArgument(arguments[0]), toArgument(arguments[1]))
        case 3: return id.value.arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]))
        case 4: return id.value.arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]), toArgument(arguments[3]))
        case 5: return id.value.arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]), toArgument(arguments[3]), toArgument(arguments[4]))
        case 6: return id.value.arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]), toArgument(arguments[3]), toArgument(arguments[4]), toArgument(arguments[5]))
        default: return id.value
        }
    }
    
    private func toArgument(_ argument: Any) -> CVarArg {
        if let localizedString = argument as? LocalizedString {
            return localizedString.string
        } else if let string = argument as? String {
            return string
        } else if let number = argument as? NSNumber {
            return switch (number.type) {
            case .sInt8Type, .charType: number.int8Value
            case .sInt16Type, .shortType: number.int16Value
            case .sInt32Type: number.int32Value
            case .sInt64Type, .longType, .longLongType: number.int64Value
            case .intType, .nsIntegerType: number.intValue
            case .doubleType: number.doubleValue
            case .floatType, .float32Type, .float64Type, .cgFloatType: number.floatValue
            case .cfIndexType: fatalError("Unsupported argument type: \(type(of: argument))")
            @unknown default: fatalError("Unsupported argument type: \(type(of: argument))")
            }
        } else {
            fatalError("Unsupported argument type: \(type(of: argument))")
        }
    }
}

private extension LocalizedStringWithFormat {
    func toString() -> String {
        switch (arguments.count) {
        case 1: return format.replacingOccurrences(of: "%s", with: "%@").arguments(toArgument(arguments[0]))
        case 2: return format.replacingOccurrences(of: "%s", with: "%@").arguments(toArgument(arguments[0]), toArgument(arguments[1]))
        case 3: return format.replacingOccurrences(of: "%s", with: "%@").arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]))
        case 4: return format.replacingOccurrences(of: "%s", with: "%@").arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]), toArgument(arguments[3]))
        case 5: return format.replacingOccurrences(of: "%s", with: "%@").arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]), toArgument(arguments[3]), toArgument(arguments[4]))
        case 6: return format.replacingOccurrences(of: "%s", with: "%@").arguments(toArgument(arguments[0]), toArgument(arguments[1]), toArgument(arguments[2]), toArgument(arguments[3]), toArgument(arguments[4]), toArgument(arguments[5]))
        default: return format
        }
    }
    
    private func toArgument(_ argument: Any) -> CVarArg {
        if let localizedString = argument as? LocalizedString {
            return localizedString.string
        } else if let string = argument as? String {
            return string
        } else if let number = argument as? NSNumber {
            return switch (number.type) {
            case .sInt8Type, .charType: number.int8Value
            case .sInt16Type, .shortType: number.int16Value
            case .sInt32Type: number.int32Value
            case .sInt64Type, .longType, .longLongType: number.int64Value
            case .intType, .nsIntegerType: number.intValue
            case .doubleType: number.doubleValue
            case .floatType, .float32Type, .float64Type, .cgFloatType: number.floatValue
            case .cfIndexType: fatalError("Unsupported argument type: \(type(of: argument))")
            @unknown default: fatalError("Unsupported argument type: \(type(of: argument))")
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
