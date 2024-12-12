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

class ElectricityMeterGeneralState: ObservableObject, Equatable {
    @Published var online: Bool = false
    @Published var totalForwardActiveEnergy: EnergyData? = nil
    @Published var totalReverseActiveEnergy: EnergyData? = nil
    @Published var currentMonthDownloading: Bool = false
    @Published var currentMonthForwardActiveEnergy: EnergyData? = nil
    @Published var currentMonthReverseActiveEnergy: EnergyData? = nil
    @Published var phaseMeasurementTypes: [SuplaElectricityMeasurementType] = []
    @Published var phaseMeasurementValues: [PhaseWithMeasurements] = []
    @Published var vectorBalancedValues: [SuplaElectricityMeasurementType: String]? = nil
    @Published var showIntroduction: Bool = false

    static func == (lhs: ElectricityMeterGeneralState, rhs: ElectricityMeterGeneralState) -> Bool {
        lhs.online == rhs.online &&
            lhs.totalForwardActiveEnergy == rhs.totalForwardActiveEnergy &&
            lhs.totalReverseActiveEnergy == rhs.totalReverseActiveEnergy &&
            lhs.currentMonthDownloading == rhs.currentMonthDownloading &&
            lhs.currentMonthForwardActiveEnergy == rhs.currentMonthForwardActiveEnergy &&
            lhs.phaseMeasurementTypes == rhs.phaseMeasurementTypes &&
            lhs.phaseMeasurementValues == rhs.phaseMeasurementValues &&
            lhs.vectorBalancedValues == rhs.vectorBalancedValues
    }
}

struct PhaseWithMeasurements: Identifiable, Equatable {
    let id: Int
    let phase: String
    let values: [SuplaElectricityMeasurementType: String]
}
