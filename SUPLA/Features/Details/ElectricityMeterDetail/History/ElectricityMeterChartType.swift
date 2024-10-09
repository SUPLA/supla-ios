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

enum ElectricityMeterChartType: Int, Codable, CaseIterable, Identifiable, PickerItem {
    case forwardActiveEnergy
    case reverseActiveEnergy
    case forwardReactiveEnergy
    case reverseReactiveEnergy
    case balanceArithmetic
    case balanceVector
    case balanceHourly
    case balanceChartAggregated
    
    var id: Int { rawValue }

    var needsPhases: Bool {
        switch (self) {
        case .forwardActiveEnergy,
             .reverseActiveEnergy,
             .forwardReactiveEnergy,
             .reverseReactiveEnergy: true
        case .balanceArithmetic,
             .balanceVector,
             .balanceHourly,
             .balanceChartAggregated: false
        }
    }

    var isBalance: Bool {
        switch (self) {
        case .balanceArithmetic,
             .balanceVector,
             .balanceHourly,
             .balanceChartAggregated: true
        case .forwardActiveEnergy,
             .reverseActiveEnergy,
             .forwardReactiveEnergy,
             .reverseReactiveEnergy: false
        }
    }
    
    var label: String {
        switch (self) {
        case .forwardActiveEnergy: Strings.ElectricityMeter.forwardActiveEnergy
        case .reverseActiveEnergy: Strings.ElectricityMeter.reverseActiveEnergy
        case .forwardReactiveEnergy: Strings.ElectricityMeter.forwardReactiveEnergy
        case .reverseReactiveEnergy: Strings.ElectricityMeter.reverseReactiveEnergy
        case .balanceArithmetic: Strings.ElectricityMeter.balanceArithmetic
        case .balanceVector: Strings.ElectricityMeter.balanceVector
        case .balanceHourly: Strings.ElectricityMeter.balanceHourly
        case .balanceChartAggregated: Strings.ElectricityMeter.balanceChartAggregated
        }
    }
}
