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
    
struct ElectricityMeterSettings: Codable {
    let currentMonthBalancing: ElectricityMeterBalanceType
    let metricOnList: ElectricityMeterMeasurementType
    let metricOnListBalancing: ElectricityMeterBalanceType
    let metricOnListAggregation: ListValueAggregation
    
    var usingAggregatedValue: Bool {
        metricOnList == .activeEnergyBalance || (metricOnList.aggregationAvailable && metricOnListAggregation != .noAggregation)
    }
    
    func copy(
        currentMonthBalancing: ElectricityMeterBalanceType? = nil,
        metricOnList: ElectricityMeterMeasurementType? = nil,
        metricOnListBalancing: ElectricityMeterBalanceType? = nil,
        metricOnListAggregation: ListValueAggregation? = nil
    ) -> ElectricityMeterSettings {
        ElectricityMeterSettings(
            currentMonthBalancing: currentMonthBalancing ?? self.currentMonthBalancing,
            metricOnList: metricOnList ?? self.metricOnList,
            metricOnListBalancing: metricOnListBalancing ?? self.metricOnListBalancing,
            metricOnListAggregation: metricOnListAggregation ?? self.metricOnListAggregation
        )
    }
    
    static func defaultSettings() -> ElectricityMeterSettings {
        ElectricityMeterSettings(
            currentMonthBalancing: .defaultValue,
            metricOnList: .forwardActiveEnergy,
            metricOnListBalancing: .arithmetic,
            metricOnListAggregation: .noAggregation
        )
    }
    
    static var balancingAllItems: [ElectricityMeterBalanceType] {
        [.vector, .arithmetic, .hourly]
    }
}

struct ElectricityMeterSettingsV1: Codable {
    let showOnList: SuplaElectricityMeasurementType
    let balancing: ElectricityMeterBalanceType
    
    var settings: ElectricityMeterSettings {
        ElectricityMeterSettings(
            currentMonthBalancing: balancing,
            metricOnList: showOnList.showOnListType,
            metricOnListBalancing: .arithmetic,
            metricOnListAggregation: .noAggregation
        )
    }
}

enum ElectricityMeterBalanceType: Int, Codable, PickerItem {
    case defaultValue, vector, arithmetic, hourly
    
    var id: Int { rawValue }
    
    var label: String {
        switch self {
        case .defaultValue: return ""
        case .vector: return Strings.ElectricityMeter.balanceVector
        case .arithmetic: return Strings.ElectricityMeter.balanceArithmetic
        case .hourly: return Strings.ElectricityMeter.balanceHourly
        }
    }
}

private extension SuplaElectricityMeasurementType {
    var showOnListType: ElectricityMeterMeasurementType {
        switch self {
        case .voltage: .voltage
        case .current: .current
        case .powerActive,
             .powerActiveKw: .powerActive
        case .reverseActiveEnergy: .reverseActiveEnergy
        case .forwardReactiveEnergy: .forwardReactiveEnergy
        case .reverseReactiveEnergy: .reverseReactiveEnergy
        case .forwardActiveEnergyBanalced: .activeEnergyBalance
        case .reverseActiveEnergyBalanced: .activeEnergyBalance
        case .frequency,
             .powerReactive,
             .powerApparent,
             .powerFactor,
             .phaseAngle,
             .currentOver65a,
             .voltagePhaseAngle12,
             .voltagePhaseAngle13,
             .voltagePhaseSequence,
             .currentPhaseSequence,
             .powerReactiveKvar,
             .powerApparentKva,
             .forwardActiveEnergy: .forwardActiveEnergy
        }
    }
}

