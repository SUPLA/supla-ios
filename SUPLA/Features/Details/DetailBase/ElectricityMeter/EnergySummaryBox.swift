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
    var forwardEnergy: SummaryCardData?
    var reverseEnergy: SummaryCardData?
    var labelSuffix: String?
    @Binding var loading: Bool
    
    init(forwardEnergy: SummaryCardData? = nil, reverseEnergy: SummaryCardData? = nil, labelSuffix: String? = nil, loading: Binding<Bool>) {
        self.forwardEnergy = forwardEnergy
        self.reverseEnergy = reverseEnergy
        self.labelSuffix = labelSuffix
        self._loading = loading
    }
    
    var body: some View {
        if let forwardEnergy = forwardEnergy,
           let reverseEnergy = reverseEnergy {
            let label = if let labelSuffix { "\(Strings.ElectricityMeter.activeEnergy) \(labelSuffix)" } else { Strings.ElectricityMeter.activeEnergy }
            DoubleSummaryCard(
                label: label,
                firstData: forwardEnergy,
                secondData: reverseEnergy,
                loading: $loading
            )
        } else if let forwardEnergy = forwardEnergy {
            let label = if let labelSuffix { "\(Strings.ElectricityMeter.forwardActiveEnergy) \(labelSuffix)" } else { Strings.ElectricityMeter.forwardedEnergy }
            SingleSummaryCard(label: label, icon: .Icons.forwardEnergy, data: forwardEnergy, loading: $loading)
        } else if let reverseEnergy = reverseEnergy {
            let label = if let labelSuffix { "\(Strings.ElectricityMeter.reverseActiveEnergy) \(labelSuffix)" } else { Strings.ElectricityMeter.reverseActiveEnergy }
            SingleSummaryCard(label: label, icon: .Icons.forwardEnergy, data: reverseEnergy, loading: $loading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EnergySummaryBox(
                forwardEnergy: SummaryCardData(energy: "12,34 kWh", price: "15,00 PLN"),
                reverseEnergy: SummaryCardData(energy: "23,45 kWh", price: "15,00 PLN"),
                labelSuffix: Strings.ElectricityMeter.totalSufix,
                loading: .constant(true)
            )
            EnergySummaryBox(
                forwardEnergy: SummaryCardData(energy: "12,34 kWh", price: "15,00 PLN"),
                reverseEnergy: SummaryCardData(energy: "23,45 kWh"),
                labelSuffix: Strings.ElectricityMeter.totalSufix,
                loading: .constant(false)
            )
            EnergySummaryBox(
                forwardEnergy: SummaryCardData(energy: "12,34 kWh"),
                reverseEnergy: SummaryCardData(energy: "23,45 kWh"),
                labelSuffix: Strings.ElectricityMeter.currentMonthSuffix,
                loading: .constant(false)
            )
            EnergySummaryBox(
                forwardEnergy: SummaryCardData(energy: "12,34 kWh", price: "15,00 PLN"),
                labelSuffix: Strings.ElectricityMeter.totalSufix,
                loading: .constant(false)
            )
            EnergySummaryBox(
                forwardEnergy: SummaryCardData(energy: "12,34 kWh"),
                labelSuffix: Strings.ElectricityMeter.currentMonthSuffix,
                loading: .constant(false)
            )
            EnergySummaryBox(
                reverseEnergy: SummaryCardData(energy: "12,34 kWh", price: "15,00 PLN"),
                labelSuffix: Strings.ElectricityMeter.totalSufix,
                loading: .constant(false)
            )
            EnergySummaryBox(
                reverseEnergy: SummaryCardData(energy: "12,34 kWh"),
                labelSuffix: Strings.ElectricityMeter.totalSufix,
                loading: .constant(false)
            )
        }.previewLayout(.sizeThatFits)
    }
}
