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

import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ElectricityMeterGeneralFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        
        var onIntroductionClose: () -> Void = { }

        var body: some SwiftUI.View {
            ElectricityMeterGeneralBaseView(
                online: $viewState.online,
                totalForwardActiveEnergy: $viewState.totalForwardActiveEnergy,
                totalReverseActiveEnergy: $viewState.totalReverseActiveEnergy,
                currentMonthDownloading: $viewState.currentMonthDownloading,
                currentMonthForwardActiveEnergy: $viewState.currentMonthForwardActiveEnergy,
                currentMonthReverseActiveEnergy: $viewState.currentMonthReverseActiveEnergy,
                phaseMeasurementTypes: $viewState.phaseMeasurementTypes,
                phaseMeasurementValues: $viewState.phaseMeasurementValues,
                vectorBalancedValues: $viewState.vectorBalancedValues,
                electricGridParameters: $viewState.electricGridParameters,
                showIntroduction: $viewState.showIntroduction,
                onIntroductionClose: onIntroductionClose
            )
        }
    }
}

#Preview("One phases") {
    let viewState = ElectricityMeterGeneralFeature.ViewState()
    viewState.totalForwardActiveEnergy = EnergyData(energy: "4273 kWh", price: "3418.33 PLN")
    viewState.totalReverseActiveEnergy = EnergyData(energy: "5715 kWh")
    viewState.currentMonthForwardActiveEnergy = EnergyData(energy: "4273 kWh", price: "3418.33 PLN")
    viewState.currentMonthReverseActiveEnergy = EnergyData(energy: "5715 kWh")
    viewState.phaseMeasurementTypes = [.frequency, .voltage, .current, .powerApparent, .reverseReactiveEnergy]
    viewState.phaseMeasurementValues = [
        .init(id: 1, phase: Strings.ElectricityMeter.phase1, values: [
            .init(type: .frequency, value: "50.00"),
            .init(type: .voltage, value: "220.00"),
            .init(type: .current, value: "10.00"),
            .init(type: .powerApparent, value: "100.00"),
            .init(type: .reverseReactiveEnergy, value: "100.00")
        ])
    ]
    return ElectricityMeterGeneralFeature.View(
        viewState: viewState
    )
}

#Preview("Three phases") {
    let viewState = ElectricityMeterGeneralFeature.ViewState()
    viewState.totalForwardActiveEnergy = EnergyData(energy: "4273 kWh", price: "3418.33 PLN")
    viewState.totalReverseActiveEnergy = EnergyData(energy: "5715 kWh")
    viewState.currentMonthForwardActiveEnergy = EnergyData(energy: "4273 kWh", price: "3418.33 PLN")
    viewState.currentMonthReverseActiveEnergy = EnergyData(energy: "5715 kWh")
    viewState.phaseMeasurementTypes = [.frequency, .voltage, .current, .powerApparent, .reverseReactiveEnergy]
    viewState.phaseMeasurementValues = [
        .init(id: 1, phase: Strings.ElectricityMeter.phase1, values: [
            .init(type: .frequency, value: "50.00"),
            .init(type: .voltage, value: "220.00"),
            .init(type: .current, value: "10.00"),
            .init(type: .powerApparent, value: "100.00"),
            .init(type: .reverseReactiveEnergy, value: "2066.96312")
        ]),
        .init(id: 2, phase: Strings.ElectricityMeter.phase2, values: [
            .init(type: .frequency, value: "50.00"),
            .init(type: .voltage, value: "220.00"),
            .init(type: .current, value: "10.00"),
            .init(type: .powerApparent, value: "100.00"),
            .init(type: .reverseReactiveEnergy, value: "100.00")
        ]),
        .init(id: 3, phase: Strings.ElectricityMeter.phase3, values: [
            .init(type: .frequency, value: "50.00"),
            .init(type: .voltage, value: "220.00"),
            .init(type: .current, value: "10.00"),
            .init(type: .powerApparent, value: "100.00"),
            .init(type: .reverseReactiveEnergy, value: "2066.96312")
        ])
    ]
    viewState.vectorBalancedValues = [
        .init(type: .forwardActiveEnergy, value: "4273"),
        .init(type: .reverseActiveEnergy, value: "5715")
    ]
    return ElectricityMeterGeneralFeature.View(
        viewState: viewState
    )
}
