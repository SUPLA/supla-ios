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

extension View {
    func suplaCard() -> some View {
        frame(maxWidth: .infinity)
            .background(Color.Supla.surface)
            .cornerRadius(Dimens.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Dimens.radiusDefault)
                    .stroke(Color.Supla.outline, lineWidth: 1)
            )
            .padding([.leading, .top, .trailing], Dimens.distanceDefault)
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ElectricityMeterGeneralFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @State private var space: CGFloat? = nil

        var body: some SwiftUI.View {
            BackgroundStack {
                let label = Strings.ElectricityMeter.forwardActiveEnergy
                GeometryReader { gp in
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 0) {
                            EnergySummaryBox(
                                label: "\(label) \(Strings.ElectricityMeter.totalSufix)",
                                forwardEnergy: viewState.totalForwardActiveEnergy,
                                reverseEnergy: viewState.totalReverseActiveEnergy,
                                loading: false
                            )
                            EnergySummaryBox(
                                label: "\(label) \(Strings.ElectricityMeter.currentMonthSuffix)",
                                forwardEnergy: viewState.currentMonthForwardActiveEnergy,
                                reverseEnergy: viewState.currentMonthReverseActiveEnergy,
                                loading: false
                            )

                            Phases(
                                types: viewState.phaseMeasurementTypes,
                                values: viewState.phaseMeasurementValues,
                                parentWidth: gp.size.width
                            )

                            VectorBalancedValues(
                                vectorValues: viewState.vectorBalancedValues,
                                parentWidth: gp.size.width
                            )
                        }
                    }
                }
            }
        }
    }

    struct Phases: SwiftUI.View {
        var types: [SuplaElectricityMeasurementType]
        var values: [PhaseWithMeasurements]
        var parentWidth: CGFloat

        @State private var horizontalSpace: CGFloat? = nil

        var body: some SwiftUI.View {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 0) {
                    PhaseDataLabels(
                        showTitle: values.count > 1,
                        types: types
                    )
                    if let horizontalSpace = horizontalSpace {
                        PhaseDataSpace(
                            showTitle: values.count > 1,
                            itemsCount: types.count,
                            width: horizontalSpace
                        )
                    }
                    PhaseDataValues(
                        types: types,
                        values: values
                    )
                }
                .padding([.leading, .trailing], Dimens.distanceDefault)
                .frame(maxWidth: .infinity)
                .background(GeometryReader {
                    Color.clear.preference(
                        key: ViewHeightKey.self,
                        value: $0.frame(in: .local).size.width
                    )
                })
            }
            .background(Color.Supla.surface)
            .padding([.top], Distance.small)
            .onPreferenceChange(ViewHeightKey.self) {
                let diff = parentWidth - $0
                if (diff > 0 || (diff > 0 && diff != horizontalSpace)) {
                    horizontalSpace = diff
                } else if (diff < -10) {
                    horizontalSpace = nil
                }
            }
        }
    }

    struct VectorBalancedValues: SwiftUI.View {
        var vectorValues: [SuplaElectricityMeasurementType: String]?
        var parentWidth: CGFloat

        @State private var horizontalSpace: CGFloat? = nil

        var body: some SwiftUI.View {
            if let vectorValues = vectorValues {
                Text.LabelMedium(text: Strings.ElectricityMeter.phaseToPhaseBalance)
                    .padding([.top], Distance.small)
                    .padding([.leading, .trailing], Distance.standard)

                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        PhaseDataLabels(
                            showTitle: false,
                            types: vectorValues.map { $0.key }
                        )
                        if let horizontalSpace = horizontalSpace {
                            PhaseDataSpace(
                                showTitle: false,
                                itemsCount: vectorValues.count,
                                width: horizontalSpace
                            )
                        }
                        SinglePhaseDataValues(
                            label: nil,
                            types: vectorValues.map(\.key),
                            values: vectorValues
                        )
                    }
                    .padding([.leading, .trailing], Dimens.distanceDefault)
                    .background(GeometryReader {
                        Color.clear.preference(
                            key: ViewHeightKey.self,
                            value: $0.frame(in: .local).size.width
                        )
                    })
                }
                .background(Color.Supla.surface)
                .padding([.top], Distance.small)
                .onPreferenceChange(ViewHeightKey.self) {
                    let diff = parentWidth - $0
                    if (diff > 0 || (diff > 0 && diff != horizontalSpace)) {
                        horizontalSpace = diff
                    }
                }
            }
        }
    }

    struct PhaseDataLabels: SwiftUI.View {
        let showTitle: Bool
        let types: [SuplaElectricityMeasurementType]

        var body: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                if (showTitle) {
                    Text.BodyMedium(text: " ")
                        .padding([.top, .bottom], Distance.emList)
                }
                ForEach(types) {
                    Text.BodyMedium(text: $0.string)
                        .padding([.top, .bottom], Distance.emList)

                    if ($0 != types.last) {
                        Divider().frame(height: 1).foregroundColor(Color.Supla.outline)
                    }
                }
            }
        }
    }

    struct PhaseDataSpace: SwiftUI.View {
        let showTitle: Bool
        let itemsCount: Int
        let width: CGFloat

        var body: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                if (showTitle) {
                    Text.BodyMedium(text: " ")
                        .padding([.top, .bottom], Distance.emList)
                }
                ForEach(0 ..< itemsCount, id: \.self) { idx in
                    Text.BodyMedium(text: " ")
                        .padding([.top, .bottom], Distance.emList)

                    if (idx < itemsCount - 1) {
                        Divider().frame(height: 1).foregroundColor(Color.Supla.outline)
                    }
                }
            }.frame(width: width)
        }
    }

    struct PhaseDataValues: SwiftUI.View {
        let types: [SuplaElectricityMeasurementType]
        let values: [PhaseWithMeasurements]

        var body: some SwiftUI.View {
            ForEach(values) { phase in
                SinglePhaseDataValues(
                    label: (values.count > 1).ifTrue { phase.phase },
                    types: types,
                    values: phase.values
                )
            }
        }
    }

    struct SinglePhaseDataValues: SwiftUI.View {
        let label: String?
        let types: [SuplaElectricityMeasurementType]
        let values: [SuplaElectricityMeasurementType: String]
        let valueMaxWidth: CGFloat

        init(
            label: String?,
            types: [SuplaElectricityMeasurementType],
            values: [SuplaElectricityMeasurementType: String]
        ) {
            self.label = label
            self.types = types
            self.values = values

            let letterWidth: CGFloat = 10
            let pointWidth: CGFloat = 4
            let longest = values.values.reduce("") { result, item in
                item.count > result.count ? item : result
            }
            self.valueMaxWidth = if (longest.contains(".")) {
                CGFloat(longest.count - 1) * letterWidth + pointWidth
            } else {
                CGFloat(longest.count) * letterWidth
            }
        }

        var body: some SwiftUI.View {
            return VStack(spacing: 0) {
                if let label {
                    Text.BodyMedium(text: label)
                        .textColor(Color.Supla.onSurfaceVariant)
                        .padding([.top, .bottom], Distance.emList)
                }
                HStack(spacing: 0) {
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(types) { type in
                            Text.BodyMedium(text: values[type] ?? " ")
                                .lineLimit(1)
                                .frame(width: valueMaxWidth, alignment: .trailing)
                                .padding([.top, .bottom], Distance.emList)
                            if (type != types.last) {
                                Divider()
                                    .frame(width: valueMaxWidth, height: 1)
                                    .foregroundColor(Color.Supla.outline)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(types) { type in
                            Text.BodyMedium(text: type.unit)
                                .textColor(Color.Supla.onSurfaceVariant)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: true)
                                .padding([.top, .bottom], Distance.emList)
                                .padding([.leading], Distance.tiny)
                                .padding([.trailing], Dimens.distanceSmall)
                            if (type != types.last) {
                                Divider()
                                    .frame(height: 1)
                                    .foregroundColor(Color.Supla.outline)
                            }
                        }
                    }
                }
            }
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
            .frequency: "50.00",
            .voltage: "220.00",
            .current: "10.00",
            .powerApparent: "100.00",
            .reverseReactiveEnergy: "100.00"
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
            .frequency: "50.00",
            .voltage: "220.00",
            .current: "10.00",
            .powerApparent: "100.00",
            .reverseReactiveEnergy: "2066.96312"
        ]),
        .init(id: 2, phase: Strings.ElectricityMeter.phase2, values: [
            .frequency: "50.00",
            .voltage: "220.00",
            .current: "10.00",
            .powerApparent: "100.00",
            .reverseReactiveEnergy: "100.00"
        ]),
        .init(id: 3, phase: Strings.ElectricityMeter.phase3, values: [
            .frequency: "50.00",
            .voltage: "220.00",
            .current: "10.00",
            .powerApparent: "100.00",
            .reverseReactiveEnergy: "2066.96312"
        ])
    ]
    viewState.vectorBalancedValues = [
        .forwardActiveEnergy: "4273",
        .reverseActiveEnergy: "5715"
    ]
    return ElectricityMeterGeneralFeature.View(
        viewState: viewState
    )
}
