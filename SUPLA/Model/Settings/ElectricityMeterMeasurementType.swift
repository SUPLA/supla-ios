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

enum ElectricityMeterMeasurementType: Int, Codable, CaseIterable, PickerItem {
    case forwardActiveEnergy
    case reverseActiveEnergy
    case forwardReactiveEnergy
    case reverseReactiveEnergy
    case activeEnergyBalance
    case powerActive
    case current
    case voltage
    
    var id: Int { rawValue }
    
    var label: String {
        switch self {
        case .forwardActiveEnergy: Strings.ElectricityMeter.forwardActiveEnergy
        case .reverseActiveEnergy: Strings.ElectricityMeter.reverseActiveEnergy
        case .forwardReactiveEnergy: Strings.ElectricityMeter.forwardReactiveEnergy
        case .reverseReactiveEnergy: Strings.ElectricityMeter.reverseReactiveEnergy
        case .activeEnergyBalance: Strings.ElectricityMeter.activeEnergyBalance
        case .powerActive: Strings.ElectricityMeter.powerActive
        case .current: Strings.ElectricityMeter.current
        case .voltage: Strings.ElectricityMeter.voltage
        }
    }

    var aggregationOptions: [ListValueAggregation] {
        if (aggregationAvailable) {
            ListValueAggregation.allCases.filter { self != .activeEnergyBalance || $0 != .noAggregation }
        } else {
            []
        }
    }

    var balancingAvailable: Bool {
        switch self {
        case .forwardActiveEnergy,
             .reverseActiveEnergy: true
        case .forwardReactiveEnergy,
             .reverseReactiveEnergy,
             .activeEnergyBalance,
             .powerActive,
             .current,
             .voltage: false
        }
    }

    var aggregationAvailable: Bool {
        switch self {
        case .forwardActiveEnergy,
             .reverseActiveEnergy,
             .forwardReactiveEnergy,
             .reverseReactiveEnergy,
             .activeEnergyBalance: true
        case .powerActive,
             .current,
             .voltage: false
        }
    }
    
    var suplaType: SuplaElectricityMeasurementType {
        switch self {
        case .forwardActiveEnergy: .forwardActiveEnergy
        case .reverseActiveEnergy: .reverseActiveEnergy
        case .forwardReactiveEnergy: .forwardReactiveEnergy
        case .reverseReactiveEnergy: .reverseReactiveEnergy
        case .activeEnergyBalance: .forwardActiveEnergyBanalced
        case .powerActive: .powerActive
        case .current: .current
        case .voltage: .voltage
        }
    }

    func inside(_ measuredValues: [SuplaElectricityMeasurementType]) -> Bool {
        switch self {
        case .forwardActiveEnergy: measuredValues.contains(.forwardActiveEnergy)
        case .reverseActiveEnergy: measuredValues.contains(.reverseActiveEnergy)
        case .forwardReactiveEnergy: measuredValues.contains(.forwardReactiveEnergy)
        case .reverseReactiveEnergy: measuredValues.contains(.reverseReactiveEnergy)
        case .activeEnergyBalance:
            (measuredValues.contains(.forwardActiveEnergyBanalced) && measuredValues.contains(.reverseActiveEnergyBalanced))
                || (measuredValues.contains(.forwardActiveEnergy) && measuredValues.contains(.reverseActiveEnergy))
        case .powerActive: measuredValues.contains(.powerActive) || measuredValues.contains(.powerActiveKw)
        case .current: measuredValues.contains(.current)
        case .voltage: measuredValues.contains(.voltage)
        }
    }
}
