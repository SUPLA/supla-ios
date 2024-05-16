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

extension SAChannelGroup {
    @objc var activePercentage: Int {
        self.getActivePercentage()
    }
    
    @objc var positions: [Int] {
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        if (!isRollerShutter()) {
            return []
        }
        
        return totalValue.values
            .map {
                if let value = $0 as? FacadeBlindGroupValue {
                    return value.position
                }
                if let value = $0 as? RollerShutterGroupValue {
                    return value.closedSensorActive ? 100 : value.position
                }
                
                return 0
            }
    }
    
    @objc var colors: [UIColor] {
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        if (self.func != SUPLA_CHANNELFNC_RGBLIGHTING && self.func != SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING) {
            return []
        }
        
        return totalValue.values
            .map {
                if let value = $0 as? RgbLightingGroupValue {
                    return value.color
                }
                if let value = $0 as? DimmerAndRgbLightingGroupValue {
                    return value.color
                }
                
                return UIColor.transparent
            }
    }
    
    @objc var colorBrightness: [Int] {
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        if (self.func != SUPLA_CHANNELFNC_RGBLIGHTING && self.func != SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING) {
            return []
        }
        
        return totalValue.values
            .map {
                if let value = $0 as? RgbLightingGroupValue {
                    return value.brightness
                }
                if let value = $0 as? DimmerAndRgbLightingGroupValue {
                    return value.colorBrightness
                }
                
                return 0
            }
    }
    
    @objc var brightness: [Int] {
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        
        if (self.func != SUPLA_CHANNELFNC_DIMMER && self.func != SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING) {
            return []
        }
        
        return totalValue.values
            .map {
                if let value = $0 as? IntegerGroupValue {
                    return value.value
                }
                if let value = $0 as? DimmerAndRgbLightingGroupValue {
                    return value.brightness
                }
                
                return 0
            }
    }
    
    func item() -> ItemBundle {
        ItemBundle(remoteId: remote_id, deviceId: 0, subjectType: .group, function: self.func)
    }
    
    override open func imgIsActive() -> Int32 {
        if (self.func == SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING) {
            var active: Int32 = 0
            if (self.getActivePercentage(idx: 2) >= 100) {
                active = 0x1
            }
            if (self.getActivePercentage(idx: 1) >= 100) {
                active = active | 0x2
            }
            return active
        }
        
        return self.activePercentage >= 100 ? 1 : 0
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

    func getActivePercentage(idx: Int = 0) -> Int {
        guard let groupTotalValue = total_value as? GroupTotalValue else { return 0 }
        
        if (groupTotalValue.values.isEmpty) {
            return 0
        }

        switch (self.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
             SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER,
             SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
            return groupTotalValue.values
                .map { $0 as! BoolGroupValue }
                .reduce(0) { result, value in
                    value.value ? result + 1 : result
                } * 100 / groupTotalValue.values.count
        case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
            return groupTotalValue.values
                .map { $0 as! IntegerGroupValue }
                .reduce(0) { result, value in
                    value.value >= 100 ? result + 1 : result
                } * 100 / groupTotalValue.values.count
        case SUPLA_CHANNELFNC_DIMMER:
            return groupTotalValue.values
                .map { $0 as! IntegerGroupValue }
                .reduce(0) { result, value in
                    value.value > 0 ? result + 1 : result
                } * 100 / groupTotalValue.values.count
        case SUPLA_CHANNELFNC_RGBLIGHTING:
            return groupTotalValue.values
                .map { $0 as! RgbLightingGroupValue }
                .reduce(0) { result, value in
                    value.brightness > 0 ? result + 1 : result
                } * 100 / groupTotalValue.values.count
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return groupTotalValue.values
                .map { $0 as! DimmerAndRgbLightingGroupValue }
                .reduce(0) { result, value in
                    var sum = result
                    if (idx == 0 || idx == 1) {
                        sum = value.colorBrightness >= 0 ? result + 1 : result
                    }
                    if (idx == 0 || idx == 2) {
                        sum = value.brightness >= 0 ? result + 1 : result
                    }
                    return sum
                } * 100 / (idx == 0 ? groupTotalValue.values.count * 2 : groupTotalValue.values.count)
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            return groupTotalValue.values
                .map { $0 as! RollerShutterGroupValue }
                .reduce(0) { result, value in
                    value.position >= 100 || value.closedSensorActive ? result + 1 : result
                } * 100 / groupTotalValue.values.count
        case SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND:
            return groupTotalValue.values
                .map { $0 as! FacadeBlindGroupValue }
                .reduce(0) { result, value in
                    value.position >= 100 ? result + 1 : result
                } * 100 / groupTotalValue.values.count
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            return groupTotalValue.values
                .map { $0 as! HeatpolThermostatGroupValue }
                .reduce(0) { result, value in
                    value.on ? result + 1 : result
                } * 100 / groupTotalValue.values.count
        default:
            return 0
        }
    }
}

fileprivate extension BaseGroupValue {
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
