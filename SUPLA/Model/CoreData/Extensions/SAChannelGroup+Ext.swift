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

extension SAChannelGroup {
    var hasBrightness: Bool {
        switch (self.func) {
            case SUPLA_CHANNELFNC_DIMMER,
                 SUPLA_CHANNELFNC_DIMMER_CCT,
                 SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING,
                 SUPLA_CHANNELFNC_DIMMER_CCT_AND_RGB: true
            default: false
        }
    }
    
    var hasColor: Bool {
        switch (self.func) {
            case SUPLA_CHANNELFNC_RGBLIGHTING,
                 SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING,
                 SUPLA_CHANNELFNC_DIMMER_CCT_AND_RGB: true
            default: false
        }
    }

    @objc var positions: [Int] {
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        if (!isShadingSystem()) {
            return []
        }
        
        return totalValue.values
            .map {
                if let value = $0 as? ShadowingBlindGroupValue {
                    return value.position
                }
                if let value = $0 as? ShadingSystemGroupValue {
                    return value.closedSensorActive ? 100 : value.position
                }
                
                return 0
            }
    }
    
    @objc var colors: [UIColor] {
        if (!hasColor) {
            return []
        }
        
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        return totalValue.values
            .compactMap {
                if let value = $0 as? RgbLightingGroupValue {
                    return value.color
                }
                if let value = $0 as? DimmerAndRgbLightingGroupValue {
                    return value.color
                }
                if let value = $0 as? DimmerCctAndRgbGroupValue {
                    return value.color
                }
                
                return nil
            }
    }
    
    var hsvColors: [HsvColor] {
        if (!hasColor) {
            return []
        }
        
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        let result = totalValue.values
            .compactMap {
                if let value = $0 as? RgbLightingGroupValue,
                   let hsv = value.color.toHsv(Int32(value.brightness))
                {
                    return hsv
                }
                if let value = $0 as? DimmerAndRgbLightingGroupValue,
                   let hsv = value.color.toHsv(Int32(value.colorBrightness))
                {
                    return hsv
                }
                if let value = $0 as? DimmerCctAndRgbGroupValue,
                   let hsv = value.color.toHsv(Int32(value.colorBrightness))
                {
                    return hsv
                }
                
                return nil
            }
        
        return Array(Set(result))
    }
    
    @objc var colorBrightness: [Int] {
        if (!hasColor) {
            return []
        }
        
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        return totalValue.values
            .map {
                if let value = $0 as? RgbLightingGroupValue {
                    return value.brightness
                }
                if let value = $0 as? DimmerAndRgbLightingGroupValue {
                    return value.colorBrightness
                }
                if let value = $0 as? DimmerCctAndRgbGroupValue {
                    return value.colorBrightness
                }
                
                return 0
            }
    }
    
    @objc var brightness: [Int] {
        if (!hasBrightness) {
            return []
        }
        
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        let result = totalValue.values
            .compactMap {
                if let value = $0 as? IntegerGroupValue {
                    return value.value
                }
                if let value = $0 as? DimmerCctGroupValue {
                    return value.brightness
                }
                if let value = $0 as? DimmerAndRgbLightingGroupValue {
                    return value.brightness
                }
                if let value = $0 as? DimmerCctAndRgbGroupValue {
                    return value.brightness
                }
                
                return nil
            }
        
        return Array(Set(result))
    }
    
    @objc var cct: [Int] {
        if (self.func != SUPLA_CHANNELFNC_DIMMER_CCT && self.func != SUPLA_CHANNELFNC_DIMMER_CCT_AND_RGB) {
            return []
        }
        
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        let result = totalValue.values
            .compactMap {
                if let value = $0 as? DimmerCctGroupValue {
                    return value.cct
                }
                if let value = $0 as? DimmerCctAndRgbGroupValue {
                    return value.cct
                }
                
                return nil
            }
        
        return Array(Set(result))
    }
    
    func item() -> ItemBundle {
        ItemBundle(remoteId: remote_id, deviceId: 0, subjectType: .group, function: self.func)
    }
    
    override open func measuredTemperatureMin() -> Double {
        guard let totalValue = total_value as? GroupTotalValue else {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        let temperaturesOnly = totalValue.values
            .map { $0.asMeasuredTemperature() }
            .compactMap { $0 }
        
        if (temperaturesOnly.isEmpty) {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        return temperaturesOnly
            .reduce(Double.greatestFiniteMagnitude) { result, measuredTemperature in
                if (measuredTemperature < result) {
                    return Double(measuredTemperature)
                }
                
                return result
            }
    }
    
    override open func presetTemperatureMin() -> Double {
        guard let totalValue = total_value as? GroupTotalValue else {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        let temperaturesOnly = totalValue.values
            .map { $0.asPresetTemperature() }
            .compactMap { $0 }
        
        if (temperaturesOnly.isEmpty) {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        return temperaturesOnly
            .reduce(Double.greatestFiniteMagnitude) { result, measuredTemperature in
                if (measuredTemperature < result) {
                    return Double(measuredTemperature)
                }
                
                return result
            }
    }
    
    override open func measuredTemperatureMax() -> Double {
        guard let totalValue = total_value as? GroupTotalValue else {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        let temperaturesOnly = totalValue.values
            .map { $0.asMeasuredTemperature() }
            .compactMap { $0 }
        
        if (temperaturesOnly.isEmpty) {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        return temperaturesOnly
            .reduce(ThermometerValueProviderImpl.UNKNOWN_VALUE) { result, measuredTemperature in
                if (measuredTemperature > result) {
                    return Double(measuredTemperature)
                }
                
                return result
            }
    }
    
    override open func presetTemperatureMax() -> Double {
        guard let totalValue = total_value as? GroupTotalValue else {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        let temperaturesOnly = totalValue.values
            .map { $0.asPresetTemperature() }
            .compactMap { $0 }
        
        if (temperaturesOnly.isEmpty) {
            return Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
        }
        
        return temperaturesOnly
            .reduce(ThermometerValueProviderImpl.UNKNOWN_VALUE) { result, measuredTemperature in
                if (measuredTemperature > result) {
                    return Double(measuredTemperature)
                }
                
                return result
            }
    }
    
    var shareable: SharedCore.Group {
        SharedCore.Group(
            remoteId: remote_id,
            caption: caption ?? "",
            function: self.func.suplaFuntion
        )
    }
}

private extension BaseGroupValue {
    func asMeasuredTemperature() -> Double? {
        if let value = self as? HeatpolThermostatGroupValue {
            return Double(value.measuredTemperature)
        }
        
        return nil
    }
    
    func asPresetTemperature() -> Double? {
        if let value = self as? HeatpolThermostatGroupValue {
            return Double(value.presetTemperature)
        }
        
        return nil
    }
}
