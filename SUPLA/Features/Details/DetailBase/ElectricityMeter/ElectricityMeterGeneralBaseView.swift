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

struct ElectricityMeterGeneralBaseView: View {
    
    @Binding var online: Bool
    @Binding var totalForwardActiveEnergy: EnergyData?
    @Binding var totalReverseActiveEnergy: EnergyData?
    @Binding var currentMonthDownloading: Bool
    @Binding var currentMonthForwardActiveEnergy: EnergyData?
    @Binding var currentMonthReverseActiveEnergy: EnergyData?
    @Binding var phaseMeasurementTypes: [SuplaElectricityMeasurementType]
    @Binding var phaseMeasurementValues: [PhaseWithMeasurements]
    @Binding var vectorBalancedValues: [SuplaElectricityMeasurementType: String]?
    @State private var space: CGFloat? = nil
    
    var body: some View {
        BackgroundStack {
            let label = Strings.ElectricityMeter.forwardActiveEnergy
            GeometryReader { gp in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        EnergySummaryBox(
                            label: "\(label) \(Strings.ElectricityMeter.totalSufix)",
                            forwardEnergy: totalForwardActiveEnergy,
                            reverseEnergy: totalReverseActiveEnergy,
                            loading: .constant(false)
                        )
                        EnergySummaryBox(
                            label: "\(label) \(Strings.ElectricityMeter.currentMonthSuffix)",
                            forwardEnergy: currentMonthForwardActiveEnergy,
                            reverseEnergy: currentMonthReverseActiveEnergy,
                            loading: $currentMonthDownloading
                        )

                        if (online) {
                            PhasesView(
                                types: phaseMeasurementTypes,
                                values: phaseMeasurementValues,
                                parentWidth: gp.size.width
                            )
                            
                            VectorBalancedValuesView(
                                vectorValues: vectorBalancedValues,
                                parentWidth: gp.size.width
                            )
                        } else {
                            HStack {
                                Spacer()
                                Image(.Icons.powerOff)
                                    .foregroundColor(Color.Supla.onSurfaceVariant)
                                Text.BodyMedium(text: Strings.General.channelOffline)
                                    .textColor(Color.Supla.onSurfaceVariant)
                                Spacer()
                            }
                            .padding(Distance.standard)
                        }
                    }
                }
            }
        }
    }
}

private struct PhasesView: View {
    var types: [SuplaElectricityMeasurementType]
    var values: [PhaseWithMeasurements]
    var parentWidth: CGFloat

    @State private var horizontalSpace: CGFloat? = nil

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 0) {
                PhaseDataLabelsView(
                    types: types,
                    showHeader: values.count > 1
                )
                if let horizontalSpace = horizontalSpace {
                    PhaseDataSpaceView(
                        width: horizontalSpace,
                        types: types,
                        showHeader: values.count > 1
                    )
                }
                PhaseDataValuesView(
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

private struct VectorBalancedValuesView: SwiftUI.View {
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
                    PhaseDataLabelsView(
                        types: vectorValues.map { $0.key },
                        showHeader: false
                    )
                    if let horizontalSpace = horizontalSpace {
                        PhaseDataSpaceView(
                            width: horizontalSpace,
                            types: vectorValues.map { $0.key },
                            showHeader: false,
                            showLabel: false
                        )
                    }
                    SinglePhaseDataValuesView(
                        header: nil,
                        types: vectorValues.map(\.key),
                        values: vectorValues,
                        showLabel: false
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

private struct PhaseDataLabelsView: View {
    let types: [SuplaElectricityMeasurementType]
    let showHeader: Bool
    let showLabel: Bool
    
    private let showEnergyLabelForType: SuplaElectricityMeasurementType?
    
    init(types: [SuplaElectricityMeasurementType], showHeader: Bool = true, showLabel: Bool = true) {
        self.types = types
        self.showHeader = showHeader
        self.showLabel = showLabel
        self.showEnergyLabelForType = showLabel.ifTrue { types.first(where: \.showEnergyLabel) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if (showHeader) {
                Text.BodyMedium(text: " ")
                    .padding([.top, .bottom], Distance.emList)
            }
            
            ForEach(types) {
                if ($0 == showEnergyLabelForType) {
                    EnergyLabelView(text: Strings.ElectricityMeter.energyLabel)
                }
                
                Text.BodyMedium(text: $0.shortString)
                    .padding([.top, .bottom], Distance.emList)

                if ($0 != types.last) {
                    SuplaCore.Divider().color(Color.Supla.outline)
                }
            }
        }
    }
}

private struct EnergyLabelView: View {
    
    let text: String
    
    init(text: String = " ") {
        self.text = text
    }
    
    var body: some View {
        Text.LabelMedium(text: text)
            .padding([.top], Distance.small)
            .padding([.bottom], Distance.emList)
    }
}

private struct PhaseDataSpaceView: View {
    let width: CGFloat
    let types: [SuplaElectricityMeasurementType]
    let showHeader: Bool
    let showLabel: Bool
    
    private let showEnergyLabelForType: SuplaElectricityMeasurementType?
    
    init(width: CGFloat, types: [SuplaElectricityMeasurementType], showHeader: Bool = true, showLabel: Bool = true) {
        self.width = width
        self.types = types
        self.showHeader = showHeader
        self.showLabel = showLabel
        
        
        self.showEnergyLabelForType = showLabel.ifTrue { types.first(where: \.showEnergyLabel) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if (showHeader) {
                Text.BodyMedium(text: " ")
                    .padding([.top, .bottom], Distance.emList)
            }
            ForEach(0 ..< types.count, id: \.self) { idx in
                if (types[idx] == showEnergyLabelForType) {
                    EnergyLabelView()
                }
                
                Text.BodyMedium(text: " ")
                    .padding([.top, .bottom], Distance.emList)

                if (idx < types.count - 1) {
                    SuplaCore.Divider().color(Color.Supla.outline)
                }
            }
        }.frame(width: width)
    }
}

private struct PhaseDataValuesView: View {
    let types: [SuplaElectricityMeasurementType]
    let values: [PhaseWithMeasurements]
    
    init(types: [SuplaElectricityMeasurementType], values: [PhaseWithMeasurements]) {
        self.types = types
        self.values = values
    }

    var body: some View {
        ForEach(values) { phase in
            SinglePhaseDataValuesView(
                header: (values.count > 1).ifTrue { phase.phase },
                types: types,
                values: phase.values
            )
        }
    }
}

private struct SinglePhaseDataValuesView: View {
    let header: String?
    let types: [SuplaElectricityMeasurementType]
    let values: [SuplaElectricityMeasurementType: String]
    let showLabel: Bool
    let valueMaxWidth: CGFloat
    
    private let showEnergyLabelForType: SuplaElectricityMeasurementType?
    
    init(
        header: String?,
        types: [SuplaElectricityMeasurementType],
        values: [SuplaElectricityMeasurementType: String],
        showLabel: Bool = true
    ) {
        self.header = header
        self.types = types
        self.values = values
        self.showLabel = showLabel

        let attributes = [NSAttributedString.Key.font: UIFont.body2]
        valueMaxWidth = values.values.reduce(0.0) { result, item in
            let size = item.size(withAttributes: attributes).width
            return size > result ? size : result
        } + Distance.tiny
        
        self.showEnergyLabelForType = showLabel.ifTrue { types.first(where: \.showEnergyLabel) }
    }

    var body: some View {
        return VStack(spacing: 0) {
            if let header {
                Text.BodyMedium(text: header)
                    .textColor(Color.Supla.onSurfaceVariant)
                    .padding([.top, .bottom], Distance.emList)
            }
            HStack(spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(types) { type in
                        if (type == showEnergyLabelForType) {
                            EnergyLabelView()
                        }
                        
                        Text.BodyMedium(text: values[type] ?? NO_VALUE_TEXT)
                            .lineLimit(1)
                            .frame(width: valueMaxWidth, alignment: .trailing)
                            .padding([.top, .bottom], Distance.emList)
                        if (type != types.last) {
                            SuplaCore.Divider()
                                .color(Color.Supla.outline)
                                .frame(width: valueMaxWidth, height: 1)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(types) { type in
                        if (type == showEnergyLabelForType) {
                            EnergyLabelView()
                        }
                        
                        Text.BodyMedium(text: values[type] == nil ? " " : type.unit)
                            .textColor(Color.Supla.onSurfaceVariant)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: true)
                            .padding([.top, .bottom], Distance.emList)
                            .padding([.leading], 4)
                            .padding([.trailing], Distance.tiny)
                        if (type != types.last) {
                            SuplaCore.Divider().color(Color.Supla.outline)
                        }
                    }
                }
            }
        }
    }
}

#Preview("One phases") {
    ElectricityMeterGeneralBaseView(
        online: .constant(true),
        totalForwardActiveEnergy: .constant(EnergyData(energy: "4273 kWh", price: "3418.33 PLN")),
        totalReverseActiveEnergy: .constant(EnergyData(energy: "5715 kWh")),
        currentMonthDownloading: .constant(false),
        currentMonthForwardActiveEnergy: .constant(EnergyData(energy: "4273 kWh", price: "3418.33 PLN")),
        currentMonthReverseActiveEnergy: .constant(EnergyData(energy: "5715 kWh")),
        phaseMeasurementTypes: .constant([.frequency, .voltage, .current, .powerApparent, .reverseReactiveEnergy]),
        phaseMeasurementValues: .constant(
            [
                .init(id: 1, phase: Strings.ElectricityMeter.phase1, values: [
                    .frequency: "50.00",
                    .voltage: "220.00",
                    .current: "10.00",
                    .powerApparent: "100.00",
                    .reverseReactiveEnergy: "100.00"
                ])
            ]
        ),
        vectorBalancedValues: .constant(nil)
    )
}

#Preview("Three phases") {
    ElectricityMeterGeneralBaseView(
        online: .constant(true),
        totalForwardActiveEnergy: .constant(EnergyData(energy: "4273 kWh", price: "3418.33 PLN")),
        totalReverseActiveEnergy: .constant(EnergyData(energy: "5715 kWh")),
        currentMonthDownloading: .constant(false),
        currentMonthForwardActiveEnergy: .constant(EnergyData(energy: "4273 kWh", price: "3418.33 PLN")),
        currentMonthReverseActiveEnergy: .constant(EnergyData(energy: "5715 kWh")),
        phaseMeasurementTypes: .constant([.frequency, .voltage, .current, .powerApparent, .reverseReactiveEnergy]),
        phaseMeasurementValues: .constant([
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
        ]),
        vectorBalancedValues: .constant([
            .forwardActiveEnergy: "4273",
            .reverseActiveEnergy: "5715"
        ])
    )
}

#Preview("Offline") {
    ElectricityMeterGeneralBaseView(
        online: .constant(false),
        totalForwardActiveEnergy: .constant(EnergyData(energy: "4273 kWh", price: "3418.33 PLN")),
        totalReverseActiveEnergy: .constant(EnergyData(energy: "5715 kWh")),
        currentMonthDownloading: .constant(false),
        currentMonthForwardActiveEnergy: .constant(EnergyData(energy: "4273 kWh", price: "3418.33 PLN")),
        currentMonthReverseActiveEnergy: .constant(EnergyData(energy: "5715 kWh")),
        phaseMeasurementTypes: .constant([.frequency, .voltage, .current, .powerApparent, .reverseReactiveEnergy]),
        phaseMeasurementValues: .constant(
            [
                .init(id: 1, phase: Strings.ElectricityMeter.phase1, values: [
                    .frequency: "50.00",
                    .voltage: "220.00",
                    .current: "10.00",
                    .powerApparent: "100.00",
                    .reverseReactiveEnergy: "100.00"
                ])
            ]
        ),
        vectorBalancedValues: .constant(nil)
    )
}
