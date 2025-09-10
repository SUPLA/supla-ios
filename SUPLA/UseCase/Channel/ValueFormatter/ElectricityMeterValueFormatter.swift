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

final class ListElectricityMeterValueFormatter: BaseElectricityMeterValueFormatter {
    
    let useNoValue: Bool?
    
    init(useNoValue: Bool? = nil) {
        self.useNoValue = useNoValue
    }
    
    override func format(_ value: Any?, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        let unit: String? = withUnit ? getUnit(custom: custom) : nil
        let checkNoValue = checkNoValue(custom)
        
        if let value = value as? Double {
            let precision = getPrecision(value, precision: precision)
            return format(value, unit: unit, precision: precision, checkNoValue: checkNoValue)
        }
        
        return format(0.0, unit: unit, precision: 0, checkNoValue: checkNoValue)
    }
    
    private func checkNoValue(_ any: Any?) -> Bool {
        if let useNoValue = useNoValue {
            return useNoValue
        }
        if let type = any as? SuplaElectricityMeasurementType {
            return type == .forwardActiveEnergy
        }
        return false
    }
    
    private func getUnit(custom: Any?) -> String {
        if let electricityMeasurementType = custom as? SuplaElectricityMeasurementType {
            return electricityMeasurementType.unit
        } else if let unit = custom as? FormatterUnit {
            switch (unit) {
            case .custom(let stringValue): return stringValue ?? "kWh"
            }
        } else {
            return "kWh"
        }
    }
}

final class ChartAxisElectricityMeterValueFormatter: BaseElectricityMeterValueFormatter {
    
    override func format(_ value: Any?, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        if let value = value as? Double {
            return format(value, unit: withUnit ? "kWh" : nil, precision: value == 0.0 ? 0 : precision.value, checkNoValue: false)
        }
        
        return format(0.0, unit: withUnit ? "kWh" : nil, precision: 0, checkNoValue: false)
    }
}
    
class BaseElectricityMeterValueFormatter: ChannelValueFormatter {
    
    func handle(function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_ELECTRICITY_METER
    }
    
    func format(_ value: Any?, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        fatalError("format(_:withUnit:precision:) has not been implemented!")
    }
    
    func formatChartLabel(_ value: Any?, precision: Int, withUnit: Bool) -> String {
        format(value, withUnit: withUnit, precision: .defaultPrecision(value: precision), custom: nil)
    }
    
    fileprivate func format(_ value: Double, unit: String?, precision: Int, checkNoValue: Bool = true) -> String {
        if (value.isNaN) {
            // Nan is possible when user selected other type than default (ex voltage) and currently there is no data
            return NO_VALUE_TEXT
        }
        if (checkNoValue && value == ElectricityMeterValueProviderImpl.UNKNOWN_VALUE) {
            return NO_VALUE_TEXT
        }
        
        return if let unit {
            "\(value.toString(precision: precision)) \(unit)"
        } else {
            value.toString(precision: precision)
        }
    }
    
    fileprivate func getPrecision(_ value: Double, precision: ChannelValuePrecision) -> Int {
        switch precision {
        case .defaultPrecision:
            return if (abs(value) < 100) {
                2
            } else if (abs(value) < 1000) {
                1
            } else {
                0
            }
        case .customPrecision(let precision):
            return precision
        }
    }
}
