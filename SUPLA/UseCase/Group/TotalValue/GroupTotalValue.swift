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

import Foundation

class GroupTotalValue: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    var values: [BaseGroupValue]
    
    override init() {
        values = []
    }
    
    init(values: [BaseGroupValue]) {
        self.values = values
    }
    
    required init?(coder: NSCoder) {
        values = coder.decodeObject(
            of: [
                NSArray.self,
                RollerShutterGroupValue.self,
                FacadeBlindGroupValue.self,
                IntegerGroupValue.self,
                BoolGroupValue.self,
                RgbLightingGroupValue.self,
                DimmerAndRgbLightingGroupValue.self,
                HeatpolThermostatGroupValue.self
            ],
            forKey: Key.values.rawValue
        ) as? [BaseGroupValue] ?? []
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(values, forKey: Key.values.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GroupTotalValue else { return false }
        return other.values == values
    }
    
    enum Key: String, CodingKey {
        case values
    }
}

@objc class BaseGroupValue: NSObject {}

@objc class RollerShutterGroupValue: BaseGroupValue, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    @objc let position: Int
    @objc let closedSensorActive: Bool
    
    init(position: Int, openSensorActive: Bool) {
        self.position = position
        self.closedSensorActive = openSensorActive
        super.init()
    }
    
    required init?(coder: NSCoder) {
        position = coder.decodeInteger(forKey: Keys.position.rawValue)
        closedSensorActive = coder.decodeBool(forKey: Keys.openSensorActive.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(position, forKey: Keys.position.rawValue)
        coder.encode(closedSensorActive, forKey: Keys.openSensorActive.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? RollerShutterGroupValue else { return false }
        return other.position == position && other.closedSensorActive == closedSensorActive
    }
    
    enum Keys: String, CodingKey {
        case position
        case openSensorActive
    }
}

@objc class FacadeBlindGroupValue: BaseGroupValue, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    @objc let position: Int
    @objc let tilt: Int
    
    init(position: Int, tilt: Int) {
        self.position = position
        self.tilt = tilt
        super.init()
    }
    
    required init?(coder: NSCoder) {
        position = coder.decodeInteger(forKey: Keys.position.rawValue)
        tilt = coder.decodeInteger(forKey: Keys.tilt.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(position, forKey: Keys.position.rawValue)
        coder.encode(tilt, forKey: Keys.tilt.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FacadeBlindGroupValue else { return false }
        return other.position == position && other.tilt == tilt
    }
    
    enum Keys: String, CodingKey {
        case position
        case tilt
    }
}

@objc class IntegerGroupValue: BaseGroupValue, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    @objc let value: Int
    
    init(value: Int) {
        self.value = value
        super.init()
    }
    
    required init?(coder: NSCoder) {
        value = coder.decodeInteger(forKey: Keys.value.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(value, forKey: Keys.value.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? IntegerGroupValue else { return false }
        return other.value == value
    }
    
    enum Keys: String, CodingKey {
        case value
    }
}

@objc class BoolGroupValue: BaseGroupValue, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    @objc let value: Bool
    
    init(value: Bool) {
        self.value = value
        super.init()
    }
    
    required init?(coder: NSCoder) {
        value = coder.decodeBool(forKey: Keys.value.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(value, forKey: Keys.value.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BoolGroupValue else { return false }
        return other.value == value
    }
    
    enum Keys: String, CodingKey {
        case value
    }
}

@objc class RgbLightingGroupValue: BaseGroupValue, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    @objc let color: UIColor
    @objc let brightness: Int
    
    init(color: UIColor, brightness: Int) {
        self.color = color
        self.brightness = brightness
        super.init()
    }
    
    required init?(coder: NSCoder) {
        color = UIColor(argb: coder.decodeInteger(forKey: Keys.color.rawValue))
        brightness = coder.decodeInteger(forKey: Keys.brightness.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(color.argbInt, forKey: Keys.color.rawValue)
        coder.encode(brightness, forKey: Keys.brightness.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? RgbLightingGroupValue else { return false }
        return other.color.argbInt == color.argbInt && other.brightness == brightness
    }
    
    enum Keys: String, CodingKey {
        case color
        case brightness
    }
}

@objc class DimmerAndRgbLightingGroupValue: BaseGroupValue, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    @objc let color: UIColor
    @objc let colorBrightness: Int
    @objc let brightness: Int
    
    init(color: UIColor, colorBrightness: Int, brightness: Int) {
        self.color = color
        self.colorBrightness = colorBrightness
        self.brightness = brightness
        super.init()
    }
    
    required init?(coder: NSCoder) {
        color = UIColor(argb: coder.decodeInteger(forKey: Keys.color.rawValue))
        colorBrightness = coder.decodeInteger(forKey: Keys.colorBrightness.rawValue)
        brightness = coder.decodeInteger(forKey: Keys.brightness.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(color.argbInt, forKey: Keys.color.rawValue)
        coder.encode(colorBrightness, forKey: Keys.colorBrightness.rawValue)
        coder.encode(brightness, forKey: Keys.brightness.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DimmerAndRgbLightingGroupValue else { return false }
        return other.color.argbInt == color.argbInt && other.colorBrightness == colorBrightness && other.brightness == brightness
    }
    
    enum Keys: String, CodingKey {
        case color
        case colorBrightness
        case brightness
    }
}

@objc class HeatpolThermostatGroupValue: BaseGroupValue, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    @objc let on: Bool
    @objc let measuredTemperature: Float
    @objc let presetTemperature: Float
    
    init(on: Bool, measuredTemperature: Float, presetTemperature: Float) {
        self.on = on
        self.measuredTemperature = measuredTemperature
        self.presetTemperature = presetTemperature
        super.init()
    }
    
    required init?(coder: NSCoder) {
        on = coder.decodeBool(forKey: Keys.on.rawValue)
        measuredTemperature = coder.decodeFloat(forKey: Keys.measuredTemperature.rawValue)
        presetTemperature = coder.decodeFloat(forKey: Keys.presetTemperature.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(on, forKey: Keys.on.rawValue)
        coder.encode(measuredTemperature, forKey: Keys.measuredTemperature.rawValue)
        coder.encode(presetTemperature, forKey: Keys.presetTemperature.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HeatpolThermostatGroupValue else { return false }
        return other.on == on && other.measuredTemperature == measuredTemperature && other.presetTemperature == presetTemperature
    }
    
    enum Keys: String, CodingKey {
        case on
        case measuredTemperature
        case presetTemperature
    }
}
