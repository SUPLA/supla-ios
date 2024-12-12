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
    @Binding var showIntroduction: Bool
    
    var onIntroductionClose: () -> Void = { }

    @State private var space: CGFloat? = nil
    @State private var offset: Double = 0

    var body: some View {
        BackgroundStack {
            let label = Strings.ElectricityMeter.forwardActiveEnergy
            GeometryReader { gp in
                ZStack {
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
                                    parentWidth: gp.size.width,
                                    offset: offset
                                )
                                .id(showIntroduction)
                                .onAppear {
                                    if (showIntroduction) {
                                        withAnimation(.easeInOut(duration: 1).repeatForever()) {
                                            offset = 100
                                        }
                                    }
                                }
                                VectorBalancedValuesView(
                                    vectorValues: vectorBalancedValues,
                                    parentWidth: gp.size.width
                                )
                            } else {
                                HStack {
                                    Spacer()
                                    Image(.Icons.powerOff)
                                        .foregroundColor(Color.Supla.onSurfaceVariant)
                                    Text(Strings.General.channelOffline)
                                        .fontBodyMedium()
                                        .textColor(Color.Supla.onSurfaceVariant)
                                    Spacer()
                                }
                                .padding(Distance.default)
                            }
                        }
                    }

                    if (showIntroduction) {
                        InfoView(
                            offset: offset,
                            onClose: {
                                showIntroduction = false
                                offset = 0
                                onIntroductionClose()
                            }
                        )
                    }
                }
            }
        }
    }
}

private struct InfoView: View {
    var offset: Double
    var onClose: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.Supla.infoScrim],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: 40)
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.Supla.onPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 8)
                        .padding([.bottom], 14)
                    Image(.Icons.touchHandFilled)
                        .offset(x: 50 - offset)
                        .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                        .foregroundColor(Color.Supla.onPrimary)

                    HStack {
                        Spacer()
                        VStack {
                            Image(.Icons.close)
                                .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                                .foregroundColor(Color.Supla.onPrimary)
                                .padding([.trailing], 10)
                                .onTapGesture { onClose() }
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding([.top, .bottom], Distance.tiny)
                .background(Color.Supla.infoScrim)

                SwiftUI.Text(Strings.ElectricityMeter.infoSwipe)
                    .fontBodyMedium()
                    .textColor(Color.Supla.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding([.bottom], Distance.small)
                    .background(Color.Supla.infoScrim)
            }
        }
    }
}

private struct PhasesView: View {
    var types: [SuplaElectricityMeasurementType]
    var values: [PhaseWithMeasurements]
    var parentWidth: CGFloat
    var offset: Double

    @State private var horizontalSpace: CGFloat? = nil
    @State private var highlightedType: SuplaElectricityMeasurementType? = nil

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 0) {
                PhaseDataLabelsView(
                    types: types,
                    showHeader: values.count > 1,
                    onItemSelected: { highlightedType = $0 },
                    selectedType: $highlightedType
                )
                if let horizontalSpace = horizontalSpace {
                    PhaseDataSpaceView(
                        width: horizontalSpace,
                        types: types,
                        showHeader: values.count > 1,
                        onItemSelected: { highlightedType = $0 },
                        selectedType: $highlightedType
                    )
                }
                PhaseDataValuesView(
                    types: types,
                    values: values,
                    onItemSelected: { highlightedType = $0 },
                    selectedType: $highlightedType
                )
            }
            .offset(x: -offset)
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
            Text(Strings.ElectricityMeter.phaseToPhaseBalance)
                .fontLabelMedium()
                .padding([.top], Distance.small)
                .padding([.leading, .trailing], Distance.default)

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
    let onItemSelected: ((SuplaElectricityMeasurementType) -> Void)?
    var selectedType: Binding<SuplaElectricityMeasurementType?>

    private let showEnergyLabelForType: SuplaElectricityMeasurementType?

    init(
        types: [SuplaElectricityMeasurementType],
        showHeader: Bool = true,
        showLabel: Bool = true,
        onItemSelected: ((SuplaElectricityMeasurementType) -> Void)? = nil,
        selectedType: Binding<SuplaElectricityMeasurementType?> = .constant(nil)
    ) {
        self.types = types
        self.showHeader = showHeader
        self.showLabel = showLabel
        self.showEnergyLabelForType = showLabel.ifTrue { types.first(where: \.showEnergyLabel) }
        self.onItemSelected = onItemSelected
        self.selectedType = selectedType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if (showHeader) {
                Text(" ")
                    .fontBodyMedium()
                    .padding([.top, .bottom], Distance.emList)
            }

            ForEach(types) { type in
                if (type == showEnergyLabelForType) {
                    EnergyLabelView(text: Strings.ElectricityMeter.energyLabel)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(type.shortString)
                        .fontBodyMedium()
                        .padding([.top, .bottom], Distance.emList)
                        .padding([.leading], Distance.default)

                    SuplaCore.Divider().color(type != types.last ? Color.Supla.outline : Color.clear)
                }
                .background(selectedType.wrappedValue == type ? Color.Supla.outline : Color.clear)
                .onTapGesture { onItemSelected?(type) }
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
        Text(text)
            .fontLabelMedium()
            .padding([.top], Distance.small)
            .padding([.bottom], Distance.emList)
            .padding([.leading], Distance.default)
    }
}

private struct PhaseDataSpaceView: View {
    let width: CGFloat
    let types: [SuplaElectricityMeasurementType]
    let showHeader: Bool
    let showLabel: Bool
    let onItemSelected: ((SuplaElectricityMeasurementType) -> Void)?
    var selectedType: Binding<SuplaElectricityMeasurementType?>

    private let showEnergyLabelForType: SuplaElectricityMeasurementType?

    init(
        width: CGFloat,
        types: [SuplaElectricityMeasurementType],
        showHeader: Bool = true,
        showLabel: Bool = true,
        onItemSelected: ((SuplaElectricityMeasurementType) -> Void)? = nil,
        selectedType: Binding<SuplaElectricityMeasurementType?> = .constant(nil)
    ) {
        self.width = width
        self.types = types
        self.showHeader = showHeader
        self.showLabel = showLabel
        self.onItemSelected = onItemSelected
        self.selectedType = selectedType

        self.showEnergyLabelForType = showLabel.ifTrue { types.first(where: \.showEnergyLabel) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if (showHeader) {
                Text(" ")
                    .fontBodyMedium()
                    .padding([.top, .bottom], Distance.emList)
            }
            ForEach(0 ..< types.count, id: \.self) { idx in
                if (types[idx] == showEnergyLabelForType) {
                    EnergyLabelView()
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(" ")
                        .fontBodyMedium()
                        .padding([.top, .bottom], Distance.emList)

                    SuplaCore.Divider().color(idx < types.count - 1 ? Color.Supla.outline : Color.clear)
                }
                .background(selectedType.wrappedValue == types[idx] ? Color.Supla.outline : Color.clear)
                .onTapGesture { onItemSelected?(types[idx]) }
            }
        }.frame(width: width)
    }
}

private struct PhaseDataValuesView: View {
    let types: [SuplaElectricityMeasurementType]
    let values: [PhaseWithMeasurements]
    let onItemSelected: ((SuplaElectricityMeasurementType) -> Void)?
    var selectedType: Binding<SuplaElectricityMeasurementType?>

    init(
        types: [SuplaElectricityMeasurementType],
        values: [PhaseWithMeasurements],
        onItemSelected: ((SuplaElectricityMeasurementType) -> Void)? = nil,
        selectedType: Binding<SuplaElectricityMeasurementType?> = .constant(nil)
    ) {
        self.types = types
        self.values = values
        self.onItemSelected = onItemSelected
        self.selectedType = selectedType
    }

    var body: some View {
        ForEach(0 ..< values.count, id: \.self) { idx in
            SinglePhaseDataValuesView(
                header: (values.count > 1).ifTrue { values[idx].phase },
                types: types,
                values: values[idx].values,
                isLast: idx == values.count - 1,
                onItemSelected: onItemSelected,
                selectedType: selectedType
            )
        }
    }
}

private struct SinglePhaseDataValuesView: View {
    let header: String?
    let types: [SuplaElectricityMeasurementType]
    let values: [SuplaElectricityMeasurementType: String]
    let showLabel: Bool
    let isLast: Bool
    let onItemSelected: ((SuplaElectricityMeasurementType) -> Void)?
    var selectedType: Binding<SuplaElectricityMeasurementType?>
    let valueMaxWidth: CGFloat

    private let showEnergyLabelForType: SuplaElectricityMeasurementType?

    init(
        header: String?,
        types: [SuplaElectricityMeasurementType],
        values: [SuplaElectricityMeasurementType: String],
        showLabel: Bool = true,
        isLast: Bool = true,
        onItemSelected: ((SuplaElectricityMeasurementType) -> Void)? = nil,
        selectedType: Binding<SuplaElectricityMeasurementType?> = .constant(nil)
    ) {
        self.header = header
        self.types = types
        self.values = values
        self.showLabel = showLabel
        self.isLast = isLast
        self.onItemSelected = onItemSelected
        self.selectedType = selectedType

        let attributes = [NSAttributedString.Key.font: UIFont.body2]
        self.valueMaxWidth = values.values.reduce(0.0) { result, item in
            let size = item.size(withAttributes: attributes).width
            return size > result ? size : result
        } + Distance.tiny

        self.showEnergyLabelForType = showLabel.ifTrue { types.first(where: \.showEnergyLabel) }
    }

    var body: some View {
        return VStack(spacing: 0) {
            if let header {
                Text(header)
                    .fontBodyMedium()
                    .textColor(Color.Supla.onSurfaceVariant)
                    .padding([.top, .bottom], Distance.emList)
            }
            HStack(spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(types) { type in
                        if (type == showEnergyLabelForType) {
                            EnergyLabelView()
                        }

                        VStack(alignment: .trailing, spacing: 0) {
                            Text(values[type] ?? NO_VALUE_TEXT)
                                .fontBodyMedium()
                                .lineLimit(1)
                                .frame(width: valueMaxWidth, alignment: .trailing)
                                .padding([.top, .bottom], Distance.emList)
                            SuplaCore.Divider()
                                .color(type != types.last ? Color.Supla.outline : Color.clear)
                                .frame(width: valueMaxWidth, height: 1)
                        }
                        .background(selectedType.wrappedValue == type ? Color.Supla.outline : Color.clear)
                        .onTapGesture { onItemSelected?(type) }
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(types) { type in
                        if (type == showEnergyLabelForType) {
                            EnergyLabelView()
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            Text(values[type] == nil ? " " : type.unit)
                                .fontBodyMedium()
                                .textColor(Color.Supla.onSurfaceVariant)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: true)
                                .padding([.top, .bottom], Distance.emList)
                                .padding([.leading], 4)
                                .padding([.trailing], isLast ? Distance.default : Distance.tiny)

                            SuplaCore.Divider().color(type != types.last ? Color.Supla.outline : Color.clear)
                        }
                        .background(selectedType.wrappedValue == type ? Color.Supla.outline : Color.clear)
                        .onTapGesture { onItemSelected?(type) }
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
        vectorBalancedValues: .constant(nil),
        showIntroduction: .constant(true)
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
        ]),
        showIntroduction: .constant(true)
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
        vectorBalancedValues: .constant(nil),
        showIntroduction: .constant(true)
    )
}
