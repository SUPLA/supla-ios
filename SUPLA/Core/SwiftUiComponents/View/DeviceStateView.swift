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

struct DeviceState {
    
    struct Data {
        let label: String
        let icon: IconResult?
        let value: String
        let iconColor: Color?
        
        init(label: String, icon: IconResult?, value: String, iconColor: Color? = nil) {
            self.label = label
            self.icon = icon
            self.value = value
            self.iconColor = iconColor
        }
    }
    
    struct View: SwiftUI.View {
        let stateLabel: String
        let icon: IconResult?
        let iconColor: Color?
        let stateValue: String
        
        init(stateLabel: String, icon: IconResult?, stateValue: String) {
            self.stateLabel = stateLabel
            self.icon = icon
            self.iconColor = nil
            self.stateValue = stateValue
        }
        
        init(data: Data) {
            self.stateLabel = data.label
            self.icon = data.icon
            self.stateValue = data.value
            self.iconColor = data.iconColor
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
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .if(iconColor != nil) { $0.foregroundColor(iconColor!) }
                }
                
                Text(stateValue)
                    .font(.Supla.bodyMedium.bold())
                Spacer()
            }
            .padding([.leading, .trailing, .top], Distance.default)
        }
    }
}
