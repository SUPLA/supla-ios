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

struct SetpointTemperature: View {
    let icon: ThermostatIndicatorIcon?
    let subValue: String

    init(icon: ThermostatIndicatorIcon?, subValue: String) {
        self.icon = icon
        self.subValue = subValue
    }

    init(subValue: String) {
        self.subValue = subValue
        self.icon = nil
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            SetpointIndicator(icon)
            SetpointText(subValue)
        }
    }
}

struct SetpointIndicator: View {
    @Environment(\.scaleFactor) var scaleFactor: CGFloat

    let icon: ThermostatIndicatorIcon?

    init(_ icon: ThermostatIndicatorIcon?) {
        self.icon = icon
    }

    var body: some View {
        if let iconResource = icon?.resourceName {
            let indicatorSize = scale(scaleFactor, 12, limit: .lower(1))

            Image(iconResource)
                .resizable()
                .scaledToFit()
                .frame(width: indicatorSize, height: indicatorSize)
        }
    }
}

struct SetpointText: View {
    @Environment(\.scaleFactor) var scaleFactor: CGFloat

    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .fontBodyMedium(scaleFactor)
            .textColor(.Supla.onBackground)
    }
}
