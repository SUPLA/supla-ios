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

struct DeviceStateData {
    let label: String
    let icon: IconResult?
    let value: String
}

struct DeviceStateView: SwiftUI.View {
    let stateLabel: String
    let icon: IconResult?
    let stateValue: String
    
    init(stateLabel: String, icon: IconResult?, stateValue: String) {
        self.stateLabel = stateLabel
        self.icon = icon
        self.stateValue = stateValue
    }
    
    init(data: DeviceStateData) {
        self.stateLabel = data.label
        self.icon = data.icon
        self.stateValue = data.value
    }

    var body: some SwiftUI.View {
        HStack(spacing: Distance.tiny) {
            Spacer()
            Text(stateLabel.uppercased())
                .fontBodyMedium()
                .textColor(Color.Supla.onSurfaceVariant)

            if let icon {
                icon.image
                    .resizable()
                    .frame(width: 25, height: 25)
            }

            Text(stateValue)
                .font(.Supla.bodyMedium.bold())
            Spacer()
        }
        .padding([.leading, .trailing, .top], Distance.default)
    }
}
