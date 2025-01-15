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

struct DoubleSummaryCard: View {
    var label: String
    var firstData: SummaryCardData
    var secondData: SummaryCardData
    @Binding var loading: Bool
    
    init(label: String, firstData: SummaryCardData, secondData: SummaryCardData, loading: Binding<Bool> = .constant(false)) {
        self.label = label
        self.firstData = firstData
        self.secondData = secondData
        self._loading = loading
    }

    var body: some View {
        ZStack {
            VStack {
                Text(label)
                    .fontBodyMedium()
                    .textColor(Color.Supla.onSurfaceVariant)
                    .padding(Dimens.distanceTiny)

                HStack(alignment: .top, spacing: 1) {
                    DoubleSummaryBox(
                        iconName: .Icons.forwardEnergy,
                        label: Strings.ElectricityMeter.forwardedEnergy,
                        value: firstData.energy,
                        price: firstData.price
                    )

                    DoubleSummaryBox(
                        iconName: .Icons.reversedEnergy,
                        label: Strings.ElectricityMeter.reversedEnergy,
                        value: secondData.energy,
                        price: secondData.price
                    )
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

struct SingleSummaryCard: View {
    var label: String
    var icon: String?
    var data: SummaryCardData
    @Binding var loading: Bool
    
    init(label: String, icon: String? = nil, data: SummaryCardData, loading: Binding<Bool> = .constant(false)) {
        self.label = label
        self.icon = icon
        self.data = data
        self._loading = loading
    }

    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .top, spacing: 0) {
                    SingleSummaryBox(
                        iconName: icon,
                        label: label,
                        value: data.energy,
                        price: data.price
                    )
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

private struct DoubleSummaryBox: View {
    var iconName: String
    var label: String
    var value: String
    var price: String?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(iconName)
                Text(label)
                    .fontBodyMedium()
                    .textColor(Color.Supla.onSurfaceVariant)
            }
            Text(value).fontLabelLarge()
            if let price = price {
                SuplaCore.Divider()
                HStack {
                    Text(Strings.ElectricityMeter.cost)
                        .fontBodyMedium()
                        .textColor(Color.Supla.onSurfaceVariant)
                    Text(price).fontLabelMedium()
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

private struct SingleSummaryBox: View {
    var iconName: String?
    var label: String
    var value: String
    var price: String?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    if let iconName = iconName {
                        Image(iconName)
                    }
                    Text(label)
                        .fontBodyMedium()
                        .textColor(Color.Supla.onSurfaceVariant)
                }
                Text(value).fontLabelLarge()
            }
            if let price = price {
                Spacer()
                SuplaCore.Divider(.vertical)
                Spacer()
                VStack(alignment: .trailing, spacing: Dimens.distanceTiny) {
                    Text(Strings.ElectricityMeter.cost)
                        .fontBodyMedium()
                        .textColor(Color.Supla.onSurfaceVariant)
                    Text(price).fontLabelMedium()
                }
            }
        }
        .padding(Dimens.distanceSmall)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.Supla.surface)
    }
}
