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
    let showOnList: SuplaElectricityMeasurementType
    let balancing: ElectricityMeterBalanceType
    
    var showOnListSafe: SuplaElectricityMeasurementType {
        ElectricityMeterSettings.showOnListAllItems.contains(showOnList) ? showOnList : ElectricityMeterSettings.showOnListAllItems.first!
    }
    
    func copy(showOnList: SuplaElectricityMeasurementType? = nil, balancing: ElectricityMeterBalanceType? = nil) -> ElectricityMeterSettings {
        ElectricityMeterSettings(showOnList: showOnList ?? self.showOnList, balancing: balancing ?? self.balancing)
    }
    
    static func defaultSettings() -> ElectricityMeterSettings {
        return .init(showOnList: .forwardActiveEnergy, balancing: .defaultValue)
    }
    
    static var showOnListAllItems: [SuplaElectricityMeasurementType] {
        [.forwardActiveEnergy, .reverseActiveEnergy, .powerActive, .voltage]
    }
    
    static var balancingAllItems: [ElectricityMeterBalanceType] {
        [.vector, .arithmetic, .hourly]
    }
}

enum ElectricityMeterBalanceType: Int, Codable, PickerItem {
    case defaultValue, vector, arithmetic, hourly
    
    var id: Int { self.rawValue }
    
    var label: String {
        switch self {
        case .defaultValue: return ""
        case .vector: return Strings.ElectricityMeter.balanceVector
        case .arithmetic: return Strings.ElectricityMeter.balanceArithmetic
        case .hourly: return Strings.ElectricityMeter.balanceHourly
        }
    }
}
