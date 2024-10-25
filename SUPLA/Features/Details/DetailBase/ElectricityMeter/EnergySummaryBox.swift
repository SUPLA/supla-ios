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

struct EnergySummaryBox: View {
    var label: String?
    var forwardEnergy: EnergyData?
    var reverseEnergy: EnergyData?
    @Binding var loading: Bool
    
    var body: some View {
        if (forwardEnergy != nil || reverseEnergy != nil) {
            ZStack {
                VStack {
                    let showLabel = forwardEnergy != nil && reverseEnergy != nil && label != nil
                    if (showLabel) {
                        if let label = label {
                            Text.BodyMedium(text: label)
                                .textColor(Color.Supla.onSurfaceVariant)
                                .padding(Dimens.distanceTiny)
                        }
                    }
                    HStack(alignment: .top, spacing: showLabel ? 1 : 0) {
                        if let forwardEnergy = forwardEnergy,
                           let reverseEnergy = reverseEnergy {
                            EnergySummaryItemBox(
                                iconName: .Icons.forwardEnergy,
                                label: Strings.ElectricityMeter.forwardedEnergy,
                                value: forwardEnergy.energy,
                                price: forwardEnergy.price)
                            
                            EnergySummaryItemBox(
                                iconName: .Icons.reversedEnergy,
                                label: Strings.ElectricityMeter.reversedEnergy,
                                value: reverseEnergy.energy,
                                price: reverseEnergy.price)
                        } else if let forwardEnergy = forwardEnergy {
                            EnergySummarySingleItemBox(
                                iconName: .Icons.forwardEnergy,
                                label: label!,
                                value: forwardEnergy.energy,
                                price: forwardEnergy.price)
                        } else if let reverseEnergy = reverseEnergy {
                            EnergySummarySingleItemBox(
                                iconName: .Icons.reversedEnergy,
                                label: label!,
                                value: reverseEnergy.energy,
                                price: reverseEnergy.price)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.top], 1)
                    .background(Color.Supla.outline)
                    .fixedSize(horizontal: false, vertical: true)
                }
                
                if (loading) {
                    Color(UIColor.loadingScrim)
                    ActivityIndicator(isAnimating: $loading, style: .medium)
                }
                
            }.suplaCard()
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

private struct EnergySummaryItemBox: View {
    var iconName: String
    var label: String
    var value: String
    var price: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(iconName)
                Text.BodyMedium(text: label)
                    .textColor(Color.Supla.onSurfaceVariant)
            }
            Text.LabelLarge(text: value)
            if let price = price {
                SuplaCore.Divider()
                HStack {
                    Text.BodyMedium(text: Strings.ElectricityMeter.cost)
                        .textColor(Color.Supla.onSurfaceVariant)
                    Text.LabelMedium(text: price)
                }
            } else {
                Spacer()
            }
        }
        .padding(Dimens.distanceSmall)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.Supla.surface)
    }
}

private struct EnergySummarySingleItemBox: View {
    var iconName: String
    var label: String
    var value: String
    var price: String?
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Image(iconName)
                    Text.BodyMedium(text: label)
                        .textColor(Color.Supla.onSurfaceVariant)
                }
                Text.LabelLarge(text: value)
            }
            if let price = price {
                Spacer()
                SuplaCore.Divider(.vertical)
                Spacer()
                VStack(alignment: .trailing, spacing: Dimens.distanceTiny) {
                    Text.BodyMedium(text: Strings.ElectricityMeter.cost)
                        .textColor(Color.Supla.onSurfaceVariant)
                    Text.LabelMedium(text: price)
                }
            }
        }
        .padding(Dimens.distanceSmall)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.Supla.surface)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EnergySummaryBox(
                label: "Active energy \(Strings.ElectricityMeter.totalSufix)",
                forwardEnergy: EnergyData(energy: "12,34 kWh", price: "15,00 PLN"),
                reverseEnergy: EnergyData(energy: "23,45 kWh", price: "15,00 PLN"),
                loading: .constant(true)
            )
            EnergySummaryBox(
                label: "Active energy",
                forwardEnergy: EnergyData(energy: "12,34 kWh", price: "15,00 PLN"),
                reverseEnergy: EnergyData(energy: "23,45 kWh"),
                loading: .constant(false)
            )
            EnergySummaryBox(
                label: "Active energy",
                forwardEnergy: EnergyData(energy: "12,34 kWh"),
                reverseEnergy: EnergyData(energy: "23,45 kWh"),
                loading: .constant(false)
            )
            EnergySummaryBox(
                label: "Forward active energy",
                forwardEnergy: EnergyData(energy: "12,34 kWh", price: "15,00 PLN"),
                loading: .constant(false)
            )
            EnergySummaryBox(
                label: "Forward active energy",
                forwardEnergy: EnergyData(energy: "12,34 kWh"),
                loading: .constant(false)
            )
            EnergySummaryBox(
                label: "Reverse active energy",
                reverseEnergy: EnergyData(energy: "12,34 kWh", price: "15,00 PLN"),
                loading: .constant(false)
            )
            EnergySummaryBox(
                label: "Reverse active energy",
                reverseEnergy: EnergyData(energy: "12,34 kWh"),
                loading: .constant(false)
            )
        }.previewLayout(.sizeThatFits)
    }
}
