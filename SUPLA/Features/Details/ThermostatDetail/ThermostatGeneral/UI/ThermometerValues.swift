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

import SharedCore
import SwiftUI

final class ThermometerValuesState: ObservableObject {
    @Published var measurements: [MeasurementValue] = []
}

struct ThermometerValues: View {
    @ObservedObject var state: ThermometerValuesState
    
    private var useSmallSize: Bool {
        state.measurements.count > 3 ||
            (state.measurements.count > 2 && state.measurements.map { $0.batteryIcon != nil ? 1 : 0 }.sum() > 1)
    }

    private var iconSize: CGFloat { useSmallSize ? Dimens.iconSize : 36 }
    private var font: Font { useSmallSize ? .Supla.bodyMedium : .Supla.headlineMedium }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(state.measurements) { measurement in
                HStack(spacing: 0) {
                    measurement.icon.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                    Spacer().frame(width: Distance.tiny)
                    Text(measurement.value)
                        .font(font)
                        .textColor(Color.Supla.onBackground)
                    if let batteryIcon = measurement.batteryIcon?.resource {
                        Image(uiImage: batteryIcon)
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(Angle(degrees: 90))
                            .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            if (state.measurements.count == 1) {
                HStack {}.frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
        .padding([.leading, .trailing], Distance.small)
        .background(Color.Supla.surface)
    }
}

#Preview {
    let twoState = ThermometerValuesState()
    twoState.measurements = [
        temperatureValue("20.0"),
        humidityValue("55")
    ]
    let threeState = ThermometerValuesState()
    threeState.measurements = [
        temperatureValue("20.0"),
        humidityValue("55"),
        temperatureValue("22.5")
    ]
    let fourState = ThermometerValuesState()
    fourState.measurements = [
        temperatureValue("20.0"),
        humidityValue("55"),
        temperatureValue("22.5"),
        humidityValue("85")
    ]
    return VStack {
        ThermometerValues(state: twoState)
        ThermometerValues(state: threeState)
        ThermometerValues(state: fourState)
    }
}

private var id = 0
private func nextId() -> Int {
    id += 1
    return id
}

private func temperatureValue(_ temperature: String, battery: Bool = true) -> MeasurementValue {
    MeasurementValue(
        id: nextId(),
        icon: .suplaIcon(name: .Icons.fncThermometerHome),
        value: temperature,
        batteryIcon: battery ? IssueIcon.Battery75() : nil
    )
}

private func humidityValue(_ temperature: String, battery: Bool = true) -> MeasurementValue {
    MeasurementValue(
        id: nextId(),
        icon: .suplaIcon(name: "humidity"),
        value: temperature,
        batteryIcon: battery ? IssueIcon.Battery75() : nil
    )
}
